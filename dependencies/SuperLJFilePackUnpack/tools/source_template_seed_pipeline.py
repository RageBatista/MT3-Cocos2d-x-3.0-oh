#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import struct
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable

import manifest_seed_pipeline as common


TEXT_EXTENSIONS = {
    ".cpp",
    ".h",
    ".hpp",
    ".cxx",
    ".cc",
    ".c",
    ".lua",
    ".xml",
    ".json",
    ".md",
    ".txt",
    ".csv",
    ".tsv",
    ".ini",
    ".cfg",
    ".set",
    ".lmx",
}

DIRECT_PATH_PREFIXES = ("effect/", "model/", "table/", "script/", "ui/", "map/")
MAP_LEAF_NAMES = (
    "maze.dat",
    "monster.dat",
    "goto.dat",
    "regiontypeinfo.dat",
    "npc.dat",
    "jumpblock.dat",
    "island.dat",
    "island2.dat",
)

QUOTED_STRING_RE = re.compile(r'"([^"\r\n]+)"|\'([^\'\r\n]+)\'')
TABLE_NAME_RE = re.compile(
    r'GetTableByName\s*\(\s*(?:CheckTableName\s*\(\s*)?["\']([A-Za-z0-9_]+\.[A-Za-z0-9_]+)["\']',
    re.IGNORECASE,
)
SPINE_MODEL_RE = re.compile(
    r'(?:UISpineSprite:new|SetSpineModel)\s*\(\s*["\']([A-Za-z0-9_]+)["\']',
    re.IGNORECASE,
)
IMAGESET_TOKEN_RE = re.compile(r'set:([A-Za-z0-9_]+)', re.IGNORECASE)


@dataclass(frozen=True)
class CandidatePath:
    path: str
    source_kind: str
    source_file: str
    evidence: str


@dataclass
class DirectHitRow:
    source_kind: str
    source_file: str
    evidence: str
    variant_kind: str
    candidate_path: str
    crc32_decimal: str
    crc32_hex: str
    status: str
    existing_mapping_path: str = ""
    note: str = ""


@dataclass
class ConflictRow:
    conflict_type: str
    crc32_decimal: str
    crc32_hex: str
    preferred_path: str
    competing_path: str
    sources: str
    note: str


@dataclass
class SeedCandidate:
    crc32_decimal: str
    path: str
    crc32_hex: str
    source_kinds: set[str] = field(default_factory=set)
    source_files: set[str] = field(default_factory=set)
    evidences: set[str] = field(default_factory=set)


def normalize_candidate_path(raw_path: str) -> str:
    normalized = raw_path.strip().replace("\\", "/")
    while normalized.startswith("/"):
        normalized = normalized[1:]
    while "//" in normalized:
        normalized = normalized.replace("//", "/")

    lower = normalized.lower()
    for prefix in common.KNOWN_RESOURCE_PREFIXES:
        if len(lower) > len(prefix) and lower.startswith(prefix):
            normalized = normalized[len(prefix):]
            lower = normalized.lower()
            break
    return normalized.rstrip("/")


def expand_candidate_variants(path: str) -> list[tuple[str, str]]:
    normalized = normalize_candidate_path(path)
    if not normalized:
        return []

    variants: list[tuple[str, str]] = [(normalized, "original")]
    lowered = normalized.lower()
    if lowered != normalized:
        variants.append((lowered, "lowercase"))
    return variants


def read_text_with_fallback(path: Path, encodings: Iterable[str]) -> str:
    content, _ = common.read_text_with_fallback(path, encodings)
    return content


def load_target_crcs_from_file(path: Path) -> set[str]:
    content, _ = common.read_text_with_fallback(path, common.DEFAULT_MANIFEST_ENCODINGS)
    crcs: set[str] = set()
    for raw_line in content.splitlines():
        line = raw_line.strip().lower()
        if not line or line.startswith("#") or line.startswith("//"):
            continue
        if line.startswith("0x"):
            crcs.add(str(int(line, 16)))
            continue
        if line.isdigit():
            crcs.add(line)
    return crcs


def iter_text_files(scan_roots: list[Path]) -> Iterable[Path]:
    for root in scan_roots:
        if not root.exists():
            continue
        if root.is_file():
            if root.suffix.lower() in TEXT_EXTENSIONS:
                yield root
            continue
        for path in root.rglob("*"):
            if path.is_file() and path.suffix.lower() in TEXT_EXTENSIONS:
                yield path


def extract_quoted_strings(text: str) -> list[str]:
    values: list[str] = []
    for match in QUOTED_STRING_RE.finditer(text):
        quoted = match.group(1) if match.group(1) is not None else match.group(2)
        if quoted:
            values.append(quoted)
    return values


def extract_candidates_from_text(text: str, source_file: str) -> list[CandidatePath]:
    out: list[CandidatePath] = []

    for quoted in extract_quoted_strings(text):
        normalized_quoted = quoted.replace("\\", "/")
        quoted_lower = normalized_quoted.lower()

        if "/" in normalized_quoted and quoted_lower.startswith(DIRECT_PATH_PREFIXES):
            out.append(
                CandidatePath(
                    path=normalized_quoted,
                    source_kind="direct_path",
                    source_file=source_file,
                    evidence=f"quoted_path={quoted}",
                )
            )

        if quoted_lower.startswith("animation/") and "." not in Path(quoted).suffix:
            out.append(
                CandidatePath(
                    path="effect/" + normalized_quoted + ".ani",
                    source_kind="animation_ref",
                    source_file=source_file,
                    evidence=f"animation_ref={quoted}",
                )
            )

        if quoted_lower.startswith("geffect/") and "." not in Path(quoted).suffix:
            out.append(
                CandidatePath(
                    path="effect/" + normalized_quoted + ".eff.inf",
                    source_kind="geffect_ref",
                    source_file=source_file,
                    evidence=f"geffect_ref={quoted}",
                )
            )

        if quoted_lower.startswith("spine/") and "." not in Path(quoted).suffix:
            out.append(
                CandidatePath(
                    path="effect/" + normalized_quoted + ".atlas",
                    source_kind="spine_effect",
                    source_file=source_file,
                    evidence=f"spine_effect={quoted}",
                )
            )
            out.append(
                CandidatePath(
                    path="effect/" + normalized_quoted + ".json",
                    source_kind="spine_effect",
                    source_file=source_file,
                    evidence=f"spine_effect={quoted}",
                )
            )

        if quoted_lower.endswith(".layout") and "/" not in quoted_lower:
            out.append(
                CandidatePath(
                    path="ui/layouts/" + quoted_lower,
                    source_kind="layout_literal",
                    source_file=source_file,
                    evidence=f"layout_literal={quoted}",
                )
            )

    for match in TABLE_NAME_RE.finditer(text):
        table_name = match.group(1)
        dot = table_name.find(".")
        if dot <= 0 or dot + 1 >= len(table_name):
            continue
        group = table_name[:dot]
        table = table_name[dot + 1:]
        out.append(
            CandidatePath(
                path=f"table/bintable/{table_name}.bin",
                source_kind="table_name",
                source_file=source_file,
                evidence=f"GetTableByName({table_name})",
            )
        )
        out.append(
            CandidatePath(
                path=f"script/tabledef/{group}/{table}.lua",
                source_kind="table_name",
                source_file=source_file,
                evidence=f"GetTableByName({table_name})",
            )
        )

    for match in SPINE_MODEL_RE.finditer(text):
        model_name = match.group(1)
        out.append(
            CandidatePath(
                path=f"model/{model_name}/{model_name}.atlas",
                source_kind="spine_model",
                source_file=source_file,
                evidence=f"spine_model={model_name}",
            )
        )
        out.append(
            CandidatePath(
                path=f"model/{model_name}/{model_name}.json",
                source_kind="spine_model",
                source_file=source_file,
                evidence=f"spine_model={model_name}",
            )
        )
        out.append(
            CandidatePath(
                path=f"model/{model_name}/{model_name}.png",
                source_kind="spine_model",
                source_file=source_file,
                evidence=f"spine_model={model_name}",
            )
        )

    for match in IMAGESET_TOKEN_RE.finditer(text):
        imageset_name = match.group(1)
        out.append(
            CandidatePath(
                path=f"ui/imagesets/{imageset_name}.imageset",
                source_kind="imageset_token",
                source_file=source_file,
                evidence=f"imageset_token={imageset_name}",
            )
        )

    return out


def parse_map_config_resdirs(path: Path) -> list[str]:
    data = path.read_bytes()
    if len(data) < 12:
        return []

    offset = 0

    def read_u32() -> int:
        nonlocal offset
        if offset + 4 > len(data):
            raise ValueError("unexpected EOF while reading u32")
        value = struct.unpack_from("<I", data, offset)[0]
        offset += 4
        return value

    def read_u16() -> int:
        nonlocal offset
        if offset + 2 > len(data):
            raise ValueError("unexpected EOF while reading u16")
        value = struct.unpack_from("<H", data, offset)[0]
        offset += 2
        return value

    def read_i32() -> int:
        nonlocal offset
        if offset + 4 > len(data):
            raise ValueError("unexpected EOF while reading i32")
        value = struct.unpack_from("<i", data, offset)[0]
        offset += 4
        return value

    def read_bool() -> int:
        nonlocal offset
        if offset + 1 > len(data):
            raise ValueError("unexpected EOF while reading bool")
        value = data[offset]
        offset += 1
        return value

    def read_string() -> str:
        length = read_i32()
        nonlocal offset
        if length < 0 or offset + length > len(data):
            raise ValueError("unexpected EOF while reading string")
        value = data[offset: offset + length].decode("utf-8", errors="replace")
        offset += length
        return value

    magic = read_u32()
    _ = read_u32()
    _ = read_u16()
    row_count = read_u16()
    _ = read_u32()
    if magic != 1499087948 or row_count == 0 or row_count > 4096:
        return []

    resdirs: list[str] = []
    for _ in range(row_count):
        _ = read_i32()
        _ = read_string()
        _ = read_string()
        _ = read_string()
        resdir = read_string()
        for _ in range(7):
            _ = read_i32()
        _ = read_bool()
        for _ in range(7):
            _ = read_i32()
        _ = read_string()
        _ = read_i32()
        _ = read_i32()
        _ = read_string()
        _ = read_i32()
        _ = read_i32()

        resdir = normalize_candidate_path(resdir)
        if resdir and "/" not in resdir and "." not in resdir:
            resdirs.append(resdir)

    return resdirs


def extract_candidates_from_map_config(path: Path) -> list[CandidatePath]:
    out: list[CandidatePath] = []
    try:
        resdirs = parse_map_config_resdirs(path)
    except Exception:
        return out

    for resdir in resdirs:
        for leaf in MAP_LEAF_NAMES:
            out.append(
                CandidatePath(
                    path=f"map/{resdir}/{leaf}",
                    source_kind="map_config_resdir",
                    source_file=str(path),
                    evidence=f"map_config_resdir={resdir}",
                )
            )
    return out


def write_tsv(path: Path, rows: list[dict], fieldnames: list[str]) -> None:
    common.write_tsv(path, rows, fieldnames)


def write_summary_md(path: Path, summary: dict, source_rows: list[dict]) -> None:
    lines = [
        "# Source Template Seed Summary",
        "",
        f"- 扫描根数: `{summary.get('scan_root_count', 0)}`",
        f"- 扫描文本文件数: `{summary.get('scanned_text_files', 0)}`",
        f"- map.cmapconfig 条目文件数: `{summary.get('map_config_inputs', 0)}`",
        f"- 提取候选总数: `{summary.get('extracted_candidate_count', 0)}`",
        f"- 直接命中: `{summary.get('direct_hits', 0)}`",
        f"- 与现有映射一致: `{summary.get('same_hits', 0)}`",
        f"- 新增 seed: `{summary.get('new_hits', 0)}`",
        f"- 映射冲突: `{summary.get('mapping_conflicts', 0)}`",
        f"- 候选冲突: `{summary.get('seed_conflicts', 0)}`",
        f"- 现有映射命中数: `{summary.get('existing_hits', 0)}`",
        f"- 合并后命中数: `{summary.get('merged_hits', 0)}`",
        f"- 命中增量: `{summary.get('hit_gain', 0)}`",
        "",
        "## 来源统计",
        "",
        "| source_kind | count |",
        "| --- | ---: |",
    ]
    for row in source_rows:
        lines.append(f"| {row['source_kind']} | {row['count']} |")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def analyze_sources(
    *,
    scan_roots: list[Path],
    map_config_bins: list[Path],
    res_dir: Path | None,
    target_crc_file: Path | None,
    existing_mapping_path: Path | None,
    output_dir: Path,
    text_encodings: Iterable[str],
    write_seed_txt: Path | None,
    write_seed_ljpm: Path | None,
    write_merged_txt: Path | None,
    write_merged_ljpm: Path | None,
    promote_dir: Path | None,
) -> dict:
    output_dir.mkdir(parents=True, exist_ok=True)
    target_crcs: set[str] = set()
    if res_dir is not None:
        target_crcs.update(common.load_numeric_target_crcs(res_dir))
    if target_crc_file is not None and target_crc_file.exists():
        target_crcs.update(load_target_crcs_from_file(target_crc_file))
    existing_mapping = common.load_existing_mapping(existing_mapping_path)

    extracted: list[CandidatePath] = []
    scanned_text_files = 0
    source_kind_counts: dict[str, int] = {}

    for map_config_bin in map_config_bins:
        if not map_config_bin.exists():
            continue
        candidates = extract_candidates_from_map_config(map_config_bin)
        extracted.extend(candidates)
        source_kind_counts["map_config_resdir"] = (
            source_kind_counts.get("map_config_resdir", 0) + len(candidates)
        )

    for text_path in iter_text_files(scan_roots):
        scanned_text_files += 1
        try:
            text = read_text_with_fallback(text_path, text_encodings)
        except Exception:
            continue
        candidates = extract_candidates_from_text(text, str(text_path))
        extracted.extend(candidates)
        for candidate in candidates:
            source_kind_counts[candidate.source_kind] = (
                source_kind_counts.get(candidate.source_kind, 0) + 1
            )

    direct_rows: list[DirectHitRow] = []
    conflicts: list[ConflictRow] = []
    seed_candidates: dict[str, SeedCandidate] = {}
    conflicted_seed_crcs: set[str] = set()

    for candidate in extracted:
        for variant_path, variant_kind in expand_candidate_variants(candidate.path):
            violation = common.validate_relative_path(variant_path)
            if violation is not None:
                continue

            crc_value = common.crc32_text(variant_path)
            if crc_value not in target_crcs:
                continue

            existing_path = existing_mapping.get(crc_value, "")
            status = "new_seed"
            note = ""
            if existing_path:
                if existing_path == variant_path:
                    status = "same_as_mapping"
                else:
                    status = "mapping_conflict"
                    note = "existing mapping keeps preferred path"
                    conflicts.append(
                        ConflictRow(
                            conflict_type="mapping_path_conflict",
                            crc32_decimal=crc_value,
                            crc32_hex=common.crc32_hex(crc_value),
                            preferred_path=existing_path,
                            competing_path=variant_path,
                            sources=candidate.source_file,
                            note=note,
                        )
                    )

            direct_rows.append(
                DirectHitRow(
                    source_kind=candidate.source_kind,
                    source_file=candidate.source_file,
                    evidence=candidate.evidence,
                    variant_kind=variant_kind,
                    candidate_path=variant_path,
                    crc32_decimal=crc_value,
                    crc32_hex=common.crc32_hex(crc_value),
                    status=status,
                    existing_mapping_path=existing_path,
                    note=note,
                )
            )

            if status != "new_seed":
                continue

            if crc_value in conflicted_seed_crcs:
                continue

            existing_candidate = seed_candidates.get(crc_value)
            if existing_candidate is None:
                seed_candidates[crc_value] = SeedCandidate(
                    crc32_decimal=crc_value,
                    crc32_hex=common.crc32_hex(crc_value),
                    path=variant_path,
                    source_kinds={candidate.source_kind},
                    source_files={candidate.source_file},
                    evidences={candidate.evidence},
                )
            elif existing_candidate.path == variant_path:
                existing_candidate.source_kinds.add(candidate.source_kind)
                existing_candidate.source_files.add(candidate.source_file)
                existing_candidate.evidences.add(candidate.evidence)
            else:
                conflicts.append(
                    ConflictRow(
                        conflict_type="seed_path_conflict",
                        crc32_decimal=crc_value,
                        crc32_hex=common.crc32_hex(crc_value),
                        preferred_path=existing_candidate.path,
                        competing_path=variant_path,
                        sources=" | ".join(
                            sorted(existing_candidate.source_files | {candidate.source_file})
                        ),
                        note="multiple template candidates produced the same CRC hit",
                    )
                )
                conflicted_seed_crcs.add(crc_value)
                del seed_candidates[crc_value]

    direct_rows_data = [
        {
            "source_kind": row.source_kind,
            "source_file": row.source_file,
            "evidence": row.evidence,
            "variant_kind": row.variant_kind,
            "candidate_path": row.candidate_path,
            "crc32_decimal": row.crc32_decimal,
            "crc32_hex": row.crc32_hex,
            "status": row.status,
            "existing_mapping_path": row.existing_mapping_path,
            "note": row.note,
        }
        for row in direct_rows
    ]
    conflicts_data = [
        {
            "conflict_type": row.conflict_type,
            "crc32_decimal": row.crc32_decimal,
            "crc32_hex": row.crc32_hex,
            "preferred_path": row.preferred_path,
            "competing_path": row.competing_path,
            "sources": row.sources,
            "note": row.note,
        }
        for row in conflicts
    ]
    seed_records = [
        {
            "crc32_decimal": seed.crc32_decimal,
            "crc32_hex": seed.crc32_hex,
            "path": seed.path,
            "source_kinds": ",".join(sorted(seed.source_kinds)),
            "source_files": " | ".join(sorted(seed.source_files)),
            "evidences": " | ".join(sorted(seed.evidences)),
        }
        for seed in sorted(seed_candidates.values(), key=lambda item: int(item.crc32_decimal))
    ]
    source_rows = [
        {"source_kind": key, "count": value}
        for key, value in sorted(source_kind_counts.items())
    ]

    write_tsv(
        output_dir / "source_template_direct_hits.tsv",
        direct_rows_data,
        [
            "source_kind",
            "source_file",
            "evidence",
            "variant_kind",
            "candidate_path",
            "crc32_decimal",
            "crc32_hex",
            "status",
            "existing_mapping_path",
            "note",
        ],
    )
    write_tsv(
        output_dir / "source_template_seed_candidates.tsv",
        seed_records,
        [
            "crc32_decimal",
            "crc32_hex",
            "path",
            "source_kinds",
            "source_files",
            "evidences",
        ],
    )
    write_tsv(
        output_dir / "source_template_conflicts.tsv",
        conflicts_data,
        [
            "conflict_type",
            "crc32_decimal",
            "crc32_hex",
            "preferred_path",
            "competing_path",
            "sources",
            "note",
        ],
    )

    if write_seed_txt is not None:
        common.write_mapping_text(
            write_seed_txt,
            {seed.crc32_decimal: seed.path for seed in seed_candidates.values()},
            [
                "Source-template seed candidates",
                f"Scan roots: {len(scan_roots)}",
                f"Map config bins: {len(map_config_bins)}",
                f"New seed hits: {len(seed_candidates)}",
            ],
        )
    if write_seed_ljpm is not None:
        common.write_mapping_ljpm(
            write_seed_ljpm,
            {seed.crc32_decimal: seed.path for seed in seed_candidates.values()},
        )

    merged_mapping = dict(existing_mapping)
    for seed in seed_candidates.values():
        merged_mapping.setdefault(seed.crc32_decimal, seed.path)

    existing_hits = common.compute_mapping_hits(existing_mapping, target_crcs)
    merged_hits = common.compute_mapping_hits(merged_mapping, target_crcs)

    if write_merged_txt is not None:
        common.write_mapping_text(
            write_merged_txt,
            merged_mapping,
            [
                "Existing mapping plus source-template seeds",
                f"Existing entries: {len(existing_mapping)}",
                f"Source-template additions: {len(seed_candidates)}",
                f"Merged entries: {len(merged_mapping)}",
            ],
        )
    if write_merged_ljpm is not None:
        common.write_mapping_ljpm(write_merged_ljpm, merged_mapping)

    if promote_dir is not None:
        promote_dir.mkdir(parents=True, exist_ok=True)
        common.write_mapping_text(
            promote_dir / "path_mapping.txt",
            merged_mapping,
            [
                "Promoted source-template merged mapping",
                f"Existing mapping: {existing_mapping_path or ''}",
                f"Source-template additions: {len(seed_candidates)}",
                f"Merged entries: {len(merged_mapping)}",
            ],
        )
        common.write_mapping_ljpm(promote_dir / "path_mapping.ljpm", merged_mapping)

    summary = {
        "scan_root_count": len(scan_roots),
        "map_config_inputs": len([path for path in map_config_bins if path.exists()]),
        "scanned_text_files": scanned_text_files,
        "extracted_candidate_count": len(extracted),
        "target_crc_file": str(target_crc_file) if target_crc_file else "",
        "res_dir": str(res_dir) if res_dir else "",
        "existing_mapping_path": str(existing_mapping_path) if existing_mapping_path else "",
        "existing_mapping_entries": len(existing_mapping),
        "target_crc_count": len(target_crcs),
        "direct_hits": len(direct_rows),
        "same_hits": sum(1 for row in direct_rows if row.status == "same_as_mapping"),
        "new_hits": len(seed_candidates),
        "mapping_conflicts": sum(1 for row in conflicts if row.conflict_type == "mapping_path_conflict"),
        "seed_conflicts": sum(1 for row in conflicts if row.conflict_type == "seed_path_conflict"),
        "existing_hits": existing_hits,
        "merged_hits": merged_hits,
        "hit_gain": merged_hits - existing_hits,
    }

    (output_dir / "source_template_summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    write_summary_md(output_dir / "source_template_summary.md", summary, source_rows)
    return summary


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build high-confidence mapping seeds from client source templates, config/text variables and exact CRC hits."
    )
    parser.add_argument("--res-dir", help="Directory containing numeric CRC-named unpack outputs")
    parser.add_argument("--target-crc-file", help="Optional text file listing target PathFileNameCRC32 values (decimal or 0xHEX)")
    parser.add_argument("--mapping", help="Existing mapping file (.txt or .ljpm) used for diffing and merge output")
    parser.add_argument("--output-dir", required=True, help="Directory for reports and optional mapping outputs")
    parser.add_argument(
        "--scan-root",
        action="append",
        default=[],
        help="Text/source/config root to scan for template variables (repeatable)",
    )
    parser.add_argument(
        "--map-config-bin",
        action="append",
        default=[],
        help="Recovered map.cmapconfig.bin path used for structured map resdir extraction (repeatable)",
    )
    parser.add_argument(
        "--encoding",
        action="append",
        default=[],
        help="Additional text decoding encodings to try (repeatable)",
    )
    parser.add_argument("--write-seed-txt", help="Optional output path for new seed candidates in text mapping format")
    parser.add_argument("--write-seed-ljpm", help="Optional output path for new seed candidates in binary ljpm format")
    parser.add_argument("--write-merged-txt", help="Optional output path for existing mapping plus new seeds in text format")
    parser.add_argument("--write-merged-ljpm", help="Optional output path for existing mapping plus new seeds in binary ljpm format")
    parser.add_argument("--promote-dir", help="Optional directory to write standard-named promoted outputs: path_mapping.txt/.ljpm")
    args = parser.parse_args()

    if not args.res_dir and not args.target_crc_file:
        parser.error("must provide at least one of --res-dir or --target-crc-file")

    encodings = list(common.DEFAULT_MANIFEST_ENCODINGS)
    for encoding in args.encoding:
        if encoding not in encodings:
            encodings.append(encoding)

    summary = analyze_sources(
        scan_roots=[Path(path) for path in args.scan_root],
        map_config_bins=[Path(path) for path in args.map_config_bin],
        res_dir=Path(args.res_dir) if args.res_dir else None,
        target_crc_file=Path(args.target_crc_file) if args.target_crc_file else None,
        existing_mapping_path=Path(args.mapping) if args.mapping else None,
        output_dir=Path(args.output_dir),
        text_encodings=encodings,
        write_seed_txt=Path(args.write_seed_txt) if args.write_seed_txt else None,
        write_seed_ljpm=Path(args.write_seed_ljpm) if args.write_seed_ljpm else None,
        write_merged_txt=Path(args.write_merged_txt) if args.write_merged_txt else None,
        write_merged_ljpm=Path(args.write_merged_ljpm) if args.write_merged_ljpm else None,
        promote_dir=Path(args.promote_dir) if args.promote_dir else None,
    )
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

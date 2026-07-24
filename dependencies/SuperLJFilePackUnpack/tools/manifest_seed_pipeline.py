#!/usr/bin/env python3
from __future__ import annotations

import argparse
import binascii
import json
import struct
from dataclasses import dataclass, field
from pathlib import Path, PurePosixPath
from typing import Iterable


KNOWN_RESOURCE_EXTENSIONS = {
    ".lua",
    ".xml",
    ".json",
    ".bin",
    ".ani",
    ".atlas",
    ".png",
    ".dds",
    ".tga",
    ".jpg",
    ".jpeg",
    ".webp",
    ".layout",
    ".imageset",
    ".font",
    ".txt",
    ".cfg",
    ".ini",
    ".eff",
    ".inf",
    ".set",
    ".dat",
    ".plist",
    ".csv",
    ".ogg",
    ".wav",
    ".mp3",
    ".act",
    ".lmx",
    ".mrmp",
    ".rmp",
}

KNOWN_RESOURCE_PREFIXES = (
    "client/resource/res/",
    "resource/res/",
    "assets/res/",
    "res/",
    "assets/",
    "resource/",
    "client/resource/",
)

DEFAULT_MANIFEST_ENCODINGS = ("utf-8", "utf-8-sig", "gb18030")


@dataclass(frozen=True)
class ManifestSpec:
    name: str
    path: Path
    ignore_case: bool = False


@dataclass
class ManifestRow:
    manifest_name: str
    manifest_path: str
    entry_order: int
    raw_entry: str
    normalized_entry: str
    chosen_path: str
    variant_kind: str
    crc32_decimal: str
    crc32_hex: str
    status: str
    existing_mapping_path: str = ""
    note: str = ""


@dataclass
class FilteredRow:
    manifest_name: str
    manifest_path: str
    entry_order: int
    raw_entry: str
    normalized_entry: str
    reason: str


@dataclass
class ConflictRow:
    conflict_type: str
    crc32_decimal: str
    crc32_hex: str
    preferred_path: str
    competing_path: str
    manifests: str
    note: str


@dataclass
class CandidateSeed:
    crc32_decimal: str
    path: str
    crc32_hex: str
    manifests: set[str] = field(default_factory=set)
    notes: list[str] = field(default_factory=list)


def normalize_storage_like_path(raw_path: str) -> str:
    normalized = raw_path.replace("\\", "/").strip().lower()
    while normalized.startswith("/"):
        normalized = normalized[1:]
    while "//" in normalized:
        normalized = normalized.replace("//", "/")
    return normalized.rstrip("/")


def get_file_extension_lower(raw_path: str) -> str:
    normalized = normalize_storage_like_path(raw_path)
    slash = normalized.rfind("/")
    dot = normalized.rfind(".")
    if dot < 0:
        return ""
    if slash >= 0 and dot < slash:
        return ""
    return normalized[dot:]


def get_directory_part(raw_path: str) -> str:
    normalized = normalize_storage_like_path(raw_path)
    slash = normalized.rfind("/")
    if slash < 0:
        return ""
    return normalized[:slash]


def get_leaf_name(raw_path: str) -> str:
    normalized = normalize_storage_like_path(raw_path)
    slash = normalized.rfind("/")
    if slash < 0:
        return normalized
    return normalized[slash + 1 :]


def is_digits_only_string(value: str) -> bool:
    return bool(value) and value.isdigit()


def is_numeric_root_like_path(raw_path: str) -> bool:
    normalized = normalize_storage_like_path(raw_path)
    if not normalized or "/" in normalized:
        return False
    dot = normalized.find(".")
    stem = normalized
    if dot >= 0:
        ext = normalized[dot + 1 :]
        if not ext:
            return False
        if not all(ch.isalnum() or ch == "_" for ch in ext):
            return False
        stem = normalized[:dot]
    return is_digits_only_string(stem)


def contains_path_segment(raw_path: str, segment: str) -> bool:
    if not segment:
        return False
    path = normalize_storage_like_path(raw_path)
    if not path:
        return False
    if path == segment:
        return True
    if path.startswith(segment + "/"):
        return True
    if f"/{segment}/" in path:
        return True
    return path.endswith("/" + segment)


def strip_known_resource_prefixes(raw_path: str) -> str:
    normalized = normalize_storage_like_path(raw_path)
    for prefix in KNOWN_RESOURCE_PREFIXES:
        if len(normalized) > len(prefix) and normalized.startswith(prefix):
            return normalized[len(prefix) :]
    return normalized


def canonicalize_storage_path(relative_path: str) -> str:
    normalized = normalize_storage_like_path(relative_path)
    if not normalized:
        return normalized
    stripped = strip_known_resource_prefixes(normalized)
    return stripped or normalized


def is_known_resource_extension(extension: str) -> bool:
    return extension in KNOWN_RESOURCE_EXTENSIONS


def is_low_confidence_crc_repository_path(relative_path: str) -> bool:
    normalized = canonicalize_storage_path(relative_path)
    if not normalized:
        return True

    has_directory = "/" in normalized
    leaf = get_leaf_name(normalized)
    ext = get_file_extension_lower(leaf)
    stem = leaf[: -len(ext)] if ext and len(leaf) >= len(ext) else leaf

    if not has_directory and "." not in normalized and len(normalized) <= 4:
        return True
    if is_numeric_root_like_path(normalized):
        return True
    if normalized == ".uedd":
        return True
    if ".conflict." in normalized:
        return True
    if contains_path_segment(normalized, "unpacked"):
        return True
    if ext == ".":
        return True
    if not ext and len(leaf) <= 1:
        return True
    if not has_directory and len(stem) <= 3 and (not ext or len(ext) <= 2) and not is_known_resource_extension(ext):
        return True
    if not has_directory and ext and len(stem) <= 4 and len(ext) <= 4 and not is_known_resource_extension(ext):
        return True

    parent_leaf = get_leaf_name(get_directory_part(normalized))
    if has_directory and not ext and len(leaf) <= 1 and len(parent_leaf) <= 3:
        return True

    stripped = strip_known_resource_prefixes(normalized)
    if is_numeric_root_like_path(stripped):
        return True
    return False


def normalize_manifest_entry(entry: str, *, ignore_case: bool) -> str:
    normalized = entry.strip().replace("\\", "/")
    if ignore_case:
        normalized = normalized.lower()
    while normalized.startswith("/"):
        normalized = normalized[1:]
    while "//" in normalized:
        normalized = normalized.replace("//", "/")
    return normalized.rstrip("/")


def validate_relative_path(path_text: str) -> str | None:
    if not path_text:
        return "empty_path"
    normalized = path_text.replace("\\", "/")
    if normalized.startswith(("/", "\\")):
        return "absolute_path"
    if len(normalized) >= 2 and normalized[1] == ":":
        return "drive_prefixed_path"
    parts = [part for part in PurePosixPath(normalized).parts if part not in ("", ".")]
    if any(part == ".." for part in parts):
        return "path_traversal"
    return None


def crc32_text(value: str) -> str:
    return str(binascii.crc32(value.encode("utf-8")) & 0xFFFFFFFF)


def crc32_hex(decimal_crc: str) -> str:
    return f"0x{int(decimal_crc):08x}"


def read_text_with_fallback(path: Path, encodings: Iterable[str]) -> tuple[str, str]:
    last_error: Exception | None = None
    for encoding in encodings:
        try:
            return path.read_text(encoding=encoding), encoding
        except UnicodeDecodeError as exc:
            last_error = exc
        except OSError as exc:
            last_error = exc
            break
    if last_error is None:
        raise OSError(f"unable to read {path}")
    raise last_error


def load_manifest_lines(spec: ManifestSpec, encodings: Iterable[str]) -> tuple[list[str], str]:
    content, encoding = read_text_with_fallback(spec.path, encodings)
    lines = [line for line in content.splitlines() if line.strip()]
    return lines, encoding


def load_numeric_target_crcs(res_dir: Path) -> set[str]:
    crcs: set[str] = set()
    for path in res_dir.rglob("*"):
        if path.is_file() and path.name.isdigit():
            crcs.add(path.name)
    return crcs


def load_mapping_text(path: Path) -> dict[str, str]:
    content, _ = read_text_with_fallback(path, DEFAULT_MANIFEST_ENCODINGS)
    mapping: dict[str, str] = {}
    for raw_line in content.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or line.startswith("//"):
            continue
        if "\t" in line:
            crc_text, rel_path = line.split("\t", 1)
        elif "|" in line:
            crc_text, rel_path = line.split("|", 1)
        else:
            continue
        crc_text = crc_text.strip().lower()
        if crc_text.startswith("0x"):
            crc_key = str(int(crc_text, 16))
        else:
            crc_key = crc_text
        mapping[crc_key] = rel_path.strip()
    return mapping


def load_mapping_ljpm(path: Path) -> dict[str, str]:
    data = path.read_bytes()
    if len(data) < 12:
        raise ValueError(f"invalid ljpm file: {path}")
    magic = data[0:4]
    if magic != b"LJPM":
        raise ValueError(f"invalid ljpm magic: {magic!r}")
    version, count = struct.unpack_from("<II", data, 4)
    if version != 1:
        raise ValueError(f"unsupported ljpm version: {version}")
    offset = 12
    mapping: dict[str, str] = {}
    for _ in range(count):
        if offset + 6 > len(data):
            raise ValueError("truncated ljpm record header")
        crc_value, path_len = struct.unpack_from("<IH", data, offset)
        offset += 6
        if offset + path_len > len(data):
            raise ValueError("truncated ljpm path payload")
        path_payload = data[offset : offset + path_len]
        rel_path = decode_ljpm_path_payload(path_payload)
        offset += path_len
        mapping[str(crc_value)] = rel_path
    return mapping


def decode_ljpm_path_payload(payload: bytes) -> str:
    for encoding in ("utf-8", "utf-8-sig", "gb18030", "cp936"):
        try:
            return payload.decode(encoding)
        except UnicodeDecodeError:
            continue
    return payload.decode("latin1")


def load_existing_mapping(path: Path | None) -> dict[str, str]:
    if path is None:
        return {}
    suffix = path.suffix.lower()
    if suffix == ".ljpm":
        return load_mapping_ljpm(path)
    return load_mapping_text(path)


def build_variants(normalized_entry: str) -> list[tuple[str, str]]:
    variants: list[tuple[str, str]] = []
    seen: set[str] = set()
    for kind, value in (
        ("manifest", normalized_entry),
        ("canonical", canonicalize_storage_path(normalized_entry)),
    ):
        candidate = value.strip()
        if not candidate or candidate in seen:
            continue
        seen.add(candidate)
        variants.append((kind, candidate))
    return variants


def write_tsv(path: Path, rows: list[dict[str, object]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    lines = ["\t".join(fieldnames)]
    for row in rows:
        values: list[str] = []
        for field in fieldnames:
            value = row.get(field, "")
            text = "" if value is None else str(value)
            values.append(text.replace("\t", " ").replace("\r", " ").replace("\n", " "))
        lines.append("\t".join(values))
    path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def write_mapping_text(path: Path, mapping: dict[str, str], header_lines: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    lines = [f"# {line}" for line in header_lines]
    lines.extend(["# Format: 0xCRC32<TAB>RelativePath", "#"])
    for crc_key, rel_path in sorted(mapping.items(), key=lambda item: int(item[0])):
        lines.append(f"{crc32_hex(crc_key)}\t{rel_path}")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def write_mapping_ljpm(path: Path, mapping: dict[str, str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("wb") as handle:
        handle.write(b"LJPM")
        handle.write(struct.pack("<I", 1))
        handle.write(struct.pack("<I", len(mapping)))
        for crc_key, rel_path in sorted(mapping.items(), key=lambda item: int(item[0])):
            encoded = rel_path.encode("utf-8")
            handle.write(struct.pack("<I", int(crc_key)))
            handle.write(struct.pack("<H", len(encoded)))
            handle.write(encoded)


def compute_mapping_hits(mapping: dict[str, str], target_crcs: set[str]) -> int:
    return sum(1 for crc_key in mapping if crc_key in target_crcs)


def write_markdown_summary(path: Path, summary: dict[str, object]) -> None:
    manifests = summary.get("manifests", [])
    lines = [
        "# Manifest Seed Summary",
        "",
        f"- 目标目录: `{summary.get('target_res_dir', '')}`",
        f"- 目标 CRC 文件数: `{summary.get('target_crc_file_count', 0)}`",
        f"- 现有映射: `{summary.get('existing_mapping_path', '')}`",
        f"- 现有映射条目数: `{summary.get('existing_mapping_entries', 0)}`",
        f"- 现有命中数: `{summary.get('existing_hits', 0)}`",
        f"- 合并后命中数: `{summary.get('merged_hits', 0)}`",
        f"- 命中增量: `{summary.get('hit_gain', 0)}`",
        f"- 合并后覆盖率: `{summary.get('merged_hit_rate_percent', 0.0):.2f}%`",
        f"- 新增候选条目: `{summary.get('new_hits', 0)}`",
        f"- 映射冲突: `{summary.get('mapping_conflicts', 0)}`",
        f"- 过滤条目: `{summary.get('filtered_entries', 0)}`",
        "",
        "## Per Manifest",
        "",
        "| manifest | direct_hits | same_hits | new_hits | mapping_conflicts | filtered |",
        "|----------|-------------|-----------|----------|-------------------|----------|",
    ]
    for row in manifests:
        lines.append(
            f"| {row.get('manifest_name', '')} | {row.get('direct_hits', 0)} | {row.get('same_hits', 0)} | "
            f"{row.get('new_hits', 0)} | {row.get('mapping_conflicts', 0)} | {row.get('filtered', 0)} |"
        )
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def default_jiebao_specs(jiebao_root: Path) -> list[ManifestSpec]:
    return [
        ManifestSpec("main", jiebao_root / "main.txt"),
        ManifestSpec("imagesets", jiebao_root / "imagesets.txt"),
        ManifestSpec("lua-layout", jiebao_root / "lua-layout.txt", ignore_case=True),
        ManifestSpec("single-file", jiebao_root / "文件解密.txt"),
        ManifestSpec("model", jiebao_root / "model.txt"),
    ]


def parse_manual_manifest_specs(args: argparse.Namespace) -> list[ManifestSpec]:
    specs: list[ManifestSpec] = []
    for raw_path in args.manifest:
        path = Path(raw_path)
        specs.append(ManifestSpec(path.stem, path))
    for raw_path in args.manifest_ignore_case:
        path = Path(raw_path)
        specs.append(ManifestSpec(path.stem, path, ignore_case=True))
    return specs


def summarize_per_manifest(rows: list[ManifestRow], filtered_rows: list[FilteredRow], manifest_specs: list[ManifestSpec]) -> list[dict[str, object]]:
    summary: list[dict[str, object]] = []
    for spec in manifest_specs:
        direct = [row for row in rows if row.manifest_name == spec.name]
        filtered = [row for row in filtered_rows if row.manifest_name == spec.name]
        summary.append(
            {
                "manifest_name": spec.name,
                "manifest_path": str(spec.path),
                "ignore_case": int(spec.ignore_case),
                "direct_hits": len(direct),
                "same_hits": sum(1 for row in direct if row.status == "same_as_mapping"),
                "new_hits": sum(1 for row in direct if row.status == "new_crc"),
                "mapping_conflicts": sum(1 for row in direct if row.status == "mapping_conflict"),
                "filtered": len(filtered),
            }
        )
    return summary


def analyze_manifests(
    manifest_specs: list[ManifestSpec],
    *,
    res_dir: Path,
    existing_mapping_path: Path | None,
    output_dir: Path,
    manifest_encodings: Iterable[str],
    write_seed_txt: Path | None,
    write_seed_ljpm: Path | None,
    write_merged_txt: Path | None,
    write_merged_ljpm: Path | None,
    promote_dir: Path | None,
) -> dict[str, object]:
    output_dir.mkdir(parents=True, exist_ok=True)
    target_crcs = load_numeric_target_crcs(res_dir)
    existing_mapping = load_existing_mapping(existing_mapping_path)

    direct_rows: list[ManifestRow] = []
    filtered_rows: list[FilteredRow] = []
    conflict_rows: list[ConflictRow] = []
    seed_candidates: dict[str, CandidateSeed] = {}
    used_encodings: list[dict[str, object]] = []

    for spec in manifest_specs:
        raw_lines, encoding = load_manifest_lines(spec, manifest_encodings)
        used_encodings.append(
            {
                "manifest_name": spec.name,
                "manifest_path": str(spec.path),
                "encoding": encoding,
                "raw_line_count": len(raw_lines),
            }
        )

        for entry_order, raw_entry in enumerate(raw_lines):
            normalized = normalize_manifest_entry(raw_entry, ignore_case=spec.ignore_case)
            safety_reason = validate_relative_path(normalized)
            if safety_reason is not None:
                filtered_rows.append(
                    FilteredRow(spec.name, str(spec.path), entry_order, raw_entry, normalized, safety_reason)
                )
                continue
            if is_low_confidence_crc_repository_path(normalized):
                filtered_rows.append(
                    FilteredRow(
                        spec.name,
                        str(spec.path),
                        entry_order,
                        raw_entry,
                        normalized,
                        "low_confidence_path",
                    )
                )
                continue

            matched_variants: list[tuple[str, str, str]] = []
            for variant_kind, variant_path in build_variants(normalized):
                if not variant_path:
                    continue
                if is_low_confidence_crc_repository_path(variant_path):
                    continue
                crc_value = crc32_text(variant_path)
                if crc_value in target_crcs:
                    matched_variants.append((variant_kind, variant_path, crc_value))

            unique_hits = {(kind, path, crc) for kind, path, crc in matched_variants}
            if not unique_hits:
                continue
            if len(unique_hits) > 1:
                ordered_hits = sorted(unique_hits, key=lambda item: (int(item[2]), item[1], item[0]))
                preferred = ordered_hits[0]
                for competing in ordered_hits[1:]:
                    conflict_rows.append(
                        ConflictRow(
                            conflict_type="variant_ambiguous_hit",
                            crc32_decimal=preferred[2],
                            crc32_hex=crc32_hex(preferred[2]),
                            preferred_path=preferred[1],
                            competing_path=competing[1],
                            manifests=spec.name,
                            note=f"{preferred[0]} vs {competing[0]}",
                        )
                    )
                continue

            variant_kind, chosen_path, crc_value = unique_hits.pop()
            existing_path = existing_mapping.get(crc_value, "")
            if not existing_path:
                status = "new_crc"
            elif existing_path == chosen_path:
                status = "same_as_mapping"
            else:
                status = "mapping_conflict"
                conflict_rows.append(
                    ConflictRow(
                        conflict_type="mapping_path_conflict",
                        crc32_decimal=crc_value,
                        crc32_hex=crc32_hex(crc_value),
                        preferred_path=existing_path,
                        competing_path=chosen_path,
                        manifests=spec.name,
                        note="existing mapping keeps preferred path",
                    )
                )

            direct_rows.append(
                ManifestRow(
                    manifest_name=spec.name,
                    manifest_path=str(spec.path),
                    entry_order=entry_order,
                    raw_entry=raw_entry,
                    normalized_entry=normalized,
                    chosen_path=chosen_path,
                    variant_kind=variant_kind,
                    crc32_decimal=crc_value,
                    crc32_hex=crc32_hex(crc_value),
                    status=status,
                    existing_mapping_path=existing_path,
                )
            )

            if status != "new_crc":
                continue

            candidate = seed_candidates.get(crc_value)
            if candidate is None:
                seed_candidates[crc_value] = CandidateSeed(
                    crc32_decimal=crc_value,
                    path=chosen_path,
                    crc32_hex=crc32_hex(crc_value),
                    manifests={spec.name},
                )
            elif candidate.path == chosen_path:
                candidate.manifests.add(spec.name)
            else:
                conflict_rows.append(
                    ConflictRow(
                        conflict_type="manifest_crc_conflict",
                        crc32_decimal=crc_value,
                        crc32_hex=crc32_hex(crc_value),
                        preferred_path=candidate.path,
                        competing_path=chosen_path,
                        manifests=",".join(sorted(candidate.manifests | {spec.name})),
                        note="new candidate skipped because crc already mapped to another manifest path",
                    )
                )

    summary_rows = summarize_per_manifest(direct_rows, filtered_rows, manifest_specs)

    direct_hit_records = [
        {
            "manifest_name": row.manifest_name,
            "manifest_path": row.manifest_path,
            "entry_order": row.entry_order,
            "raw_entry": row.raw_entry,
            "normalized_entry": row.normalized_entry,
            "chosen_path": row.chosen_path,
            "variant_kind": row.variant_kind,
            "crc32_decimal": row.crc32_decimal,
            "crc32_hex": row.crc32_hex,
            "status": row.status,
            "existing_mapping_path": row.existing_mapping_path,
            "note": row.note,
        }
        for row in direct_rows
    ]
    new_hit_records = [record for record in direct_hit_records if record["status"] == "new_crc"]
    filtered_records = [
        {
            "manifest_name": row.manifest_name,
            "manifest_path": row.manifest_path,
            "entry_order": row.entry_order,
            "raw_entry": row.raw_entry,
            "normalized_entry": row.normalized_entry,
            "reason": row.reason,
        }
        for row in filtered_rows
    ]
    conflict_records = [
        {
            "conflict_type": row.conflict_type,
            "crc32_decimal": row.crc32_decimal,
            "crc32_hex": row.crc32_hex,
            "preferred_path": row.preferred_path,
            "competing_path": row.competing_path,
            "manifests": row.manifests,
            "note": row.note,
        }
        for row in conflict_rows
    ]
    seed_records = [
        {
            "crc32_decimal": candidate.crc32_decimal,
            "crc32_hex": candidate.crc32_hex,
            "path": candidate.path,
            "manifests": ",".join(sorted(candidate.manifests)),
        }
        for candidate in sorted(seed_candidates.values(), key=lambda item: int(item.crc32_decimal))
    ]

    write_tsv(
        output_dir / "manifest_direct_hits.tsv",
        direct_hit_records,
        [
            "manifest_name",
            "manifest_path",
            "entry_order",
            "raw_entry",
            "normalized_entry",
            "chosen_path",
            "variant_kind",
            "crc32_decimal",
            "crc32_hex",
            "status",
            "existing_mapping_path",
            "note",
        ],
    )
    write_tsv(
        output_dir / "manifest_new_hits.tsv",
        new_hit_records,
        [
            "manifest_name",
            "manifest_path",
            "entry_order",
            "raw_entry",
            "normalized_entry",
            "chosen_path",
            "variant_kind",
            "crc32_decimal",
            "crc32_hex",
            "status",
            "existing_mapping_path",
            "note",
        ],
    )
    write_tsv(
        output_dir / "manifest_crc_conflicts.tsv",
        conflict_records,
        [
            "conflict_type",
            "crc32_decimal",
            "crc32_hex",
            "preferred_path",
            "competing_path",
            "manifests",
            "note",
        ],
    )
    write_tsv(
        output_dir / "manifest_filtered_entries.tsv",
        filtered_records,
        [
            "manifest_name",
            "manifest_path",
            "entry_order",
            "raw_entry",
            "normalized_entry",
            "reason",
        ],
    )
    write_tsv(
        output_dir / "manifest_summary.tsv",
        summary_rows,
        [
            "manifest_name",
            "manifest_path",
            "ignore_case",
            "direct_hits",
            "same_hits",
            "new_hits",
            "mapping_conflicts",
            "filtered",
        ],
    )
    write_tsv(
        output_dir / "manifest_seed_candidates.tsv",
        seed_records,
        ["crc32_decimal", "crc32_hex", "path", "manifests"],
    )

    if write_seed_txt is not None:
        write_mapping_text(
            write_seed_txt,
            {candidate.crc32_decimal: candidate.path for candidate in seed_candidates.values()},
            [
                "Manifest seed candidates",
                f"Target CRC pool: {res_dir}",
                f"Direct hits: {len(direct_rows)}",
                f"New seed hits: {len(seed_candidates)}",
            ],
        )
    if write_seed_ljpm is not None:
        write_mapping_ljpm(
            write_seed_ljpm,
            {candidate.crc32_decimal: candidate.path for candidate in seed_candidates.values()},
        )

    merged_mapping = dict(existing_mapping)
    for candidate in seed_candidates.values():
        merged_mapping.setdefault(candidate.crc32_decimal, candidate.path)

    existing_hits = compute_mapping_hits(existing_mapping, target_crcs)
    merged_hits = compute_mapping_hits(merged_mapping, target_crcs)
    hit_gain = merged_hits - existing_hits
    merged_hit_rate_percent = (merged_hits * 100.0 / len(target_crcs)) if target_crcs else 0.0
    existing_hit_rate_percent = (existing_hits * 100.0 / len(target_crcs)) if target_crcs else 0.0

    if write_merged_txt is not None:
        write_mapping_text(
            write_merged_txt,
            merged_mapping,
            [
                "Existing mapping plus manifest seed additions",
                f"Existing entries: {len(existing_mapping)}",
                f"Manifest seed additions: {len(seed_candidates)}",
                f"Merged entries: {len(merged_mapping)}",
            ],
        )
    if write_merged_ljpm is not None:
        write_mapping_ljpm(write_merged_ljpm, merged_mapping)

    if promote_dir is not None:
        promote_dir.mkdir(parents=True, exist_ok=True)
        write_mapping_text(
            promote_dir / "path_mapping.txt",
            merged_mapping,
            [
                "Promoted manifest-seed merged mapping",
                f"Existing mapping: {existing_mapping_path or ''}",
                f"Manifest seed additions: {len(seed_candidates)}",
                f"Existing hits: {existing_hits}",
                f"Merged hits: {merged_hits}",
            ],
        )
        write_mapping_ljpm(promote_dir / "path_mapping.ljpm", merged_mapping)

    summary = {
        "target_res_dir": str(res_dir),
        "target_crc_file_count": len(target_crcs),
        "existing_mapping_path": str(existing_mapping_path) if existing_mapping_path else "",
        "existing_mapping_entries": len(existing_mapping),
        "existing_hits": existing_hits,
        "existing_hit_rate_percent": existing_hit_rate_percent,
        "manifest_count": len(manifest_specs),
        "direct_hits": len(direct_rows),
        "same_hits": sum(1 for row in direct_rows if row.status == "same_as_mapping"),
        "new_hits": len(seed_candidates),
        "mapping_conflicts": sum(1 for row in direct_rows if row.status == "mapping_conflict"),
        "filtered_entries": len(filtered_rows),
        "conflict_rows": len(conflict_rows),
        "merged_entries": len(merged_mapping),
        "merged_hits": merged_hits,
        "merged_hit_rate_percent": merged_hit_rate_percent,
        "hit_gain": hit_gain,
        "promote_dir": str(promote_dir) if promote_dir else "",
        "encodings": used_encodings,
        "manifests": summary_rows,
    }
    (output_dir / "manifest_summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    write_markdown_summary(output_dir / "manifest_summary.md", summary)
    return summary


def build_argument_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Build high-confidence mapping seeds from txt manifests.")
    parser.add_argument("--res-dir", required=True, help="Target CRC repository directory, e.g. E:\\orange\\assets\\res")
    parser.add_argument("--mapping", help="Existing mapping file (.txt or .ljpm) used for diffing and merge output")
    parser.add_argument("--output-dir", required=True, help="Directory for reports and optional mapping outputs")
    parser.add_argument("--jiebao-root", help="Root directory for E:\\jiebao style default manifests")
    parser.add_argument("--manifest", action="append", default=[], help="Additional manifest path, keep original case")
    parser.add_argument(
        "--manifest-ignore-case",
        action="append",
        default=[],
        help="Additional manifest path that should be lowercased before CRC",
    )
    parser.add_argument(
        "--write-seed-txt",
        help="Optional output path for new manifest seed candidates in text mapping format",
    )
    parser.add_argument(
        "--write-seed-ljpm",
        help="Optional output path for new manifest seed candidates in binary ljpm format",
    )
    parser.add_argument(
        "--write-merged-txt",
        help="Optional output path for existing mapping plus new manifest seeds in text format",
    )
    parser.add_argument(
        "--write-merged-ljpm",
        help="Optional output path for existing mapping plus new manifest seeds in binary ljpm format",
    )
    parser.add_argument(
        "--promote-dir",
        help="Optional directory to write standard-named promoted outputs: path_mapping.txt/.ljpm",
    )
    return parser


def main() -> int:
    parser = build_argument_parser()
    args = parser.parse_args()

    manifest_specs: list[ManifestSpec] = []
    if args.jiebao_root:
        manifest_specs.extend(default_jiebao_specs(Path(args.jiebao_root)))
    manifest_specs.extend(parse_manual_manifest_specs(args))
    if not manifest_specs:
        parser.error("No manifests specified. Use --jiebao-root or --manifest/--manifest-ignore-case.")

    summary = analyze_manifests(
        manifest_specs,
        res_dir=Path(args.res_dir),
        existing_mapping_path=Path(args.mapping) if args.mapping else None,
        output_dir=Path(args.output_dir),
        manifest_encodings=DEFAULT_MANIFEST_ENCODINGS,
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

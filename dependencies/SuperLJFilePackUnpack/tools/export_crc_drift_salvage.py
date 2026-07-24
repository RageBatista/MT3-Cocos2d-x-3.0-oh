#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import shutil
import struct
import zlib
from pathlib import Path, PurePosixPath


def parse_crc32(text: str) -> int:
    value = text.strip()
    if value.lower().startswith("0x"):
        return int(value, 16)
    return int(value, 10)


def load_failed_items(path: Path) -> list[dict]:
    with path.open("r", encoding="utf-8") as f:
        data = json.load(f)
    return list(data.get("failed_items", []))


def load_manifest(path: Path) -> dict[int, dict]:
    mapping: dict[int, dict] = {}
    with path.open("r", encoding="utf-8", errors="ignore", newline="") as f:
        reader = csv.DictReader(f, delimiter="\t")
        for row in reader:
            try:
                crc = parse_crc32(row["path_crc32"])
            except Exception:
                continue
            mapping[crc] = row
    return mapping


def parse_ljpi_index(path: Path) -> dict[int, dict]:
    data = path.read_bytes()
    off = 0
    count, = struct.unpack_from("<I", data, off)
    off += 4
    result: dict[int, dict] = {}
    for _ in range(count):
        pack_index, = struct.unpack_from("<I", data, off)
        off += 4
        pos = 0
        if pack_index > 0:
            pos, = struct.unpack_from("<I", data, off)
            off += 4
        size, crc32, compress_type, code_type = struct.unpack_from("<IIII", data, off)
        off += 16
        if compress_type > 0 or code_type > 0:
            size_original, crc32_original = struct.unpack_from("<II", data, off)
            off += 8
        else:
            size_original, crc32_original = size, crc32
        path_crc32, = struct.unpack_from("<I", data, off)
        off += 4
        result[path_crc32] = {
            "pack_index": pack_index,
            "pos": pos,
            "size": size,
            "crc32": crc32,
            "compress_type": compress_type,
            "code_type": code_type,
            "size_original": size_original,
            "crc32_original": crc32_original,
        }
    return result


def choose_source_relative_path(failed_item: dict, manifest_row: dict | None) -> str:
    if manifest_row is not None:
        for key in ("final_relative_path", "written_relative_path", "normalized_relative_path"):
            value = (manifest_row.get(key) or "").strip()
            if value:
                return value.replace("\\", "/")
    display_path = (failed_item.get("display_path") or "").strip()
    if display_path:
        return display_path.replace("\\", "/")
    return ""


def sha256_hex(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as f:
        while True:
            chunk = f.read(1024 * 1024)
            if not chunk:
                break
            digest.update(chunk)
    return digest.hexdigest()


def crc32_hex(path: Path) -> str:
    crc = 0
    with path.open("rb") as f:
        while True:
            chunk = f.read(1024 * 1024)
            if not chunk:
                break
            crc = zlib.crc32(chunk, crc)
    return f"0x{crc & 0xFFFFFFFF:08X}"


def write_json(path: Path, payload: object) -> None:
    with path.open("w", encoding="utf-8", newline="\n") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
        f.write("\n")


def write_tsv(path: Path, rows: list[dict]) -> None:
    if not rows:
        headers = [
            "file_index",
            "path_crc32",
            "error_code",
            "error_text",
            "display_path",
            "source_relative_path",
            "salvaged_relative_path",
            "source_exists",
            "repo_exists",
            "repo_same_sha256",
            "repo_same_crc32",
            "source_size",
            "expected_crc32",
            "actual_crc32",
            "sha256",
            "pack_index",
            "compress_type",
            "code_type",
        ]
    else:
        headers = list(rows[0].keys())

    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=headers, delimiter="\t")
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Export salvageable outputs for strict-mode CRC drift failures."
    )
    parser.add_argument("--failed-json", required=True, type=Path)
    parser.add_argument("--source-root", required=True, type=Path)
    parser.add_argument("--source-manifest", required=True, type=Path)
    parser.add_argument("--index", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--reference-root", type=Path)
    args = parser.parse_args()

    failed_items = load_failed_items(args.failed_json)
    source_manifest = load_manifest(args.source_manifest)
    index_info = parse_ljpi_index(args.index)

    salvage_root = args.output_dir / "salvaged"
    salvage_root.mkdir(parents=True, exist_ok=True)

    rows: list[dict] = []
    exported = 0
    repo_matches = 0

    for item in failed_items:
        path_crc = parse_crc32(item["path_crc32"])
        manifest_row = source_manifest.get(path_crc)
        index_row = index_info.get(path_crc, {})
        source_rel = choose_source_relative_path(item, manifest_row)
        source_path = args.source_root / PurePosixPath(source_rel) if source_rel else None
        source_exists = bool(source_path and source_path.exists())

        salvaged_rel = ""
        source_size = 0
        actual_crc = ""
        sha256 = ""

        if source_exists and source_path is not None:
            salvaged_rel = source_rel
            dest_path = salvage_root / PurePosixPath(source_rel)
            dest_path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source_path, dest_path)
            exported += 1
            source_size = source_path.stat().st_size
            actual_crc = crc32_hex(source_path)
            sha256 = sha256_hex(source_path)

        repo_exists = False
        repo_same_sha256 = False
        repo_same_crc32 = False
        if args.reference_root is not None and source_rel:
            repo_path = args.reference_root / PurePosixPath(source_rel)
            repo_exists = repo_path.exists()
            if repo_exists and source_exists and source_path is not None:
                repo_sha = sha256_hex(repo_path)
                repo_crc = crc32_hex(repo_path)
                repo_same_sha256 = (repo_sha == sha256)
                repo_same_crc32 = (repo_crc == actual_crc)
                if repo_same_sha256:
                    repo_matches += 1

        rows.append(
            {
                "file_index": item.get("file_index", 0),
                "path_crc32": item.get("path_crc32", ""),
                "error_code": item.get("error_code", 0),
                "error_text": item.get("error_text", ""),
                "display_path": item.get("display_path", ""),
                "source_relative_path": source_rel,
                "salvaged_relative_path": salvaged_rel,
                "source_exists": str(source_exists).lower(),
                "repo_exists": str(repo_exists).lower(),
                "repo_same_sha256": str(repo_same_sha256).lower(),
                "repo_same_crc32": str(repo_same_crc32).lower(),
                "source_size": source_size,
                "expected_crc32": f"0x{index_row.get('crc32_original', 0):08X}" if index_row else "",
                "actual_crc32": actual_crc,
                "sha256": sha256,
                "pack_index": index_row.get("pack_index", 0),
                "compress_type": index_row.get("compress_type", 0),
                "code_type": index_row.get("code_type", 0),
            }
        )

    summary = {
        "version": 1,
        "failed_item_count": len(failed_items),
        "salvaged_count": exported,
        "reference_match_count": repo_matches,
        "failed_json": str(args.failed_json),
        "source_root": str(args.source_root),
        "source_manifest": str(args.source_manifest),
        "index": str(args.index),
        "reference_root": str(args.reference_root) if args.reference_root else "",
    }

    write_tsv(args.output_dir / "salvage_report.tsv", rows)
    write_json(args.output_dir / "salvage_report.json", {"summary": summary, "items": rows})
    write_json(args.output_dir / "salvage_summary.json", summary)

    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
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
        payload = json.load(f)
    return list(payload.get("failed_items", []))


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


def build_fixed_key_words() -> list[int]:
    return [0x18151F19, 0x0900050A, 0x040E1217, 0x140B020F]


def decrypt_client_128_block(block: bytes, key_words: list[int]) -> bytes:
    v0, v1, v2, v3 = struct.unpack("<4I", block)
    sum_ = 0x8DDE6E40
    delta = 0x61C88647
    round_step = 0xC3910C8E

    while sum_ != 0:
        sum_plus = (sum_ + delta) & 0xFFFFFFFF
        idx0 = (sum_ >> 21) & 0x3
        idx1 = (sum_plus >> 11) & 0x3

        m0 = ((((v2 << 4) ^ (v2 >> 5)) + v2) ^ ((sum_ + key_words[idx0]) & 0xFFFFFFFF)) & 0xFFFFFFFF
        m1 = ((((v0 << 4) ^ (v0 >> 5)) + v0) ^ ((sum_plus + key_words[idx1]) & 0xFFFFFFFF)) & 0xFFFFFFFF
        v3 = (v3 - m0) & 0xFFFFFFFF
        v1 = (v1 - m1) & 0xFFFFFFFF

        sum_ = (sum_ + round_step) & 0xFFFFFFFF
        idx2 = (sum_plus >> 16) & 0x3
        idx3 = sum_ & 0x3

        m2 = ((((v3 << 4) ^ (v3 >> 5)) + v3) ^ ((sum_plus + key_words[idx2]) & 0xFFFFFFFF)) & 0xFFFFFFFF
        m3 = ((((v1 << 4) ^ (v1 >> 5)) + v1) ^ ((sum_ + key_words[idx3]) & 0xFFFFFFFF)) & 0xFFFFFFFF
        v2 = (v2 - m2) & 0xFFFFFFFF
        v0 = (v0 - m3) & 0xFFFFFFFF

    return struct.pack("<4I", v0, v1, v2, v3)


def decrypt_clientobf_window1024(data: bytes) -> bytes:
    out = bytearray(data)
    process_size = min(len(data), 1024)
    block_count = process_size // 16
    key_words = build_fixed_key_words()
    for i in range(block_count):
        begin = i * 16
        out[begin:begin + 16] = decrypt_client_128_block(data[begin:begin + 16], key_words)
    return bytes(out)


def classify_output(data: bytes) -> str:
    if data.startswith(b"\x89PNG\r\n\x1a\n"):
        return "png"
    if data.startswith(b"\xff\xfe<\x00"):
        return "utf16le-xml"
    if data.startswith(b"\xef\xbb\xbf<") or data.startswith(b"<"):
        return "xml"
    if data.startswith(b"{") or data.startswith(b"["):
        return "json"
    sample = data[:128]
    if sample and all(b in b"\t\r\n" or 32 <= b <= 126 for b in sample):
        return "text"
    return "binary"


def write_json(path: Path, payload: object) -> None:
    with path.open("w", encoding="utf-8", newline="\n") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
        f.write("\n")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Export clientobf-window1024 candidate outputs for strict-mode failed items."
    )
    parser.add_argument("--failed-json", required=True, type=Path)
    parser.add_argument("--index", required=True, type=Path)
    parser.add_argument("--input-dir", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    args = parser.parse_args()

    failed_items = load_failed_items(args.failed_json)
    index_info = parse_ljpi_index(args.index)
    candidate_root = args.output_dir / "clientobf_window1024"
    candidate_root.mkdir(parents=True, exist_ok=True)

    rows: list[dict] = []
    exported = 0

    for item in failed_items:
        path_crc = parse_crc32(item["path_crc32"])
        info = index_info.get(path_crc)
        if info is None or info["pack_index"] != 0:
            rows.append(
                {
                    "path_crc32": item["path_crc32"],
                    "display_path": item.get("display_path", ""),
                    "status": "skip_non_loose",
                    "error": "",
                    "output_class": "",
                    "actual_crc32": "",
                    "expected_crc32": "",
                    "output_size": 0,
                }
            )
            continue

        source_path = args.input_dir / str(path_crc)
        if not source_path.exists():
            rows.append(
                {
                    "path_crc32": item["path_crc32"],
                    "display_path": item.get("display_path", ""),
                    "status": "missing_source",
                    "error": "",
                    "output_class": "",
                    "actual_crc32": "",
                    "expected_crc32": "",
                    "output_size": 0,
                }
            )
            continue

        source_data = source_path.read_bytes()
        transformed = decrypt_clientobf_window1024(source_data)

        try:
            if info["compress_type"] > 0:
                output = zlib.decompress(transformed)
            else:
                output = transformed
            output_class = classify_output(output)
            actual_crc = zlib.crc32(output) & 0xFFFFFFFF
            expected_crc = info["crc32_original"]

            display_path = (item.get("display_path") or "").strip()
            if not display_path or display_path.isdigit():
                rel = f"{path_crc}"
            else:
                rel = display_path.replace("\\", "/")

            out_path = candidate_root / PurePosixPath(rel)
            out_path.parent.mkdir(parents=True, exist_ok=True)
            out_path.write_bytes(output)
            exported += 1

            rows.append(
                {
                    "path_crc32": item["path_crc32"],
                    "display_path": display_path,
                    "status": "exported",
                    "error": "",
                    "output_class": output_class,
                    "actual_crc32": f"0x{actual_crc:08X}",
                    "expected_crc32": f"0x{expected_crc:08X}",
                    "output_size": len(output),
                }
            )
        except Exception as ex:
            rows.append(
                {
                    "path_crc32": item["path_crc32"],
                    "display_path": item.get("display_path", ""),
                    "status": "failed",
                    "error": str(ex),
                    "output_class": "",
                    "actual_crc32": "",
                    "expected_crc32": f"0x{info['crc32_original']:08X}",
                    "output_size": 0,
                }
            )

    summary = {
        "version": 1,
        "failed_item_count": len(failed_items),
        "exported_count": exported,
        "failed_json": str(args.failed_json),
        "index": str(args.index),
        "input_dir": str(args.input_dir),
        "candidate_root": str(candidate_root),
    }

    with (args.output_dir / "clientobf_window1024_report.tsv").open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "path_crc32",
                "display_path",
                "status",
                "error",
                "output_class",
                "actual_crc32",
                "expected_crc32",
                "output_size",
            ],
            delimiter="\t",
        )
        writer.writeheader()
        writer.writerows(rows)

    write_json(args.output_dir / "clientobf_window1024_report.json", {"summary": summary, "items": rows})
    write_json(args.output_dir / "clientobf_window1024_summary.json", summary)

    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

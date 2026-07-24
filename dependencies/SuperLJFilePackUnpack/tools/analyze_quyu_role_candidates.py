#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import struct
from collections import Counter, defaultdict
from pathlib import Path


def parse_quyu(path: Path) -> tuple[int, int, int, int] | None:
    data = path.read_bytes()
    if len(data) < 16 or data[:4] != b"QUYU":
        return None
    width = struct.unpack("<I", data[4:8])[0]
    height = struct.unpack("<I", data[8:12])[0]
    count = struct.unpack("<I", data[12:16])[0]
    return (width, height, count, len(data))


def load_role_examples(map_root: Path) -> dict[str, Counter]:
    role_examples: dict[str, Counter] = defaultdict(Counter)
    for path in map_root.rglob("*.dat"):
        if path.name not in {"island.dat", "island2.dat", "jumpblock.dat", "regiontypeinfo.dat"}:
            continue
        meta = parse_quyu(path)
        if meta is not None:
            role_examples[path.name][meta] += 1
    return role_examples


def classify_role(meta: tuple[int, int, int, int]) -> tuple[str, str]:
    width, height, count, size = meta
    if size == 16 and count == 0:
        return ("island2_or_jumpblock_like", "empty_region_buffer")
    if size == 16 and count != 0:
        return ("island2_or_jumpblock_like", "tiny_buffer_with_nonzero_count")

    if size == 16 + count * 6:
        return ("regiontypeinfo_like", "unsigned_short_regionbuffer")
    if size == 16 + count * 5:
        return ("island2_or_jumpblock_like", "unsigned_char_regionbuffer")

    if size > 16000 and count > 4000:
        return ("island_like", "large_region_graph")
    if count >= 1000 and size >= 5000:
        return ("regiontypeinfo_like", "dense_region_mask")
    if count < 200 and size < 1000:
        return ("island2_or_jumpblock_like", "sparse_unsigned_char_like")

    return ("quyu_unclassified", "no_rule_match")


def write_csv(path: Path, fieldnames: list[str], rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8-sig", newline="") as fp:
        writer = csv.DictWriter(fp, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser(description="分析 QUYU 候选，更细分到 island/region/jumpblock 角色层")
    parser.add_argument("--quyu-root", required=True, help="review/recovered_dat_signature_candidates/quyu 目录")
    parser.add_argument("--map-root", required=True, help="主 map 目录")
    parser.add_argument("--report-dir", required=True, help="报告输出目录")
    args = parser.parse_args()

    quyu_root = Path(args.quyu_root)
    map_root = Path(args.map_root)
    report_dir = Path(args.report_dir)
    report_dir.mkdir(parents=True, exist_ok=True)

    role_examples = load_role_examples(map_root)

    rows: list[dict[str, object]] = []
    role_counter = Counter()
    for path in sorted(quyu_root.glob("*.dat")):
        meta = parse_quyu(path)
        if meta is None:
            continue
        role, reason = classify_role(meta)
        width, height, count, size = meta
        rows.append(
            {
                "file": path.name,
                "width": width,
                "height": height,
                "count": count,
                "size": size,
                "role_class": role,
                "reason": reason,
                "example_island": ";".join(str(meta) for meta, _ in role_examples["island.dat"].most_common(5)),
                "example_island2": ";".join(str(meta) for meta, _ in role_examples["island2.dat"].most_common(5)),
                "example_jumpblock": ";".join(str(meta) for meta, _ in role_examples["jumpblock.dat"].most_common(5)),
                "example_regiontypeinfo": ";".join(str(meta) for meta, _ in role_examples["regiontypeinfo.dat"].most_common(5)),
            }
        )
        role_counter[role] += 1

    summary = {
        "quyu_file_count": len(rows),
        "role_class_counts": dict(role_counter),
    }

    write_csv(
        report_dir / "quyu_role_candidates.csv",
        [
            "file",
            "width",
            "height",
            "count",
            "size",
            "role_class",
            "reason",
            "example_island",
            "example_island2",
            "example_jumpblock",
            "example_regiontypeinfo",
        ],
        rows,
    )
    (report_dir / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    (report_dir / "README.md").write_text(
        "\n".join(
            [
                "# QUYU 角色层细分",
                "",
                f"- QUYU 文件数: {len(rows)}",
                "",
                "规则：",
                "- `size = 16 + count * 6` 倾向 `regiontypeinfo_like`（`unsigned short`）",
                "- `size = 16 + count * 5` 倾向 `island2_or_jumpblock_like`（`unsigned char`）",
                "- 大尺寸高 count 倾向 `island_like`",
                "- `size == 16 && count == 0` 只能细到 `island2_or_jumpblock_like`，无法继续区分",
            ]
        )
        + "\n",
        encoding="utf-8",
    )

    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

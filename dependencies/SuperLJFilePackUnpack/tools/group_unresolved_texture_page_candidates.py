#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import re
import shutil
import struct
from collections import Counter, defaultdict
from pathlib import Path


PNG_MAGIC = b"\x89PNG\r\n\x1a\n"


def ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def safe_move(src: Path, dst: Path) -> Path:
    ensure_parent(dst)
    if dst.exists():
        candidate = dst
        index = 1
        while candidate.exists():
            suffix = dst.suffix
            stem = dst.stem
            alt_name = f"{stem}.variant{index}{suffix}" if suffix else f"{stem}.variant{index}"
            candidate = dst.with_name(alt_name)
            index += 1
        shutil.move(str(src), str(candidate))
        return candidate
    shutil.move(str(src), str(dst))
    return dst


def write_csv(path: Path, fieldnames: list[str], rows: list[dict[str, object]]) -> None:
    ensure_parent(path)
    with path.open("w", encoding="utf-8-sig", newline="") as fp:
        writer = csv.DictWriter(fp, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def normalized_pattern(stem: str) -> str:
    value = stem.lower()
    value = re.sub(r"res\d+", "res###", value)
    value = re.sub(r"\d+", "#", value)
    value = re.sub(r"#+", "#", value)
    return value


def parse_png_signature(path: Path) -> tuple[str, int, int, int, int] | None:
    data = path.read_bytes()[:32]
    if len(data) < 26 or not data.startswith(PNG_MAGIC):
        return None
    width = struct.unpack(">I", data[16:20])[0]
    height = struct.unpack(">I", data[20:24])[0]
    bit_depth = data[24]
    color_type = data[25]
    return ("png", width, height, bit_depth, color_type)


def parse_webp_signature(path: Path) -> tuple[str, str, int, int] | None:
    data = path.read_bytes()[:64]
    if len(data) < 30 or data[:4] != b"RIFF" or data[8:12] != b"WEBP":
        return None

    subtype = data[12:16].decode("ascii", errors="ignore").lower()
    if subtype == "vp8 ":
        width = (data[26] | ((data[27] & 0x3F) << 8)) + 1
        height = (data[28] | ((data[29] & 0x3F) << 8)) + 1
    elif subtype == "vp8l" and len(data) >= 25:
        bits = data[21] | (data[22] << 8) | (data[23] << 16) | (data[24] << 24)
        width = (bits & 0x3FFF) + 1
        height = ((bits >> 14) & 0x3FFF) + 1
    elif subtype == "vp8x":
        width = 1 + data[24] + (data[25] << 8) + (data[26] << 16)
        height = 1 + data[27] + (data[28] << 8) + (data[29] << 16)
    else:
        return None
    return ("webp", subtype.strip(), width, height)


def signature_key_to_text(sig: tuple) -> str:
    if sig[0] == "png":
        _, width, height, bit_depth, color_type = sig
        return f"png_{width}x{height}_b{bit_depth}_c{color_type}"
    _, subtype, width, height = sig
    safe_subtype = subtype.replace(" ", "_")
    return f"webp_{safe_subtype}_{width}x{height}"


def collect_resolved_patterns(resolved_root: Path) -> tuple[dict[tuple, Counter], dict[tuple, list[str]]]:
    image_exts = {".png", ".pngpart", ".webp", ".jpg", ".jpeg", ".dds", ".tga"}
    by_signature: dict[tuple, Counter] = defaultdict(Counter)
    sample_paths: dict[tuple, list[str]] = defaultdict(list)

    for path in resolved_root.rglob("*"):
        if not path.is_file():
            continue
        rel = str(path.relative_to(resolved_root)).replace("\\", "/")
        if rel.startswith("review/"):
            continue
        if path.suffix.lower() not in image_exts:
            continue
        sig = parse_png_signature(path)
        if sig is None:
            sig = parse_webp_signature(path)
        if sig is None:
            continue

        by_signature[sig][normalized_pattern(path.stem)] += 1
        if len(sample_paths[sig]) < 12:
            sample_paths[sig].append(rel)

    return by_signature, sample_paths


def main() -> int:
    parser = argparse.ArgumentParser(description="把 unresolved 中的 png/webp 批量提升为纹理页候选组")
    parser.add_argument("--unresolved-root", required=True, help="review/unresolved 根目录")
    parser.add_argument("--review-root", required=True, help="review 根目录")
    parser.add_argument("--resolved-root", required=True, help="已恢复主树根目录，用于抽取同签名命名模式")
    parser.add_argument("--report-dir", required=True, help="报告输出目录")
    args = parser.parse_args()

    unresolved_root = Path(args.unresolved_root)
    review_root = Path(args.review_root)
    resolved_root = Path(args.resolved_root)
    report_dir = Path(args.report_dir)
    report_dir.mkdir(parents=True, exist_ok=True)

    resolved_patterns, resolved_samples = collect_resolved_patterns(resolved_root)

    moved_rows: list[dict[str, object]] = []
    group_rows: list[dict[str, object]] = []
    grouped: dict[tuple, list[Path]] = defaultdict(list)

    for ext in ("png", "webp"):
        directory = unresolved_root / ext
        if not directory.exists():
            continue
        for path in sorted(directory.glob(f"*.{ext}")):
            sig = parse_png_signature(path) if ext == "png" else parse_webp_signature(path)
            if sig is None:
                continue
            grouped[sig].append(path)

    for sig, paths in sorted(grouped.items(), key=lambda item: (item[0][0], signature_key_to_text(item[0]))):
        signature_text = signature_key_to_text(sig)
        top_patterns = resolved_patterns.get(sig, Counter()).most_common(8)
        top_pattern_text = ";".join(f"{name}:{count}" for name, count in top_patterns)
        resolved_sample_text = ";".join(resolved_samples.get(sig, [])[:8])

        size_counter = Counter(path.stat().st_size for path in paths)
        for size_value, size_count in sorted(size_counter.items()):
            group_rows.append(
                {
                    "signature": signature_text,
                    "size": size_value,
                    "count": size_count,
                    "resolved_pattern_hints": top_pattern_text,
                    "resolved_sample_paths": resolved_sample_text,
                }
            )

        for path in paths:
            size_value = path.stat().st_size
            dest = review_root / "recovered_texture_page_group_candidates" / sig[0] / signature_text / f"size_{size_value}" / path.name
            actual = safe_move(path, dest)
            moved_rows.append(
                {
                    "source_rel": str(path.relative_to(review_root)).replace("\\", "/"),
                    "signature": signature_text,
                    "size": size_value,
                    "resolved_pattern_hints": top_pattern_text,
                    "resolved_sample_paths": resolved_sample_text,
                    "actual_path": str(actual),
                }
            )

    summary = {
        "moved_count": len(moved_rows),
        "group_count": len(group_rows),
        "signature_count": len(grouped),
        "moved_by_ext": dict(Counter(path["source_rel"].split("/")[1] for path in moved_rows)),
    }

    write_csv(
        report_dir / "texture_page_group_members.csv",
        ["source_rel", "signature", "size", "resolved_pattern_hints", "resolved_sample_paths", "actual_path"],
        moved_rows,
    )
    write_csv(
        report_dir / "texture_page_group_summary.csv",
        ["signature", "size", "count", "resolved_pattern_hints", "resolved_sample_paths"],
        group_rows,
    )
    (report_dir / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    (report_dir / "README.md").write_text(
        "\n".join(
            [
                "# unresolved 纹理页候选分组",
                "",
                f"- 提升文件数: {len(moved_rows)}",
                f"- 尺寸/魔数组数: {len(grouped)}",
                "",
                "分组方式：",
                "- PNG：按 `width x height + bit depth + color type` 分组，再按文件大小分桶。",
                "- WebP：按 `VP8/VP8L/VP8X + width x height` 分组，再按文件大小分桶。",
                "- 报告中补充已恢复树里同签名图片的高频命名模式，作为纹理页命名参考。",
            ]
        )
        + "\n",
        encoding="utf-8",
    )

    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

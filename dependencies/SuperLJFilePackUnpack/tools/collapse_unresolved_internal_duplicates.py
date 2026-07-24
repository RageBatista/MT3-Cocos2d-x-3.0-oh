#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import shutil
from collections import Counter, defaultdict
from pathlib import Path


def sha1_bytes(path: Path) -> str:
    h = hashlib.sha1()
    with path.open("rb") as fp:
        for chunk in iter(lambda: fp.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


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


def main() -> int:
    parser = argparse.ArgumentParser(description="折叠 review/unresolved 内部同内容重复副本")
    parser.add_argument("--unresolved-root", required=True, help="review/unresolved 根目录")
    parser.add_argument("--review-root", required=True, help="review 根目录")
    parser.add_argument("--report-dir", required=True, help="报告输出目录")
    parser.add_argument("--ext", action="append", default=[], help="仅处理指定扩展目录名，如 png")
    args = parser.parse_args()

    unresolved_root = Path(args.unresolved_root)
    review_root = Path(args.review_root)
    report_dir = Path(args.report_dir)
    report_dir.mkdir(parents=True, exist_ok=True)

    ext_filters = set(ext.lower().lstrip(".") for ext in args.ext)
    target_dirs = []
    for path in sorted(unresolved_root.iterdir()):
        if not path.is_dir():
            continue
        if ext_filters and path.name.lower() not in ext_filters:
            continue
        target_dirs.append(path)

    moved_rows: list[dict[str, object]] = []
    group_rows: list[dict[str, object]] = []

    for directory in target_dirs:
        by_hash: dict[str, list[Path]] = defaultdict(list)
        for path in sorted(directory.glob("*")):
            if not path.is_file():
                continue
            by_hash[sha1_bytes(path)].append(path)

        for sha1, paths in sorted(by_hash.items(), key=lambda item: (item[1][0].suffix.lower(), item[1][0].name)):
            if len(paths) <= 1:
                continue
            keeper = sorted(paths, key=lambda p: p.name)[0]
            duplicates = [path for path in sorted(paths, key=lambda p: p.name) if path != keeper]
            group_rows.append(
                {
                    "extension_dir": directory.name,
                    "sha1": sha1,
                    "keeper_rel": str(keeper.relative_to(review_root)).replace("\\", "/"),
                    "duplicate_count": len(duplicates),
                    "duplicate_sample": ";".join(str(path.relative_to(review_root)).replace("\\", "/") for path in duplicates[:12]),
                }
            )
            for duplicate in duplicates:
                dest = review_root / "resolved_internal_content_alias" / directory.name / sha1 / duplicate.name
                actual = safe_move(duplicate, dest)
                moved_rows.append(
                    {
                        "extension_dir": directory.name,
                        "sha1": sha1,
                        "keeper_rel": str(keeper.relative_to(review_root)).replace("\\", "/"),
                        "duplicate_rel": str(duplicate.relative_to(review_root)).replace("\\", "/"),
                        "actual_path": str(actual),
                    }
                )

    summary = {
        "target_dirs": [path.name for path in target_dirs],
        "group_count": len(group_rows),
        "moved_count": len(moved_rows),
        "moved_by_extension_dir": dict(Counter(row["extension_dir"] for row in moved_rows)),
    }

    write_csv(
        report_dir / "internal_duplicate_groups.csv",
        ["extension_dir", "sha1", "keeper_rel", "duplicate_count", "duplicate_sample"],
        group_rows,
    )
    write_csv(
        report_dir / "moved_internal_duplicates.csv",
        ["extension_dir", "sha1", "keeper_rel", "duplicate_rel", "actual_path"],
        moved_rows,
    )
    (report_dir / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    (report_dir / "README.md").write_text(
        "\n".join(
            [
                "# unresolved 内部同内容去重",
                "",
                f"- 重复组数量: {len(group_rows)}",
                f"- 实际移动数量: {len(moved_rows)}",
                "",
                "处理规则：",
                "- 同一扩展目录下按 SHA1 分组。",
                "- 每组保留一个代表样本继续留在 `review/unresolved`。",
                "- 其余副本移动到 `review/resolved_internal_content_alias/<ext>/<sha1>/`。",
            ]
        )
        + "\n",
        encoding="utf-8",
    )

    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

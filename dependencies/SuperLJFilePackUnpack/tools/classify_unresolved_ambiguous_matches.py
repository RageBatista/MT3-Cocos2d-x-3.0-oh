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
    if not dst.exists():
        shutil.move(str(src), str(dst))
        return dst

    if sha1_bytes(src) == sha1_bytes(dst):
        src.unlink()
        return dst

    index = 1
    while True:
        suffix = dst.suffix
        stem = dst.stem
        alt_name = f"{stem}.conflict{index}{suffix}" if suffix else f"{stem}.conflict{index}"
        alt_path = dst.with_name(alt_name)
        if not alt_path.exists():
            shutil.move(str(src), str(alt_path))
            return alt_path
        if sha1_bytes(src) == sha1_bytes(alt_path):
            src.unlink()
            return alt_path
        index += 1


def write_csv(path: Path, fieldnames: list[str], rows: list[dict[str, object]]) -> None:
    ensure_parent(path)
    with path.open("w", encoding="utf-8-sig", newline="") as fp:
        writer = csv.DictWriter(fp, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser(description="把 review/unresolved 中与已恢复树同内容但多命中的歧义项分类出去")
    parser.add_argument("--resolved-root", required=True, help="已恢复资源树根目录")
    parser.add_argument("--unresolved-root", required=True, help="review/unresolved 目录")
    parser.add_argument("--review-root", required=True, help="review 根目录")
    parser.add_argument("--report-dir", required=True, help="报告输出目录")
    parser.add_argument("--apply-move", action="store_true", help="实际移动文件")
    parser.add_argument("--sample-limit", type=int, default=12, help="每条记录保留多少个候选样本")
    args = parser.parse_args()

    resolved_root = Path(args.resolved_root)
    unresolved_root = Path(args.unresolved_root)
    review_root = Path(args.review_root)
    report_dir = Path(args.report_dir)
    alias_root = review_root / "resolved_ambiguous_content_alias"

    resolved_by_size: dict[int, list[Path]] = defaultdict(list)
    resolved_hash_cache: dict[Path, str] = {}
    unresolved_hash_cache: dict[Path, str] = {}

    for path in resolved_root.rglob("*"):
        if path.is_file():
            resolved_by_size[path.stat().st_size].append(path)

    ambiguous_rows: list[dict[str, object]] = []
    moved_rows: list[dict[str, object]] = []

    for path in sorted(unresolved_root.rglob("*")):
        if not path.is_file():
            continue

        candidates = resolved_by_size.get(path.stat().st_size, [])
        if not candidates:
            continue

        src_hash = unresolved_hash_cache.setdefault(path, sha1_bytes(path))
        hits: list[Path] = []
        for candidate in candidates:
            candidate_hash = resolved_hash_cache.setdefault(candidate, sha1_bytes(candidate))
            if candidate_hash == src_hash:
                hits.append(candidate)

        if len(hits) <= 1:
            continue

        rel = path.relative_to(unresolved_root)
        dest = alias_root / rel
        row = {
            "unresolved_path": str(path),
            "unresolved_rel": rel.as_posix(),
            "size": path.stat().st_size,
            "sha1": src_hash,
            "match_count": len(hits),
            "match_sample": ";".join(hit.relative_to(resolved_root).as_posix() for hit in hits[: args.sample_limit]),
            "move_target_rel": rel.as_posix(),
        }
        ambiguous_rows.append(row)
        if args.apply_move:
            actual = safe_move(path, dest)
            moved = dict(row)
            moved["actual_move_path"] = str(actual)
            moved_rows.append(moved)

    summary = {
        "resolved_root": str(resolved_root),
        "unresolved_root": str(unresolved_root),
        "review_root": str(review_root),
        "alias_root": str(alias_root),
        "apply_move": args.apply_move,
        "ambiguous_match_count": len(ambiguous_rows),
        "moved_count": len(moved_rows),
        "ambiguous_match_by_suffix": dict(Counter((Path(row["unresolved_rel"]).suffix.lower() or "<noext>") for row in ambiguous_rows)),
    }

    write_csv(
        report_dir / "ambiguous_exact_matches.csv",
        [
            "unresolved_path",
            "unresolved_rel",
            "size",
            "sha1",
            "match_count",
            "match_sample",
            "move_target_rel",
        ],
        ambiguous_rows,
    )
    if args.apply_move:
        write_csv(
            report_dir / "moved_ambiguous_exact_matches.csv",
            [
                "unresolved_path",
                "unresolved_rel",
                "size",
                "sha1",
                "match_count",
                "match_sample",
                "move_target_rel",
                "actual_move_path",
            ],
            moved_rows,
        )

    ensure_parent(report_dir / "summary.json")
    (report_dir / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")

    md = [
        "# unresolved 歧义同内容分类",
        "",
        f"- 歧义同内容数量: {len(ambiguous_rows)}",
        f"- 实际移动数量: {len(moved_rows)}",
        "",
        "说明：",
        "- 这些文件与 `dev_res` 中至少 2 个文件字节完全一致，因此内容已知但无法唯一恢复原始路径。",
        "- 它们被移动到 `review/resolved_ambiguous_content_alias`，从 `unresolved` 主 backlog 中剥离。",
        "",
        "主要导出：",
        "- `ambiguous_exact_matches.csv`",
        "- `summary.json`",
    ]
    if args.apply_move:
        md.append("- `moved_ambiguous_exact_matches.csv`")
    (report_dir / "README.md").write_text("\n".join(md) + "\n", encoding="utf-8")

    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

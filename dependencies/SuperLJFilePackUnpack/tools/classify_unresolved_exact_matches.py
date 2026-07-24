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

    candidate = dst
    index = 1
    while True:
        suffix = candidate.suffix
        stem = candidate.stem
        alt_name = f"{stem}.conflict{index}{suffix}" if suffix else f"{stem}.conflict{index}"
        candidate = candidate.with_name(alt_name)
        if not candidate.exists():
            shutil.move(str(src), str(candidate))
            return candidate
        if sha1_bytes(src) == sha1_bytes(candidate):
            src.unlink()
            return candidate
        index += 1


def write_csv(path: Path, fieldnames: list[str], rows: list[dict[str, object]]) -> None:
    ensure_parent(path)
    with path.open("w", encoding="utf-8-sig", newline="") as fp:
        writer = csv.DictWriter(fp, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser(description="把 review/unresolved 中与已恢复树完全同内容且唯一命中的文件分类出去")
    parser.add_argument("--resolved-root", required=True, help="已恢复资源树根目录")
    parser.add_argument("--unresolved-root", required=True, help="review/unresolved 目录")
    parser.add_argument("--review-root", required=True, help="review 根目录")
    parser.add_argument("--report-dir", required=True, help="报告输出目录")
    parser.add_argument("--apply-move", action="store_true", help="实际移动文件")
    args = parser.parse_args()

    resolved_root = Path(args.resolved_root)
    unresolved_root = Path(args.unresolved_root)
    review_root = Path(args.review_root)
    report_dir = Path(args.report_dir)
    alias_root = review_root / "resolved_exact_content_alias"

    resolved_by_size: dict[int, list[Path]] = defaultdict(list)
    resolved_hash_cache: dict[Path, str] = {}
    unresolved_hash_cache: dict[Path, str] = {}

    for path in resolved_root.rglob("*"):
        if path.is_file():
            resolved_by_size[path.stat().st_size].append(path)

    unique_rows: list[dict[str, object]] = []
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

        if len(hits) == 1:
            hit = hits[0]
            rel = path.relative_to(unresolved_root)
            dest = alias_root / rel
            same_suffix = path.suffix.lower() == hit.suffix.lower()
            row = {
                "unresolved_path": str(path),
                "unresolved_rel": rel.as_posix(),
                "resolved_match_path": str(hit),
                "resolved_match_rel": hit.relative_to(resolved_root).as_posix(),
                "size": path.stat().st_size,
                "sha1": src_hash,
                "same_suffix": str(same_suffix).lower(),
                "unresolved_suffix": path.suffix.lower(),
                "resolved_suffix": hit.suffix.lower(),
                "move_target_rel": rel.as_posix(),
            }
            unique_rows.append(row)
            if args.apply_move:
                actual = safe_move(path, dest)
                moved = dict(row)
                moved["actual_move_path"] = str(actual)
                moved_rows.append(moved)
        elif len(hits) > 1:
            ambiguous_rows.append(
                {
                    "unresolved_path": str(path),
                    "unresolved_rel": path.relative_to(unresolved_root).as_posix(),
                    "size": path.stat().st_size,
                    "sha1": src_hash,
                    "match_count": len(hits),
                    "match_sample": ";".join(hit.relative_to(resolved_root).as_posix() for hit in hits[:8]),
                }
            )

    summary = {
        "resolved_root": str(resolved_root),
        "unresolved_root": str(unresolved_root),
        "review_root": str(review_root),
        "alias_root": str(alias_root),
        "apply_move": args.apply_move,
        "unique_match_count": len(unique_rows),
        "ambiguous_match_count": len(ambiguous_rows),
        "moved_count": len(moved_rows),
        "unique_match_by_suffix": dict(Counter(row["unresolved_suffix"] or "<noext>" for row in unique_rows)),
        "ambiguous_match_by_suffix": dict(Counter(row["unresolved_rel"].split("/")[0] for row in ambiguous_rows)),
    }

    write_csv(
        report_dir / "unique_exact_matches.csv",
        [
            "unresolved_path",
            "unresolved_rel",
            "resolved_match_path",
            "resolved_match_rel",
            "size",
            "sha1",
            "same_suffix",
            "unresolved_suffix",
            "resolved_suffix",
            "move_target_rel",
        ],
        unique_rows,
    )
    write_csv(
        report_dir / "ambiguous_exact_matches.csv",
        [
            "unresolved_path",
            "unresolved_rel",
            "size",
            "sha1",
            "match_count",
            "match_sample",
        ],
        ambiguous_rows,
    )
    if args.apply_move:
        write_csv(
            report_dir / "moved_exact_matches.csv",
            [
                "unresolved_path",
                "unresolved_rel",
                "resolved_match_path",
                "resolved_match_rel",
                "size",
                "sha1",
                "same_suffix",
                "unresolved_suffix",
                "resolved_suffix",
                "move_target_rel",
                "actual_move_path",
            ],
            moved_rows,
        )

    ensure_parent(report_dir / "summary.json")
    (report_dir / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")

    md = [
        "# unresolved 精确同内容分类",
        "",
        f"- 唯一精确命中数量: {len(unique_rows)}",
        f"- 多命中歧义数量: {len(ambiguous_rows)}",
        f"- 实际移动数量: {len(moved_rows)}",
        "",
        "说明：",
        "- 唯一精确命中：`review/unresolved` 文件与 `dev_res` 中某个文件字节完全一致，且只命中一个目标。",
        "- 这批文件会被移动到 `review/resolved_exact_content_alias`，作为“内容已知、原始路径仍待追踪”的别名候选。",
        "- 多命中歧义项暂不移动，避免误判。",
        "",
        "主要导出：",
        "- `unique_exact_matches.csv`",
        "- `ambiguous_exact_matches.csv`",
        "- `summary.json`",
    ]
    if args.apply_move:
        md.append("- `moved_exact_matches.csv`")
    (report_dir / "README.md").write_text("\n".join(md) + "\n", encoding="utf-8")

    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

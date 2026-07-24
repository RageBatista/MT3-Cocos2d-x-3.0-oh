#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import re
import shutil
from collections import Counter
from pathlib import Path


PNG_MAGIC = b"\x89PNG\r\n\x1a\n"
QUYU_MAGIC = b"QUYU"
DYEP_MAGIC = b"DYEP"


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


def is_act_like(data: bytes) -> bool:
    if len(data) < 16:
        return False
    first = int.from_bytes(data[0:4], "little", signed=False)
    second = int.from_bytes(data[4:8], "little", signed=False)
    if first not in {3, 8, 9, 10, 12, 16}:
        return False
    return 0 < second < 100000


def signature_group(data: bytes) -> str:
    head = data[:12].hex()
    return f"sig_{head}"


def classify_noext(data: bytes) -> tuple[str, str, str]:
    if data.startswith(DYEP_MAGIC):
        return ("recovered_extensionless_binary_candidates", "dyeinfo", ".dye")
    if data.startswith(PNG_MAGIC) or data.startswith(PNG_MAGIC[:4]):
        return ("recovered_extensionless_binary_candidates", "png_wrapped", ".bin")
    if is_act_like(data):
        return ("recovered_extensionless_binary_candidates", "action_like", ".act")
    return ("recovered_extensionless_binary_candidates", signature_group(data), ".bin")


def classify_dat(data: bytes) -> tuple[str, str]:
    if data.startswith(QUYU_MAGIC):
        return ("recovered_dat_signature_candidates", "quyu")
    return ("recovered_dat_signature_candidates", signature_group(data))


def classify_ani(data: bytes) -> tuple[str, str]:
    if b"_res" in data and b".png" in data:
        return ("recovered_ani_binary_candidates", "texture_ref")
    if is_act_like(data):
        return ("recovered_ani_binary_candidates", "act_like")
    return ("recovered_ani_binary_candidates", "unclassified")


def extract_ani_hint(data: bytes) -> str:
    match = re.search(rb"([A-Za-z0-9_\-]+_res\d+\.(?:png|jpg|jpeg|webp|dds|tga))", data)
    if not match:
        return ""
    try:
        return match.group(1).decode("utf-8", errors="ignore")
    except Exception:
        return ""


def main() -> int:
    parser = argparse.ArgumentParser(description="把 unresolved 中带稳定二进制签名的 noext/dat/ani 提升成候选目录")
    parser.add_argument("--unresolved-root", required=True, help="review/unresolved 根目录")
    parser.add_argument("--review-root", required=True, help="review 根目录")
    parser.add_argument("--report-dir", required=True, help="报告输出目录")
    args = parser.parse_args()

    unresolved_root = Path(args.unresolved_root)
    review_root = Path(args.review_root)
    report_dir = Path(args.report_dir)
    report_dir.mkdir(parents=True, exist_ok=True)

    moved_rows: list[dict[str, object]] = []

    # noext
    for path in sorted((unresolved_root / "noext").glob("*")):
        if not path.is_file():
            continue
        data = path.read_bytes()[:256]
        bucket, subgroup, suffix = classify_noext(data)
        if not bucket:
            continue
        target_name = path.name + suffix
        dest = review_root / bucket / subgroup / target_name
        actual = safe_move(path, dest)
        moved_rows.append(
            {
                "source_rel": str(path.relative_to(review_root)).replace("\\", "/"),
                "category": bucket,
                "candidate_rel": f"{subgroup}/{target_name}",
                "confidence": "high" if subgroup == "dyeinfo" else "medium",
                "evidence": subgroup,
                "actual_path": str(actual),
            }
        )

    # dat
    for path in sorted((unresolved_root / "dat").glob("*.dat")):
        data = path.read_bytes()[:256]
        bucket, subgroup = classify_dat(data)
        dest = review_root / bucket / subgroup / path.name
        actual = safe_move(path, dest)
        moved_rows.append(
            {
                "source_rel": str(path.relative_to(review_root)).replace("\\", "/"),
                "category": bucket,
                "candidate_rel": f"{subgroup}/{path.name}",
                "confidence": "high",
                "evidence": subgroup,
                "actual_path": str(actual),
            }
        )

    # ani
    for path in sorted((unresolved_root / "ani").glob("*.ani")):
        data = path.read_bytes()[:512]
        bucket, subgroup = classify_ani(data)
        hint = extract_ani_hint(data)
        dest = review_root / bucket / subgroup / path.name
        actual = safe_move(path, dest)
        evidence = subgroup if not hint else f"{subgroup};hint={hint}"
        moved_rows.append(
            {
                "source_rel": str(path.relative_to(review_root)).replace("\\", "/"),
                "category": bucket,
                "candidate_rel": f"{subgroup}/{path.name}",
                "confidence": "high" if subgroup == "texture_ref" else "medium",
                "evidence": evidence,
                "actual_path": str(actual),
            }
        )

    # map binaries with already-known extensions
    for ext, subgroup in (("mrmp", "mrmp"), ("rmp", "rmp")):
        for path in sorted((unresolved_root / ext).glob(f"*.{ext}")):
            dest = review_root / "recovered_map_binary_candidates" / subgroup / path.name
            actual = safe_move(path, dest)
            moved_rows.append(
                {
                    "source_rel": str(path.relative_to(review_root)).replace("\\", "/"),
                    "category": "recovered_map_binary_candidates",
                    "candidate_rel": f"{subgroup}/{path.name}",
                    "confidence": "high",
                    "evidence": subgroup,
                    "actual_path": str(actual),
                }
            )

    summary = {
        "moved_count": len(moved_rows),
        "by_category": dict(Counter(row["category"] for row in moved_rows)),
    }

    write_csv(
        report_dir / "binary_signature_candidate_promotions.csv",
        ["source_rel", "category", "candidate_rel", "confidence", "evidence", "actual_path"],
        moved_rows,
    )
    (report_dir / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    (report_dir / "README.md").write_text(
        "\n".join(
            [
                "# unresolved 二进制签名候选提升",
                "",
                f"- 提升条目数: {len(moved_rows)}",
                "",
                "分类：",
                "- `recovered_extensionless_binary_candidates`：无扩展二进制别名，按 `dyeinfo / action_like / png_wrapped` 分流",
                "- `recovered_dat_signature_candidates/quyu`：`QUYU` 区域/寻路数据",
                "- `recovered_ani_binary_candidates`：带纹理引用的动作动画二进制",
            ]
        )
        + "\n",
        encoding="utf-8",
    )

    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

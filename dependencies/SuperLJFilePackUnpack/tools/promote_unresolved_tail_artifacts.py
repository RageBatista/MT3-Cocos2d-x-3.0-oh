#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import shutil
import zipfile
from pathlib import Path


def read_text_auto(path: Path) -> str:
    data = path.read_bytes()
    for encoding in ("utf-8-sig", "gb18030", "utf-16", "utf-16-le", "utf-16-be", "latin1"):
        try:
            return data.decode(encoding).replace("\x00", "")
        except UnicodeDecodeError:
            continue
    return data.decode("latin1", errors="ignore").replace("\x00", "")


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


def classify_ini(path: Path) -> tuple[str, str, str]:
    text = read_text_auto(path)
    if "[ClientSetting]" in text:
        return ("recovered_config_tail_candidates", "clientsetting_ini", "high")
    if "[LocalizedFileNames]" in text:
        return ("recovered_config_tail_candidates", "localizedfilenames_ini", "high")
    return ("recovered_config_tail_candidates", "generic_ini", "medium")


def classify_txt(path: Path) -> tuple[str, str, str]:
    text = read_text_auto(path)
    if "BUG" in text or "审核人" in text or "提交人" in text:
        return ("recovered_issue_note_candidates", "bug_note", "high")
    return ("recovered_issue_note_candidates", "plain_text", "medium")


def classify_zip(path: Path) -> tuple[str, str, str, str]:
    try:
        with zipfile.ZipFile(path, "r") as zf:
            names = zf.namelist()
    except Exception:
        return ("recovered_archive_tail_candidates", "generic_zip", "medium", "zip_entries=unreadable")

    if names:
        joined = ";".join(names[:8])
        if any("leitai" in name.lower() for name in names):
            return ("recovered_archive_tail_candidates", "leitai_script_bundle", "high", f"zip_entries={joined}")
        return ("recovered_archive_tail_candidates", "named_zip_bundle", "medium", f"zip_entries={joined}")
    return ("recovered_archive_tail_candidates", "empty_zip", "medium", "zip_entries=")


def classify_tail(path: Path) -> tuple[str, str, str, str]:
    ext = path.suffix.lower()
    if ext == ".dds":
        return ("recovered_texture_binary_tail_candidates", "dds_texture", "medium", "dds_magic")
    if ext == ".jpg":
        return ("recovered_texture_binary_tail_candidates", "jpg_texture", "medium", "jpeg_magic")
    if ext == ".tga":
        return ("recovered_texture_binary_tail_candidates", "tga_texture", "medium", "tga_magic")
    if ext == ".img":
        return ("recovered_misc_binary_tail_candidates", "img_binary", "medium", "img_binary_header")
    if ext == ".ptc":
        return ("recovered_particle_binary_tail_candidates", "ptc_binary", "medium", "ptc_extension")
    if ext == ".ttf":
        return ("recovered_font_tail_candidates", "ttf_font", "high", "ttf_magic")
    if ext == ".cfb":
        return ("recovered_office_binary_tail_candidates", "cfb_document", "high", "compound_file_binary")
    if ext == ".dmp":
        return ("recovered_crashdump_tail_candidates", "windows_minidump", "high", "mdmp_magic")
    if ext == ".ini":
        bucket, subgroup, confidence = classify_ini(path)
        return (bucket, subgroup, confidence, "ini_sections")
    if ext == ".txt":
        bucket, subgroup, confidence = classify_txt(path)
        return (bucket, subgroup, confidence, "text_content")
    if ext == ".zip":
        return classify_zip(path)
    return ("recovered_misc_tail_candidates", ext.lstrip(".") or "noext", "low", "fallback")


def main() -> int:
    parser = argparse.ArgumentParser(description="把 review/unresolved 剩余尾项提升成稳定候选桶")
    parser.add_argument("--unresolved-root", required=True, help="review/unresolved 根目录")
    parser.add_argument("--review-root", required=True, help="review 根目录")
    parser.add_argument("--report-dir", required=True, help="报告输出目录")
    args = parser.parse_args()

    unresolved_root = Path(args.unresolved_root)
    review_root = Path(args.review_root)
    report_dir = Path(args.report_dir)
    report_dir.mkdir(parents=True, exist_ok=True)

    moved_rows: list[dict[str, object]] = []

    for path in sorted(unresolved_root.rglob("*")):
        if not path.is_file():
            continue
        bucket, subgroup, confidence, evidence = classify_tail(path)
        dest = review_root / bucket / subgroup / path.name
        actual = safe_move(path, dest)
        moved_rows.append(
            {
                "source_rel": str(path.relative_to(review_root)).replace("\\", "/"),
                "category": bucket,
                "candidate_rel": f"{subgroup}/{path.name}",
                "confidence": confidence,
                "evidence": evidence,
                "actual_path": str(actual),
            }
        )

    summary = {
        "moved_count": len(moved_rows),
        "by_category": {},
    }
    for row in moved_rows:
        summary["by_category"].setdefault(row["category"], 0)
        summary["by_category"][row["category"]] += 1

    write_csv(
        report_dir / "tail_artifact_promotions.csv",
        ["source_rel", "category", "candidate_rel", "confidence", "evidence", "actual_path"],
        moved_rows,
    )
    (report_dir / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    (report_dir / "README.md").write_text(
        "\n".join(
            [
                "# unresolved 尾项候选归桶",
                "",
                f"- 提升条目数: {len(moved_rows)}",
                "",
                "说明：",
                "- 这批文件已能稳定判断为某种文件类型，但仍缺少真实原始路径。",
                "- 因此从 `unresolved` 主 backlog 中剥离，提升到按文件语义分桶的候选目录。",
            ]
        )
        + "\n",
        encoding="utf-8",
    )

    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

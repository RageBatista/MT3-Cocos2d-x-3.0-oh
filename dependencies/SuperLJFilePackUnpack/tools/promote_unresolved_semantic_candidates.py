#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import re
import shutil
from pathlib import Path


SCRIPT_CANDIDATES = {
    "WorkshopLabel": ("recovered_script_path_candidates", "script/logic/workshop/workshoplabel.lua", "high"),
    "TitleDlg": ("recovered_script_path_candidates", "script/logic/title/titledlg.lua", "high"),
    "AttunementDlg": ("recovered_script_path_candidates", "script/logic/workshop/attunement.lua", "high"),
    "MTGFirstChargeDlg": ("recovered_script_path_candidates", "script/logic/qiandaosongli/mtg_firstchargedlg.lua", "high"),
    "QiandaosongliDlg": ("recovered_script_path_candidates", "script/logic/qiandaosongli/qiandaosonglidlg_mtg.lua", "high"),
    "LogoInfoDialog": ("recovered_script_path_candidates", "script/logic/logo/logoinfodlg.lua", "high"),
    "HuoBanZhuZhanDialog": ("recovered_script_path_candidates", "script/logic/team/huobanzhuzhandialog.lua", "high"),
    "jingmaihecheng_dt1": ("recovered_script_path_candidates", "script/logic/shengsizhan/jingmaihecheng_dt1.lua", "high"),
    "PetGalleryDlg": ("recovered_script_path_candidates", "script/logic/pet/petgallerydlg.lua", "high"),
    "CChangeGem": ("recovered_script_path_candidates", "script/protodef/fire/pb/school/change/cchangegem.lua", "medium"),
}

LAYOUT_CANDIDATES = {
    "friendmailcontent": ("recovered_layout_path_candidates", "ui/layouts/friendmailcontent.layout", "high"),
    "PetPropertyNew": ("recovered_layout_path_candidates", "ui/layouts/petpropertynew.layout", "high"),
    "MainControlDlg": ("recovered_layout_path_candidates", "ui/layouts/maincontrol.layout", "medium"),
}


def read_text_auto(path: Path) -> str:
    data = path.read_bytes()
    for encoding in ("utf-8-sig", "utf-16", "utf-16-le", "utf-16-be", "gb18030", "latin1"):
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


def detect_script_symbol(text: str) -> str | None:
    for symbol in SCRIPT_CANDIDATES.keys():
        if re.search(rf"\b{re.escape(symbol)}\s*=\s*\{{", text):
            return symbol
    return None


def detect_layout_root(text: str) -> str | None:
    for root_name in LAYOUT_CANDIDATES.keys():
        if f'Name="{root_name}"' in text:
            return root_name
    return None


def detect_editor_sidecar(text: str) -> tuple[str, str] | None:
    if "<Project" in text and ("ProjectView>ShowAllFiles" in text or "<StartProgram>" in text):
        return ("recovered_editor_sidecar_candidates", "script/logic.luaproj.user")
    return None


def detect_qhdz_variant(text: str) -> tuple[str, str, str] | None:
    if 'Type="TaharezLook/FrameWindowqhdz"' in text:
        return (
            "recovered_layout_path_candidates",
            "ui/layouts/framewindowqhdz.variant.layout",
            "medium",
        )
    return None


def detect_actionset(text: str) -> tuple[str, str, str] | None:
    actions = re.findall(r'<action\s+name="([^"]+)"', text)
    if actions:
        action_key = ",".join(sorted(actions))
        return ("recovered_actionset_candidates", f"xml/{action_key}.xml", "medium")
    return None


def classify_map_record(text: str) -> tuple[str, str, str] | None:
    record_ids = re.findall(r'<record\s+id="(\d+)"', text)
    if not record_ids:
        return None
    prefixes = sorted({rid[:3] for rid in record_ids if len(rid) >= 3})
    if all(rid.startswith("250") for rid in record_ids):
        return ("recovered_map_record_candidates", "series_250xxx", "medium")
    if all(rid.startswith("254") for rid in record_ids):
        return ("recovered_map_record_candidates", "series_254xxx", "medium")
    if all(rid.startswith("255") for rid in record_ids):
        return ("recovered_map_record_candidates", "series_255xxx", "medium")
    return ("recovered_map_record_candidates", "mixed_record_groups", "low")


def main() -> int:
    parser = argparse.ArgumentParser(description="把 unresolved 中有明确语义锚点的 lua/xml 提升为候选目录")
    parser.add_argument("--unresolved-root", required=True, help="review/unresolved 根目录")
    parser.add_argument("--review-root", required=True, help="review 根目录")
    parser.add_argument("--report-dir", required=True, help="报告输出目录")
    args = parser.parse_args()

    unresolved_root = Path(args.unresolved_root)
    review_root = Path(args.review_root)
    report_dir = Path(args.report_dir)
    report_dir.mkdir(parents=True, exist_ok=True)

    moved_rows: list[dict[str, object]] = []

    # Lua candidates
    for path in sorted((unresolved_root / "lua").glob("*.lua")):
        text = read_text_auto(path)
        symbol = detect_script_symbol(text)
        if symbol is None:
            continue
        bucket, rel_path, confidence = SCRIPT_CANDIDATES[symbol]
        dest = review_root / bucket / rel_path
        actual = safe_move(path, dest)
        moved_rows.append(
            {
                "source_rel": str(path.relative_to(review_root)).replace("\\", "/"),
                "category": bucket,
                "candidate_rel": rel_path,
                "confidence": confidence,
                "evidence": f"top_level_symbol={symbol}",
                "actual_path": str(actual),
            }
        )

    # XML candidates
    for path in sorted((unresolved_root / "xml").glob("*.xml")):
        text = read_text_auto(path)

        layout_root = detect_layout_root(text)
        if layout_root is not None:
            bucket, rel_path, confidence = LAYOUT_CANDIDATES[layout_root]
            dest = review_root / bucket / rel_path
            actual = safe_move(path, dest)
            moved_rows.append(
                {
                    "source_rel": str(path.relative_to(review_root)).replace("\\", "/"),
                    "category": bucket,
                    "candidate_rel": rel_path,
                    "confidence": confidence,
                    "evidence": f"layout_root_name={layout_root}",
                    "actual_path": str(actual),
                }
            )
            continue

        sidecar = detect_editor_sidecar(text)
        if sidecar is not None:
            bucket, rel_path = sidecar
            dest = review_root / bucket / rel_path
            actual = safe_move(path, dest)
            moved_rows.append(
                {
                    "source_rel": str(path.relative_to(review_root)).replace("\\", "/"),
                    "category": bucket,
                    "candidate_rel": rel_path,
                    "confidence": "medium",
                    "evidence": "xml_project_sidecar",
                    "actual_path": str(actual),
                }
            )
            continue

        qhdz_variant = detect_qhdz_variant(text)
        if qhdz_variant is not None:
            bucket, rel_path, confidence = qhdz_variant
            dest = review_root / bucket / rel_path
            actual = safe_move(path, dest)
            moved_rows.append(
                {
                    "source_rel": str(path.relative_to(review_root)).replace("\\", "/"),
                    "category": bucket,
                    "candidate_rel": rel_path,
                    "confidence": confidence,
                    "evidence": "window_type=FrameWindowqhdz",
                    "actual_path": str(actual),
                }
            )
            continue

        actionset = detect_actionset(text)
        if actionset is not None:
            bucket, rel_path, confidence = actionset
            dest = review_root / bucket / path.name
            actual = safe_move(path, dest)
            moved_rows.append(
                {
                    "source_rel": str(path.relative_to(review_root)).replace("\\", "/"),
                    "category": bucket,
                    "candidate_rel": rel_path,
                    "confidence": confidence,
                    "evidence": "action_name_list",
                    "actual_path": str(actual),
                }
            )
            continue

        map_group = classify_map_record(text)
        if map_group is not None:
            bucket, rel_group, confidence = map_group
            dest = review_root / bucket / rel_group / path.name
            actual = safe_move(path, dest)
            record_ids = re.findall(r'<record\s+id="(\d+)"', text)
            moved_rows.append(
                {
                    "source_rel": str(path.relative_to(review_root)).replace("\\", "/"),
                    "category": bucket,
                    "candidate_rel": f"{rel_group}/{path.name}",
                    "confidence": confidence,
                    "evidence": f"record_ids={','.join(record_ids[:8])}",
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
        report_dir / "semantic_candidate_promotions.csv",
        ["source_rel", "category", "candidate_rel", "confidence", "evidence", "actual_path"],
        moved_rows,
    )
    (report_dir / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    (report_dir / "README.md").write_text(
        "\n".join(
            [
                "# unresolved 语义候选提升",
                "",
                f"- 提升条目数: {len(moved_rows)}",
                "",
                "分类：",
                "- `recovered_script_path_candidates`：脚本类名/模块名可稳定锚定目标路径",
                "- `recovered_layout_path_candidates`：布局根窗口名可稳定锚定目标 layout 路径",
                "- `recovered_editor_sidecar_candidates`：编辑器/工程侧边 XML",
                "- `recovered_actionset_candidates`：动作集合 XML",
                "- `recovered_map_record_candidates`：地图 record 配置 XML",
            ]
        )
        + "\n",
        encoding="utf-8",
    )

    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

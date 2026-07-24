#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import shutil
from collections import defaultdict
from pathlib import Path


PNG_MAGIC = b"\x89PNG\r\n\x1a\n"


def sha1_bytes(path: Path) -> str:
    h = hashlib.sha1()
    with path.open("rb") as fp:
        for chunk in iter(lambda: fp.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def is_json_like(data: bytes) -> bool:
    stripped = data.lstrip()
    return stripped.startswith(b"{") or stripped.startswith(b"[")


def is_png_like(data: bytes) -> bool:
    return data.startswith(PNG_MAGIC)


def is_ani_like(data: bytes) -> bool:
    if len(data) < 16:
        return False
    a = int.from_bytes(data[0:4], "little", signed=False)
    b = int.from_bytes(data[4:8], "little", signed=False)
    c = int.from_bytes(data[8:12], "little", signed=False)
    return 0 < a < 512 and 0 < b < 32 and 0 < c < 512


def is_binary_dat_candidate(data: bytes) -> bool:
    if is_json_like(data) or is_png_like(data):
        return False
    if data.startswith(b"QUYU") or data.startswith(b"DYEP"):
        return True
    if len(data) >= 16:
        return True
    return False


def detect_content_kind(data: bytes) -> str:
    if is_json_like(data):
        return "json_text"
    if is_png_like(data):
        return "png"
    if is_ani_like(data):
        return "ani_or_act_like"
    if data.startswith(b"QUYU"):
        return "quyu_bin"
    if data.startswith(b"DYEP"):
        return "dyeinfo"
    if data.startswith(b"\xff\xfe<\x00d\x00a\x00t\x00a\x00"):
        return "utf16_xml"
    return "binary_other"


def classify_skip_relation(unresolved_suffix: str, resolved_rel: str, data: bytes) -> tuple[str, str]:
    unresolved_suffix = unresolved_suffix.lower()
    resolved_suffix = Path(resolved_rel).suffix.lower()
    kind = detect_content_kind(data)

    if unresolved_suffix == "" and resolved_suffix in {".dye", ".act"}:
        return (
            "extensionless_alias_existing",
            f"源文件是无扩展别名，内容类型为 {kind}，而主树中已存在带正确扩展名的二进制资源。",
        )

    if unresolved_suffix == ".xml" and resolved_suffix == ".user" and kind in {"json_text", "utf16_xml", "binary_other"}:
        stripped = data.lstrip()
        if stripped.startswith(b"\xef\xbb\xbf<?xml") or stripped.startswith(b"<?xml"):
            return (
                "editor_sidecar_alias_existing",
                "源文件是 XML 文本，但唯一命中到编辑器/工程侧边配置 `.user` 文件，不属于运行时资源树回流对象。",
            )

    return ("suffix_not_allowed", "当前规则不允许把该源扩展直接提升为主资源树修正。")


def should_integrate(unresolved_suffix: str, resolved_rel: str, data: bytes) -> tuple[bool, str]:
    unresolved_suffix = unresolved_suffix.lower()
    resolved_suffix = Path(resolved_rel).suffix.lower()

    if unresolved_suffix == ".json":
        if is_json_like(data):
            return True, "json_text_detected"
        return False, "json_not_detected"

    if unresolved_suffix == ".png":
        if is_png_like(data):
            return True, "png_magic_detected"
        return False, "png_magic_missing"

    if unresolved_suffix == ".ani":
        if is_ani_like(data):
            return True, "ani_header_detected"
        return False, "ani_header_missing"

    if unresolved_suffix == ".dat":
        if resolved_suffix in {".jpg", ".jpeg", ".dds"} and is_binary_dat_candidate(data):
            return True, "binary_payload_prefers_dat"
        return False, "dat_rule_not_met"

    if unresolved_suffix == ".xml":
        if resolved_rel.startswith("map/") and resolved_suffix == ".dat":
            return True, "map_dat_xml_readable_copy"
        return False, "xml_rule_not_met"

    return False, "suffix_not_allowed"


def copy_if_missing(src: Path, dst: Path) -> tuple[bool, str]:
    ensure_parent(dst)
    if dst.exists():
        if sha1_bytes(src) == sha1_bytes(dst):
            return False, "already_same"
        return False, "exists_conflict"
    shutil.copy2(src, dst)
    return True, "copied"


def classify_existing_relation(
    resolved_rel: str,
    corrected_rel: str,
    src: Path,
    dst: Path,
) -> tuple[str, str, str, str]:
    src_data = src.read_bytes()[:256]
    dst_data = dst.read_bytes()[:256]
    src_kind = detect_content_kind(src_data)
    dst_kind = detect_content_kind(dst_data)
    resolved_suffix = Path(resolved_rel).suffix.lower()
    corrected_suffix = Path(corrected_rel).suffix.lower()

    if (
        resolved_suffix == ".pngpart"
        and corrected_suffix == ".png"
        and src_kind == "png"
        and dst_kind == "png"
    ):
        return (
            "coexist_sidecar_pngpart",
            "源文件是 PNG 内容的 .pngpart 侧车，目标 .png 已存在且内容不同，应保留双轨共存。",
            src_kind,
            dst_kind,
        )

    return (
        "exists_conflict",
        "目标路径已存在不同内容，当前规则不足以自动裁决。",
        src_kind,
        dst_kind,
    )


def write_csv(path: Path, fieldnames: list[str], rows: list[dict[str, object]]) -> None:
    ensure_parent(path)
    with path.open("w", encoding="utf-8-sig", newline="") as fp:
        writer = csv.DictWriter(fp, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser(description="把强信号扩展修正整合进 unpacked_res / dev_res")
    parser.add_argument("--report-csv", required=True, help="unique_exact_matches.csv 路径")
    parser.add_argument("--unpacked-root", required=True, help="unpacked_res 根目录")
    parser.add_argument("--dev-root", required=True, help="dev_res 根目录")
    parser.add_argument("--report-dir", required=True, help="报告输出目录")
    args = parser.parse_args()

    report_csv = Path(args.report_csv)
    unpacked_root = Path(args.unpacked_root)
    dev_root = Path(args.dev_root)
    report_dir = Path(args.report_dir)
    report_dir.mkdir(parents=True, exist_ok=True)

    dedup: dict[tuple[str, str], dict[str, object]] = {}
    skipped_rows: list[dict[str, object]] = []

    with report_csv.open("r", encoding="utf-8-sig", newline="") as fp:
        for row in csv.DictReader(fp):
            if row["same_suffix"] == "true":
                continue
            resolved_rel = row["resolved_match_rel"].replace("\\", "/")
            unresolved_suffix = row["unresolved_suffix"].lower()
            src = Path(row["resolved_match_path"])
            data = src.read_bytes()[:256]
            ok, reason = should_integrate(unresolved_suffix, resolved_rel, data)
            if not ok:
                skipped = dict(row)
                skip_reason, skip_note = classify_skip_relation(unresolved_suffix, resolved_rel, data)
                skipped["skip_reason"] = skip_reason if skip_reason != "suffix_not_allowed" else reason
                skipped["skip_note"] = skip_note
                skipped["source_kind"] = detect_content_kind(data)
                skipped_rows.append(skipped)
                continue

            corrected_rel = str(Path(resolved_rel).with_suffix(unresolved_suffix)).replace("\\", "/")
            key = (resolved_rel, corrected_rel)
            info = dedup.setdefault(
                key,
                {
                    "resolved_rel": resolved_rel,
                    "corrected_rel": corrected_rel,
                    "resolved_match_path": row["resolved_match_path"],
                    "unresolved_suffix": unresolved_suffix,
                    "resolved_suffix": row["resolved_suffix"],
                    "source_unresolved_rows": [],
                    "decision_reason": reason,
                },
            )
            info["source_unresolved_rows"].append(row["unresolved_rel"])

    applied_rows: list[dict[str, object]] = []
    for info in dedup.values():
        src = Path(info["resolved_match_path"])
        unpacked_target = unpacked_root / info["corrected_rel"]
        dev_target = dev_root / info["corrected_rel"]
        unpacked_changed, unpacked_status = copy_if_missing(src, unpacked_target)
        dev_changed, dev_status = copy_if_missing(src, dev_target)
        relation_note = ""
        source_kind = ""
        target_kind = ""
        if unpacked_status == "exists_conflict" and unpacked_target.exists():
            unpacked_status, relation_note, source_kind, target_kind = classify_existing_relation(
                info["resolved_rel"],
                info["corrected_rel"],
                src,
                unpacked_target,
            )
        if dev_status == "exists_conflict" and dev_target.exists():
            dev_status, dev_relation_note, dev_source_kind, dev_target_kind = classify_existing_relation(
                info["resolved_rel"],
                info["corrected_rel"],
                src,
                dev_target,
            )
            if not relation_note:
                relation_note = dev_relation_note
                source_kind = dev_source_kind
                target_kind = dev_target_kind
        applied_rows.append(
            {
                "resolved_rel": info["resolved_rel"],
                "corrected_rel": info["corrected_rel"],
                "resolved_suffix": info["resolved_suffix"],
                "corrected_suffix": info["unresolved_suffix"],
                "decision_reason": info["decision_reason"],
                "source_kind": source_kind,
                "target_kind": target_kind,
                "relation_note": relation_note,
                "source_unresolved_count": len(info["source_unresolved_rows"]),
                "source_unresolved_rows": ";".join(sorted(info["source_unresolved_rows"])),
                "unpacked_status": unpacked_status,
                "dev_status": dev_status,
                "unpacked_target": str(unpacked_target),
                "dev_target": str(dev_target),
            }
        )

    summary = {
        "report_csv": str(report_csv),
        "unpacked_root": str(unpacked_root),
        "dev_root": str(dev_root),
        "candidate_count": len(dedup),
        "applied_count_unpacked": sum(1 for row in applied_rows if row["unpacked_status"] == "copied"),
        "applied_count_dev": sum(1 for row in applied_rows if row["dev_status"] == "copied"),
        "coexist_sidecar_count": sum(1 for row in applied_rows if row["unpacked_status"] == "coexist_sidecar_pngpart"),
        "exists_conflict_count": sum(1 for row in applied_rows if row["unpacked_status"] == "exists_conflict"),
        "skipped_count": len(skipped_rows),
    }

    write_csv(
        report_dir / "applied_extension_corrections.csv",
        [
            "resolved_rel",
            "corrected_rel",
            "resolved_suffix",
            "corrected_suffix",
            "decision_reason",
            "source_kind",
            "target_kind",
            "relation_note",
            "source_unresolved_count",
            "source_unresolved_rows",
            "unpacked_status",
            "dev_status",
            "unpacked_target",
            "dev_target",
        ],
        sorted(applied_rows, key=lambda row: row["corrected_rel"]),
    )
    write_csv(
        report_dir / "skipped_extension_corrections.csv",
        [
            "unresolved_rel",
            "resolved_match_rel",
            "unresolved_suffix",
            "resolved_suffix",
            "skip_reason",
            "source_kind",
            "skip_note",
        ],
        [
            {
                "unresolved_rel": row["unresolved_rel"],
                "resolved_match_rel": row["resolved_match_rel"],
                "unresolved_suffix": row["unresolved_suffix"],
                "resolved_suffix": row["resolved_suffix"],
                "skip_reason": row["skip_reason"],
                "source_kind": row.get("source_kind", ""),
                "skip_note": row.get("skip_note", ""),
            }
            for row in skipped_rows
        ],
    )
    (report_dir / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    (report_dir / "README.md").write_text(
        "\n".join(
            [
                "# 强信号扩展修正",
                "",
                f"- 候选修正路径数: {len(dedup)}",
                f"- 已写入 unpacked_res 的数量: {summary['applied_count_unpacked']}",
                f"- 已写入 dev_res 的数量: {summary['applied_count_dev']}",
                f"- `.pngpart` 侧车共存数量: {summary['coexist_sidecar_count']}",
                f"- 仍需人工裁决的真实冲突数量: {summary['exists_conflict_count']}",
                f"- 跳过数量: {len(skipped_rows)}",
                "",
                "规则：",
                "- `.json` 需要内容是 JSON 文本。",
                "- `.png` 需要内容命中 PNG 魔数。",
                "- `.ani` 需要命中 ANI 头特征。",
                "- `.dat` 仅接受当前误落到 `.jpg/.jpeg/.dds` 的二进制块。",
                "- `.xml` 仅为地图 `.dat` 生成辅助可读副本。",
                "- 若 `.pngpart -> .png` 且两侧都是不同 PNG 内容，则按 `coexist_sidecar_pngpart` 处理，保留双轨资源。",
            ]
        )
        + "\n",
        encoding="utf-8",
    )

    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

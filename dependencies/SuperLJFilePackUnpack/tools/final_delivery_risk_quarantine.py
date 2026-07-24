from __future__ import annotations

import argparse
import csv
import json
import shutil
from pathlib import Path, PurePosixPath
from typing import Iterable


QUARANTINE_BUCKETS = {
    "mapping_seed_suspect",
    "animation_path_contains_image_payload",
    "source_asset_payload_mismatch",
    "manual_type_mapping_review",
}

QUARANTINE_PREFIX = "review/high_risk_type_mismatch_candidates"


def normalize_relative_path(value: str | None) -> str:
    return (value or "").replace("\\", "/").strip().lstrip("/")


def load_tsv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def write_tsv(path: Path, fieldnames: Iterable[str], rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(fieldnames), delimiter="\t")
        writer.writeheader()
        for row in rows:
            writer.writerow(row)


def write_json(path: Path, payload: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def is_quarantinable(row: dict[str, str]) -> bool:
    return (row.get("action_bucket") or "").strip() in QUARANTINE_BUCKETS


def build_quarantine_relative(row: dict[str, str]) -> str:
    bucket = (row.get("action_bucket") or "manual_type_mapping_review").strip()
    crc = (row.get("path_crc32") or "unknown").strip()
    rel = normalize_relative_path(
        row.get("actual_relative_path") or row.get("final_relative_path") or crc
    )
    return normalize_relative_path(f"{QUARANTINE_PREFIX}/{bucket}/{crc}/{rel}")


def tree_path(root: Path, relative_path: str) -> Path:
    return root / Path(*normalize_relative_path(relative_path).split("/"))


def move_file(src: Path, dst: Path, *, apply: bool) -> str:
    if not src.is_file():
        return "missing_source"
    if dst.exists():
        return "target_exists"
    if not apply:
        return "dry_run"
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(str(src), str(dst))
    return "moved"


def update_manifest_rows(
    manifest_path: Path,
    quarantine_by_crc: dict[str, str],
    *,
    apply: bool,
) -> tuple[int, list[dict[str, str]]]:
    if not manifest_path.is_file():
        return 0, []

    with manifest_path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        fieldnames = list(reader.fieldnames or [])
        rows = list(reader)

    updated = 0
    for row in rows:
        crc = (row.get("path_crc32") or "").upper()
        if crc not in quarantine_by_crc:
            continue
        quarantine_rel = quarantine_by_crc[crc]
        row["final_relative_path"] = quarantine_rel
        row["actual_relative_path"] = quarantine_rel
        row["physical_path_status"] = "high_risk_quarantined"
        flags = [part for part in (row.get("flags") or "").split(",") if part]
        for flag in ("review_bucketed", "high_risk_quarantined"):
            if flag not in flags:
                flags.append(flag)
        row["flags"] = ",".join(flags)
        updated += 1

    if apply and updated > 0:
        write_tsv(manifest_path, fieldnames, rows)

    return updated, rows


def apply_quarantine(
    *,
    high_risk_tsv: Path,
    unpacked_root: Path,
    dev_root: Path,
    manifest_path: Path,
    report_dir: Path,
    dev_quarantine_root: Path,
    stamp: str,
    apply: bool,
) -> dict[str, object]:
    rows = load_tsv(high_risk_tsv)
    plan_rows: list[dict[str, object]] = []
    quarantine_by_crc: dict[str, str] = {}
    quarantined = 0
    retained = 0

    for row in rows:
        actual_rel = normalize_relative_path(
            row.get("actual_relative_path") or row.get("final_relative_path")
        )
        quarantine_rel = build_quarantine_relative(row)
        should_quarantine = is_quarantinable(row)
        if should_quarantine:
            quarantined += 1
            quarantine_by_crc[(row.get("path_crc32") or "").upper()] = quarantine_rel
        else:
            retained += 1

        unpacked_status = "retained"
        dev_status = "retained"
        if should_quarantine:
            unpacked_status = move_file(
                tree_path(unpacked_root, actual_rel),
                tree_path(unpacked_root, quarantine_rel),
                apply=apply,
            )
            dev_status = move_file(
                tree_path(dev_root, actual_rel),
                tree_path(dev_quarantine_root, actual_rel),
                apply=apply,
            )

        plan = dict(row)
        plan.update(
            {
                "quarantine": str(should_quarantine).lower(),
                "quarantine_relative_path": quarantine_rel if should_quarantine else "",
                "unpacked_action_status": unpacked_status,
                "dev_action_status": dev_status,
            }
        )
        plan_rows.append(plan)

    manifest_updates, _ = update_manifest_rows(
        manifest_path,
        quarantine_by_crc,
        apply=apply,
    )

    report_dir.mkdir(parents=True, exist_ok=True)
    plan_fields = list(plan_rows[0].keys()) if plan_rows else []
    if plan_rows:
        write_tsv(report_dir / "high_risk_quarantine_plan.tsv", plan_fields, plan_rows)

    summary = {
        "version": 1,
        "stamp": stamp,
        "apply": apply,
        "high_risk_records": len(rows),
        "quarantined_records": quarantined,
        "retained_records": retained,
        "manifest_updates": manifest_updates,
        "high_risk_tsv": str(high_risk_tsv),
        "unpacked_root": str(unpacked_root),
        "dev_root": str(dev_root),
        "dev_quarantine_root": str(dev_quarantine_root),
        "report_dir": str(report_dir),
        "quarantine_buckets": sorted(QUARANTINE_BUCKETS),
    }
    write_json(report_dir / "high_risk_quarantine_summary.json", summary)
    readme = [
        "# high risk quarantine",
        "",
        f"- stamp: `{stamp}`",
        f"- apply: `{str(apply).lower()}`",
        f"- quarantined_records: `{quarantined}`",
        f"- retained_records: `{retained}`",
        "",
        "Only deterministic path/payload conflicts are quarantined. "
        "Image paths without a generic signature are retained for renderer probing.",
        "",
    ]
    (report_dir / "README.md").write_text("\n".join(readme), encoding="utf-8", newline="\n")
    return summary


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Quarantine deterministic high-risk delivery path/type mismatches."
    )
    parser.add_argument("--high-risk-tsv", required=True, type=Path)
    parser.add_argument("--unpacked-root", required=True, type=Path)
    parser.add_argument("--dev-root", required=True, type=Path)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--report-dir", required=True, type=Path)
    parser.add_argument("--dev-quarantine-root", required=True, type=Path)
    parser.add_argument("--stamp", required=True)
    parser.add_argument("--apply", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    summary = apply_quarantine(
        high_risk_tsv=args.high_risk_tsv,
        unpacked_root=args.unpacked_root,
        dev_root=args.dev_root,
        manifest_path=args.manifest,
        report_dir=args.report_dir,
        dev_quarantine_root=args.dev_quarantine_root,
        stamp=args.stamp,
        apply=args.apply,
    )
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

from __future__ import annotations

import argparse
import csv
import hashlib
import json
from collections import Counter
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Iterable, Sequence


NONE_EXT = "<none>"

XML_DOMAIN_EXTENSIONS = {
    ".font",
    ".imageset",
    ".inf",
    ".layout",
    ".lmx",
    ".looknfeel",
    ".luaproj",
    ".mps",
    ".audio",
    ".config",
    ".plist",
    ".scheme",
    ".user",
    ".xsd",
}

XML_PAYLOAD_ALIAS_EXTENSIONS = {
    ".dat",
    ".set",
}

PRIVATE_BINARY_NO_SIGNATURE_EXTENSIONS = {
    ".act",
    ".ani",
    ".bin",
    ".cfb",
    ".dat",
    ".dis",
    ".dye",
    ".lko",
    ".lst",
    ".mrmp",
    ".patch",
    ".path",
    ".ptc",
    ".rmp",
    ".set",
}

IMAGE_EXTENSIONS = {
    ".cur",
    ".dds",
    ".img",
    ".jpeg",
    ".jpg",
    ".png",
    ".psd",
    ".tga",
    ".webp",
}

RUNTIME_LOADABLE_IMAGE_EXTENSIONS = {
    ".dds",
    ".jpeg",
    ".jpg",
    ".png",
    ".tga",
    ".webp",
}

TEXT_EXTENSIONS = {
    ".ini",
    ".json",
    ".lua",
    ".txt",
}

TEXT_PROJECT_EXTENSIONS = {
    ".sln",
}

MEDIA_CONTAINER_EXTENSIONS = {
    ".mp4",
    ".wmv",
}


@dataclass(frozen=True)
class Classification:
    classification: str
    severity: str
    reason: str
    recommended_action: str
    final_extension: str
    detected_extension: str
    is_mismatch: bool


@dataclass(frozen=True)
class ReferenceEvidence:
    status: str
    root: str
    relative_path: str


@dataclass(frozen=True)
class ActionPlan:
    action_bucket: str
    action_priority: str
    evidence_needed: str
    suggested_next_step: str


def normalize_relative_path(value: str | None) -> str:
    return (value or "").replace("\\", "/").strip().lstrip("/")


def normalize_extension(value: str | None) -> str:
    cleaned = (value or "").strip().lower()
    if not cleaned or cleaned == NONE_EXT:
        return NONE_EXT
    if not cleaned.startswith("."):
        return "." + cleaned
    return cleaned


def path_extension(relative_path: str | None) -> str:
    suffix = PurePosixPath(normalize_relative_path(relative_path)).suffix.lower()
    return suffix or NONE_EXT


def parse_bool(value: str | None) -> bool:
    return (value or "").strip().lower() in {"1", "true", "yes", "y"}


def parse_int(value: str | None) -> int:
    try:
        return int((value or "").strip())
    except ValueError:
        return 0


def is_review_unresolved(path: str) -> bool:
    return path.lower().startswith("review/unresolved/")


def is_review_high_risk_quarantine(path: str) -> bool:
    return path.lower().startswith("review/high_risk_type_mismatch_candidates/")


def is_map_element_path(path: str) -> bool:
    return path.lower().startswith("map/elements/")


def is_loading_tga_path(path: str) -> bool:
    return path.lower().startswith("image/loading/")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def probe_reference_evidence(
    *,
    output_root: Path,
    relative_path: str,
    reference_roots: Sequence[Path],
) -> ReferenceEvidence:
    if not reference_roots:
        return ReferenceEvidence("not_checked", "", "")

    normalized = normalize_relative_path(relative_path)
    output_path = output_root / Path(*normalized.split("/"))
    best_status = "reference_missing"
    best_root = ""

    if not output_path.is_file():
        return ReferenceEvidence("output_missing_for_reference_probe", "", normalized)

    output_size = output_path.stat().st_size
    output_hash = ""

    for root in reference_roots:
        candidate = root / Path(*normalized.split("/"))
        if not candidate.is_file():
            continue

        best_root = str(root)
        if candidate.stat().st_size != output_size:
            best_status = "reference_size_mismatch"
            continue

        if not output_hash:
            output_hash = sha256_file(output_path)
        if sha256_file(candidate) == output_hash:
            return ReferenceEvidence("reference_exact_match", str(root), normalized)
        best_status = "reference_hash_mismatch"

    return ReferenceEvidence(best_status, best_root, normalized)


def apply_reference_evidence(
    classification: Classification,
    evidence: ReferenceEvidence,
) -> Classification:
    if evidence.status != "reference_exact_match":
        return classification
    if classification.severity not in {"high", "medium"}:
        return classification

    return Classification(
        "expected_reference_tree_exact_alias",
        "low",
        "same path and byte-identical payload exists in a reference resource tree",
        "keep the manifest path; treat the detector mismatch as a source-tree quirk unless runtime load fails",
        classification.final_extension,
        classification.detected_extension,
        classification.is_mismatch,
    )


def classify_row(row: dict[str, str]) -> Classification:
    final_path = normalize_relative_path(
        row.get("final_relative_path") or row.get("actual_relative_path")
    )
    actual_path = normalize_relative_path(row.get("actual_relative_path") or final_path)
    final_ext = path_extension(final_path)
    detected_ext = normalize_extension(row.get("detected_extension"))
    extension_consistent = parse_bool(row.get("extension_consistent"))
    physical_exists = parse_bool(row.get("physical_exists"))
    physical_size = parse_int(row.get("physical_size"))
    probe_path = actual_path or final_path

    if not physical_exists:
        return Classification(
            "physical_missing",
            "error",
            "manifest row does not have a matching physical file",
            "recover or remove the stale manifest path before judging type consistency",
            final_ext,
            detected_ext,
            True,
        )

    if extension_consistent:
        return Classification(
            "consistent",
            "ok",
            "final path extension matches the detected payload type",
            "no action required",
            final_ext,
            detected_ext,
            False,
        )

    if is_review_unresolved(probe_path):
        return Classification(
            "review_unresolved_type_probe",
            "review",
            "file is still in review/unresolved, so the detected type is only a triage hint",
            "resolve the name/path first, then re-check extension consistency",
            final_ext,
            detected_ext,
            True,
        )

    if is_review_high_risk_quarantine(probe_path):
        return Classification(
            "review_high_risk_quarantined",
            "review",
            "file was removed from the delivery path and isolated for manual review",
            "keep it out of dev_res until the path seed or payload type is proven",
            final_ext,
            detected_ext,
            True,
        )

    if final_ext in XML_DOMAIN_EXTENSIONS and detected_ext == ".xml":
        return Classification(
            "expected_xml_domain_alias",
            "low",
            "domain-specific extension stores XML payload",
            "keep the domain extension; no data loss indicated",
            final_ext,
            detected_ext,
            True,
        )

    if final_ext in XML_PAYLOAD_ALIAS_EXTENSIONS and detected_ext == ".xml":
        return Classification(
            "expected_xml_payload_alias",
            "low",
            "legacy resource keeps a non-XML extension for XML payload",
            "keep the manifest path unless runtime lookup proves a rename is required",
            final_ext,
            detected_ext,
            True,
        )

    if final_ext == ".pngpart" and detected_ext == ".png":
        return Classification(
            "expected_payload_alias",
            "low",
            "pngpart stores a PNG payload while preserving packer/runtime naming",
            "keep pngpart as the primary name and use detected type as metadata",
            final_ext,
            detected_ext,
            True,
        )

    if final_ext == NONE_EXT and is_map_element_path(probe_path) and detected_ext in IMAGE_EXTENSIONS:
        return Classification(
            "expected_extensionless_map_asset",
            "low",
            "map element assets are referenced without a file extension",
            "keep the extensionless runtime path and record detected type for review",
            final_ext,
            detected_ext,
            True,
        )

    if final_ext in PRIVATE_BINARY_NO_SIGNATURE_EXTENSIONS and detected_ext == NONE_EXT:
        return Classification(
            "expected_private_binary_no_signature",
            "low",
            "private binary format has no generic file signature",
            "treat as type-consistent unless a schema parser reports corruption",
            final_ext,
            detected_ext,
            True,
        )

    if final_ext == ".set" and detected_ext == ".img":
        return Classification(
            "expected_img_payload_alias",
            "low",
            "map set metadata points at IMG-style payload data",
            "keep the manifest extension and validate through map loader semantics",
            final_ext,
            detected_ext,
            True,
        )

    if final_ext == ".tga" and (detected_ext == ".cur" or (detected_ext == NONE_EXT and is_loading_tga_path(probe_path))):
        return Classification(
            "expected_runtime_tga_payload_alias",
            "low",
            "runtime renderer treats this legacy TGA-family payload by header, while the generic detector cannot name it precisely",
            "keep the manifest path and validate visually only if the loader reports a texture failure",
            final_ext,
            detected_ext,
            True,
        )

    if final_ext in RUNTIME_LOADABLE_IMAGE_EXTENSIONS and detected_ext in RUNTIME_LOADABLE_IMAGE_EXTENSIONS:
        return Classification(
            "expected_runtime_image_payload_alias",
            "low",
            "renderer detects the actual in-memory image format, so the runtime path extension is an alias rather than data loss",
            "keep the runtime path and use detected type as audit metadata",
            final_ext,
            detected_ext,
            True,
        )

    if final_ext in TEXT_PROJECT_EXTENSIONS and detected_ext == ".luaproj":
        return Classification(
            "expected_text_project_alias",
            "low",
            "project metadata is text and shares the Lua-project text detector signature",
            "keep the project file extension",
            final_ext,
            detected_ext,
            True,
        )

    if final_ext in MEDIA_CONTAINER_EXTENSIONS and detected_ext == NONE_EXT:
        return Classification(
            "expected_media_container_alias",
            "low",
            "media container formats are not part of the generic resource detector table",
            "keep the media extension and validate with a media probe if playback fails",
            final_ext,
            detected_ext,
            True,
        )

    if final_ext == ".lua" and detected_ext == NONE_EXT and physical_size <= 64:
        return Classification(
            "expected_empty_text_script",
            "low",
            "short or whitespace-only Lua files can evade text-type heuristics",
            "keep the .lua path; no payload recovery is required",
            final_ext,
            detected_ext,
            True,
        )

    if final_ext == ".lua" and detected_ext == ".txt":
        return Classification(
            "expected_text_script_alias",
            "low",
            "Lua source may be detected as generic text when syntax probes are inconclusive",
            "keep the .lua path and verify with script parser only if runtime load fails",
            final_ext,
            detected_ext,
            True,
        )

    if final_ext in TEXT_EXTENSIONS and detected_ext in TEXT_EXTENSIONS:
        return Classification(
            "expected_text_payload_alias",
            "low",
            "text-like formats share generic text signatures",
            "keep the manifest path and use content parser for deeper validation",
            final_ext,
            detected_ext,
            True,
        )

    if final_ext == NONE_EXT and detected_ext != NONE_EXT:
        return Classification(
            "extensionless_detected_payload",
            "medium",
            "payload type is detectable but runtime path has no extension",
            "check loader references before adding a sidecar extension",
            final_ext,
            detected_ext,
            True,
        )

    if final_ext in IMAGE_EXTENSIONS and detected_ext in IMAGE_EXTENSIONS and final_ext != detected_ext:
        return Classification(
            "true_extension_mismatch",
            "high",
            "image-like payload signature is not in the runtime-supported image alias set",
            "prioritize manual review and mapping-seed validation",
            final_ext,
            detected_ext,
            True,
        )

    return Classification(
        "true_extension_mismatch",
        "high",
        "detected payload type is not an expected alias for the manifest extension",
        "prioritize manual review and mapping-seed validation",
        final_ext,
        detected_ext,
        True,
    )


def build_action_plan(row: dict[str, object]) -> ActionPlan:
    classification = str(row.get("classification", ""))
    severity = str(row.get("severity", ""))
    final_ext = str(row.get("final_extension", ""))
    detected_ext = str(row.get("detected_extension", ""))

    if severity in {"ok", "low"}:
        return ActionPlan("", "", "", "")

    if classification == "physical_missing":
        return ActionPlan(
            "recover_or_remove_stale_manifest_path",
            "P0",
            "manifest row, physical tree, and unpack log for the same path_crc32",
            "restore the physical payload or remove the stale manifest entry before judging type consistency",
        )

    if classification == "review_unresolved_type_probe":
        return ActionPlan(
            "recover_review_unresolved_path",
            "P2",
            "path CRC seed, source-template hit, exact-content alias, or runtime reference",
            "resolve the real name/path first, then re-run extension consistency classification",
        )

    if classification == "review_high_risk_quarantined":
        return ActionPlan(
            "manual_review_quarantined_payload",
            "P1",
            "path CRC seed, payload parser, and runtime/source references",
            "promote back only after the path and payload type are both proven",
        )

    if classification == "extensionless_detected_payload":
        return ActionPlan(
            "verify_extensionless_runtime_reference",
            "P1",
            "client reference, loader behavior, and source-tree comparison for the extensionless path",
            "keep extensionless if runtime/source references confirm it; otherwise add a sidecar rename candidate",
        )

    if final_ext == ".png" and detected_ext == ".psd":
        return ActionPlan(
            "source_asset_payload_mismatch",
            "P0",
            "spine atlas/json references, source tree comparison, and visual/tool loader probe",
            "validate whether this is an authoring PSD accidentally mapped to a runtime PNG path",
        )

    if final_ext == ".ani" and detected_ext in RUNTIME_LOADABLE_IMAGE_EXTENSIONS:
        return ActionPlan(
            "animation_path_contains_image_payload",
            "P0",
            "ANI model references, neighboring *_res files, and path CRC seed candidates",
            "treat as a likely path mapping collision and search for the matching texture path",
        )

    if final_ext in IMAGE_EXTENSIONS and detected_ext == NONE_EXT:
        return ActionPlan(
            "image_path_without_generic_signature",
            "P0",
            "reference tree match, renderer probe, and neighboring resource naming pattern",
            "confirm whether the payload is a private runtime image/container before renaming",
        )

    if final_ext in IMAGE_EXTENSIONS and detected_ext not in IMAGE_EXTENSIONS:
        return ActionPlan(
            "mapping_seed_suspect",
            "P0",
            "path CRC seed, same-directory siblings, and content parser for the detected payload type",
            "prioritize mapping-seed correction because an image path currently points at non-image content",
        )

    return ActionPlan(
        "manual_type_mapping_review",
        "P1" if severity == "medium" else "P0",
        "payload signature, path CRC seed, and runtime/source references",
        "manually validate whether the path or detected extension should be corrected",
    )


def read_manifest_rows(manifest_path: Path) -> Iterable[dict[str, str]]:
    with manifest_path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        for row in reader:
            yield dict(row)


def write_tsv(path: Path, rows: list[dict[str, object]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, delimiter="\t")
        writer.writeheader()
        for row in rows:
            writer.writerow(row)


def top_counter(counter: Counter[object], limit: int) -> list[dict[str, object]]:
    result: list[dict[str, object]] = []
    for key, count in counter.most_common(limit):
        if isinstance(key, tuple):
            final_extension, detected_extension = key
            result.append(
                {
                    "final_extension": final_extension,
                    "detected_extension": detected_extension,
                    "count": count,
                }
            )
        else:
            result.append({"name": key, "count": count})
    return result


def write_summary_md(path: Path, summary: dict[str, object]) -> None:
    classification_counts = summary.get("classification_counts", {})
    severity_counts = summary.get("severity_counts", {})
    top_pairs = summary.get("top_mismatch_pairs", [])
    high_pairs = summary.get("top_high_risk_pairs", [])

    lines = [
        "# extension mismatch classification",
        "",
        f"- manifest: `{summary.get('manifest', '')}`",
        f"- total_records: `{summary.get('total_records', 0)}`",
        f"- mismatch_records: `{summary.get('mismatch_records', 0)}`",
        f"- physical_missing_records: `{summary.get('physical_missing_records', 0)}`",
        f"- low_or_expected_records: `{summary.get('low_or_expected_records', 0)}`",
        f"- review_records: `{summary.get('review_records', 0)}`",
        f"- medium_records: `{summary.get('medium_records', 0)}`",
        f"- high_risk_records: `{summary.get('high_risk_records', 0)}`",
        "",
        "## Classification counts",
    ]
    for name, count in classification_counts.items():
        lines.append(f"- `{name}`: `{count}`")
    lines.extend(["", "## Severity counts"])
    for name, count in severity_counts.items():
        lines.append(f"- `{name}`: `{count}`")
    lines.extend(["", "## Top mismatch pairs"])
    for item in top_pairs:
        lines.append(
            f"- `{item['final_extension']}` -> `{item['detected_extension']}`: `{item['count']}`"
        )
    lines.extend(["", "## Top high risk pairs"])
    for item in high_pairs:
        lines.append(
            f"- `{item['final_extension']}` -> `{item['detected_extension']}`: `{item['count']}`"
        )
    lines.append("")
    path.write_text("\n".join(lines), encoding="utf-8", newline="\n")


def analyze_manifest(
    manifest_path: Path,
    output_dir: Path,
    *,
    top_limit: int = 30,
    reference_roots: Sequence[Path] | None = None,
) -> dict[str, object]:
    output_dir.mkdir(parents=True, exist_ok=True)
    checked_reference_roots = [root for root in (reference_roots or []) if root]

    detail_rows: list[dict[str, object]] = []
    classification_counts: Counter[str] = Counter()
    severity_counts: Counter[str] = Counter()
    mismatch_pairs: Counter[tuple[str, str]] = Counter()
    high_risk_pairs: Counter[tuple[str, str]] = Counter()
    total_records = 0
    mismatch_records = 0
    physical_missing_records = 0

    for row in read_manifest_rows(manifest_path):
        total_records += 1
        result = classify_row(row)
        reference_evidence = ReferenceEvidence("not_checked", "", "")
        if result.severity in {"high", "medium"} and checked_reference_roots:
            reference_evidence = probe_reference_evidence(
                output_root=manifest_path.parent,
                relative_path=normalize_relative_path(
                    row.get("actual_relative_path") or row.get("final_relative_path")
                ),
                reference_roots=checked_reference_roots,
            )
            result = apply_reference_evidence(result, reference_evidence)

        classification_counts[result.classification] += 1
        severity_counts[result.severity] += 1
        if result.is_mismatch:
            mismatch_records += 1
            mismatch_pairs[(result.final_extension, result.detected_extension)] += 1
        if result.classification == "physical_missing":
            physical_missing_records += 1
        if result.severity == "high":
            high_risk_pairs[(result.final_extension, result.detected_extension)] += 1

        detail_row: dict[str, object] = {
            "path_crc32": row.get("path_crc32", ""),
            "final_relative_path": normalize_relative_path(row.get("final_relative_path")),
            "actual_relative_path": normalize_relative_path(row.get("actual_relative_path")),
            "physical_path_status": row.get("physical_path_status", ""),
            "physical_exists": row.get("physical_exists", ""),
            "physical_size": row.get("physical_size", ""),
            "final_extension": result.final_extension,
            "detected_extension": result.detected_extension,
            "extension_consistent": row.get("extension_consistent", ""),
            "classification": result.classification,
            "severity": result.severity,
            "reason": result.reason,
            "recommended_action": result.recommended_action,
            "reference_match_status": reference_evidence.status,
            "reference_root": reference_evidence.root,
            "reference_relative_path": reference_evidence.relative_path,
            "flags": row.get("flags", ""),
        }
        action_plan = build_action_plan(detail_row)
        detail_row.update(
            {
                "action_bucket": action_plan.action_bucket,
                "action_priority": action_plan.action_priority,
                "evidence_needed": action_plan.evidence_needed,
                "suggested_next_step": action_plan.suggested_next_step,
            }
        )
        detail_rows.append(detail_row)

    summary: dict[str, object] = {
        "manifest": str(manifest_path),
        "total_records": total_records,
        "mismatch_records": mismatch_records,
        "consistent_records": classification_counts.get("consistent", 0),
        "physical_missing_records": physical_missing_records,
        "low_or_expected_records": severity_counts.get("low", 0),
        "review_records": severity_counts.get("review", 0),
        "medium_records": severity_counts.get("medium", 0),
        "high_risk_records": severity_counts.get("high", 0),
        "reference_roots": [str(root) for root in checked_reference_roots],
        "reference_exact_match_records": classification_counts.get(
            "expected_reference_tree_exact_alias", 0
        ),
        "classification_counts": dict(classification_counts),
        "severity_counts": dict(severity_counts),
        "top_mismatch_pairs": top_counter(mismatch_pairs, top_limit),
        "top_high_risk_pairs": top_counter(high_risk_pairs, top_limit),
    }

    detail_fieldnames = [
        "path_crc32",
        "final_relative_path",
        "actual_relative_path",
        "physical_path_status",
        "physical_exists",
        "physical_size",
        "final_extension",
        "detected_extension",
        "extension_consistent",
        "classification",
        "severity",
        "reason",
        "recommended_action",
        "reference_match_status",
        "reference_root",
        "reference_relative_path",
        "flags",
        "action_bucket",
        "action_priority",
        "evidence_needed",
        "suggested_next_step",
    ]
    write_tsv(
        output_dir / "extension_mismatch_classification.tsv",
        detail_rows,
        detail_fieldnames,
    )
    write_tsv(
        output_dir / "extension_mismatch_high_risk.tsv",
        [row for row in detail_rows if row["severity"] == "high"],
        detail_fieldnames,
    )
    write_tsv(
        output_dir / "extension_mismatch_review.tsv",
        [row for row in detail_rows if row["severity"] in {"review", "medium", "error"}],
        detail_fieldnames,
    )
    write_tsv(
        output_dir / "extension_mismatch_action_plan.tsv",
        [
            row
            for row in detail_rows
            if row["severity"] in {"high", "medium", "review", "error"}
        ],
        detail_fieldnames,
    )
    (output_dir / "extension_mismatch_summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    write_summary_md(output_dir / "extension_mismatch_summary.md", summary)
    return summary


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Classify extension mismatch rows from unpack_path_manifest.tsv."
    )
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--top-limit", type=int, default=30)
    parser.add_argument(
        "--reference-root",
        action="append",
        default=[],
        type=Path,
        help="Optional resource tree used to downgrade byte-identical source-tree aliases.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    summary = analyze_manifest(
        args.manifest,
        args.output_dir,
        top_limit=args.top_limit,
        reference_roots=args.reference_root,
    )
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

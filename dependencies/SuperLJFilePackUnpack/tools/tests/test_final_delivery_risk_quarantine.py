from __future__ import annotations

import csv
import tempfile
import unittest
from pathlib import Path

import sys


TOOLS_ROOT = Path(__file__).resolve().parents[1]
if str(TOOLS_ROOT) not in sys.path:
    sys.path.insert(0, str(TOOLS_ROOT))

import final_delivery_risk_quarantine as quarantine


MANIFEST_FIELDS = [
    "path_crc32",
    "source_kind",
    "raw_mapping_path",
    "normalized_relative_path",
    "written_relative_path",
    "final_relative_path",
    "actual_relative_path",
    "physical_path_status",
    "physical_exists",
    "physical_size",
    "detected_extension",
    "extension_consistent",
    "flags",
]


HIGH_RISK_FIELDS = [
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


def write_tsv(path: Path, fieldnames: list[str], rows: list[dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, delimiter="\t")
        writer.writeheader()
        writer.writerows(rows)


class FinalDeliveryRiskQuarantineTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = Path(self.temp_dir.name)

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def test_apply_quarantine_moves_only_deterministic_high_risk_paths(self) -> None:
        unpacked_root = self.root / "unpacked_res"
        dev_root = self.root / "dev_res"
        report_dir = self.root / "reports"
        dev_quarantine_root = self.root / "dev_quarantine"

        bad_rel = "model/demo/bad.webp"
        keep_rel = "model/demo/private.webp"
        for root in (unpacked_root, dev_root):
            (root / bad_rel).parent.mkdir(parents=True, exist_ok=True)
            (root / bad_rel).write_bytes(b"RMAP-bad")
            (root / keep_rel).parent.mkdir(parents=True, exist_ok=True)
            (root / keep_rel).write_bytes(b"\x09\x00private-container")

        high_risk_path = self.root / "high.tsv"
        write_tsv(
            high_risk_path,
            HIGH_RISK_FIELDS,
            [
                {
                    "path_crc32": "0x05D69DBD",
                    "final_relative_path": bad_rel,
                    "actual_relative_path": bad_rel,
                    "physical_path_status": "manifest_path",
                    "physical_exists": "True",
                    "physical_size": "8",
                    "final_extension": ".webp",
                    "detected_extension": ".rmp",
                    "extension_consistent": "false",
                    "classification": "true_extension_mismatch",
                    "severity": "high",
                    "reason": "detected payload type is not an expected alias",
                    "recommended_action": "review",
                    "reference_match_status": "reference_missing",
                    "reference_root": "",
                    "reference_relative_path": bad_rel,
                    "flags": "postprocess_relocated,extension_mismatch",
                    "action_bucket": "mapping_seed_suspect",
                    "action_priority": "P0",
                    "evidence_needed": "seed",
                    "suggested_next_step": "quarantine",
                },
                {
                    "path_crc32": "0x0F8AFD4C",
                    "final_relative_path": keep_rel,
                    "actual_relative_path": keep_rel,
                    "physical_path_status": "manifest_path",
                    "physical_exists": "True",
                    "physical_size": "18",
                    "final_extension": ".webp",
                    "detected_extension": "<none>",
                    "extension_consistent": "false",
                    "classification": "true_extension_mismatch",
                    "severity": "high",
                    "reason": "detector cannot name private payload",
                    "recommended_action": "probe",
                    "reference_match_status": "reference_missing",
                    "reference_root": "",
                    "reference_relative_path": keep_rel,
                    "flags": "postprocess_relocated,extension_mismatch",
                    "action_bucket": "image_path_without_generic_signature",
                    "action_priority": "P0",
                    "evidence_needed": "renderer",
                    "suggested_next_step": "probe",
                },
            ],
        )

        manifest_path = unpacked_root / "unpack_path_manifest.tsv"
        write_tsv(
            manifest_path,
            MANIFEST_FIELDS,
            [
                {
                    "path_crc32": "0x05D69DBD",
                    "source_kind": "generated",
                    "raw_mapping_path": "",
                    "normalized_relative_path": "97951165.rmp",
                    "written_relative_path": "97951165.rmp",
                    "final_relative_path": bad_rel,
                    "actual_relative_path": bad_rel,
                    "physical_path_status": "manifest_path",
                    "physical_exists": "True",
                    "physical_size": "8",
                    "detected_extension": ".rmp",
                    "extension_consistent": "false",
                    "flags": "postprocess_relocated,extension_mismatch",
                },
                {
                    "path_crc32": "0x0F8AFD4C",
                    "source_kind": "generated",
                    "raw_mapping_path": "",
                    "normalized_relative_path": "260767052",
                    "written_relative_path": "260767052",
                    "final_relative_path": keep_rel,
                    "actual_relative_path": keep_rel,
                    "physical_path_status": "manifest_path",
                    "physical_exists": "True",
                    "physical_size": "18",
                    "detected_extension": "<none>",
                    "extension_consistent": "false",
                    "flags": "postprocess_relocated,extension_mismatch",
                },
            ],
        )

        summary = quarantine.apply_quarantine(
            high_risk_tsv=high_risk_path,
            unpacked_root=unpacked_root,
            dev_root=dev_root,
            manifest_path=manifest_path,
            report_dir=report_dir,
            dev_quarantine_root=dev_quarantine_root,
            stamp="test",
            apply=True,
        )

        quarantined_rel = (
            "review/high_risk_type_mismatch_candidates/mapping_seed_suspect/"
            "0x05D69DBD/model/demo/bad.webp"
        )
        self.assertEqual(summary["quarantined_records"], 1)
        self.assertEqual(summary["retained_records"], 1)
        self.assertFalse((unpacked_root / bad_rel).exists())
        self.assertTrue((unpacked_root / quarantined_rel).is_file())
        self.assertFalse((dev_root / bad_rel).exists())
        self.assertTrue((dev_quarantine_root / bad_rel).is_file())
        self.assertTrue((unpacked_root / keep_rel).is_file())
        self.assertTrue((dev_root / keep_rel).is_file())

        with manifest_path.open("r", encoding="utf-8", newline="") as handle:
            rows = list(csv.DictReader(handle, delimiter="\t"))
        bad_row = rows[0]
        keep_row = rows[1]
        self.assertEqual(bad_row["final_relative_path"], quarantined_rel)
        self.assertEqual(bad_row["actual_relative_path"], quarantined_rel)
        self.assertEqual(bad_row["physical_path_status"], "high_risk_quarantined")
        self.assertIn("high_risk_quarantined", bad_row["flags"])
        self.assertEqual(keep_row["final_relative_path"], keep_rel)


if __name__ == "__main__":
    unittest.main()

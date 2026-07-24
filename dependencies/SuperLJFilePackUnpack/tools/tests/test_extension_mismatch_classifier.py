from __future__ import annotations

import csv
import tempfile
import unittest
from pathlib import Path

import sys


TOOLS_ROOT = Path(__file__).resolve().parents[1]
if str(TOOLS_ROOT) not in sys.path:
    sys.path.insert(0, str(TOOLS_ROOT))

import extension_mismatch_classifier as classifier


def make_row(
    final_path: str,
    detected_extension: str,
    *,
    extension_consistent: str = "false",
    physical_exists: str = "True",
    physical_size: str = "100",
    actual_path: str | None = None,
) -> dict[str, str]:
    return {
        "path_crc32": "0x00000001",
        "final_relative_path": final_path,
        "actual_relative_path": actual_path or final_path,
        "physical_path_status": "manifest_path",
        "physical_exists": physical_exists,
        "physical_size": physical_size,
        "detected_extension": detected_extension,
        "extension_consistent": extension_consistent,
        "flags": "postprocess_relocated,extension_mismatch",
    }


class ExtensionMismatchClassifierTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = Path(self.temp_dir.name)

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def test_classify_known_domain_aliases_and_true_mismatches(self) -> None:
        cases = [
            (
                make_row("ui/layouts/main.layout", ".xml"),
                "expected_xml_domain_alias",
                "low",
            ),
            (
                make_row("model/role/body/run_res001.pngpart", ".png"),
                "expected_payload_alias",
                "low",
            ),
            (
                make_row("map/elements/map_1601/demo_tile_01", ".webp"),
                "expected_extensionless_map_asset",
                "low",
            ),
            (
                make_row("model/role/action/stand1.ani", ""),
                "expected_private_binary_no_signature",
                "low",
            ),
            (
                make_row("review/unresolved/tga/123456.tga", ".cur"),
                "review_unresolved_type_probe",
                "review",
            ),
            (
                make_row(
                    "review/high_risk_type_mismatch_candidates/mapping_seed_suspect/"
                    "0x05D69DBD/model/bad.webp",
                    ".rmp",
                ),
                "review_high_risk_quarantined",
                "review",
            ),
            (
                make_row("model/role/body/demo.jpg", ".png"),
                "expected_runtime_image_payload_alias",
                "low",
            ),
            (
                make_row("script/logic/demo.lua", ".txt"),
                "expected_text_script_alias",
                "low",
            ),
            (
                make_row("cfg/ios_notify.plist", ".xml"),
                "expected_xml_domain_alias",
                "low",
            ),
            (
                make_row("map/distortionobjects/jing.dis", ""),
                "expected_private_binary_no_signature",
                "low",
            ),
            (
                make_row("model/role/body/demo.dds", ".png"),
                "expected_runtime_image_payload_alias",
                "low",
            ),
            (
                make_row("image/loading/hei.tga", ""),
                "expected_runtime_tga_payload_alias",
                "low",
            ),
            (
                make_row("ui/imagesets/back.tga", ".cur"),
                "expected_runtime_tga_payload_alias",
                "low",
            ),
            (
                make_row("script/logic.sln", ".luaproj"),
                "expected_text_project_alias",
                "low",
            ),
            (
                make_row("cfg/video/mt3.mp4", ""),
                "expected_media_container_alias",
                "low",
            ),
            (
                make_row("script/handler/empty.lua", "", physical_size="10"),
                "expected_empty_text_script",
                "low",
            ),
            (
                make_row("effect/spine/qizi1/qizi1.png", ".psd"),
                "true_extension_mismatch",
                "high",
            ),
            (
                make_row("ui/imagesets/main.png", ".png", extension_consistent="true"),
                "consistent",
                "ok",
            ),
        ]

        for row, expected_classification, expected_severity in cases:
            with self.subTest(row=row):
                result = classifier.classify_row(row)
                self.assertEqual(result.classification, expected_classification)
                self.assertEqual(result.severity, expected_severity)

    def test_analyze_manifest_writes_summary_and_details(self) -> None:
        manifest_path = self.root / "unpack_path_manifest.tsv"
        fieldnames = [
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
        rows = [
            make_row("ui/layouts/main.layout", ".xml"),
            make_row("map/elements/map_1601/demo_tile_01", ".png"),
            make_row("model/role/body/demo.jpg", ".png"),
            make_row("effect/spine/qizi1/qizi1.png", ".psd"),
            make_row("ui/imagesets/main.png", ".png", extension_consistent="true"),
        ]
        with manifest_path.open("w", encoding="utf-8", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=fieldnames, delimiter="\t")
            writer.writeheader()
            for row in rows:
                writer.writerow(row)

        output_dir = self.root / "report"
        summary = classifier.analyze_manifest(manifest_path, output_dir)

        self.assertEqual(summary["total_records"], 5)
        self.assertEqual(summary["mismatch_records"], 4)
        self.assertEqual(summary["classification_counts"]["expected_xml_domain_alias"], 1)
        self.assertEqual(summary["classification_counts"]["expected_extensionless_map_asset"], 1)
        self.assertEqual(summary["classification_counts"]["expected_runtime_image_payload_alias"], 1)
        self.assertEqual(summary["classification_counts"]["true_extension_mismatch"], 1)
        self.assertEqual(summary["severity_counts"]["high"], 1)

        detail_tsv = (output_dir / "extension_mismatch_classification.tsv").read_text(
            encoding="utf-8"
        )
        self.assertIn("classification", detail_tsv)
        self.assertIn("expected_runtime_image_payload_alias", detail_tsv)
        self.assertIn("true_extension_mismatch", detail_tsv)

        high_risk_tsv = (output_dir / "extension_mismatch_high_risk.tsv").read_text(
            encoding="utf-8"
        )
        self.assertIn("effect/spine/qizi1/qizi1.png", high_risk_tsv)
        self.assertNotIn("model/role/body/demo.jpg", high_risk_tsv)
        self.assertNotIn("ui/layouts/main.layout", high_risk_tsv)

        summary_md = (output_dir / "extension_mismatch_summary.md").read_text(
            encoding="utf-8"
        )
        self.assertIn("extension mismatch classification", summary_md)

        action_plan_tsv = (output_dir / "extension_mismatch_action_plan.tsv").read_text(
            encoding="utf-8"
        )
        self.assertIn("action_bucket", action_plan_tsv)
        self.assertIn("effect/spine/qizi1/qizi1.png", action_plan_tsv)
        self.assertNotIn("model/role/body/demo.jpg", action_plan_tsv)

    def test_reference_root_exact_match_downgrades_mismatch(self) -> None:
        unpack_root = self.root / "unpack"
        manifest_path = unpack_root / "unpack_path_manifest.tsv"
        reference_root = self.root / "reference"
        rel_path = "effect/animation/skill/mt_yueguanglindi/ygld_pubu.dds"
        payload = b"\x01\x02custom-effect-payload"

        (unpack_root / rel_path).parent.mkdir(parents=True, exist_ok=True)
        (unpack_root / rel_path).write_bytes(payload)
        (reference_root / rel_path).parent.mkdir(parents=True, exist_ok=True)
        (reference_root / rel_path).write_bytes(payload)

        fieldnames = [
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
        with manifest_path.open("w", encoding="utf-8", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=fieldnames, delimiter="\t")
            writer.writeheader()
            writer.writerow(
                make_row(
                    rel_path,
                    "",
                    physical_size=str(len(payload)),
                )
            )

        output_dir = self.root / "report"
        summary = classifier.analyze_manifest(
            manifest_path,
            output_dir,
            reference_roots=[reference_root],
        )

        self.assertEqual(
            summary["classification_counts"]["expected_reference_tree_exact_alias"],
            1,
        )
        self.assertEqual(summary["high_risk_records"], 0)
        self.assertEqual(summary["low_or_expected_records"], 1)

        detail_tsv = (output_dir / "extension_mismatch_classification.tsv").read_text(
            encoding="utf-8"
        )
        self.assertIn("expected_reference_tree_exact_alias", detail_tsv)
        self.assertIn("reference_exact_match", detail_tsv)


if __name__ == "__main__":
    unittest.main()

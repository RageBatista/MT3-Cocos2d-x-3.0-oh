from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

import sys


TOOLS_ROOT = Path(__file__).resolve().parents[1]
if str(TOOLS_ROOT) not in sys.path:
    sys.path.insert(0, str(TOOLS_ROOT))

import manifest_seed_pipeline as pipeline


class ManifestSeedPipelineTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = Path(self.temp_dir.name)

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def test_canonicalize_and_filter_low_confidence_paths(self) -> None:
        self.assertEqual(
            pipeline.canonicalize_storage_path("Assets/Res/UI/Layouts/Test.layout"),
            "ui/layouts/test.layout",
        )
        self.assertTrue(pipeline.is_low_confidence_crc_repository_path("2ei."))
        self.assertTrue(pipeline.is_low_confidence_crc_repository_path("2nmo.re"))
        self.assertFalse(
            pipeline.is_low_confidence_crc_repository_path("ui/layouts/main.layout")
        )

    def test_load_existing_mapping_text_and_binary(self) -> None:
        text_path = self.root / "mapping.txt"
        text_path.write_text(
            "# header\n0x00000001\tui/layouts/main.layout\n2|script/logic/test.lua\n",
            encoding="utf-8",
            newline="\n",
        )
        binary_path = self.root / "mapping.ljpm"
        pipeline.write_mapping_ljpm(
            binary_path,
            {
                "1": "ui/layouts/main.layout",
                "2": "script/logic/test.lua",
            },
        )

        self.assertEqual(
            pipeline.load_existing_mapping(text_path),
            {
                "1": "ui/layouts/main.layout",
                "2": "script/logic/test.lua",
            },
        )
        self.assertEqual(
            pipeline.load_existing_mapping(binary_path),
            {
                "1": "ui/layouts/main.layout",
                "2": "script/logic/test.lua",
            },
        )

    def test_load_existing_mapping_binary_with_legacy_acp_path_bytes(self) -> None:
        binary_path = self.root / "mapping_cp936.ljpm"
        rel_path = "script/逻辑/测试.lua"
        encoded = rel_path.encode("gb18030")
        binary_path.write_bytes(
            b"LJPM"
            + (1).to_bytes(4, "little")
            + (1).to_bytes(4, "little")
            + (3).to_bytes(4, "little")
            + len(encoded).to_bytes(2, "little")
            + encoded
        )

        self.assertEqual(
            pipeline.load_existing_mapping(binary_path),
            {"3": rel_path},
        )

    def test_analyze_manifests_reports_new_hits_and_conflicts(self) -> None:
        res_dir = self.root / "res"
        res_dir.mkdir()

        direct_path = "script/logic/direct.lua"
        new_path = "ui/layouts/new.layout"
        conflict_old_path = "model/old/path.png"
        conflict_new_path = "effect/new/path.png"

        for rel_path in (direct_path, new_path, conflict_old_path):
            (res_dir / pipeline.crc32_text(rel_path)).write_text("payload", encoding="utf-8")

        mapping_path = self.root / "path_mapping.txt"
        pipeline.write_mapping_text(
            mapping_path,
            {
                pipeline.crc32_text(direct_path): direct_path,
                pipeline.crc32_text(conflict_old_path): conflict_old_path,
            },
            ["test mapping"],
        )

        manifest_main = self.root / "main.txt"
        manifest_main.write_text(
            "\n".join(
                [
                    direct_path,
                    new_path,
                    conflict_new_path,
                    "2ei.",
                    "",
                ]
            ),
            encoding="utf-8",
            newline="\n",
        )

        output_dir = self.root / "reports"
        promote_dir = self.root / "promoted"
        summary = pipeline.analyze_manifests(
            [pipeline.ManifestSpec("main", manifest_main)],
            res_dir=res_dir,
            existing_mapping_path=mapping_path,
            output_dir=output_dir,
            manifest_encodings=pipeline.DEFAULT_MANIFEST_ENCODINGS,
            write_seed_txt=output_dir / "seed.txt",
            write_seed_ljpm=output_dir / "seed.ljpm",
            write_merged_txt=output_dir / "merged.txt",
            write_merged_ljpm=output_dir / "merged.ljpm",
            promote_dir=promote_dir,
        )

        self.assertEqual(summary["direct_hits"], 2)
        self.assertEqual(summary["same_hits"], 1)
        self.assertEqual(summary["new_hits"], 1)
        self.assertEqual(summary["mapping_conflicts"], 0)
        self.assertEqual(summary["filtered_entries"], 1)
        self.assertEqual(summary["existing_hits"], 2)
        self.assertEqual(summary["merged_hits"], 3)
        self.assertEqual(summary["hit_gain"], 1)

        new_hits = (output_dir / "manifest_new_hits.tsv").read_text(encoding="utf-8")
        self.assertIn(new_path, new_hits)
        self.assertNotIn(direct_path + "\tsame_as_mapping", new_hits)

        filtered = (output_dir / "manifest_filtered_entries.tsv").read_text(encoding="utf-8")
        self.assertIn("2ei.", filtered)

        seed_mapping = pipeline.load_existing_mapping(output_dir / "seed.ljpm")
        self.assertIn(pipeline.crc32_text(new_path), seed_mapping)
        self.assertEqual(seed_mapping[pipeline.crc32_text(new_path)], new_path)

        promoted_mapping = pipeline.load_existing_mapping(promote_dir / "path_mapping.ljpm")
        self.assertEqual(promoted_mapping[pipeline.crc32_text(new_path)], new_path)
        summary_md = (output_dir / "manifest_summary.md").read_text(encoding="utf-8")
        self.assertIn("命中增量", summary_md)


if __name__ == "__main__":
    unittest.main()

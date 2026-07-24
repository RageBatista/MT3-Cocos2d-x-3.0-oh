from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

import sys


TOOLS_ROOT = Path(__file__).resolve().parents[1]
if str(TOOLS_ROOT) not in sys.path:
    sys.path.insert(0, str(TOOLS_ROOT))

import manifest_seed_pipeline as common
import source_template_seed_pipeline as pipeline


def append_i32(buf: bytearray, value: int) -> None:
    buf.extend(int(value).to_bytes(4, byteorder="little", signed=True))


def append_u16(buf: bytearray, value: int) -> None:
    buf.extend(int(value).to_bytes(2, byteorder="little", signed=False))


def append_str(buf: bytearray, value: str) -> None:
    encoded = value.encode("utf-8")
    append_i32(buf, len(encoded))
    buf.extend(encoded)


def build_map_config_bin_rows(resdirs: list[str]) -> bytes:
    data = bytearray()
    append_i32(data, 1499087948)
    append_i32(data, 0)
    append_u16(data, 101)
    append_u16(data, len(resdirs))
    append_i32(data, 1704330)

    for index, resdir in enumerate(resdirs):
        append_i32(data, 5001 + index)
        append_str(data, f"demo_map_{index + 1}")
        append_str(data, "demo_icon")
        append_str(data, "demo_desc")
        append_str(data, resdir)
        for _ in range(7):
            append_i32(data, 0)
        data.append(0)
        for _ in range(7):
            append_i32(data, 0)
        append_str(data, "scene.mp3")
        append_i32(data, 0)
        append_i32(data, 0)
        append_str(data, "255,255,255")
        append_i32(data, 0)
        append_i32(data, 0)

    file_len = len(data)
    data[4:8] = int(file_len).to_bytes(4, byteorder="little", signed=True)
    return bytes(data)


class SourceTemplateSeedPipelineTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = Path(self.temp_dir.name)

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def test_extract_candidates_from_text(self) -> None:
        text = """
        local layout = "FriendMailContent.layout"
        local tableName = GetTableByName("battle.cbattleaiconfig")
        local model = UISpineSprite:new("hero_spine")
        local fx = "geffect/ui/youjian"
        local anim = "animation/ui/mail/open"
        local spineEffect = "spine/ui/mail_open"
        local img = "set:MainAtlas"
        """
        candidates = pipeline.extract_candidates_from_text(text, "demo.lua")
        paths = {candidate.path for candidate in candidates}

        self.assertIn("ui/layouts/friendmailcontent.layout", paths)
        self.assertIn("table/bintable/battle.cbattleaiconfig.bin", paths)
        self.assertIn("script/tabledef/battle/cbattleaiconfig.lua", paths)
        self.assertIn("model/hero_spine/hero_spine.atlas", paths)
        self.assertIn("model/hero_spine/hero_spine.json", paths)
        self.assertIn("effect/geffect/ui/youjian.eff.inf", paths)
        self.assertIn("effect/animation/ui/mail/open.ani", paths)
        self.assertIn("effect/spine/ui/mail_open.atlas", paths)
        self.assertIn("effect/spine/ui/mail_open.json", paths)
        self.assertIn("ui/imagesets/MainAtlas.imageset", paths)

    def test_parse_map_config_resdirs(self) -> None:
        config_path = self.root / "map.cmapconfig.bin"
        config_path.write_bytes(build_map_config_bin_rows(["map_1601_yunmengze", "zichen1"]))
        self.assertEqual(
            pipeline.parse_map_config_resdirs(config_path),
            ["map_1601_yunmengze", "zichen1"],
        )

    def test_analyze_sources_reports_exact_crc_hits(self) -> None:
        res_dir = self.root / "res"
        res_dir.mkdir()

        source_root = self.root / "src"
        source_root.mkdir()
        (source_root / "demo.lua").write_text(
            "\n".join(
                [
                    'GetTableByName("battle.cbattleaiconfig")',
                    'local layout = "friendmailcontent.layout"',
                    'UISpineSprite:new("hero_spine")',
                    'local fx = "geffect/ui/youjian"',
                ]
            ),
            encoding="utf-8",
            newline="\n",
        )

        map_config_path = self.root / "map.cmapconfig.bin"
        map_config_path.write_bytes(build_map_config_bin_rows(["map_1601_yunmengze", "zichen1"]))

        exact_paths = [
            "table/bintable/battle.cbattleaiconfig.bin",
            "ui/layouts/friendmailcontent.layout",
            "model/hero_spine/hero_spine.atlas",
            "effect/geffect/ui/youjian.eff.inf",
            "map/map_1601_yunmengze/regiontypeinfo.dat",
            "map/zichen1/jumpblock.dat",
        ]
        for rel_path in exact_paths:
            (res_dir / common.crc32_text(rel_path)).write_text("payload", encoding="utf-8")

        existing_mapping_path = self.root / "mapping.txt"
        common.write_mapping_text(
            existing_mapping_path,
            {common.crc32_text("ui/layouts/friendmailcontent.layout"): "ui/layouts/friendmailcontent.layout"},
            ["existing mapping"],
        )

        output_dir = self.root / "reports"
        promote_dir = self.root / "promoted"
        summary = pipeline.analyze_sources(
            scan_roots=[source_root],
            map_config_bins=[map_config_path],
            res_dir=res_dir,
            target_crc_file=None,
            existing_mapping_path=existing_mapping_path,
            output_dir=output_dir,
            text_encodings=common.DEFAULT_MANIFEST_ENCODINGS,
            write_seed_txt=output_dir / "seed.txt",
            write_seed_ljpm=output_dir / "seed.ljpm",
            write_merged_txt=output_dir / "merged.txt",
            write_merged_ljpm=output_dir / "merged.ljpm",
            promote_dir=promote_dir,
        )

        self.assertEqual(summary["direct_hits"], 6)
        self.assertEqual(summary["same_hits"], 1)
        self.assertEqual(summary["new_hits"], 5)
        self.assertEqual(summary["mapping_conflicts"], 0)
        self.assertEqual(summary["seed_conflicts"], 0)
        self.assertEqual(summary["existing_hits"], 1)
        self.assertEqual(summary["merged_hits"], 6)
        self.assertEqual(summary["hit_gain"], 5)

        seed_mapping = common.load_existing_mapping(output_dir / "seed.ljpm")
        self.assertEqual(
            seed_mapping[common.crc32_text("map/map_1601_yunmengze/regiontypeinfo.dat")],
            "map/map_1601_yunmengze/regiontypeinfo.dat",
        )
        self.assertEqual(
            seed_mapping[common.crc32_text("map/zichen1/jumpblock.dat")],
            "map/zichen1/jumpblock.dat",
        )
        self.assertEqual(
            seed_mapping[common.crc32_text("effect/geffect/ui/youjian.eff.inf")],
            "effect/geffect/ui/youjian.eff.inf",
        )

        direct_hits_tsv = (output_dir / "source_template_direct_hits.tsv").read_text(encoding="utf-8")
        self.assertIn("map/map_1601_yunmengze/regiontypeinfo.dat", direct_hits_tsv)
        self.assertIn("map/zichen1/jumpblock.dat", direct_hits_tsv)
        self.assertIn("same_as_mapping", direct_hits_tsv)

        summary_md = (output_dir / "source_template_summary.md").read_text(encoding="utf-8")
        self.assertIn("命中增量", summary_md)

        promoted_mapping = common.load_existing_mapping(promote_dir / "path_mapping.ljpm")
        self.assertIn(common.crc32_text("map/zichen1/jumpblock.dat"), promoted_mapping)

    def test_analyze_sources_supports_target_crc_file_without_res_dir(self) -> None:
        source_root = self.root / "src"
        source_root.mkdir()
        (source_root / "demo.lua").write_text(
            'local layout = "friendmailcontent.layout"\n',
            encoding="utf-8",
            newline="\n",
        )

        target_crc_file = self.root / "target_crc32.txt"
        target_crc_file.write_text(
            common.crc32_text("ui/layouts/friendmailcontent.layout") + "\n",
            encoding="utf-8",
            newline="\n",
        )

        output_dir = self.root / "reports"
        summary = pipeline.analyze_sources(
            scan_roots=[source_root],
            map_config_bins=[],
            res_dir=None,
            target_crc_file=target_crc_file,
            existing_mapping_path=None,
            output_dir=output_dir,
            text_encodings=common.DEFAULT_MANIFEST_ENCODINGS,
            write_seed_txt=None,
            write_seed_ljpm=None,
            write_merged_txt=None,
            write_merged_ljpm=None,
            promote_dir=None,
        )

        self.assertEqual(summary["target_crc_count"], 1)
        self.assertEqual(summary["direct_hits"], 1)
        self.assertEqual(summary["new_hits"], 1)

        seed_tsv = (output_dir / "source_template_seed_candidates.tsv").read_text(encoding="utf-8")
        self.assertIn("ui/layouts/friendmailcontent.layout", seed_tsv)


if __name__ == "__main__":
    unittest.main()

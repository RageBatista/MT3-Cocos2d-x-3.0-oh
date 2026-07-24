#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import shutil
import struct
from collections import defaultdict
from pathlib import Path


ROLE_FILENAMES = {
    "island": "island.dat",
    "island2": "island2.dat",
    "jumpblock": "jumpblock.dat",
}


def parse_quyu_u8(path: Path) -> dict | None:
    data = path.read_bytes()
    if len(data) < 16 or data[:4] != b"QUYU":
        return None

    width, height, count = struct.unpack_from("<III", data, 4)
    if len(data) != 16 + count * 5:
        return None

    offset = 16
    values: list[int] = []
    for _ in range(count):
        offset += 4  # key
        values.append(data[offset])
        offset += 1

    unique_values = tuple(sorted(set(values)))
    cell_count = width * height
    density = (count / cell_count) if cell_count else 0.0

    return {
        "path": path,
        "file": path.name,
        "width": width,
        "height": height,
        "count": count,
        "size": len(data),
        "cell_count": cell_count,
        "density": density,
        "unique_values": unique_values,
        "sha1": hashlib.sha1(data).hexdigest(),
        "data": data,
    }


def read_i32(data: bytes, offset: int) -> tuple[int, int]:
    return struct.unpack_from("<i", data, offset)[0], offset + 4


def read_u16(data: bytes, offset: int) -> tuple[int, int]:
    return struct.unpack_from("<H", data, offset)[0], offset + 2


def read_bool(data: bytes, offset: int) -> tuple[bool, int]:
    return data[offset] != 0, offset + 1


def read_str(data: bytes, offset: int) -> tuple[str, int]:
    length, offset = read_i32(data, offset)
    if length < 0 or offset + length > len(data):
        raise ValueError(f"bad string length {length} at {offset - 4}")
    text = data[offset:offset + length].decode("utf-8", errors="replace")
    return text, offset + length


def parse_map_config(path: Path) -> list[dict]:
    data = path.read_bytes()
    offset = 0

    _, offset = read_i32(data, offset)
    _, offset = read_i32(data, offset)
    _, offset = read_u16(data, offset)
    member_count, offset = read_u16(data, offset)
    _, offset = read_i32(data, offset)

    rows: list[dict] = []
    for _ in range(member_count):
        row: dict[str, object] = {}
        row["id"], offset = read_i32(data, offset)
        row["mapName"], offset = read_str(data, offset)
        row["mapIcon"], offset = read_str(data, offset)
        row["desc"], offset = read_str(data, offset)
        row["resdir"], offset = read_str(data, offset)
        row["battleground"], offset = read_i32(data, offset)
        row["width"], offset = read_i32(data, offset)
        row["height"], offset = read_i32(data, offset)
        row["safemap"], offset = read_i32(data, offset)
        row["xjPos"], offset = read_i32(data, offset)
        row["yjPos"], offset = read_i32(data, offset)
        row["qinggong"], offset = read_i32(data, offset)
        row["bShowInWorld"], offset = read_bool(data, offset)
        row["LevelLimitMin"], offset = read_i32(data, offset)
        row["LevelLimitMax"], offset = read_i32(data, offset)
        row["fightinfor"], offset = read_i32(data, offset)
        row["playerPosX"], offset = read_i32(data, offset)
        row["playerPosY"], offset = read_i32(data, offset)
        row["dynamic"], offset = read_i32(data, offset)
        row["fubenType"], offset = read_i32(data, offset)
        row["music"], offset = read_str(data, offset)
        row["flyPosX"], offset = read_i32(data, offset)
        row["flyPosY"], offset = read_i32(data, offset)
        row["sceneColor"], offset = read_str(data, offset)
        row["jumpmappoint"], offset = read_i32(data, offset)
        row["isMemVisible"], offset = read_i32(data, offset)
        row["grid_w"] = (int(row["width"]) + 23) // 24
        row["grid_h"] = (int(row["height"]) + 15) // 16
        rows.append(row)

    return rows


def classify_primary_role(meta: dict) -> tuple[str, str]:
    unique_values = meta["unique_values"]
    count = meta["count"]
    density = meta["density"]

    if count == 0:
        return ("empty_ambiguous", "count_zero")
    if unique_values == (1,) and abs(density - 1.0) < 1e-9:
        return ("island2_like", "full_coverage_all_ones")
    if unique_values and set(unique_values).issubset({3, 8}) and count <= 64:
        return ("jumpblock_like", "sparse_small_bitmask_values")
    if unique_values == (1,):
        return ("island_like", "partial_coverage_all_ones")
    if unique_values and unique_values[0] >= 1 and unique_values[-1] >= 2:
        return ("island_like", "multi_level_island_regions")
    return ("unsigned_char_unclassified", "no_rule_match")


def collect_existing_role_status(map_root: Path) -> dict[str, dict[str, bool]]:
    out: dict[str, dict[str, bool]] = {}
    for path in map_root.iterdir():
        if not path.is_dir():
            continue
        out[path.name.lower()] = {
            "regiontypeinfo": (path / "regiontypeinfo.dat").exists(),
            "jumpblock": (path / "jumpblock.dat").exists(),
            "island": (path / "island.dat").exists(),
            "island2": (path / "island2.dat").exists(),
        }
    return out


def group_candidates(candidate_root: Path) -> dict[tuple, dict]:
    groups: dict[tuple, dict] = {}
    for path in sorted(candidate_root.glob("*.dat")):
        meta = parse_quyu_u8(path)
        if meta is None:
            continue
        primary_role, primary_reason = classify_primary_role(meta)
        group_key = (
            meta["width"],
            meta["height"],
            meta["count"],
            meta["size"],
            meta["sha1"],
        )
        if group_key not in groups:
            groups[group_key] = {
                **meta,
                "primary_role": primary_role,
                "primary_reason": primary_reason,
                "files": [],
            }
            groups[group_key].pop("path")
            groups[group_key].pop("data")
            groups[group_key]["sha1"] = meta["sha1"]
        groups[group_key]["files"].append(path.name)
    return groups


def write_csv(path: Path, fieldnames: list[str], rows: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8-sig", newline="") as fp:
        writer = csv.DictWriter(fp, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def bytes_equal(path: Path, data: bytes) -> bool:
    return path.exists() and path.read_bytes() == data


def build_resolution(
    candidate_groups: dict[tuple, dict],
    map_rows: list[dict],
    existing_status: dict[str, dict[str, bool]],
) -> tuple[list[dict], list[dict]]:
    resdirs_by_grid: dict[tuple[int, int], list[dict]] = defaultdict(list)
    for row in map_rows:
        grid = (int(row["grid_w"]), int(row["grid_h"]))
        resdirs_by_grid[grid].append(row)

    grouped_by_grid: dict[tuple[int, int], list[dict]] = defaultdict(list)
    for group in candidate_groups.values():
        grid = (int(group["width"]), int(group["height"]))
        grouped_by_grid[grid].append(group)

    candidate_rows: list[dict] = []
    family_rows: list[dict] = []

    for grid in sorted(grouped_by_grid):
        grid_groups = sorted(grouped_by_grid[grid], key=lambda item: (item["primary_role"], item["count"], item["sha1"]))
        resdir_rows = resdirs_by_grid.get(grid, [])

        role_buckets: dict[str, list[dict]] = defaultdict(list)
        for group in grid_groups:
            role_buckets[group["primary_role"]].append(group)

        inferred_role_by_sha: dict[str, str] = {}
        inferred_reason_by_sha: dict[str, str] = {}

        if role_buckets["empty_ambiguous"]:
            if role_buckets["island_like"] and role_buckets["island2_like"] and not role_buckets["jumpblock_like"]:
                for group in role_buckets["empty_ambiguous"]:
                    inferred_role_by_sha[group["sha1"]] = "jumpblock"
                    inferred_reason_by_sha[group["sha1"]] = "family_has_island_and_island2_only_missing_jumpblock"
            elif role_buckets["island_like"] and role_buckets["jumpblock_like"] and not role_buckets["island2_like"]:
                for group in role_buckets["empty_ambiguous"]:
                    inferred_role_by_sha[group["sha1"]] = "island2"
                    inferred_reason_by_sha[group["sha1"]] = "family_has_island_and_jumpblock_only_missing_island2"
            elif role_buckets["island_like"] and not role_buckets["jumpblock_like"] and not role_buckets["island2_like"]:
                remaining = sum(len(group["files"]) for group in role_buckets["empty_ambiguous"])
                if len(resdir_rows) == 1 and remaining == 2:
                    for group in role_buckets["empty_ambiguous"]:
                        inferred_role_by_sha[group["sha1"]] = "jumpblock_or_island2_pair"
                        inferred_reason_by_sha[group["sha1"]] = "single_resdir_two_identical_empty_files_fill_jumpblock_and_island2"

        for group in grid_groups:
            resdirs = [str(row["resdir"]) for row in resdir_rows]
            candidate_rows.append(
                {
                    "grid_w": group["width"],
                    "grid_h": group["height"],
                    "count": group["count"],
                    "size": group["size"],
                    "density": f"{group['density']:.6f}",
                    "unique_values": ";".join(str(v) for v in group["unique_values"]),
                    "primary_role": group["primary_role"],
                    "primary_reason": group["primary_reason"],
                    "refined_role": inferred_role_by_sha.get(group["sha1"], ""),
                    "refined_reason": inferred_reason_by_sha.get(group["sha1"], ""),
                    "sha1": group["sha1"],
                    "file_count": len(group["files"]),
                    "files": ";".join(group["files"]),
                    "candidate_resdirs": ";".join(resdirs),
                }
            )

        if not resdir_rows:
            family_rows.append(
                {
                    "grid_w": grid[0],
                    "grid_h": grid[1],
                    "candidate_resdirs": "",
                    "family_status": "no_resdir_from_map_config",
                    "role_summary": ";".join(
                        f"{group['primary_role']}:{len(group['files'])}"
                        for group in grid_groups
                    ),
                    "integration_summary": "",
                }
            )
            continue

        role_to_groups: dict[str, list[dict]] = defaultdict(list)
        for group in grid_groups:
            primary = group["primary_role"]
            if primary == "island_like":
                role_to_groups["island"].append(group)
            elif primary == "island2_like":
                role_to_groups["island2"].append(group)
            elif primary == "jumpblock_like":
                role_to_groups["jumpblock"].append(group)
            elif inferred_role_by_sha.get(group["sha1"]) == "island2":
                role_to_groups["island2"].append(group)
            elif inferred_role_by_sha.get(group["sha1"]) == "jumpblock":
                role_to_groups["jumpblock"].append(group)

        integration_tokens: list[str] = []
        if len(resdir_rows) == 1:
            resdir = str(resdir_rows[0]["resdir"])
            for role in ("island", "island2", "jumpblock"):
                if len(role_to_groups[role]) == 1 and len(role_to_groups[role][0]["files"]) == 1:
                    integration_tokens.append(f"{resdir}/{ROLE_FILENAMES[role]}=direct")

            pair_groups = [
                group for group in grid_groups
                if inferred_role_by_sha.get(group["sha1"]) == "jumpblock_or_island2_pair"
            ]
            if len(pair_groups) == 1 and len(pair_groups[0]["files"]) == 2:
                integration_tokens.append(f"{resdir}/jumpblock.dat=empty_pair")
                integration_tokens.append(f"{resdir}/island2.dat=empty_pair")

        family_rows.append(
            {
                "grid_w": grid[0],
                "grid_h": grid[1],
                "candidate_resdirs": ";".join(str(row["resdir"]) for row in resdir_rows),
                "family_status": "resdir_known",
                "role_summary": ";".join(
                    f"{group['primary_role']}:{len(group['files'])}"
                    for group in grid_groups
                ),
                "integration_summary": ";".join(integration_tokens),
            }
        )

    return candidate_rows, family_rows


def apply_integrations(
    candidate_groups: dict[tuple, dict],
    map_rows: list[dict],
    map_root: Path,
    dev_root: Path | None,
) -> dict:
    by_grid: dict[tuple[int, int], list[dict]] = defaultdict(list)
    for row in map_rows:
        by_grid[(int(row["grid_w"]), int(row["grid_h"]))].append(row)

    groups_by_grid: dict[tuple[int, int], list[dict]] = defaultdict(list)
    for group in candidate_groups.values():
        groups_by_grid[(int(group["width"]), int(group["height"]))].append(group)

    result = {
        "copied": [],
        "skipped_existing_same": [],
        "conflicts": [],
    }

    for grid, grid_groups in groups_by_grid.items():
        resdir_rows = by_grid.get(grid, [])
        if len(resdir_rows) != 1:
            continue

        resdir = str(resdir_rows[0]["resdir"])
        target_dir = map_root / resdir

        island_group = next((g for g in grid_groups if g["primary_role"] == "island_like"), None)
        island2_group = next((g for g in grid_groups if g["primary_role"] == "island2_like"), None)
        jump_group = next((g for g in grid_groups if g["primary_role"] == "jumpblock_like"), None)
        empty_group = next((g for g in grid_groups if g["primary_role"] == "empty_ambiguous"), None)

        direct_plan: list[tuple[str, Path]] = []
        if island_group and len(island_group["files"]) == 1:
            direct_plan.append(("island.dat", Path(island_group["path"])))
        if island2_group and len(island2_group["files"]) == 1:
            direct_plan.append(("island2.dat", Path(island2_group["path"])))
        if jump_group and len(jump_group["files"]) == 1:
            direct_plan.append(("jumpblock.dat", Path(jump_group["path"])))

        if island_group and island2_group and not jump_group and empty_group and len(empty_group["files"]) == 1:
            direct_plan.append(("jumpblock.dat", Path(empty_group["path"])))
        if island_group and jump_group and not island2_group and empty_group and len(empty_group["files"]) == 1:
            direct_plan.append(("island2.dat", Path(empty_group["path"])))
        if island_group and not island2_group and not jump_group and empty_group and len(empty_group["files"]) == 2:
            empty_files = sorted(Path(name) for name in empty_group["files"])
            direct_plan.append(("jumpblock.dat", Path(empty_group["path"]).parent / empty_files[0].name))
            direct_plan.append(("island2.dat", Path(empty_group["path"]).parent / empty_files[1].name))

        for role_name, source_path in direct_plan:
            target_path = target_dir / role_name
            source_data = source_path.read_bytes()
            if target_path.exists():
                if bytes_equal(target_path, source_data):
                    result["skipped_existing_same"].append(str(target_path))
                    continue
                result["conflicts"].append(
                    {
                        "target": str(target_path),
                        "source": str(source_path),
                    }
                )
                continue

            target_path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source_path, target_path)
            result["copied"].append(str(target_path))

            if dev_root is not None:
                dev_target = dev_root / resdir / role_name
                dev_target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source_path, dev_target)

    return result


def enrich_groups_with_paths(candidate_groups: dict[tuple, dict], candidate_root: Path) -> None:
    for group in candidate_groups.values():
        group["path"] = candidate_root / group["files"][0]


def main() -> int:
    parser = argparse.ArgumentParser(description="把 QUYU unsigned-char 候选细分到 island/island2/jumpblock，并输出可执行回流计划。")
    parser.add_argument("--candidate-root", required=True, type=Path, help="review/recovered_dat_signature_candidates/quyu/island2_or_jumpblock_like")
    parser.add_argument("--map-config-bin", required=True, type=Path, help="map.cmapconfig.bin")
    parser.add_argument("--map-root", required=True, type=Path, help="unpacked_res/map")
    parser.add_argument("--report-dir", required=True, type=Path, help="正式报告输出目录")
    parser.add_argument("--dev-map-root", type=Path, help="dev_res/map")
    parser.add_argument("--apply", action="store_true", help="把高置信唯一项复制回 unpacked_res/dev_res")
    args = parser.parse_args()

    candidate_groups = group_candidates(args.candidate_root)
    enrich_groups_with_paths(candidate_groups, args.candidate_root)
    map_rows = parse_map_config(args.map_config_bin)
    existing_status = collect_existing_role_status(args.map_root)

    candidate_rows, family_rows = build_resolution(candidate_groups, map_rows, existing_status)

    args.report_dir.mkdir(parents=True, exist_ok=True)
    write_csv(
        args.report_dir / "quyu_unsigned_char_candidates.csv",
        [
            "grid_w",
            "grid_h",
            "count",
            "size",
            "density",
            "unique_values",
            "primary_role",
            "primary_reason",
            "refined_role",
            "refined_reason",
            "sha1",
            "file_count",
            "files",
            "candidate_resdirs",
        ],
        candidate_rows,
    )
    write_csv(
        args.report_dir / "quyu_unsigned_char_families.csv",
        [
            "grid_w",
            "grid_h",
            "candidate_resdirs",
            "family_status",
            "role_summary",
            "integration_summary",
        ],
        family_rows,
    )

    integration_result = {
        "copied": [],
        "skipped_existing_same": [],
        "conflicts": [],
    }
    if args.apply:
        integration_result = apply_integrations(
            candidate_groups,
            map_rows,
            args.map_root,
            args.dev_map_root,
        )

    summary = {
        "candidate_group_count": len(candidate_rows),
        "family_count": len(family_rows),
        "direct_copy_count": len(integration_result["copied"]),
        "conflict_count": len(integration_result["conflicts"]),
    }
    (args.report_dir / "quyu_unsigned_char_summary.json").write_text(
        json.dumps(
            {
                "summary": summary,
                "integration_result": integration_result,
            },
            ensure_ascii=False,
            indent=2,
        ) + "\n",
        encoding="utf-8",
    )

    readme_lines = [
        "# QUYU Unsigned-Char 细分",
        "",
        f"- 候选组数: {summary['candidate_group_count']}",
        f"- grid 家族数: {summary['family_count']}",
        f"- 本轮直接回流文件数: {summary['direct_copy_count']}",
        f"- 冲突数: {summary['conflict_count']}",
        "",
        "判定规则：",
        "- `values == {1}` 且 `count == width * height` => `island2_like`",
        "- `values ⊆ {3,8}` 且记录很稀疏 => `jumpblock_like`",
        "- `values` 出现 `1..N` 或 `values == {1}` 但不是满图覆盖 => `island_like`",
        "- `count == 0` 先记为 `empty_ambiguous`，再用同 grid 家族补角色",
        "",
        "输出文件：",
        "- `quyu_unsigned_char_candidates.csv`：每个 exact-content 候选组的值域与角色判定",
        "- `quyu_unsigned_char_families.csv`：按 grid/resdir 汇总的 family 级恢复情况",
        "- `quyu_unsigned_char_summary.json`：本轮回流结果与冲突清单",
    ]
    (args.report_dir / "README_unsigned_char.md").write_text(
        "\n".join(readme_lines) + "\n",
        encoding="utf-8",
    )

    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

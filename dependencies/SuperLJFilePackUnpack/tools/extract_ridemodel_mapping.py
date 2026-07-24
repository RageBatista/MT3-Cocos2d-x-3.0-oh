#!/usr/bin/env python3
from __future__ import annotations

import argparse
import binascii
import csv
import json
import re
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


LAYER_RE = re.compile(
    r'<layer\s+id="(?P<id>\d+)"\s+name="(?P<name>[^"]+)"[^>]*type="(?P<type>\d+)"(?:[^>]*ride="(?P<ride>[^"]+)")?',
    re.IGNORECASE,
)
ACTION_RE = re.compile(r'<action\s+name="(?P<name>riding_[^"]+)"', re.IGNORECASE)


@dataclass(frozen=True)
class RideContext:
    model: str
    layer: str


def read_text_auto(path: Path) -> str:
    data = path.read_bytes()
    for encoding in ("utf-8-sig", "utf-16", "utf-16-le", "utf-16-be", "gb18030"):
        try:
            return data.decode(encoding)
        except UnicodeDecodeError:
            continue
    return data.decode("latin1", errors="ignore")


def find_ride_layers(layerdef_text: str) -> list[str]:
    ride_layers: list[str] = []
    for match in LAYER_RE.finditer(layerdef_text):
        type_value = int(match.group("type"))
        ride_flag = (match.group("ride") or "").strip().lower()
        if (type_value & 1) != 0 or ride_flag == "true":
            ride_layers.append(match.group("name"))
    return ride_layers


def find_riding_actions(action_text: str) -> list[str]:
    return sorted(set(match.group("name") for match in ACTION_RE.finditer(action_text)))


def find_layer_components(layer_name: str, layer_text: str) -> list[str]:
    pattern = re.compile(
        rf"<{re.escape(layer_name)}\s+name=\"(?P<name>[^\"]+)\"",
        re.IGNORECASE,
    )
    return [match.group("name") for match in pattern.finditer(layer_text)]


def normalize_rel(path: str) -> str:
    return path.replace("\\", "/").strip().lower()


def crc32_text(path: str) -> str:
    return str(binascii.crc32(normalize_rel(path).encode("utf-8")) & 0xFFFFFFFF)


def sample_join(values: Iterable[str], limit: int = 12) -> str:
    ordered = sorted(set(values))
    if len(ordered) <= limit:
        return ";".join(ordered)
    head = ordered[:limit]
    return ";".join(head) + f";...(+{len(ordered) - limit})"


def write_csv(path: Path, fieldnames: list[str], rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8-sig", newline="") as fp:
        writer = csv.DictWriter(fp, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser(description="提取 MT3 ridemodel 到模型目录上下文映射")
    parser.add_argument("--model-root", required=True, help="model 根目录")
    parser.add_argument("--unresolved-root", required=True, help="review/unresolved 根目录")
    parser.add_argument("--output-dir", required=True, help="输出目录")
    args = parser.parse_args()

    model_root = Path(args.model_root)
    unresolved_root = Path(args.unresolved_root)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    unresolved_ani = {path.stem for path in (unresolved_root / "ani").glob("*.ani")}

    model_rows: list[dict[str, object]] = []
    context_rows: list[dict[str, object]] = []
    expanded_rows: list[dict[str, object]] = []
    group_rows: list[dict[str, object]] = []
    ridemodel_rows: list[dict[str, object]] = []
    local_hit_rows: list[dict[str, object]] = []
    shared_hit_rows: list[dict[str, object]] = []

    ridemodel_to_contexts: dict[str, set[RideContext]] = defaultdict(set)
    ridemodel_to_models: dict[str, set[str]] = defaultdict(set)
    ridemodel_to_layers: dict[str, set[str]] = defaultdict(set)
    ridemodel_to_actions: dict[str, set[str]] = defaultdict(set)
    group_to_models: dict[tuple[str, tuple[str, ...]], set[str]] = defaultdict(set)
    context_to_signature: dict[tuple[str, str], tuple[str, tuple[str, ...]]] = {}

    ride_model_count = 0
    ride_context_count = 0

    for layerdef in sorted(model_root.glob("*/layerdef.lmx")):
        model_dir = layerdef.parent
        model_name = model_dir.name
        layerdef_text = read_text_auto(layerdef)
        ride_layers = find_ride_layers(layerdef_text)
        if not ride_layers:
            continue

        action_lmx = model_dir / "action" / "action.lmx"
        if not action_lmx.exists():
            continue

        riding_actions = find_riding_actions(read_text_auto(action_lmx))
        layer_component_map: dict[str, list[str]] = {}
        ride_model_count += 1

        for layer_name in ride_layers:
            layer_lmx = model_dir / layer_name / f"{layer_name}.lmx"
            if not layer_lmx.exists():
                continue

            components = find_layer_components(layer_name, read_text_auto(layer_lmx))
            if not components:
                continue

            layer_component_map[layer_name] = components
            ride_context_count += 1
            component_signature = tuple(sorted(set(components)))
            group_to_models[(layer_name, component_signature)].add(model_name)
            context_to_signature[(model_name, layer_name)] = (layer_name, component_signature)

            context_rows.append(
                {
                    "model": model_name,
                    "layer": layer_name,
                    "component_count": len(components),
                    "component_sample": sample_join(components, limit=16),
                    "action_count": len(riding_actions),
                    "action_sample": sample_join(riding_actions, limit=8),
                    "layer_lmx_path": f"model/{model_name}/{layer_name}/{layer_name}.lmx",
                }
            )

            for component in components:
                ridemodel_to_contexts[component].add(RideContext(model=model_name, layer=layer_name))
                ridemodel_to_models[component].add(model_name)
                ridemodel_to_layers[component].add(layer_name)
                ridemodel_to_actions[component].update(riding_actions)

                for action_name in riding_actions:
                    local_path = f"model/{model_name}/{layer_name}/{component}/{action_name}.ani"
                    local_crc = crc32_text(local_path)
                    if local_crc in unresolved_ani:
                        local_hit_rows.append(
                            {
                                "ridemodel": component,
                                "model": model_name,
                                "layer": layer_name,
                                "action": action_name,
                                "candidate_path": local_path,
                                "candidate_crc32_decimal": local_crc,
                                "candidate_crc32_hex": f"0x{int(local_crc):08X}",
                            }
                        )

                    shared_path = f"model/mt_zuoqi/{layer_name}/{component}/{action_name}.ani"
                    shared_crc = crc32_text(shared_path)
                    if shared_crc in unresolved_ani:
                        shared_hit_rows.append(
                            {
                                "ridemodel": component,
                                "model": model_name,
                                "layer": layer_name,
                                "action": action_name,
                                "candidate_path": shared_path,
                                "candidate_crc32_decimal": shared_crc,
                                "candidate_crc32_hex": f"0x{int(shared_crc):08X}",
                            }
                        )

        model_rows.append(
            {
                "model": model_name,
                "ride_layer_count": len(layer_component_map),
                "ride_layers": sample_join(layer_component_map.keys(), limit=8),
                "riding_action_count": len(riding_actions),
                "riding_actions": sample_join(riding_actions, limit=8),
            }
        )

    signature_to_group_id: dict[tuple[str, tuple[str, ...]], str] = {}
    for index, ((layer_name, component_signature), models) in enumerate(
        sorted(group_to_models.items(), key=lambda item: (item[0][0], item[0][1]))
    ):
        components = list(component_signature)
        group_id = f"G{index + 1:03d}"
        signature_to_group_id[(layer_name, component_signature)] = group_id
        group_rows.append(
            {
                "group_id": group_id,
                "layer": layer_name,
                "component_count": len(components),
                "component_min": components[0] if components else "",
                "component_max": components[-1] if components else "",
                "component_sample": sample_join(components, limit=20),
                "model_count": len(models),
                "models": sample_join(models, limit=16),
            }
        )

    for ridemodel in sorted(ridemodel_to_contexts.keys(), key=lambda value: int(value)):
        contexts = sorted(ridemodel_to_contexts[ridemodel], key=lambda item: (item.model, item.layer))
        local_declared_layer_dirs = [f"model/{item.model}/{item.layer}" for item in contexts]
        shared_dirs = sorted(
            {f"model/mt_zuoqi/{layer}/{ridemodel}" for layer in ridemodel_to_layers[ridemodel]}
        )
        group_ids = []
        for item in contexts:
            signature = context_to_signature.get((item.model, item.layer))
            if signature is None:
                continue
            group_id = signature_to_group_id.get(signature)
            if group_id is not None:
                group_ids.append(group_id)
                expanded_rows.append(
                    {
                        "ridemodel": ridemodel,
                        "model": item.model,
                        "layer": item.layer,
                        "group_id": group_id,
                        "declared_layer_dir": f"model/{item.model}/{item.layer}",
                        "engine_expected_shared_dir": f"model/mt_zuoqi/{item.layer}/{ridemodel}",
                    }
                )
        ridemodel_rows.append(
            {
                "ridemodel": ridemodel,
                "model_count": len(ridemodel_to_models[ridemodel]),
                "models": sample_join(ridemodel_to_models[ridemodel], limit=18),
                "layers": sample_join(ridemodel_to_layers[ridemodel], limit=8),
                "group_ids": sample_join(group_ids, limit=12),
                "context_count": len(contexts),
                "declared_layer_dirs": sample_join(local_declared_layer_dirs, limit=18),
                "engine_expected_shared_dirs": sample_join(shared_dirs, limit=8),
                "riding_actions": sample_join(ridemodel_to_actions[ridemodel], limit=8),
                "local_candidate_hit_count": sum(1 for row in local_hit_rows if row["ridemodel"] == ridemodel),
                "shared_candidate_hit_count": sum(1 for row in shared_hit_rows if row["ridemodel"] == ridemodel),
            }
        )

    write_csv(
        output_dir / "ridemodel_model_contexts.csv",
        [
            "model",
            "layer",
            "component_count",
            "component_sample",
            "action_count",
            "action_sample",
            "layer_lmx_path",
        ],
        context_rows,
    )
    write_csv(
        output_dir / "ride_layer_groups.csv",
        [
            "group_id",
            "layer",
            "component_count",
            "component_min",
            "component_max",
            "component_sample",
            "model_count",
            "models",
        ],
        group_rows,
    )
    write_csv(
        output_dir / "ridemodel_mapping_summary.csv",
        [
            "ridemodel",
            "model_count",
            "models",
            "layers",
            "group_ids",
            "context_count",
            "declared_layer_dirs",
            "engine_expected_shared_dirs",
            "riding_actions",
            "local_candidate_hit_count",
            "shared_candidate_hit_count",
        ],
        ridemodel_rows,
    )
    write_csv(
        output_dir / "ridemodel_context_expanded.csv",
        [
            "ridemodel",
            "model",
            "layer",
            "group_id",
            "declared_layer_dir",
            "engine_expected_shared_dir",
        ],
        expanded_rows,
    )
    write_csv(
        output_dir / "ridemodel_local_candidate_hits.csv",
        [
            "ridemodel",
            "model",
            "layer",
            "action",
            "candidate_path",
            "candidate_crc32_decimal",
            "candidate_crc32_hex",
        ],
        local_hit_rows,
    )
    write_csv(
        output_dir / "ridemodel_shared_candidate_hits.csv",
        [
            "ridemodel",
            "model",
            "layer",
            "action",
            "candidate_path",
            "candidate_crc32_decimal",
            "candidate_crc32_hex",
        ],
        shared_hit_rows,
    )

    summary = {
        "model_root": str(model_root),
        "unresolved_root": str(unresolved_root),
        "ride_model_count": ride_model_count,
        "ride_context_count": ride_context_count,
        "unique_ridemodel_count": len(ridemodel_rows),
        "unresolved_ani_count": len(unresolved_ani),
        "local_candidate_hit_count": len(local_hit_rows),
        "shared_candidate_hit_count": len(shared_hit_rows),
    }
    (output_dir / "ridemodel_mapping_summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    md_lines = [
        "# ridemodel 映射追踪",
        "",
        f"- 参与 ride 层的模型目录数: {ride_model_count}",
        f"- 解析出的 ride 层上下文数: {ride_context_count}",
        f"- 唯一 ridemodel 数量: {len(ridemodel_rows)}",
        f"- unresolved ani 数量: {len(unresolved_ani)}",
        f"- 本地样式候选命中数: {len(local_hit_rows)}",
        f"- 共享 mt_zuoqi 样式候选命中数: {len(shared_hit_rows)}",
        "",
        "说明：",
        "- `declared_layer_dirs` 表示当前恢复树里，哪个模型目录的 ride 层定义文件声明了该 ridemodel。",
        "- `engine_expected_shared_dirs` 表示按引擎代码推导的共享目录形态 `model/mt_zuoqi/<layer>/<ridemodel>`。",
        "- 当前没有在 `review/unresolved/ani` 中撞到 ridemodel 组件动画候选，说明这批组件 payload 尚未被当前恢复结果直接命中。",
        "",
        "主要导出：",
        "- `ridemodel_mapping_summary.csv`",
        "- `ridemodel_context_expanded.csv`",
        "- `ridemodel_model_contexts.csv`",
        "- `ride_layer_groups.csv`",
        "- `ridemodel_local_candidate_hits.csv`",
        "- `ridemodel_shared_candidate_hits.csv`",
    ]
    (output_dir / "README.md").write_text("\n".join(md_lines) + "\n", encoding="utf-8")

    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

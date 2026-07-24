#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import re
import struct
from pathlib import Path


COLOR_RE = re.compile(r"^\d{1,3},\d{1,3},\d{1,3},\d{1,3}$")


def extract_utf8_strings(data: bytes, min_len: int = 2) -> list[str]:
    out: list[str] = []
    cur = bytearray()
    for b in data:
        if 32 <= b <= 126 or b >= 0x80:
            cur.append(b)
            continue
        if len(cur) >= min_len:
            try:
                out.append(cur.decode("utf-8"))
            except Exception:
                pass
        cur = bytearray()
    if len(cur) >= min_len:
        try:
            out.append(cur.decode("utf-8"))
        except Exception:
            pass
    return out


def read_i32(data: bytes, offset: int) -> tuple[int, int]:
    return struct.unpack_from("<i", data, offset)[0], offset + 4


def read_str(data: bytes, offset: int) -> tuple[str, int]:
    n, offset = read_i32(data, offset)
    if n < 0 or offset + n > len(data):
        raise ValueError(f"bad string length {n} at {offset - 4}")
    text = data[offset:offset + n].decode("utf-8", errors="replace")
    return text, offset + n


def parse_cchatboxout(path: Path) -> dict:
    data = path.read_bytes()
    offset = 0
    magic, offset = read_i32(data, offset)
    file_length, offset = read_i32(data, offset)
    version = struct.unpack_from("<H", data, offset)[0]
    offset += 2
    item_count = struct.unpack_from("<H", data, offset)[0]
    offset += 2
    check_number, offset = read_i32(data, offset)

    rows = []
    error = None
    try:
        for idx in range(item_count):
            record_id, offset = read_i32(data, offset)
            widget_look, offset = read_str(data, offset)
            display_name, offset = read_str(data, offset)
            font_color, offset = read_str(data, offset)
            top, offset = read_i32(data, offset)
            left, offset = read_i32(data, offset)
            path_text, offset = read_str(data, offset)
            location, offset = read_i32(data, offset)
            width, offset = read_i32(data, offset)
            height, offset = read_i32(data, offset)
            show_path, offset = read_str(data, offset)
            price, offset = read_i32(data, offset)

            rows.append(
                {
                    "index": idx,
                    "id": record_id,
                    "widget_look": widget_look,
                    "display_name": display_name,
                    "font_color": font_color,
                    "top": top,
                    "left": left,
                    "path": path_text,
                    "location": location,
                    "width": width,
                    "height": height,
                    "show_path": show_path,
                    "price": price,
                }
            )
    except Exception as ex:
        error = {"index": len(rows), "offset": offset, "error": str(ex)}

    result = {
        "table": path.name,
        "magic": magic,
        "file_length": file_length,
        "version": version,
        "item_count": item_count,
        "check_number": check_number,
        "rows": rows,
        "error": error,
        "remaining_bytes": len(data) - offset,
    }
    if rows and error is None:
        return result

    strings = extract_utf8_strings(data, min_len=2)
    grouped_rows = []
    i = 0
    while i < len(strings):
        if not strings[i].startswith("TaharezLook/POPORichEditbox"):
            i += 1
            continue
        if i + 3 >= len(strings):
            break
        grouped_rows.append(
            {
                "index": len(grouped_rows),
                "id": "",
                "widget_look": strings[i],
                "display_name": strings[i + 1],
                "font_color": strings[i + 2],
                "top": "",
                "left": "",
                "path": strings[i + 3],
                "location": "",
                "width": "",
                "height": "",
                "show_path": "",
                "price": "",
            }
        )
        i += 4
    result["string_group_rows"] = grouped_rows
    result["string_group_count"] = len(grouped_rows)
    return result


def parse_ctitleconfig_semantic(path: Path) -> dict:
    strings = extract_utf8_strings(path.read_bytes(), min_len=2)
    blocks = []
    start = 0
    idx = 0
    while idx < len(strings):
        if not COLOR_RE.match(strings[idx]):
            idx += 1
            continue

        pre = strings[start:idx]
        color = strings[idx]
        gettype = ""
        next_idx = idx + 1
        if next_idx < len(strings) and not COLOR_RE.match(strings[next_idx]):
            gettype = strings[next_idx]
            idx = next_idx

        blocks.append(
            {
                "block_index": len(blocks),
                "leading_fields": pre,
                "font_color": color,
                "get_type": gettype,
            }
        )
        start = idx + 1
        idx += 1

    return {
        "table": path.name,
        "string_count": len(strings),
        "blocks": blocks,
    }


def parse_ctitleconfig_structured(path: Path) -> dict:
    data = path.read_bytes()
    offset = 0

    magic, offset = read_i32(data, offset)
    file_length, offset = read_i32(data, offset)
    version = struct.unpack_from("<H", data, offset)[0]
    offset += 2
    item_count = struct.unpack_from("<H", data, offset)[0]
    offset += 2
    check_number, offset = read_i32(data, offset)

    legacy_rows = []
    rank_rows = []
    legacy_error = None

    legacy_offset = offset
    legacy_resume_offset = offset
    try:
        while len(legacy_rows) < item_count:
            legacy_resume_offset = legacy_offset
            row = {
                "variant": "legacy",
                "id": read_i32(data, legacy_offset)[0],
            }
            legacy_offset += 4
            row["titlename"], legacy_offset = read_str(data, legacy_offset)
            row["availtime"], legacy_offset = read_i32(data, legacy_offset)
            row["category"], legacy_offset = read_str(data, legacy_offset)
            row["species"], legacy_offset = read_str(data, legacy_offset)
            row["description"], legacy_offset = read_str(data, legacy_offset)
            row["fontcolor"], legacy_offset = read_str(data, legacy_offset)
            row["chatsee"], legacy_offset = read_i32(data, legacy_offset)
            row["buff"], legacy_offset = read_i32(data, legacy_offset)
            row["gettype"], legacy_offset = read_str(data, legacy_offset)
            legacy_rows.append(row)
    except Exception as ex:
        legacy_error = {"index": len(legacy_rows), "offset": legacy_offset, "error": str(ex)}

    rank_offset = legacy_resume_offset
    rank_error = None
    try:
        while len(legacy_rows) + len(rank_rows) < item_count:
            row = {
                "variant": "rank",
                "id": read_i32(data, rank_offset)[0],
            }
            rank_offset += 4
            row["titlename"], rank_offset = read_str(data, rank_offset)
            row["availtime"], rank_offset = read_i32(data, rank_offset)
            row["category"], rank_offset = read_str(data, rank_offset)
            row["species"], rank_offset = read_str(data, rank_offset)
            row["description"], rank_offset = read_str(data, rank_offset)
            row["color1"], rank_offset = read_str(data, rank_offset)
            row["color2"], rank_offset = read_str(data, rank_offset)
            row["color3"], rank_offset = read_str(data, rank_offset)
            row["gettype"], rank_offset = read_str(data, rank_offset)
            rank_rows.append(row)
    except Exception as ex:
        rank_error = {"index": len(rank_rows), "offset": rank_offset, "error": str(ex)}

    return {
        "table": path.name,
        "magic": magic,
        "file_length": file_length,
        "version": version,
        "item_count": item_count,
        "check_number": check_number,
        "legacy_rows": legacy_rows,
        "rank_rows": rank_rows,
        "legacy_error": legacy_error,
        "rank_error": rank_error,
        "remaining_bytes": len(data) - rank_offset,
    }


def write_csv(path: Path, rows: list[dict], fieldnames: list[str]) -> None:
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Extract semantic records from cchatboxout/title drift binary tables."
    )
    parser.add_argument("--chatbox-bin", required=True, type=Path)
    parser.add_argument("--title-bin", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    args = parser.parse_args()

    args.output_dir.mkdir(parents=True, exist_ok=True)

    chatbox = parse_cchatboxout(args.chatbox_bin)
    title = parse_ctitleconfig_semantic(args.title_bin)
    title_structured = parse_ctitleconfig_structured(args.title_bin)

    cchatbox_rows = chatbox["rows"]
    if len(cchatbox_rows) < 2 and chatbox.get("string_group_rows"):
        cchatbox_rows = chatbox["string_group_rows"]

    write_csv(
        args.output_dir / "cchatboxout_records.csv",
        cchatbox_rows,
        ["index", "id", "widget_look", "display_name", "font_color", "top", "left", "path", "location", "width", "height", "show_path", "price"],
    )
    write_csv(
        args.output_dir / "ctitleconfig_semantic_blocks.csv",
        [
            {
                "block_index": row["block_index"],
                "leading_fields": " | ".join(row["leading_fields"]),
                "font_color": row["font_color"],
                "get_type": row["get_type"],
            }
            for row in title["blocks"]
        ],
        ["block_index", "leading_fields", "font_color", "get_type"],
    )

    structured_rows = []
    for row in title_structured["legacy_rows"]:
        structured_rows.append(
            {
                "variant": row["variant"],
                "id": row["id"],
                "titlename": row["titlename"],
                "availtime": row["availtime"],
                "category": row["category"],
                "species": row["species"],
                "description": row["description"],
                "fontcolor": row["fontcolor"],
                "chatsee_or_color1": row["chatsee"],
                "buff_or_color2": row["buff"],
                "color3": "",
                "gettype": row["gettype"],
            }
        )
    for row in title_structured["rank_rows"]:
        structured_rows.append(
            {
                "variant": row["variant"],
                "id": row["id"],
                "titlename": row["titlename"],
                "availtime": row["availtime"],
                "category": row["category"],
                "species": row["species"],
                "description": row["description"],
                "fontcolor": "",
                "chatsee_or_color1": row["color1"],
                "buff_or_color2": row["color2"],
                "color3": row["color3"],
                "gettype": row["gettype"],
            }
        )
    write_csv(
        args.output_dir / "ctitleconfig_records.csv",
        structured_rows,
        [
            "variant",
            "id",
            "titlename",
            "availtime",
            "category",
            "species",
            "description",
            "fontcolor",
            "chatsee_or_color1",
            "buff_or_color2",
            "color3",
            "gettype",
        ],
    )

    payload = {
        "cchatboxout": chatbox,
        "ctitleconfig": title,
        "ctitleconfig_structured": title_structured,
    }
    with (args.output_dir / "semantic_binary_records.json").open("w", encoding="utf-8", newline="\n") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
        f.write("\n")

    md_lines = [
        "# Semantic Binary Records",
        "",
        f"- cchatboxout parsed rows: {len(chatbox['rows'])}",
        f"- cchatboxout fallback grouped rows: {chatbox.get('string_group_count', 0)}",
        f"- cchatboxout parse error: {chatbox['error']}",
        f"- ctitle semantic blocks: {len(title['blocks'])}",
        f"- ctitle structured legacy rows: {len(title_structured['legacy_rows'])}",
        f"- ctitle structured rank rows: {len(title_structured['rank_rows'])}",
        f"- ctitle legacy parse error: {title_structured['legacy_error']}",
        f"- ctitle rank parse error: {title_structured['rank_error']}",
        "",
        "## CChatBoxOut",
    ]
    for row in cchatbox_rows:
        md_lines.append(
            f"- #{row['index']} id={row['id']} | {row['widget_look']} | {row['display_name']} | {row['font_color']} | top={row['top']} left={row['left']} location={row['location']} size={row['width']}x{row['height']} | path={row['path']} | show={row['show_path']} | price={row['price']}"
        )
    md_lines.append("")
    md_lines.append("## CTitleConfig Semantic Blocks")
    for row in title["blocks"][:80]:
        md_lines.append(
            f"- #{row['block_index']} | {' | '.join(row['leading_fields'])} | {row['font_color']} | {row['get_type']}"
        )

    (args.output_dir / "semantic_binary_records.md").write_text(
        "\n".join(md_lines) + "\n",
        encoding="utf-8",
    )

    print(
        json.dumps(
            {
                "output_dir": str(args.output_dir),
                "cchatboxout_rows": len(chatbox["rows"]),
                "cchatboxout_string_group_rows": chatbox.get("string_group_count", 0),
                "ctitle_blocks": len(title["blocks"]),
                "cchatboxout_error": chatbox["error"],
            },
            ensure_ascii=False,
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

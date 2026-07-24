from __future__ import annotations

import argparse
import codecs
import difflib
import fnmatch
import hashlib
import json
import os
import re
import subprocess
import sys
import unicodedata
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath
from typing import Any, Iterable
from urllib.parse import unquote, urlsplit


REQUIRED_POLICY_KEYS = {
    "schema_version",
    "inventory_patterns",
    "tracked_only",
    "docs_directory_names",
    "case_insensitive_directory_match",
    "excluded_path_segments",
    "editorial_extensions",
    "near_duplicate_threshold",
    "minimum_similarity_tokens",
    "vendor_path_segments",
    "vendor_path_prefixes",
    "protected_file_name_patterns",
    "generated_path_patterns",
    "strict_markdown_utf8_no_bom_lf",
    "fail_on_encoding_issues",
    "fail_on_fence_issues",
    "fail_on_heading_issues",
    "fail_on_exact_duplicates",
}
REVIEW_DOMAINS = {
    "root_current",
    "platform_build",
    "architecture_resource",
    "module_first_party",
    "historical_archive",
    "generated_evidence",
    "vendor_snapshot",
}

REFERENCE_LINK_RE = re.compile(
    r"^\s{0,3}\[[^\]]+\]:\s*(?:<([^>]+)>|(\S+))", re.MULTILINE
)
ATX_HEADING_RE = re.compile(r"^\s{0,3}(#{1,6})(?:[ \t]+(.*)|[ \t]*)$")
SETEXT_HEADING_RE = re.compile(r"^\s{0,3}(=+|-+)[ \t]*$")
FENCE_RE = re.compile(r"^\s{0,3}(`{3,}|~{3,})")
SOURCE_LINE_TARGET_RE = re.compile(
    r"^(?P<path>.+):(?P<start>\d+)(?:-(?P<end>\d+))?$"
)
TOKEN_RE = re.compile(
    r"[A-Za-z0-9]+(?:[-_'][A-Za-z0-9]+)*|"
    r"[\u3400-\u4dbf\u4e00-\u9fff]|"
    r"[^\W_]+",
    re.UNICODE,
)


def _normalize_relative_path(path: str) -> str:
    normalized = path.replace("\\", "/")
    while normalized.startswith("./"):
        normalized = normalized[2:]
    return normalized.strip("/")


def _require_string_list(policy: dict[str, Any], key: str) -> None:
    value = policy.get(key)
    if not isinstance(value, list) or not value or not all(
        isinstance(item, str) and item for item in value
    ):
        raise ValueError(f"policy field must be a non-empty string array: {key}")


def load_policy(path: Path) -> dict:
    with path.open("r", encoding="utf-8", errors="strict") as stream:
        policy = json.load(stream)
    if not isinstance(policy, dict):
        raise ValueError("docs audit policy must be a JSON object")

    missing = sorted(REQUIRED_POLICY_KEYS.difference(policy))
    if missing:
        raise ValueError(f"docs audit policy is missing fields: {', '.join(missing)}")
    if not isinstance(policy["schema_version"], str) or not policy["schema_version"]:
        raise ValueError("policy schema_version must be a non-empty string")

    for key in (
        "docs_directory_names",
        "inventory_patterns",
        "excluded_path_segments",
        "editorial_extensions",
        "vendor_path_segments",
        "vendor_path_prefixes",
        "protected_file_name_patterns",
        "generated_path_patterns",
    ):
        _require_string_list(policy, key)

    if not isinstance(policy["case_insensitive_directory_match"], bool):
        raise ValueError("case_insensitive_directory_match must be a boolean")
    if not isinstance(policy["tracked_only"], bool):
        raise ValueError("tracked_only must be a boolean")
    if not isinstance(policy["strict_markdown_utf8_no_bom_lf"], bool):
        raise ValueError("strict_markdown_utf8_no_bom_lf must be a boolean")
    for key in (
        "fail_on_encoding_issues",
        "fail_on_fence_issues",
        "fail_on_heading_issues",
        "fail_on_exact_duplicates",
    ):
        if not isinstance(policy[key], bool):
            raise ValueError(f"{key} must be a boolean")
    threshold = policy["near_duplicate_threshold"]
    if not isinstance(threshold, (int, float)) or isinstance(threshold, bool):
        raise ValueError("near_duplicate_threshold must be numeric")
    if not 0.0 <= float(threshold) <= 1.0:
        raise ValueError("near_duplicate_threshold must be between 0.0 and 1.0")
    minimum_tokens = policy["minimum_similarity_tokens"]
    if not isinstance(minimum_tokens, int) or isinstance(minimum_tokens, bool):
        raise ValueError("minimum_similarity_tokens must be an integer")
    if minimum_tokens < 0:
        raise ValueError("minimum_similarity_tokens must not be negative")
    if not all(extension.startswith(".") for extension in policy["editorial_extensions"]):
        raise ValueError("editorial_extensions entries must begin with a dot")
    return policy


def _matches_directory_name(name: str, policy: dict) -> bool:
    candidates = policy["docs_directory_names"]
    if policy["case_insensitive_directory_match"]:
        return name.casefold() in {candidate.casefold() for candidate in candidates}
    return name in candidates


def _is_excluded_segment(name: str, policy: dict) -> bool:
    excluded = {segment.casefold() for segment in policy["excluded_path_segments"]}
    return name.casefold() in excluded


def _raise_walk_error(error: OSError) -> None:
    raise error


def list_docs_directories(root: Path, policy: dict) -> list[Path]:
    root = root.resolve()
    if not root.is_dir():
        raise FileNotFoundError(f"docs inventory root is not a directory: {root}")

    matches: list[Path] = []
    for pattern in policy["inventory_patterns"]:
        parts = PurePosixPath(_normalize_relative_path(pattern)).parts
        if not parts or any(character in parts[0] for character in "*?["):
            continue
        candidate = root / parts[0]
        if candidate.is_dir() and not _is_excluded_segment(parts[0], policy):
            matches.append(candidate)

    unique: dict[str, Path] = {}
    for match in matches:
        relative = match.relative_to(root).as_posix()
        unique.setdefault(relative.casefold(), match)
    return sorted(
        unique.values(),
        key=lambda item: item.relative_to(root).as_posix().casefold(),
    )


def _run_git_paths(root: Path, arguments: list[str]) -> list[str]:
    if not root.is_dir():
        return []
    command = ["git", "-C", str(root), "ls-files", "-z", *arguments]
    try:
        result = subprocess.run(
            command,
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
    except OSError as error:
        raise RuntimeError(f"unable to start Git for docs audit root {root}: {error}") from error
    if result.returncode != 0:
        stderr = result.stderr.decode("utf-8", errors="replace").strip()
        stdout = result.stdout.decode("utf-8", errors="replace").strip()
        detail = stderr or stdout or f"exit code {result.returncode}"
        if "not a git repository" in detail.casefold():
            return []
        raise RuntimeError(
            f"Git path query failed for docs audit root {root}: {detail}"
        )

    decoded = result.stdout.decode("utf-8", errors="surrogateescape")
    return sorted(
        {
            _normalize_relative_path(item)
            for item in decoded.split("\0")
            if item
        },
        key=str.casefold,
    )


def list_git_paths(project_root: Path, inventory_root: Path) -> dict[str, str]:
    states: dict[str, tuple[str, str]] = {}
    priorities = {"ignored": 1, "untracked": 2, "tracked": 3}

    def merge(paths: Iterable[str], state: str) -> None:
        for relative_path in paths:
            normalized_path = _normalize_relative_path(relative_path)
            path_key = normalized_path.casefold()
            existing = states.get(path_key)
            if existing is None or priorities[state] > priorities[existing[1]]:
                states[path_key] = (normalized_path, state)

    merge(_run_git_paths(project_root, ["--cached"]), "tracked")
    merge(
        _run_git_paths(project_root, ["--others", "--exclude-standard"]),
        "untracked",
    )
    merge(
        _run_git_paths(
            project_root,
            ["--others", "--ignored", "--exclude-standard"],
        ),
        "ignored",
    )
    merge(
        _run_git_paths(inventory_root, ["--others", "--exclude-standard"]),
        "untracked",
    )
    merge(
        _run_git_paths(
            inventory_root,
            ["--others", "--ignored", "--exclude-standard"],
        ),
        "ignored",
    )
    return dict(
        sorted(
            (normalized_and_state for normalized_and_state in states.values()),
            key=lambda item: item[0].casefold(),
        )
    )


def _join_relative(root: Path, relative_path: str) -> Path:
    parts = PurePosixPath(_normalize_relative_path(relative_path)).parts
    return root.joinpath(*parts)


def select_content_path(
    relative_path: str, project_root: Path, inventory_root: Path
) -> tuple[Path, str]:
    project_path = _join_relative(project_root, relative_path)
    if project_path.is_file():
        return project_path, "branch"
    inventory_path = _join_relative(inventory_root, relative_path)
    if inventory_path.is_file():
        return inventory_path, "local_only"
    raise FileNotFoundError(f"document disappeared during audit: {relative_path}")


def _detect_newline(text: str) -> str:
    crlf_count = text.count("\r\n")
    without_crlf = text.replace("\r\n", "")
    lf_count = without_crlf.count("\n")
    cr_count = without_crlf.count("\r")
    kinds = [
        name
        for name, count in (("CRLF", crlf_count), ("LF", lf_count), ("CR", cr_count))
        if count
    ]
    if not kinds:
        return "NONE"
    if len(kinds) == 1:
        return kinds[0]
    return "MIXED"


def read_document_text(path: Path) -> tuple[str, str, bool, str]:
    raw = path.read_bytes()
    bom_decoders = (
        (codecs.BOM_UTF32_LE, "utf-32-le"),
        (codecs.BOM_UTF32_BE, "utf-32-be"),
        (codecs.BOM_UTF8, "utf-8"),
        (codecs.BOM_UTF16_LE, "utf-16-le"),
        (codecs.BOM_UTF16_BE, "utf-16-be"),
    )
    for marker, encoding in bom_decoders:
        if raw.startswith(marker):
            text = raw[len(marker) :].decode(encoding, errors="strict")
            return text, encoding, True, _detect_newline(text)

    last_error: UnicodeDecodeError | None = None
    for encoding in ("utf-8", "gb18030", "cp1252"):
        try:
            text = raw.decode(encoding, errors="strict")
            return text, encoding, False, _detect_newline(text)
        except UnicodeDecodeError as error:
            last_error = error
    if last_error is None:
        raise UnicodeError(f"unable to decode document: {path}")
    raise last_error


def classify_ownership(relative_path: str, policy: dict) -> str:
    normalized = _normalize_relative_path(relative_path)
    folded_path = normalized.casefold()
    path_segments = {segment.casefold() for segment in PurePosixPath(normalized).parts}
    vendor_segments = {segment.casefold() for segment in policy["vendor_path_segments"]}
    if path_segments.intersection(vendor_segments):
        return "vendor"
    for prefix in policy["vendor_path_prefixes"]:
        if folded_path.startswith(_normalize_relative_path(prefix).casefold()):
            return "vendor"
    return "first_party"


def _glob_pattern_regex(pattern: str) -> re.Pattern[str]:
    pattern = _normalize_relative_path(pattern).casefold()
    pieces = ["^"]
    index = 0
    while index < len(pattern):
        if pattern[index : index + 3] == "**/":
            pieces.append("(?:.*/)?")
            index += 3
        elif pattern[index : index + 2] == "**":
            pieces.append(".*")
            index += 2
        elif pattern[index] == "*":
            pieces.append("[^/]*")
            index += 1
        elif pattern[index] == "?":
            pieces.append("[^/]")
            index += 1
        else:
            pieces.append(re.escape(pattern[index]))
            index += 1
    pieces.append("$")
    return re.compile("".join(pieces))


def _matches_path_pattern(relative_path: str, pattern: str) -> bool:
    normalized = _normalize_relative_path(relative_path).casefold()
    return _glob_pattern_regex(pattern).fullmatch(normalized) is not None


def classify_document(relative_path: str, policy: dict) -> str:
    if classify_ownership(relative_path, policy) == "vendor":
        return "vendor"
    if any(
        _matches_path_pattern(relative_path, pattern)
        for pattern in policy["generated_path_patterns"]
    ):
        return "generated"

    normalized = _normalize_relative_path(relative_path)
    segments = {segment.casefold() for segment in PurePosixPath(normalized).parts}
    historical_segments = {
        "archive",
        "archives",
        "archived",
        "backup",
        "backups",
        "deprecated",
        "historical",
        "history",
        "legacy",
        "obsolete",
        "old",
    }
    if segments.intersection(historical_segments):
        return "historical"
    first_segment = PurePosixPath(normalized).parts[0].casefold()
    docs_names = {name.casefold() for name in policy["docs_directory_names"]}
    if first_segment in docs_names:
        return "active"
    return "module"


def normalize_document_text(text: str) -> str:
    normalized_newlines = text.replace("\r\n", "\n").replace("\r", "\n")
    normalized_characters: list[str] = []
    for character in normalized_newlines:
        if character == "\n":
            normalized_characters.append(character)
        elif character.isspace() or unicodedata.category(character) == "Zs":
            normalized_characters.append(" ")
        else:
            normalized_characters.append(character)
    normalized_whitespace = "".join(normalized_characters)
    return "\n".join(
        re.sub(r" +", " ", line).rstrip(" ")
        for line in normalized_whitespace.split("\n")
    )


def _is_escaped(text: str, index: int) -> bool:
    backslashes = 0
    cursor = index - 1
    while cursor >= 0 and text[cursor] == "\\":
        backslashes += 1
        cursor -= 1
    return backslashes % 2 == 1


def _is_indented_code_line(line: str) -> bool:
    indentation = 0
    for character in line:
        if character == " ":
            indentation += 1
        elif character == "\t":
            indentation += 4 - (indentation % 4)
        else:
            break
        if indentation >= 4:
            return True
    return False


def _strip_inline_code_spans(line: str) -> str:
    characters = list(line)
    index = 0
    while index < len(line):
        if line[index] != "`" or _is_escaped(line, index):
            index += 1
            continue
        run_length = 1
        while index + run_length < len(line) and line[index + run_length] == "`":
            run_length += 1
        cursor = index + run_length
        closing_index = -1
        while cursor < len(line):
            if line[cursor] != "`" or _is_escaped(line, cursor):
                cursor += 1
                continue
            closing_length = 1
            while (
                cursor + closing_length < len(line)
                and line[cursor + closing_length] == "`"
            ):
                closing_length += 1
            if closing_length == run_length:
                closing_index = cursor
                break
            cursor += closing_length
        if closing_index < 0:
            index += run_length
            continue
        for character_index in range(index, closing_index + run_length):
            if characters[character_index] not in {"\r", "\n"}:
                characters[character_index] = " "
        index = closing_index + run_length
    return "".join(characters)


def _strip_fenced_code(text: str) -> str:
    output: list[str] = []
    active_marker = ""
    active_length = 0
    for line in text.splitlines():
        fence = FENCE_RE.match(line)
        if fence:
            marker = fence.group(1)
            if not active_marker:
                active_marker = marker[0]
                active_length = len(marker)
                output.append("")
                continue
            if marker[0] == active_marker and len(marker) >= active_length:
                active_marker = ""
                active_length = 0
                output.append("")
                continue
        if active_marker or _is_indented_code_line(line):
            output.append("")
        else:
            output.append(line)
    return _strip_inline_code_spans("\n".join(output))


def _find_closing_bracket(text: str, opening_index: int) -> int | None:
    depth = 1
    cursor = opening_index + 1
    while cursor < len(text):
        character = text[cursor]
        if character == "\\" and cursor + 1 < len(text):
            cursor += 2
            continue
        if character == "[":
            depth += 1
        elif character == "]":
            depth -= 1
            if depth == 0:
                return cursor
        cursor += 1
    return None


def _find_link_container_end(text: str, cursor: int) -> int | None:
    depth = 1
    quote = ""
    while cursor < len(text):
        character = text[cursor]
        if character == "\\" and cursor + 1 < len(text):
            cursor += 2
            continue
        if quote:
            if character == quote:
                quote = ""
        elif character in {"'", '"'}:
            quote = character
        elif character == "(":
            depth += 1
        elif character == ")":
            depth -= 1
            if depth == 0:
                return cursor + 1
        cursor += 1
    return None


def _parse_inline_link_destination(
    text: str, opening_parenthesis: int
) -> tuple[str, int] | None:
    cursor = opening_parenthesis + 1
    while cursor < len(text) and text[cursor] in {" ", "\t"}:
        cursor += 1
    if cursor >= len(text):
        return None

    if text[cursor] == "<":
        cursor += 1
        destination: list[str] = []
        while cursor < len(text):
            character = text[cursor]
            if character == "\\" and cursor + 1 < len(text):
                destination.append(text[cursor + 1])
                cursor += 2
                continue
            if character in {"\r", "\n"}:
                return None
            if character == ">":
                container_end = _find_link_container_end(text, cursor + 1)
                if container_end is None:
                    return None
                return "".join(destination), container_end
            destination.append(character)
            cursor += 1
        return None

    destination = []
    depth = 1
    collecting_destination = True
    quote = ""
    while cursor < len(text):
        character = text[cursor]
        if character == "\\" and cursor + 1 < len(text):
            if collecting_destination:
                destination.append(text[cursor + 1])
            cursor += 2
            continue
        if collecting_destination:
            if character in {"\r", "\n"}:
                return None
            if character.isspace() and depth == 1:
                collecting_destination = False
            elif character == "(":
                depth += 1
                destination.append(character)
            elif character == ")":
                depth -= 1
                if depth == 0:
                    return "".join(destination), cursor + 1
                destination.append(character)
            else:
                destination.append(character)
        elif quote:
            if character == quote:
                quote = ""
        elif character in {"'", '"'}:
            quote = character
        elif character == "(":
            depth += 1
        elif character == ")":
            depth -= 1
            if depth == 0:
                return "".join(destination), cursor + 1
        cursor += 1
    return None


def _extract_inline_link_targets(text: str) -> list[str]:
    targets: list[str] = []
    index = 0
    while index < len(text):
        if text[index] != "[" or _is_escaped(text, index):
            index += 1
            continue
        if index > 0 and text[index - 1] == "!" and _is_escaped(text, index - 1):
            index += 1
            continue
        closing_bracket = _find_closing_bracket(text, index)
        if closing_bracket is None or closing_bracket + 1 >= len(text):
            index += 1
            continue
        opening_parenthesis = closing_bracket + 1
        if text[opening_parenthesis] != "(":
            index = closing_bracket + 1
            continue
        parsed = _parse_inline_link_destination(text, opening_parenthesis)
        if parsed is None:
            index += 1
            continue
        target, container_end = parsed
        targets.append(target)
        index = container_end
    return targets


def _parse_source_line_target(target: str) -> dict[str, Any] | None:
    value = target.strip()
    match = SOURCE_LINE_TARGET_RE.fullmatch(value)
    if match is None:
        return None
    source_path = match.group("path")
    parsed = urlsplit(source_path)
    if parsed.scheme or source_path.startswith(("#", "//")):
        return None
    start = int(match.group("start"))
    end = int(match.group("end") or start)
    return {"path": source_path, "start": start, "end": end}


def _is_relative_link(target: str) -> bool:
    value = target.strip()
    if not value or value.startswith("#") or value.startswith("//"):
        return False
    if _parse_source_line_target(value) is not None:
        return True
    parsed = urlsplit(value)
    if parsed.scheme:
        return False
    if re.fullmatch(r"[^/@\s]+@[^/@\s]+\.[^/@\s]+", value):
        return False
    return True


def extract_relative_markdown_links(text: str) -> list[str]:
    searchable = _strip_fenced_code(text)
    targets: list[str] = []
    for target in _extract_inline_link_targets(searchable):
        target = target.strip()
        if _is_relative_link(target):
            targets.append(target)
    for match in REFERENCE_LINK_RE.finditer(searchable):
        target = next((group for group in match.groups() if group is not None), "")
        target = target.strip()
        if _is_relative_link(target):
            targets.append(target)
    return list(dict.fromkeys(targets))


def find_heading_issues(text: str, relative_path: str) -> list[dict]:
    headings: list[dict[str, Any]] = []
    issues: list[dict[str, Any]] = []
    lines = text.splitlines()
    active_marker = ""
    active_length = 0
    index = 0

    if lines and lines[0].strip() == "---":
        for front_matter_index in range(1, len(lines)):
            if lines[front_matter_index].strip() in {"---", "..."}:
                index = front_matter_index + 1
                break

    while index < len(lines):
        line = lines[index]
        fence = FENCE_RE.match(line)
        if fence:
            marker = fence.group(1)
            if not active_marker:
                active_marker = marker[0]
                active_length = len(marker)
            elif marker[0] == active_marker and len(marker) >= active_length:
                active_marker = ""
                active_length = 0
            index += 1
            continue
        if active_marker:
            index += 1
            continue

        atx = ATX_HEADING_RE.match(line)
        if atx:
            level = len(atx.group(1))
            heading_text = (atx.group(2) or "").strip()
            heading_text = re.sub(r"[ \t]+#+[ \t]*$", "", heading_text).strip()
            heading = {"level": level, "line": index + 1, "text": heading_text}
            headings.append(heading)
            if not heading_text:
                issues.append(
                    {
                        "path": relative_path,
                        "type": "empty_heading",
                        "line": index + 1,
                        "message": "heading text is empty",
                    }
                )
            index += 1
            continue

        if index + 1 < len(lines) and line.strip():
            setext = SETEXT_HEADING_RE.match(lines[index + 1])
            if setext:
                level = 1 if setext.group(1).startswith("=") else 2
                headings.append(
                    {"level": level, "line": index + 1, "text": line.strip()}
                )
                index += 2
                continue
        index += 1

    if headings and headings[0]["level"] != 1:
        issues.append(
            {
                "path": relative_path,
                "type": "first_heading_not_h1",
                "line": headings[0]["line"],
                "actual_level": headings[0]["level"],
                "message": "first heading is not H1",
            }
        )

    h1_lines = [heading["line"] for heading in headings if heading["level"] == 1]
    if len(h1_lines) > 1:
        issues.append(
            {
                "path": relative_path,
                "type": "multiple_h1",
                "lines": h1_lines,
                "message": "document contains multiple H1 headings",
            }
        )

    for previous, current in zip(headings, headings[1:]):
        if current["level"] > previous["level"] + 1:
            issues.append(
                {
                    "path": relative_path,
                    "type": "heading_level_jump",
                    "line": current["line"],
                    "previous_level": previous["level"],
                    "actual_level": current["level"],
                    "message": "heading level jumps by more than one",
                }
            )
    return issues


def find_fence_issues(text: str, relative_path: str) -> list[dict[str, Any]]:
    active_marker = ""
    active_length = 0
    opening_line = 0
    for line_number, line in enumerate(text.splitlines(), start=1):
        fence = FENCE_RE.match(line)
        if fence is None:
            continue
        marker = fence.group(1)
        if not active_marker:
            active_marker = marker[0]
            active_length = len(marker)
            opening_line = line_number
        elif marker[0] == active_marker and len(marker) >= active_length:
            active_marker = ""
            active_length = 0
            opening_line = 0
    if not active_marker:
        return []
    return [
        {
            "path": relative_path,
            "type": "unclosed_fence",
            "line": opening_line,
            "message": "fenced code block is not closed",
        }
    ]


def token_sequence_ratio(left: list[str], right: list[str]) -> float:
    if not left and not right:
        return 1.0
    if not left or not right:
        return 0.0
    return float(difflib.SequenceMatcher(None, left, right, autojunk=False).ratio())


def write_json_report(report: dict, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    serialized = json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    with path.open("w", encoding="utf-8", errors="strict", newline="\n") as stream:
        stream.write(serialized)


def _list_editorial_files(
    root: Path, docs_directories: list[Path], policy: dict
) -> dict[str, tuple[str, str]]:
    extensions = {extension.casefold() for extension in policy["editorial_extensions"]}
    discovered: dict[str, tuple[str, str]] = {}
    patterns = policy["inventory_patterns"]

    for pattern in patterns:
        if any(character in pattern for character in "*?["):
            continue
        file_path = _join_relative(root, pattern)
        if file_path.is_file() and file_path.suffix.casefold() in extensions:
            relative_path = file_path.relative_to(root).as_posix()
            discovered[relative_path.casefold()] = (relative_path, ".")

    for docs_directory in docs_directories:
        docs_root = docs_directory.relative_to(root).as_posix()
        for current, directory_names, file_names in os.walk(
            docs_directory,
            topdown=True,
            followlinks=False,
            onerror=_raise_walk_error,
        ):
            directory_names[:] = sorted(
                (
                    name
                    for name in directory_names
                    if not _is_excluded_segment(name, policy)
                ),
                key=str.casefold,
            )
            current_path = Path(current)
            for file_name in sorted(file_names, key=str.casefold):
                if Path(file_name).suffix.casefold() not in extensions:
                    continue
                file_path = current_path / file_name
                if not file_path.is_file():
                    continue
                relative_path = file_path.relative_to(root).as_posix()
                if not any(
                    _matches_path_pattern(relative_path, pattern)
                    for pattern in patterns
                ):
                    continue
                key = relative_path.casefold()
                existing = discovered.get(key)
                if existing is None:
                    discovered[key] = (relative_path, docs_root)
                    continue
                existing_depth = len(PurePosixPath(existing[1]).parts)
                current_depth = len(PurePosixPath(docs_root).parts)
                if current_depth > existing_depth:
                    discovered[key] = (relative_path, docs_root)
    return discovered


def _is_protected(relative_path: str, policy: dict) -> bool:
    file_name = PurePosixPath(relative_path).name.casefold()
    return any(
        fnmatch.fnmatchcase(file_name, pattern.casefold())
        for pattern in policy["protected_file_name_patterns"]
    )


def _tokenize(text: str) -> list[str]:
    return [match.group(0).casefold() for match in TOKEN_RE.finditer(text)]


def _load_review_statuses(path: Path) -> tuple[dict[str, dict[str, Any]], bool]:
    if not path.is_file():
        return {}, False
    with path.open("r", encoding="utf-8", errors="strict") as stream:
        document = json.load(stream)
    if not isinstance(document, dict):
        raise ValueError("docs review manifest must be a JSON object")

    items = document.get("records")
    if not isinstance(items, list):
        raise ValueError("docs review manifest records must be an array")

    metadata_by_path: dict[str, dict[str, Any]] = {}
    required_fields = (
        "path",
        "domain",
        "review_status",
        "canonical_target",
        "replacement_for",
        "evidence_sources",
    )
    for index, item in enumerate(items):
        if not isinstance(item, dict):
            raise ValueError(f"docs review manifest record {index} must be an object")
        missing = [field for field in required_fields if field not in item]
        if missing:
            raise ValueError(
                f"docs review manifest record {index} is missing fields: {', '.join(missing)}"
            )

        relative_path = item["path"]
        if not isinstance(relative_path, str) or not relative_path:
            raise ValueError(f"docs review manifest record {index} path must be a string")
        normalized_path = _normalize_relative_path(relative_path)
        if not normalized_path:
            raise ValueError(f"docs review manifest record {index} path is empty")
        path_key = normalized_path.casefold()
        if path_key in metadata_by_path:
            raise ValueError(f"duplicate docs review manifest path: {normalized_path}")

        domain = item["domain"]
        if not isinstance(domain, str) or domain not in REVIEW_DOMAINS:
            raise ValueError(
                f"docs review manifest record {normalized_path} has invalid domain: {domain!r}"
            )
        review_status = item["review_status"]
        if not isinstance(review_status, str) or not review_status:
            raise ValueError(
                f"docs review manifest record {normalized_path} review_status must be a string"
            )
        canonical_target = item["canonical_target"]
        if canonical_target is not None and not isinstance(canonical_target, str):
            raise ValueError(
                f"docs review manifest record {normalized_path} canonical_target must be null or string"
            )

        replacement_for = item["replacement_for"]
        if not isinstance(replacement_for, list) or not all(
            isinstance(value, str) for value in replacement_for
        ):
            raise ValueError(
                f"docs review manifest record {normalized_path} replacement_for must be a string array"
            )
        evidence_sources = item["evidence_sources"]
        if not isinstance(evidence_sources, list) or not all(
            isinstance(value, str) for value in evidence_sources
        ):
            raise ValueError(
                f"docs review manifest record {normalized_path} evidence_sources must be a string array"
            )

        metadata_by_path[path_key] = {
            "canonical_target": canonical_target,
            "domain": domain,
            "evidence_sources": list(evidence_sources),
            "path": normalized_path,
            "replacement_for": list(replacement_for),
            "review_status": review_status,
        }
    return metadata_by_path, True


def _broken_link_key(
    item: dict[str, Any],
) -> tuple[str, str, str | None, str]:
    def normalize(value: str | None) -> str | None:
        if value is None:
            return None
        return value.replace("\\", "/").casefold()

    return (
        normalize(item["path"]),
        normalize(item["target"]),
        normalize(item["resolved_path"]),
        normalize(item["reason"]),
    )


def _load_broken_link_baseline(path: Path) -> set[tuple[str, str, str | None, str]]:
    if not path.is_file():
        raise ValueError(f"broken link baseline file does not exist: {path}")
    try:
        with path.open("r", encoding="utf-8", errors="strict") as stream:
            document = json.load(stream)
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise ValueError(f"unable to parse broken link baseline {path}: {error}") from error
    if not isinstance(document, dict):
        raise ValueError("broken link baseline must be a JSON object")
    broken_links = document.get("broken_links")
    if not isinstance(broken_links, list):
        raise ValueError("broken link baseline must contain a broken_links array")

    keys: set[tuple[str, str, str | None, str]] = set()
    for index, item in enumerate(broken_links):
        if not isinstance(item, dict):
            raise ValueError(f"broken link baseline item {index} must be an object")
        for field in ("path", "target", "reason"):
            if not isinstance(item.get(field), str):
                raise ValueError(
                    f"broken link baseline item {index} {field} must be a string"
                )
        resolved_path = item.get("resolved_path")
        if resolved_path is not None and not isinstance(resolved_path, str):
            raise ValueError(
                f"broken link baseline item {index} resolved_path must be null or string"
            )
        keys.add(_broken_link_key(item))
    return keys


def _resolve_link_path(source_path: str, target: str) -> tuple[str | None, str | None]:
    parsed = urlsplit(target.strip())
    link_path = unquote(parsed.path).replace("\\", "/")
    if not link_path:
        return source_path, None

    if link_path.startswith("/"):
        candidate_parts: list[str] = []
    else:
        candidate_parts = list(PurePosixPath(source_path).parent.parts)

    for part in PurePosixPath(link_path.lstrip("/")).parts:
        if part in ("", "."):
            continue
        if part == "..":
            if not candidate_parts:
                return None, "link escapes the inventory root"
            candidate_parts.pop()
            continue
        candidate_parts.append(part)
    if not candidate_parts:
        return "", None
    return PurePosixPath(*candidate_parts).as_posix(), None


def _relative_path_exists(
    relative_path: str, project_root: Path, inventory_root: Path
) -> bool:
    if relative_path == "":
        return True
    return _join_relative(project_root, relative_path).exists() or _join_relative(
        inventory_root, relative_path
    ).exists()


def _existing_file_path(
    relative_path: str, project_root: Path, inventory_root: Path
) -> Path | None:
    for root in (project_root, inventory_root):
        candidate = _join_relative(root, relative_path)
        if candidate.is_file():
            return candidate
    return None


def _count_file_lines(path: Path) -> int:
    return len(path.read_bytes().splitlines())


def _portable_report_path(path: Path, project_root: Path, label: str) -> str:
    resolved = path.resolve()
    try:
        relative = resolved.relative_to(project_root)
    except ValueError:
        name = resolved.name or label
        return f"<external:{label}>/{name}"
    value = relative.as_posix()
    return value if value else "."


def _resolve_project_path(value: str, project_root: Path) -> Path:
    path = Path(value)
    if not path.is_absolute():
        path = project_root / path
    return path.resolve()


def _build_safe_path_replacements(
    project_root: Path, labeled_paths: Iterable[tuple[str, Path]]
) -> list[tuple[str, str]]:
    replacements: dict[str, str] = {}
    for label, path in labeled_paths:
        resolved = path.resolve()
        safe_path = (
            "."
            if label == "project-root"
            else _portable_report_path(resolved, project_root, label)
        )
        for absolute_path in {str(resolved), resolved.as_posix()}:
            if absolute_path:
                replacements[absolute_path] = safe_path
    return sorted(replacements.items(), key=lambda item: len(item[0]), reverse=True)


def _sanitize_user_visible_text(
    message: str, replacements: Iterable[tuple[str, str]]
) -> str:
    sanitized = message
    flags = re.IGNORECASE if os.name == "nt" else 0
    for absolute_path, safe_path in replacements:
        sanitized = re.sub(
            re.escape(absolute_path),
            lambda _match, replacement=safe_path: replacement,
            sanitized,
            flags=flags,
        )
    sanitized = re.sub(
        r"(?i)(?<![A-Za-z0-9])(?:[A-Z]:[\\/][^\r\n:]*)",
        "<absolute-path>",
        sanitized,
    )
    sanitized = re.sub(
        r"(?<![A-Za-z0-9._>~-])/(?:[^/\s:]+/)+[^/\s:]*",
        "<absolute-path>",
        sanitized,
    )
    return sanitized


def _build_exact_duplicate_groups(
    records: list[dict[str, Any]], contexts: dict[str, dict[str, Any]]
) -> tuple[list[dict[str, Any]], dict[str, str]]:
    groups: dict[str, list[str]] = defaultdict(list)
    record_by_path = {record["path"]: record for record in records}
    for path, context in contexts.items():
        normalized_sha256 = context.get("normalized_sha256")
        if normalized_sha256:
            groups[normalized_sha256].append(path)

    duplicate_groups: list[dict[str, Any]] = []
    representatives: dict[str, str] = {}
    for normalized_sha256, paths in groups.items():
        sorted_paths = sorted(paths, key=str.casefold)
        representatives[normalized_sha256] = sorted_paths[0]
        if len(sorted_paths) < 2:
            continue
        raw_hashes = sorted(
            {
                record_by_path[path]["raw_sha256"]
                for path in sorted_paths
                if record_by_path[path]["raw_sha256"] is not None
            }
        )
        duplicate_groups.append(
            {
                "normalized_sha256": normalized_sha256,
                "paths": sorted_paths,
                "protected": any(record_by_path[path]["protected"] for path in sorted_paths),
                "raw_identical": len(raw_hashes) <= 1,
                "record_count": len(sorted_paths),
            }
        )
    duplicate_groups.sort(key=lambda group: tuple(path.casefold() for path in group["paths"]))
    return duplicate_groups, representatives


def _build_near_duplicate_pairs(
    contexts: dict[str, dict[str, Any]],
    representatives: dict[str, str],
    policy: dict,
) -> list[dict[str, Any]]:
    representative_paths = sorted(set(representatives.values()), key=str.casefold)
    minimum_tokens = int(policy["minimum_similarity_tokens"])
    threshold = float(policy["near_duplicate_threshold"])
    pairs: list[dict[str, Any]] = []

    for left_index, left_path in enumerate(representative_paths):
        left_tokens = contexts[left_path]["tokens"]
        if len(left_tokens) < minimum_tokens:
            continue
        for right_path in representative_paths[left_index + 1 :]:
            right_tokens = contexts[right_path]["tokens"]
            if len(right_tokens) < minimum_tokens:
                continue
            token_length_ratio = min(len(left_tokens), len(right_tokens)) / max(
                len(left_tokens), len(right_tokens)
            )
            if token_length_ratio < 0.75:
                continue
            left_set = set(left_tokens)
            right_set = set(right_tokens)
            union = left_set | right_set
            token_jaccard = len(left_set & right_set) / len(union) if union else 1.0
            if token_jaccard < 0.5:
                continue
            forward_ratio = token_sequence_ratio(left_tokens, right_tokens)
            reverse_ratio = token_sequence_ratio(right_tokens, left_tokens)
            similarity = (forward_ratio + reverse_ratio) / 2.0
            if similarity < threshold:
                continue
            pairs.append(
                {
                    "forward_ratio": round(forward_ratio, 6),
                    "left_path": left_path,
                    "left_token_count": len(left_tokens),
                    "ratio": round(similarity, 6),
                    "reverse_ratio": round(reverse_ratio, 6),
                    "right_path": right_path,
                    "right_token_count": len(right_tokens),
                    "token_jaccard": round(token_jaccard, 6),
                    "token_length_ratio": round(token_length_ratio, 6),
                }
            )
    return pairs


def _record_lookup(records: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    return {record["path"]: record for record in records}


def _count_values(records: list[dict[str, Any]], field: str, value: str) -> int:
    return sum(1 for record in records if record[field] == value)


def _sorted_casefold_unique(values: Iterable[str]) -> list[str]:
    unique: dict[str, str] = {}
    for value in values:
        unique.setdefault(value.casefold(), value)
    return sorted(unique.values(), key=str.casefold)


def _is_reviewed(status: str) -> bool:
    return status.strip().casefold() in {
        "approved",
        "complete",
        "completed",
        "pass",
        "passed",
        "reviewed",
    }


def _parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit every MT3 docs directory")
    parser.add_argument("--project-root", required=True)
    parser.add_argument("--inventory-root", required=True)
    parser.add_argument("--policy", required=True)
    parser.add_argument("--review-manifest", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--broken-link-baseline", default="")
    parser.add_argument("--fail-on-broken-links", action="store_true")
    parser.add_argument("--fail-on-new-broken-links", action="store_true")
    parser.add_argument("--require-reviewed-first-party", action="store_true")
    return parser.parse_args()


def main() -> int:
    safe_path_replacements: list[tuple[str, str]] = []
    try:
        arguments = _parse_arguments()
        project_root = Path(arguments.project_root).resolve()
        inventory_root = _resolve_project_path(arguments.inventory_root, project_root)
        policy_path = _resolve_project_path(arguments.policy, project_root)
        review_manifest_path = _resolve_project_path(
            arguments.review_manifest, project_root
        )
        output_path = _resolve_project_path(arguments.output, project_root)
        baseline_argument = arguments.broken_link_baseline.strip()
        broken_link_baseline_path = (
            _resolve_project_path(baseline_argument, project_root)
            if baseline_argument
            else None
        )
        labeled_paths = [
            ("project-root", project_root),
            ("inventory-root", inventory_root),
            ("policy", policy_path),
            ("review-manifest", review_manifest_path),
            ("output", output_path),
        ]
        if broken_link_baseline_path is not None:
            labeled_paths.append(
                ("broken-link-baseline", broken_link_baseline_path)
            )
        safe_path_replacements = _build_safe_path_replacements(
            project_root, labeled_paths
        )
        broken_link_baseline_keys: set[tuple[str, str, str | None, str]] = set()

        if arguments.fail_on_new_broken_links:
            if broken_link_baseline_path is None:
                raise ValueError(
                    "--broken-link-baseline is required with --fail-on-new-broken-links"
                )
            broken_link_baseline_keys = _load_broken_link_baseline(
                broken_link_baseline_path
            )

        if not project_root.is_dir():
            raise FileNotFoundError(f"project root is not a directory: {project_root}")
        if not inventory_root.is_dir():
            raise FileNotFoundError(f"inventory root is not a directory: {inventory_root}")

        policy = load_policy(policy_path)
        review_metadata_by_path, review_manifest_loaded = _load_review_statuses(
            review_manifest_path
        )
        git_states = list_git_paths(project_root, inventory_root)
        folded_git_states = {path.casefold(): state for path, state in git_states.items()}

        inventory_docs = list_docs_directories(inventory_root, policy)
        project_docs = (
            inventory_docs
            if project_root == inventory_root
            else list_docs_directories(project_root, policy)
        )

        docs_directory_map: dict[str, str] = {}
        for root, directories in (
            (inventory_root, inventory_docs),
            (project_root, project_docs),
        ):
            for directory in directories:
                relative = directory.relative_to(root).as_posix()
                docs_directory_map[relative.casefold()] = relative

        inventory_files = _list_editorial_files(
            inventory_root, inventory_docs, policy
        )
        project_files = (
            inventory_files
            if project_root == inventory_root
            else _list_editorial_files(project_root, project_docs, policy)
        )
        document_map = dict(inventory_files)
        document_map.update(project_files)
        if policy["tracked_only"]:
            document_map = {
                key: value
                for key, value in document_map.items()
                if folded_git_states.get(key) == "tracked"
            }

        records: list[dict[str, Any]] = []
        contexts: dict[str, dict[str, Any]] = {}
        for relative_path, docs_root in sorted(
            document_map.values(), key=lambda item: item[0].casefold()
        ):
            source_path, delivery_scope = select_content_path(
                relative_path, project_root, inventory_root
            )
            content_root = project_root if delivery_scope == "branch" else inventory_root
            ownership = classify_ownership(relative_path, policy)
            document_class = classify_document(relative_path, policy)
            document_issues: list[dict[str, Any]] = []
            raw_sha256: str | None = None
            normalized_sha256: str | None = None
            encoding = "unknown"
            bom = False
            newline = "UNKNOWN"
            token_count = 0
            normalized_text = ""
            tokens: list[str] = []

            try:
                raw_sha256 = hashlib.sha256(source_path.read_bytes()).hexdigest()
                text, encoding, bom, newline = read_document_text(source_path)
                normalized_text = normalize_document_text(text)
                normalized_sha256 = hashlib.sha256(
                    normalized_text.encode("utf-8")
                ).hexdigest()
                tokens = _tokenize(normalized_text)
                token_count = len(tokens)
            except (OSError, UnicodeError) as error:
                text = ""
                document_issues.append(
                    {
                        "type": "encoding_error",
                        "message": _sanitize_user_visible_text(
                            str(error), safe_path_replacements
                        ),
                    }
                )

            is_markdown = PurePosixPath(relative_path).suffix.casefold() in {
                ".md",
                ".markdown",
            }
            if (
                policy["strict_markdown_utf8_no_bom_lf"]
                and ownership == "first_party"
                and is_markdown
                and relative_path.casefold().startswith("docs/")
                and encoding != "unknown"
            ):
                violations: list[str] = []
                if encoding != "utf-8":
                    violations.append(f"encoding is {encoding}")
                if bom:
                    violations.append("BOM is present")
                if newline in {"CR", "CRLF", "MIXED"}:
                    violations.append(f"newline is {newline}")
                if violations:
                    document_issues.append(
                        {
                            "type": "encoding_policy",
                            "message": "; ".join(violations),
                        }
                    )

            if ownership == "vendor":
                review_metadata = {
                    "canonical_target": None,
                    "domain": "vendor_snapshot",
                    "evidence_sources": [],
                    "replacement_for": [],
                    "review_status": "not_applicable",
                }
            elif document_class == "generated":
                review_metadata = {
                    "canonical_target": None,
                    "domain": "generated_evidence",
                    "evidence_sources": [],
                    "replacement_for": [],
                    "review_status": "not_applicable",
                }
            else:
                review_metadata = review_metadata_by_path.get(
                    relative_path.casefold(),
                    {
                        "canonical_target": None,
                        "domain": None,
                        "evidence_sources": [],
                        "replacement_for": [],
                        "review_status": "unreviewed",
                    },
                )
            record = {
                "bom": bom,
                "canonical_target": review_metadata["canonical_target"],
                "content_root": (
                    "project" if content_root == project_root else "inventory"
                ),
                "delivery_scope": delivery_scope,
                "domain": review_metadata["domain"],
                "docs_root": docs_root,
                "document_class": document_class,
                "encoding": encoding,
                "evidence_sources": list(review_metadata["evidence_sources"]),
                "git_state": folded_git_states.get(
                    relative_path.casefold(), "unversioned"
                ),
                "inbound_links": [],
                "issues": document_issues,
                "newline": newline,
                "normalized_sha256": normalized_sha256,
                "outbound_links": [],
                "ownership": ownership,
                "path": relative_path,
                "protected": _is_protected(relative_path, policy),
                "raw_sha256": raw_sha256,
                "replacement_for": list(review_metadata["replacement_for"]),
                "review_status": review_metadata["review_status"],
                "token_count": token_count,
            }
            records.append(record)
            contexts[relative_path] = {
                "normalized_sha256": normalized_sha256,
                "text": text,
                "tokens": tokens,
            }

        records.sort(key=lambda record: record["path"].casefold())
        record_by_path = _record_lookup(records)
        canonical_record_paths = {
            record["path"].casefold(): record["path"] for record in records
        }
        broken_links: list[dict[str, Any]] = []
        heading_issues: list[dict[str, Any]] = []
        fence_issues: list[dict[str, Any]] = []
        source_line_links: list[dict[str, Any]] = []
        link_edges_by_key: dict[tuple[str, str], dict[str, str]] = {}
        markdown_links = 0
        markdown_records = 0

        for record in records:
            relative_path = record["path"]
            text = contexts[relative_path]["text"]
            if record["encoding"] == "unknown":
                continue
            if PurePosixPath(relative_path).suffix.casefold() in {".md", ".markdown"}:
                markdown_records += 1
                file_heading_issues = find_heading_issues(text, relative_path)
                heading_issues.extend(file_heading_issues)
                record["issues"].extend(file_heading_issues)
                file_fence_issues = find_fence_issues(text, relative_path)
                fence_issues.extend(file_fence_issues)
                record["issues"].extend(file_fence_issues)
                targets = extract_relative_markdown_links(text)
                markdown_links += len(targets)
                for target in targets:
                    source_line = _parse_source_line_target(target)
                    resolution_target = (
                        source_line["path"] if source_line is not None else target
                    )
                    resolved_path, resolution_error = _resolve_link_path(
                        relative_path, resolution_target
                    )
                    source_line_file = None
                    if (
                        source_line is not None
                        and resolution_error is None
                        and resolved_path is not None
                    ):
                        source_line_file = _existing_file_path(
                            resolved_path, project_root, inventory_root
                        )
                    if source_line is not None and source_line_file is not None:
                        line_count = _count_file_lines(source_line_file)
                        line_start = int(source_line["start"])
                        line_end = int(source_line["end"])
                        valid_range = (
                            line_start >= 1
                            and line_end >= line_start
                            and line_end <= line_count
                        )
                        source_line_record = {
                            "line_count": line_count,
                            "line_end": line_end,
                            "line_start": line_start,
                            "path": relative_path,
                            "resolved_path": resolved_path,
                            "status": "valid" if valid_range else "line_out_of_range",
                            "target": target,
                        }
                        source_line_links.append(source_line_record)
                        if not valid_range:
                            resolution_error = (
                                f"source line range {line_start}-{line_end} is outside "
                                f"1-{line_count}"
                            )
                            record["issues"].append(
                                {
                                    "type": "source_line_out_of_range",
                                    "target": target,
                                    "resolved_path": resolved_path,
                                    "message": resolution_error,
                                }
                            )
                    elif source_line is not None:
                        if resolved_path is not None:
                            resolved_path = (
                                f"{resolved_path}:{source_line['start']}"
                                + (
                                    f"-{source_line['end']}"
                                    if source_line["end"] != source_line["start"]
                                    else ""
                                )
                            )
                        if resolution_error is None:
                            resolution_error = "source line target is not a file"
                    if resolution_error is None and resolved_path is not None:
                        if _relative_path_exists(
                            resolved_path, project_root, inventory_root
                        ):
                            target_path = canonical_record_paths.get(
                                resolved_path.casefold(), resolved_path
                            )
                            edge_key = (
                                relative_path.casefold(),
                                target_path.casefold(),
                            )
                            link_edges_by_key.setdefault(
                                edge_key,
                                {"source": relative_path, "target": target_path},
                            )
                            target_record = record_by_path.get(target_path)
                            if target_record is not None:
                                record["outbound_links"].append(target_path)
                                target_record["inbound_links"].append(relative_path)
                            continue
                        resolution_error = "target does not exist"
                    broken_link = {
                        "path": relative_path,
                        "reason": resolution_error or "target does not exist",
                        "resolved_path": resolved_path,
                        "target": target,
                    }
                    broken_links.append(broken_link)
                    record["issues"].append(
                        {
                            "type": "broken_link",
                            "target": target,
                            "resolved_path": resolved_path,
                            "message": broken_link["reason"],
                        }
                    )

        for record in records:
            record["inbound_links"] = _sorted_casefold_unique(
                record["inbound_links"]
            )
            record["outbound_links"] = _sorted_casefold_unique(
                record["outbound_links"]
            )
        link_edges = sorted(
            link_edges_by_key.values(),
            key=lambda edge: (edge["source"].casefold(), edge["target"].casefold()),
        )
        broken_links.sort(
            key=lambda item: (item["path"].casefold(), item["target"].casefold())
        )
        source_line_links.sort(
            key=lambda item: (item["path"].casefold(), item["target"].casefold())
        )
        source_line_issues = [
            item for item in source_line_links if item["status"] != "valid"
        ]
        fence_issues.sort(
            key=lambda item: (item["path"].casefold(), int(item["line"]))
        )
        encoding_issues = [
            {"path": record["path"], **issue}
            for record in records
            for issue in record["issues"]
            if issue.get("type") in {"encoding_error", "encoding_policy"}
        ]
        new_broken_links: list[dict[str, Any]] = []
        if arguments.fail_on_new_broken_links:
            seen_broken_link_keys: set[tuple[str, str, str | None, str]] = set()
            for item in broken_links:
                item_key = _broken_link_key(item)
                if (
                    item_key in broken_link_baseline_keys
                    or item_key in seen_broken_link_keys
                ):
                    continue
                seen_broken_link_keys.add(item_key)
                new_broken_links.append(item)
        heading_issues.sort(
            key=lambda item: (
                item["path"].casefold(),
                int(item.get("line", 0)),
                item["type"],
            )
        )
        duplicate_groups, representatives = _build_exact_duplicate_groups(
            records, contexts
        )
        near_duplicate_pairs = _build_near_duplicate_pairs(
            contexts, representatives, policy
        )

        human_reviewable_first_party = [
            record
            for record in records
            if record["ownership"] == "first_party"
            and record["document_class"] != "generated"
        ]
        unreviewed_first_party = [
            record["path"]
            for record in human_reviewable_first_party
            if not _is_reviewed(record["review_status"])
        ]
        fail_reasons: list[str] = []
        if arguments.fail_on_broken_links and broken_links:
            fail_reasons.append("broken_links")
        if arguments.fail_on_new_broken_links and new_broken_links:
            fail_reasons.append("new_broken_links")
        if arguments.require_reviewed_first_party and unreviewed_first_party:
            fail_reasons.append("unreviewed_first_party")
        if policy["fail_on_encoding_issues"] and encoding_issues:
            fail_reasons.append("encoding_issues")
        if policy["fail_on_fence_issues"] and fence_issues:
            fail_reasons.append("fence_issues")
        if policy["fail_on_heading_issues"] and heading_issues:
            fail_reasons.append("heading_issues")
        if policy["fail_on_exact_duplicates"] and duplicate_groups:
            fail_reasons.append("exact_duplicates")

        summary = {
            "branch_records": _count_values(records, "delivery_scope", "branch"),
            "broken_links": len(broken_links),
            "docs_directories": len(docs_directory_map),
            "encoding_issues": len(encoding_issues),
            "exact_duplicate_groups": len(duplicate_groups),
            "first_party_records": _count_values(
                records, "ownership", "first_party"
            ),
            "heading_issues": len(heading_issues),
            "fence_issues": len(fence_issues),
            "human_reviewable_first_party": len(human_reviewable_first_party),
            "ignored_records": _count_values(records, "git_state", "ignored"),
            "local_only_records": _count_values(
                records, "delivery_scope", "local_only"
            ),
            "link_edges": len(link_edges),
            "markdown_links": markdown_links,
            "markdown_records": markdown_records,
            "near_duplicate_pairs": len(near_duplicate_pairs),
            "new_broken_links": len(new_broken_links),
            "protected_records": sum(1 for record in records if record["protected"]),
            "records": len(records),
            "source_line_link_issues": len(source_line_issues),
            "source_line_links": len(source_line_links),
            "reviewed_first_party": sum(
                1
                for record in human_reviewable_first_party
                if _is_reviewed(record["review_status"])
            ),
            "tracked_records": _count_values(records, "git_state", "tracked"),
            "unreviewed_first_party": len(unreviewed_first_party),
            "untracked_records": _count_values(records, "git_state", "untracked"),
            "unversioned_records": _count_values(
                records, "git_state", "unversioned"
            ),
            "vendor_records": _count_values(records, "ownership", "vendor"),
        }
        report = {
            "broken_links": broken_links,
            "docs_directories": sorted(
                docs_directory_map.values(), key=str.casefold
            ),
            "duplicate_groups": duplicate_groups,
            "encoding_issues": encoding_issues,
            "fail_closed": {
                "broken_link_baseline_path": (
                    _portable_report_path(
                        broken_link_baseline_path,
                        project_root,
                        "broken-link-baseline",
                    )
                    if broken_link_baseline_path is not None
                    else ""
                ),
                "fail_on_broken_links": bool(arguments.fail_on_broken_links),
                "fail_on_new_broken_links": bool(
                    arguments.fail_on_new_broken_links
                ),
                "fail_on_encoding_issues": bool(policy["fail_on_encoding_issues"]),
                "fail_on_exact_duplicates": bool(
                    policy["fail_on_exact_duplicates"]
                ),
                "fail_on_fence_issues": bool(policy["fail_on_fence_issues"]),
                "fail_on_heading_issues": bool(policy["fail_on_heading_issues"]),
                "reasons": fail_reasons,
                "require_reviewed_first_party": bool(
                    arguments.require_reviewed_first_party
                ),
            },
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "fence_issues": fence_issues,
            "heading_issues": heading_issues,
            "inventory_root": _portable_report_path(
                inventory_root, project_root, "inventory-root"
            ),
            "link_edges": link_edges,
            "near_duplicate_pairs": near_duplicate_pairs,
            "new_broken_links": new_broken_links,
            "policy_path": _portable_report_path(policy_path, project_root, "policy"),
            "project_root": ".",
            "records": records,
            "review_manifest_loaded": review_manifest_loaded,
            "review_manifest_path": _portable_report_path(
                review_manifest_path, project_root, "review-manifest"
            ),
            "source_line_issues": source_line_issues,
            "source_line_links": source_line_links,
            "schema_version": "1.0.0",
            "status": "FAIL" if fail_reasons else "PASS",
            "summary": summary,
        }
        write_json_report(report, output_path)
        print(
            "MT3 docs audit: "
            f"{summary['records']} records, "
            f"{summary['exact_duplicate_groups']} exact groups, "
            f"{summary['near_duplicate_pairs']} near pairs, "
            f"{summary['broken_links']} broken links"
        )
        return 1 if fail_reasons else 0
    except Exception as error:
        safe_message = _sanitize_user_visible_text(
            str(error), safe_path_replacements
        )
        print(f"MT3 docs audit failed: {safe_message}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())

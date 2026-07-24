param(
    [string]$ProjectRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
    } else {
        $ProjectRoot = (Get-Location).Path
    }
}

$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
$reportRoot = Join-Path $ProjectRoot ".claude\reports"
$requirementsPath = Join-Path $ProjectRoot ".codex\requirements.toml"
$configPath = Join-Path $ProjectRoot ".codex\config.toml"
$profilesPath = Join-Path $ProjectRoot ".codex\mcp\mcp-profiles.json"
$profileSchemaPath = Join-Path $ProjectRoot ".codex\schemas\mcp-profile.schema.json"
$manifestPath = Join-Path $ProjectRoot ".claude\config\mcp.manifest.json"
$workflowCatalogPath = Join-Path $ProjectRoot ".codex\workflows\workflow-engine.json"
$workflowSchemaPath = Join-Path $ProjectRoot ".codex\schemas\workflow-catalog.schema.json"
$projectMapPath = Join-Path $ProjectRoot ".codex\project-map.json"
$projectMapSchemaPath = Join-Path $ProjectRoot ".codex\schemas\project-map.schema.json"

function Write-Utf8NoBom {
    param(
        [string]$FilePath,
        [string]$Text
    )

    $dir = Split-Path -Parent $FilePath
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory | Out-Null
    }

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($FilePath, $Text, $encoding)
}

function Load-Json {
    param([string]$Path)
    return (Get-Content -Raw -Encoding UTF8 $Path | ConvertFrom-Json)
}

function Get-TomlArrayValues {
    param(
        [string]$Text,
        [string]$Key
    )

    $pattern = '(?ms)^\s*' + [regex]::Escape($Key) + '\s*=\s*\[(.*?)\]'
    $match = [regex]::Match($Text, $pattern)
    if (-not $match.Success) {
        return @()
    }

    return @(
        [regex]::Matches($match.Groups[1].Value, '"([^"]+)"') |
            ForEach-Object { $_.Groups[1].Value.Trim() } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )
}

function Get-TomlMcpIdentities {
    param([string]$Text)

    return @(
        [regex]::Matches($Text, '(?m)^\[mcp_servers\.([^.]+)\.identity\]') |
            ForEach-Object { $_.Groups[1].Value.Trim() } |
            Sort-Object -Unique
    )
}

function Get-TomlMcpServerIds {
    param([string]$Text)

    return @(
        [regex]::Matches($Text, '(?m)^\[mcp_servers\.([A-Za-z0-9_-]+)\]\s*$') |
            ForEach-Object { $_.Groups[1].Value.Trim() } |
            Sort-Object -Unique
    )
}

function Test-CodexTomlParsing {
    param([string]$Root)

    $python = Get-Command python -ErrorAction SilentlyContinue
    if ($null -eq $python) {
        return @([pscustomobject]@{
            file = ".codex/**/*.toml"
            error = "Python 3 with tomllib is required to parse-check .codex TOML files"
        })
    }

    $script = @'
import json
import os
import pathlib
import sys
import tomllib

root = pathlib.Path(os.environ["MT3_CODEX_AUDIT_ROOT"])
failures = []
for path in sorted((root / ".codex").rglob("*.toml")):
    try:
        tomllib.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        failures.append({
            "file": path.relative_to(root).as_posix(),
            "error": str(exc),
        })
print(json.dumps(failures, ensure_ascii=False))
'@

    $oldAuditRoot = $env:MT3_CODEX_AUDIT_ROOT
    $oldErrorActionPreference = $ErrorActionPreference
    $tempScriptPath = [System.IO.Path]::ChangeExtension([System.IO.Path]::GetTempFileName(), ".py")
    try {
        $env:MT3_CODEX_AUDIT_ROOT = $Root
        [System.IO.File]::WriteAllText($tempScriptPath, $script, (New-Object System.Text.UTF8Encoding($false)))
        $ErrorActionPreference = "Continue"
        $output = & $python.Source $tempScriptPath 2>&1
        $ErrorActionPreference = $oldErrorActionPreference
        if ($LASTEXITCODE -ne 0) {
            return @([pscustomobject]@{
                file = ".codex/**/*.toml"
                error = "Python TOML parse-check exited with code $LASTEXITCODE`: $($output -join ' ')"
            })
        }
        $jsonText = ($output -join "`n").Trim()
        if ([string]::IsNullOrWhiteSpace($jsonText) -or $jsonText -eq "[]") {
            return @()
        }
        return @($jsonText | ConvertFrom-Json)
    } finally {
        $ErrorActionPreference = $oldErrorActionPreference
        Remove-Item -LiteralPath $tempScriptPath -Force -ErrorAction SilentlyContinue
        if ($null -eq $oldAuditRoot) {
            Remove-Item Env:MT3_CODEX_AUDIT_ROOT -ErrorAction SilentlyContinue
        } else {
            $env:MT3_CODEX_AUDIT_ROOT = $oldAuditRoot
        }
    }
}

function Invoke-JsonSchemaValidation {
    param([string]$Root)

    $documents = @(
        [pscustomobject]@{
            id = "workflow_catalog"
            document = (Join-Path $Root ".codex\workflows\workflow-engine.json")
            schema = (Join-Path $Root ".codex\schemas\workflow-catalog.schema.json")
        },
        [pscustomobject]@{
            id = "project_map"
            document = (Join-Path $Root ".codex\project-map.json")
            schema = (Join-Path $Root ".codex\schemas\project-map.schema.json")
        },
        [pscustomobject]@{
            id = "mcp_profile"
            document = (Join-Path $Root ".codex\mcp\mcp-profiles.json")
            schema = (Join-Path $Root ".codex\schemas\mcp-profile.schema.json")
        }
    )

    $python = Get-Command python -ErrorAction SilentlyContinue
    $pwsh = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    $pwshSupportsSchema = $false
    if ($null -eq $python -and $null -ne $pwsh) {
        $oldErrorActionPreference = $ErrorActionPreference
        try {
            $ErrorActionPreference = "Continue"
            $probeCommand = '$command = Get-Command Test-Json -ErrorAction SilentlyContinue; if ($null -ne $command -and $null -ne $command.Parameters.SchemaFile) { exit 0 }; exit 2'
            $probeOutput = @(& $pwsh.Source -NoLogo -NoProfile -Command $probeCommand 2>&1)
            $pwshSupportsSchema = ($LASTEXITCODE -eq 0)
        } finally {
            $ErrorActionPreference = $oldErrorActionPreference
        }
    }

    $engine = ""
    $results = [ordered]@{}
    if ($pwshSupportsSchema) {
        $engine = "pwsh/Test-Json -SchemaFile"
        foreach ($item in $documents) {
            $oldDocument = $env:MT3_SCHEMA_DOCUMENT
            $oldSchema = $env:MT3_SCHEMA_FILE
            $oldErrorActionPreference = $ErrorActionPreference
            try {
                $env:MT3_SCHEMA_DOCUMENT = [string]$item.document
                $env:MT3_SCHEMA_FILE = [string]$item.schema
                $ErrorActionPreference = "Continue"
                $validationCommand = '$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop; $json = Get-Content -Raw -Encoding UTF8 -LiteralPath $env:MT3_SCHEMA_DOCUMENT; if (-not ($json | Test-Json -SchemaFile $env:MT3_SCHEMA_FILE -ErrorAction Stop)) { exit 1 }'
                $raw = @(& $pwsh.Source -NoLogo -NoProfile -Command $validationCommand 2>&1)
                $exitCode = $LASTEXITCODE
            } finally {
                $ErrorActionPreference = $oldErrorActionPreference
                if ($null -eq $oldDocument) { Remove-Item Env:MT3_SCHEMA_DOCUMENT -ErrorAction SilentlyContinue } else { $env:MT3_SCHEMA_DOCUMENT = $oldDocument }
                if ($null -eq $oldSchema) { Remove-Item Env:MT3_SCHEMA_FILE -ErrorAction SilentlyContinue } else { $env:MT3_SCHEMA_FILE = $oldSchema }
            }
            $issues = @(if ($exitCode -ne 0) { "$($item.id) schema validation failed: $([string]::Join(' ', @($raw)))" })
            $results[[string]$item.id] = [pscustomobject][ordered]@{
                status = if ($issues.Count -eq 0) { "PASS" } else { "FAIL" }
                errors = $issues
            }
        }
    } else {
        if ($null -eq $python) {
            $engine = "unavailable"
            foreach ($item in $documents) {
                $results[[string]$item.id] = [pscustomobject][ordered]@{
                    status = "FAIL"
                    errors = @("No JSON Schema validator is available: pwsh Test-Json -SchemaFile and Python jsonschema are both unavailable.")
                }
            }
        } else {
            $engine = "python/jsonschema"
            $pythonScript = @'
import json
import pathlib
import sys

try:
    import jsonschema
except Exception as exc:
    print(json.dumps({"available": False, "errors": [f"Python package jsonschema is unavailable: {exc}"]}, ensure_ascii=False))
    sys.exit(4)

document_path = pathlib.Path(sys.argv[1])
schema_path = pathlib.Path(sys.argv[2])
issues = []
try:
    document = json.loads(document_path.read_text(encoding="utf-8"))
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    jsonschema.Draft202012Validator.check_schema(schema)
    validator = jsonschema.Draft202012Validator(schema)
    for issue in sorted(validator.iter_errors(document), key=lambda item: list(item.absolute_path)):
        location = "/".join(str(part) for part in issue.absolute_path) or "<root>"
        issues.append(f"schema violation at {location}: {issue.message}")
except Exception as exc:
    issues.append(str(exc))
print(json.dumps({"available": True, "errors": issues}, ensure_ascii=False))
sys.exit(0 if not issues else 1)
'@
            $tempScriptPath = [System.IO.Path]::ChangeExtension([System.IO.Path]::GetTempFileName(), ".py")
            try {
                [System.IO.File]::WriteAllText($tempScriptPath, $pythonScript, (New-Object System.Text.UTF8Encoding($false)))
                foreach ($item in $documents) {
                    $oldErrorActionPreference = $ErrorActionPreference
                    try {
                        $ErrorActionPreference = "Continue"
                        $raw = @(& $python.Source -X utf8 $tempScriptPath $item.document $item.schema 2>&1)
                        $exitCode = $LASTEXITCODE
                    } finally {
                        $ErrorActionPreference = $oldErrorActionPreference
                    }
                    $text = [string]::Join("`n", @($raw | ForEach-Object { [string]$_ })).Trim()
                    try {
                        $parsed = $text | ConvertFrom-Json -ErrorAction Stop
                        $issues = @($parsed.errors | ForEach-Object { "$($item.id) schema validation failed: $_" })
                        if (-not [bool]$parsed.available -and $issues.Count -eq 0) {
                            $issues = @("$($item.id) schema validation failed: Python jsonschema is unavailable")
                        }
                    } catch {
                        $issues = @("$($item.id) schema validator output is invalid (exit=$exitCode): $text")
                    }
                    $results[[string]$item.id] = [pscustomobject][ordered]@{
                        status = if ($exitCode -eq 0 -and $issues.Count -eq 0) { "PASS" } else { "FAIL" }
                        errors = $issues
                    }
                }
            } finally {
                Remove-Item -LiteralPath $tempScriptPath -Force -ErrorAction SilentlyContinue
            }
        }
    }

    return [pscustomobject][ordered]@{
        engine = $engine
        workflow_catalog = $results["workflow_catalog"]
        project_map = $results["project_map"]
        mcp_profile = $results["mcp_profile"]
    }
}

function Invoke-StructuralValidation {
    param([string]$Root)

    $python = Get-Command python -ErrorAction SilentlyContinue
    if ($null -eq $python) {
        throw "Python 3 is required for schema, graph, cross-file, path, and LFS validation."
    }

    $script = @'
import json
import os
import pathlib
import re
import subprocess
import sys
import tomllib

root = pathlib.Path(os.environ["MT3_CODEX_AUDIT_ROOT"]).resolve()
catalog_path = root / ".codex/workflows/workflow-engine.json"
catalog_schema_path = root / ".codex/schemas/workflow-catalog.schema.json"
project_map_path = root / ".codex/project-map.json"
project_map_schema_path = root / ".codex/schemas/project-map.schema.json"

errors = []


class DuplicateKeyError(ValueError):
    pass


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise DuplicateKeyError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def load_json(path):
    try:
        return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_object)
    except Exception as exc:
        errors.append(f"JSON parse failed: {path.relative_to(root).as_posix()}: {exc}")
        return None


catalog = load_json(catalog_path)
catalog_schema = load_json(catalog_schema_path)
project_map = load_json(project_map_path)
project_map_schema = load_json(project_map_schema_path)

workflow_graphs = {
    "total": 0,
    "unique": 0,
    "connected": 0,
    "edges_checked": 0,
    "details": [],
}
workflow_ids = set()
workflow_by_id = {}
if catalog is not None:
    workflows = catalog.get("workflows", [])
    workflow_graphs["total"] = len(workflows)
    ids = [str(workflow.get("id", "")) for workflow in workflows]
    workflow_ids = set(ids)
    workflow_graphs["unique"] = len(workflow_ids)
    if len(workflows) != 13:
        errors.append(f"workflow catalog must contain 13 workflows, found {len(workflows)}")
    if len(ids) != len(workflow_ids):
        errors.append("workflow ids must be unique")
    if catalog_schema is not None:
        expected = set(
            catalog_schema.get("$defs", {})
            .get("workflow", {})
            .get("properties", {})
            .get("id", {})
            .get("enum", [])
        )
        if expected and workflow_ids != expected:
            errors.append(
                "workflow ids differ from schema enum: "
                f"missing={sorted(expected - workflow_ids)} extra={sorted(workflow_ids - expected)}"
            )

    for workflow in workflows:
        workflow_id = str(workflow.get("id", ""))
        workflow_by_id[workflow_id] = workflow
        nodes = workflow.get("nodes", {})
        entry = str(workflow.get("entry_node", ""))
        graph_errors = []
        if entry not in nodes:
            graph_errors.append(f"entry node does not exist: {entry}")

        adjacency = {node_id: [] for node_id in nodes}
        terminal_nodes = set()
        for node_id, node in nodes.items():
            if node.get("kind") == "terminal":
                terminal_nodes.add(node_id)
            for edge_name in ("on_success", "on_failure", "on_skip"):
                target = node.get(edge_name)
                if target is None:
                    continue
                workflow_graphs["edges_checked"] += 1
                if target not in nodes:
                    graph_errors.append(f"{node_id}.{edge_name} references missing node: {target}")
                else:
                    adjacency[node_id].append(target)

        reachable = set()
        pending = [entry] if entry in nodes else []
        while pending:
            current = pending.pop()
            if current in reachable:
                continue
            reachable.add(current)
            pending.extend(adjacency.get(current, []))
        unreachable = sorted(set(nodes) - reachable)
        if unreachable:
            graph_errors.append(f"unreachable nodes: {unreachable}")
        if not terminal_nodes:
            graph_errors.append("workflow has no terminal node")

        can_reach_terminal = set(terminal_nodes)
        changed = True
        while changed:
            changed = False
            for source, targets in adjacency.items():
                if source not in can_reach_terminal and any(target in can_reach_terminal for target in targets):
                    can_reach_terminal.add(source)
                    changed = True
        nonterminating = sorted(reachable - can_reach_terminal)
        if nonterminating:
            graph_errors.append(f"reachable nodes without a terminal path: {nonterminating}")

        connected = not graph_errors
        if connected:
            workflow_graphs["connected"] += 1
        for issue in graph_errors:
            errors.append(f"workflow {workflow_id}: {issue}")
        workflow_graphs["details"].append({
            "id": workflow_id,
            "nodes": len(nodes),
            "reachable": len(reachable),
            "terminal_nodes": len(terminal_nodes),
            "connected": connected,
            "errors": graph_errors,
        })


agent_dir = root / ".codex/agents"
agent_files = {path.stem: path for path in agent_dir.glob("*.toml")}
skill_root = root / ".agents/skills"
skill_ids = {path.name for path in skill_root.iterdir() if path.is_dir()} if skill_root.is_dir() else set()
cross_file = {
    "agent_references_checked": 0,
    "skill_references_checked": 0,
    "optional_external_skills": [],
    "workflow_references_checked": 0,
    "errors": [],
}


def cross_error(message):
    cross_file["errors"].append(message)
    errors.append(message)


config_path = root / ".codex/config.toml"
try:
    config = tomllib.loads(config_path.read_text(encoding="utf-8"))
    configured_agents = {
        key: value for key, value in config.get("agents", {}).items() if isinstance(value, dict)
    }
    if len(configured_agents) != 13 or len(agent_files) != 13:
        cross_error(
            f"expected 13 configured Agent definitions and 13 Agent files; "
            f"configured={len(configured_agents)} files={len(agent_files)}"
        )
    if set(configured_agents) != set(agent_files):
        cross_error(
            f"Agent config/file ids differ: missing_files={sorted(set(configured_agents) - set(agent_files))} "
            f"unconfigured_files={sorted(set(agent_files) - set(configured_agents))}"
        )
    for agent_id, definition in configured_agents.items():
        cross_file["agent_references_checked"] += 1
        relative = str(definition.get("config_file", ""))
        expected_path = (root / ".codex" / relative).resolve()
        actual_path = agent_files.get(agent_id)
        if actual_path is None or expected_path != actual_path.resolve():
            cross_error(f"Agent {agent_id} config_file does not resolve to .codex/agents/{agent_id}.toml")
            continue
        try:
            agent_config = tomllib.loads(actual_path.read_text(encoding="utf-8"))
            if agent_config.get("name") != agent_id:
                cross_error(f"Agent file name mismatch: {actual_path.relative_to(root).as_posix()}")
        except Exception as exc:
            cross_error(f"Agent TOML parse failed: {actual_path.relative_to(root).as_posix()}: {exc}")
except Exception as exc:
    cross_error(f".codex/config.toml cross-file parse failed: {exc}")


def check_agent(agent_id, context):
    cross_file["agent_references_checked"] += 1
    if agent_id not in agent_files:
        cross_error(f"{context} references missing Agent: {agent_id}")


def check_skill(skill_id, context, required=True):
    cross_file["skill_references_checked"] += 1
    skill_path = skill_root / skill_id
    if skill_id not in skill_ids:
        if required:
            cross_error(f"{context} references missing skill: {skill_id}")
        else:
            cross_file["optional_external_skills"].append(skill_id)
        return
    for child in ("SKILL.md", "agents/openai.yaml"):
        if not (skill_path / child).is_file():
            cross_error(f"{context} skill {skill_id} is missing {child}")


if catalog is not None:
    for workflow in catalog.get("workflows", []):
        workflow_id = workflow.get("id", "")
        routing = workflow.get("routing", {})
        check_agent(str(routing.get("primary_agent", "")), f"workflow {workflow_id}")
        for agent_id in routing.get("supporting_agents", []):
            check_agent(str(agent_id), f"workflow {workflow_id}")
        for skill_id in routing.get("required_skills", []):
            check_skill(str(skill_id), f"workflow {workflow_id}")
        for skill_id in routing.get("optional_runtime_skills", []):
            check_skill(str(skill_id), f"workflow {workflow_id}", required=False)
        for node_id, node in workflow.get("nodes", {}).items():
            if node.get("kind") == "handoff":
                check_agent(str(node.get("target_agent", "")), f"workflow {workflow_id} node {node_id}")

if project_map is not None:
    for domain in project_map.get("task_domains", []):
        context = f"project-map task domain {domain.get('id', '')}"
        check_agent(str(domain.get("agent", "")), context)
        for agent_id in domain.get("supporting_agents", []):
            check_agent(str(agent_id), context)
        check_skill(str(domain.get("skill", "")), context)
        for workflow_id in domain.get("workflow_ids", []):
            cross_file["workflow_references_checked"] += 1
            if workflow_id not in workflow_ids:
                cross_error(f"{context} references missing workflow: {workflow_id}")
    for collection in ("path_availability", "build_entrypoints"):
        for item in project_map.get(collection, []):
            ids = item.get("required_by_workflow_ids", []) if collection == "path_availability" else [item.get("workflow_id")]
            for workflow_id in ids:
                cross_file["workflow_references_checked"] += 1
                if workflow_id not in workflow_ids:
                    cross_error(f"project-map {collection} references missing workflow: {workflow_id}")


input_defaults = {"checked": 0, "references_checked": 0, "errors": []}


def input_error(workflow_id, message):
    value = f"workflow {workflow_id} input contract: {message}"
    input_defaults["errors"].append(value)
    errors.append(value)


def matches_type(value, type_name):
    if type_name == "boolean":
        return isinstance(value, bool)
    if type_name == "integer":
        return isinstance(value, int) and not isinstance(value, bool)
    if type_name in ("string", "path"):
        return isinstance(value, str)
    return False


placeholder_pattern = re.compile(r"\$\{inputs\.([A-Za-z][A-Za-z0-9_]*)\}")
if catalog is not None:
    for workflow in catalog.get("workflows", []):
        workflow_id = str(workflow.get("id", ""))
        inputs = workflow.get("inputs", {})
        for input_id, definition in inputs.items():
            input_defaults["checked"] += 1
            if "default" in definition:
                default = definition["default"]
                if not matches_type(default, definition.get("type")):
                    input_error(workflow_id, f"{input_id} default does not match type {definition.get('type')}")
                if "enum" in definition and default not in definition["enum"]:
                    input_error(workflow_id, f"{input_id} default is not present in enum")
            if "enum" in definition:
                for enum_value in definition["enum"]:
                    if not matches_type(enum_value, definition.get("type")):
                        input_error(workflow_id, f"{input_id} enum value does not match type {definition.get('type')}")

        serialized = json.dumps(workflow, ensure_ascii=False)
        for input_id in placeholder_pattern.findall(serialized):
            input_defaults["references_checked"] += 1
            if input_id not in inputs:
                input_error(workflow_id, f"placeholder references undeclared input {input_id}")
        for node_id, node in workflow.get("nodes", {}).items():
            condition = node.get("when")
            if condition:
                input_id = str(condition.get("input", ""))
                input_defaults["references_checked"] += 1
                if input_id not in inputs:
                    input_error(workflow_id, f"node {node_id} condition references undeclared input {input_id}")
                elif "value" in condition and not matches_type(condition["value"], inputs[input_id].get("type")):
                    input_error(workflow_id, f"node {node_id} condition value does not match input {input_id}")


def normalize_repo_path(value):
    text = str(value).replace("\\", "/").strip()
    if not text or text == ".":
        return text
    if text.startswith("./"):
        text = text[2:]
    candidate = pathlib.PurePosixPath(text)
    if candidate.is_absolute() or ".." in candidate.parts:
        return None
    return candidate.as_posix()


def git_tracked(path_text):
    completed = subprocess.run(
        ["git", "-C", str(root), "ls-files", "--", path_text],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    return completed.returncode == 0 and bool(completed.stdout.strip())


path_availability = {
    "checked": 0,
    "tracked_required_checked": 0,
    "runtime_or_external_checked": 0,
    "errors": [],
}
lfs_candidates = set()


def path_error(message):
    path_availability["errors"].append(message)
    errors.append(message)


def check_path(locator, classification, context, locator_kind="repository_path"):
    path_availability["checked"] += 1
    if classification == "tracked_required":
        path_availability["tracked_required_checked"] += 1
    else:
        path_availability["runtime_or_external_checked"] += 1

    if locator_kind == "external_command":
        if classification not in ("environment_required", "external_platform"):
            path_error(f"{context}: external command {locator} has invalid availability {classification}")
        return

    relative = normalize_repo_path(locator)
    if relative is None or relative == "":
        path_error(f"{context}: invalid repository path {locator}")
        return
    absolute = root / relative
    if classification == "tracked_required":
        if not absolute.exists():
            path_error(f"{context}: tracked_required path is missing: {relative}")
        if not git_tracked(relative):
            path_error(f"{context}: tracked_required path is not tracked: {relative}")
        if absolute.is_file():
            lfs_candidates.add(absolute)
    elif classification in ("runtime_workspace_local", "generated_may_be_absent"):
        pass
    elif classification in ("environment_required", "external_platform"):
        path_error(f"{context}: repository path {relative} cannot use {classification}")


if catalog is not None:
    for workflow in catalog.get("workflows", []):
        workflow_id = workflow.get("id", "")
        for node_id, node in workflow.get("nodes", {}).items():
            command = node.get("command")
            if not command:
                continue
            entry_kind = command.get("entry_kind")
            availability = command.get("availability")
            entry = command.get("entry", "")
            if entry_kind == "repo_script":
                check_path(entry, availability, f"workflow {workflow_id} node {node_id}")
            elif entry_kind == "external_command":
                check_path(entry, availability, f"workflow {workflow_id} node {node_id}", "external_command")

if project_map is not None:
    for item in project_map.get("directories", []):
        check_path(item.get("path", ""), item.get("availability", ""), "project-map directory")
    for item in project_map.get("path_availability", []):
        check_path(
            item.get("locator", ""),
            item.get("classification", ""),
            "project-map path_availability",
            item.get("locator_kind", "repository_path"),
        )
    for item in project_map.get("build_entrypoints", []):
        kind = item.get("entry_kind", "")
        locator_kind = "external_command" if kind == "external_command" else "repository_path"
        check_path(item.get("entry", ""), item.get("availability", ""), f"build entrypoint {item.get('id', '')}", locator_kind)
        if item.get("build_file"):
            check_path(item["build_file"], "tracked_required", f"build entrypoint {item.get('id', '')} build_file")
    for item in project_map.get("verification_entrypoints", []):
        check_path(item.get("entry", ""), item.get("availability", ""), f"verification entrypoint {item.get('id', '')}")

for critical in (
    catalog_path,
    catalog_schema_path,
    project_map_path,
    project_map_schema_path,
    root / ".codex/config.toml",
    root / ".codex/requirements.toml",
    root / "server/server/game_server/build.xml",
    root / "server/server/game_server/protocol.main.xml",
    root / "server/server/game_server/xbean.xml",
    root / "server/server/game_server/gbeans.xml",
):
    if critical.is_file():
        lfs_candidates.add(critical)
for subtree in (root / ".codex", root / ".agents/skills"):
    if subtree.is_dir():
        for candidate in subtree.rglob("*"):
            if candidate.is_file():
                lfs_candidates.add(candidate)

lfs = {"checked": 0, "pointer_failures": [], "errors": []}
pointer_prefix = b"version https://git-lfs.github.com/spec/v1"
for path in sorted(lfs_candidates):
    try:
        with path.open("rb") as handle:
            prefix = handle.read(200).lstrip(b"\xef\xbb\xbf")
        lfs["checked"] += 1
        if prefix.startswith(pointer_prefix):
            relative = path.relative_to(root).as_posix()
            message = f"Git LFS pointer is not hydrated: {relative}"
            lfs["pointer_failures"].append(relative)
            lfs["errors"].append(message)
            errors.append(message)
    except Exception as exc:
        message = f"LFS hydration check failed: {path.relative_to(root).as_posix()}: {exc}"
        lfs["errors"].append(message)
        errors.append(message)

result = {
    "tooling": {
        "python": sys.version.split()[0],
    },
    "workflow_graphs": workflow_graphs,
    "cross_file": cross_file,
    "input_defaults": input_defaults,
    "path_availability": path_availability,
    "lfs": lfs,
    "errors": errors,
}
print(json.dumps(result, ensure_ascii=False))
'@

    $oldAuditRoot = $env:MT3_CODEX_AUDIT_ROOT
    $oldErrorActionPreference = $ErrorActionPreference
    $tempScriptPath = [System.IO.Path]::ChangeExtension([System.IO.Path]::GetTempFileName(), ".py")
    try {
        $env:MT3_CODEX_AUDIT_ROOT = $Root
        [System.IO.File]::WriteAllText($tempScriptPath, $script, (New-Object System.Text.UTF8Encoding($false)))
        $ErrorActionPreference = "Continue"
        $output = @(& $python.Source -X utf8 $tempScriptPath 2>&1)
        $exitCode = $LASTEXITCODE
        $ErrorActionPreference = $oldErrorActionPreference
        $jsonText = ([string]::Join("`n", @($output | ForEach-Object { [string]$_ }))).Trim()
        if ([string]::IsNullOrWhiteSpace($jsonText)) {
            throw "Structural validator produced no JSON output (exit=$exitCode)."
        }
        $result = $jsonText | ConvertFrom-Json -ErrorAction Stop
        if ($exitCode -ne 0) {
            $fatal = if ($result.PSObject.Properties.Name -contains "fatal_error") { [string]$result.fatal_error } else { $jsonText }
            throw "Structural validator failed (exit=$exitCode): $fatal"
        }
        return $result
    } finally {
        $ErrorActionPreference = $oldErrorActionPreference
        Remove-Item -LiteralPath $tempScriptPath -Force -ErrorAction SilentlyContinue
        if ($null -eq $oldAuditRoot) {
            Remove-Item Env:MT3_CODEX_AUDIT_ROOT -ErrorAction SilentlyContinue
        } else {
            $env:MT3_CODEX_AUDIT_ROOT = $oldAuditRoot
        }
    }
}

$validationErrors = New-Object System.Collections.Generic.List[string]
$validationWarnings = New-Object System.Collections.Generic.List[string]
$structuralValidation = $null
$schemaValidation = $null
$tomlParseFailures = @(Test-CodexTomlParsing -Root $ProjectRoot)
foreach ($failure in $tomlParseFailures) {
    if ($null -eq $failure -or -not ($failure.PSObject.Properties.Name -contains "file")) {
        continue
    }
    [void]$validationErrors.Add(".codex TOML parse failed: $([string]$failure.file): $([string]$failure.error)")
}

foreach ($requiredPath in @(
    $requirementsPath,
    $configPath,
    $profilesPath,
    $profileSchemaPath,
    $manifestPath,
    $workflowCatalogPath,
    $workflowSchemaPath,
    $projectMapPath,
    $projectMapSchemaPath
)) {
    if (-not (Test-Path $requiredPath -PathType Leaf)) {
        [void]$validationErrors.Add("Missing required file: $requiredPath")
    }
}

if ($validationErrors.Count -eq 0) {
    try {
        $schemaValidation = Invoke-JsonSchemaValidation -Root $ProjectRoot
        $structuralValidation = Invoke-StructuralValidation -Root $ProjectRoot
        $structuralValidation | Add-Member -NotePropertyName "schema_validation" -NotePropertyValue $schemaValidation -Force
        $structuralValidation.tooling | Add-Member -NotePropertyName "schema_engine" -NotePropertyValue ([string]$schemaValidation.engine) -Force
        foreach ($schemaId in @("workflow_catalog", "project_map", "mcp_profile")) {
            $schemaResult = $schemaValidation.$schemaId
            foreach ($item in @($schemaResult.errors)) {
                if (-not [string]::IsNullOrWhiteSpace([string]$item)) {
                    [void]$validationErrors.Add([string]$item)
                }
            }
        }
        foreach ($item in @($structuralValidation.errors)) {
            if (-not [string]::IsNullOrWhiteSpace([string]$item)) {
                [void]$validationErrors.Add([string]$item)
            }
        }
    } catch {
        [void]$validationErrors.Add("Structural validation failed closed: $($_.Exception.Message)")
    }
}

$requirementsText = if (Test-Path $requirementsPath -PathType Leaf) {
    Get-Content -Raw -Encoding UTF8 $requirementsPath
} else {
    ""
}

$configText = if (Test-Path $configPath -PathType Leaf) {
    Get-Content -Raw -Encoding UTF8 $configPath
} else {
    ""
}
$configMcpIds = @(Get-TomlMcpServerIds -Text $configText)

$profiles = if (Test-Path $profilesPath -PathType Leaf) { Load-Json -Path $profilesPath } else { $null }
$manifest = if (Test-Path $manifestPath -PathType Leaf) { Load-Json -Path $manifestPath } else { $null }

if (-not [string]::IsNullOrWhiteSpace($requirementsText)) {
    foreach ($token in @("schema-compatible sidecar", "project-scoped runtime", "managed/system requirements")) {
        if (-not $requirementsText.Contains($token)) {
            [void]$validationErrors.Add(".codex/requirements.toml missing sidecar boundary note: $token")
        }
    }

    $approvalPolicies = @(Get-TomlArrayValues -Text $requirementsText -Key "allowed_approval_policies")
    $sandboxModes = @(Get-TomlArrayValues -Text $requirementsText -Key "allowed_sandbox_modes")
    $webSearchModes = @(Get-TomlArrayValues -Text $requirementsText -Key "allowed_web_search_modes")
    $approvedMcpIds = @(Get-TomlMcpIdentities -Text $requirementsText)

    foreach ($value in $approvalPolicies) {
        if (@("untrusted", "on-request", "never", "granular") -notcontains $value) {
            [void]$validationErrors.Add("allowed_approval_policies contains unsupported value: $value")
        }
    }
    foreach ($value in $sandboxModes) {
        if (@("read-only", "workspace-write", "danger-full-access") -notcontains $value) {
            [void]$validationErrors.Add("allowed_sandbox_modes contains unsupported value: $value")
        }
    }
    foreach ($value in $webSearchModes) {
        if (@("disabled", "enabled", "cached") -notcontains $value) {
            [void]$validationErrors.Add("allowed_web_search_modes contains unsupported value: $value")
        }
    }

    foreach ($disallowedMcp in @("notion", "open-websearch")) {
        if ($approvedMcpIds -contains $disallowedMcp) {
            [void]$validationErrors.Add("requirements sidecar should not include $disallowedMcp in the default approved MCP identity set")
        }
    }
}

if (-not [string]::IsNullOrWhiteSpace($configText)) {
    foreach ($token in @(
        'approval_policy = "on-request"',
        'sandbox_mode = "workspace-write"',
        'web_search = "cached"',
        '[mcp_servers.openaiDeveloperDocs]',
        'enabled = false'
    )) {
        if (-not $configText.Contains($token)) {
            [void]$validationErrors.Add(".codex/config.toml missing native runtime token: $token")
        }
    }
}

$manifestServerIds = @()
$manifestEnabledIds = @()
if ($null -ne $manifest) {
    $manifestServers = @($manifest.servers)
    $manifestServerIds = @($manifestServers | ForEach-Object { [string]$_.id } | Sort-Object -Unique)
    $manifestEnabledIds = @(
        $manifestServers |
            Where-Object { [bool]$_.enabled_by_default } |
            ForEach-Object { [string]$_.id } |
            Sort-Object -Unique
    )

    if ($manifestEnabledIds.Count -ne 0) {
        [void]$validationErrors.Add(".claude/config/mcp.manifest.json default enabled set must be empty")
    }

    foreach ($server in $manifestServers) {
        $serverId = [string]$server.id
        $provider = [string]$server.provider
        if ($server.PSObject.Properties.Name -contains "required_env") {
            [void]$validationErrors.Add("mcp.manifest.json must not copy environment variable bindings: $serverId")
        }
        if ($provider -match '^[A-Za-z]:[\\/]' -or $provider -match '(^|[\\/])Users[\\/]' -or $provider -match '(?i)(TOKEN|API_KEY|PASSWORD)') {
            [void]$validationErrors.Add("mcp.manifest.json provider must stay generic and secret-free: $serverId")
        }
    }
}

$profilesById = @{}
if ($null -ne $profiles) {
    $knownServers = @($profiles.known_servers | ForEach-Object { [string]$_ } | Sort-Object -Unique)
    foreach ($profile in @($profiles.profiles)) {
        $profileId = [string]$profile.id
        if ($profilesById.ContainsKey($profileId)) {
            [void]$validationErrors.Add("MCP profile id must be unique: $profileId")
            continue
        }
        $profilesById[$profileId] = $profile
    }

    $expectedProfileIds = @("browser-debug", "none", "official-docs", "research")
    $actualProfileIds = @($profilesById.Keys | Sort-Object)
    if (($actualProfileIds -join "|") -ne ($expectedProfileIds -join "|")) {
        [void]$validationErrors.Add("MCP profile ids must be exactly: $($expectedProfileIds -join ', ')")
    }

    foreach ($profile in @($profiles.profiles)) {
        $profileId = [string]$profile.id
        $enabledServers = @($profile.enable | ForEach-Object { [string]$_ } | Sort-Object -Unique)
        $disabledServers = @($profile.disable | ForEach-Object { [string]$_ } | Sort-Object -Unique)
        $requiredConfigured = @($profile.required_configured | ForEach-Object { [string]$_ } | Sort-Object -Unique)
        $overlap = @($enabledServers | Where-Object { $disabledServers -contains $_ })
        $coveredServers = @($enabledServers + $disabledServers | Sort-Object -Unique)
        $missingServers = @($knownServers | Where-Object { $coveredServers -notcontains $_ })
        $unknownServers = @($coveredServers | Where-Object { $knownServers -notcontains $_ })
        $requiredButDisabled = @($requiredConfigured | Where-Object { $enabledServers -notcontains $_ })

        if ($overlap.Count -gt 0) {
            [void]$validationErrors.Add("MCP profile $profileId enable/disable overlap: $($overlap -join ', ')")
        }
        if ($missingServers.Count -gt 0) {
            [void]$validationErrors.Add("MCP profile $profileId does not cover known servers: $($missingServers -join ', ')")
        }
        if ($unknownServers.Count -gt 0) {
            [void]$validationErrors.Add("MCP profile $profileId references unknown servers: $($unknownServers -join ', ')")
        }
        if ($requiredButDisabled.Count -gt 0) {
            [void]$validationErrors.Add("MCP profile $profileId required_configured must be enabled: $($requiredButDisabled -join ', ')")
        }
    }
}

if ($null -ne $manifest -and $null -ne $profiles -and -not [string]::IsNullOrWhiteSpace($requirementsText)) {
    $approvedMcpIds = @(Get-TomlMcpIdentities -Text $requirementsText)
    foreach ($serverId in $approvedMcpIds) {
        if ($manifestServerIds -notcontains $serverId) {
            [void]$validationErrors.Add("requirements sidecar approves an MCP that is missing from mcp.manifest.json: $serverId")
        }
    }

    foreach ($profile in @($profiles.profiles)) {
        foreach ($serverId in @($profile.enable + $profile.disable + $profile.required_configured)) {
            $sid = [string]$serverId
            if ([string]::IsNullOrWhiteSpace($sid)) {
                continue
            }
            if ($manifestServerIds -notcontains $sid) {
                [void]$validationErrors.Add("mcp-profiles.json references a server not declared in mcp.manifest.json: $sid")
            }
        }
    }

    $profileKnownServers = @($profiles.known_servers | ForEach-Object { [string]$_ } | Sort-Object -Unique)
    if (($manifestServerIds -join "|") -ne ($profileKnownServers -join "|")) {
        [void]$validationErrors.Add("mcp.manifest.json server ids must exactly match mcp-profiles.json known_servers")
    }
    if (($configMcpIds -join "|") -ne ($profileKnownServers -join "|")) {
        [void]$validationErrors.Add(".codex/config.toml MCP ids must exactly match mcp-profiles.json known_servers")
    }
    if (($configMcpIds -join "|") -ne ($manifestServerIds -join "|")) {
        [void]$validationErrors.Add(".codex/config.toml MCP ids must exactly match mcp.manifest.json server ids")
    }
}

$status = if ($validationErrors.Count -eq 0) { "PASS" } else { "FAIL" }
$timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

$result = [ordered]@{
    timestamp = $timestamp
    project_root = $ProjectRoot
    status = $status
    errors = @($validationErrors)
    warnings = @($validationWarnings)
    toml_parse_failures = @($tomlParseFailures)
    config_mcp_ids = @($configMcpIds)
    approved_mcp_identities = @(Get-TomlMcpIdentities -Text $requirementsText)
    manifest_enabled_by_default = @($manifestEnabledIds)
    profiles = if ($null -ne $profiles) {
        @($profiles.profiles | ForEach-Object {
            [ordered]@{
                id = [string]$_.id
                enable = @($_.enable)
                disable = @($_.disable)
                required_configured = @($_.required_configured)
            }
        })
    } else {
        @()
    }
    schema_validation = if ($null -ne $structuralValidation) { $structuralValidation.schema_validation } else { $null }
    workflow_graphs = if ($null -ne $structuralValidation) { $structuralValidation.workflow_graphs } else { $null }
    cross_file = if ($null -ne $structuralValidation) { $structuralValidation.cross_file } else { $null }
    input_defaults = if ($null -ne $structuralValidation) { $structuralValidation.input_defaults } else { $null }
    path_availability = if ($null -ne $structuralValidation) { $structuralValidation.path_availability } else { $null }
    lfs = if ($null -ne $structuralValidation) { $structuralValidation.lfs } else { $null }
    tooling = if ($null -ne $structuralValidation) { $structuralValidation.tooling } else { $null }
}

$jsonPath = Join-Path $reportRoot "codex-sidecars-validation.json"
$mdPath = Join-Path $reportRoot "codex-sidecars-validation.md"

Write-Utf8NoBom -FilePath $jsonPath -Text ($result | ConvertTo-Json -Depth 20)

$md = @()
$md += "# Codex Sidecars Validation"
$md += ""
$md += "- Time: $timestamp"
$md += "- Project: $ProjectRoot"
$md += "- Status: **$status**"
$md += "- Config MCP ids: $((@($result.config_mcp_ids) -join ', '))"
$md += "- Approved MCP identities: $((@($result.approved_mcp_identities) -join ', '))"
$md += "- Manifest enabled by default: $((@($result.manifest_enabled_by_default) -join ', '))"
if ($null -ne $structuralValidation) {
    $md += "- Schemas: workflow=$($structuralValidation.schema_validation.workflow_catalog.status), project-map=$($structuralValidation.schema_validation.project_map.status), mcp-profile=$($structuralValidation.schema_validation.mcp_profile.status)"
    $md += "- Workflow graphs: $($structuralValidation.workflow_graphs.connected)/$($structuralValidation.workflow_graphs.total) connected"
    $md += "- Cross-file references: agents=$($structuralValidation.cross_file.agent_references_checked), skills=$($structuralValidation.cross_file.skill_references_checked), workflows=$($structuralValidation.cross_file.workflow_references_checked)"
    $md += "- Path availability checks: $($structuralValidation.path_availability.checked)"
    $md += "- LFS hydration checks: $($structuralValidation.lfs.checked)"
}
$md += ""
if ($validationErrors.Count -gt 0) {
    $md += "## Errors"
    foreach ($item in $validationErrors) {
        $md += "- $item"
    }
    $md += ""
}
if ($validationWarnings.Count -gt 0) {
    $md += "## Warnings"
    foreach ($item in $validationWarnings) {
        $md += "- $item"
    }
}

Write-Utf8NoBom -FilePath $mdPath -Text ([string]::Join("`r`n", $md))

Write-Output "=== Codex Sidecars Validation ==="
Write-Output "Status: $status"
Write-Output "Errors: $($validationErrors.Count)"
Write-Output "Warnings: $($validationWarnings.Count)"
if ($null -ne $structuralValidation) {
    Write-Output "Workflow Graphs: $($structuralValidation.workflow_graphs.connected)/$($structuralValidation.workflow_graphs.total)"
    Write-Output "Path Availability Checks: $($structuralValidation.path_availability.checked)"
    Write-Output "LFS Hydration Checks: $($structuralValidation.lfs.checked)"
}
Write-Output "JSON Report: $jsonPath"
Write-Output "Markdown Report: $mdPath"

if ($status -eq "PASS") {
    exit 0
}
exit 1

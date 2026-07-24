#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROBOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

TARGET_DIR="${ROBOT_DIR}/config/auto"
LIST_FILE="${ROBOT_DIR}/config/auto_required.list"
MODE="${ROBOT_SYNC_MODE:-minimal}"
DRY_RUN=0
DELETE_EXTRA=0
STRICT=1

detect_source_dir() {
  local cand1="${ROBOT_DIR}/../gamedata/xml/auto"
  local search="${ROBOT_DIR}"
  local i
  if [[ -d "$cand1" ]]; then
    echo "$cand1"
    return 0
  fi

  # 向上回溯目录，兼容 tools 目录与独立运行目录两种布局。
  for ((i=0; i<8; i++)); do
    local cand="${search}/centos_mhxy/home/game/server1/game_server/gamedata/xml/auto"
    if [[ -d "$cand" ]]; then
      echo "$cand"
      return 0
    fi
    search="$(dirname "$search")"
  done
  echo "$cand1"
}

SOURCE_DIR="$(detect_source_dir)"

usage() {
  cat <<'EOF'
用法:
  sync_auto_configs.sh [选项]

选项:
  --source <dir>        服务端 auto 源目录，默认: ../gamedata/xml/auto
  --target <dir>        机器人 auto 目标目录，默认: config/auto
  --list <file>         最小同步清单文件，默认: config/auto_required.list
  --mode <minimal|all>  同步模式，默认: minimal
  --delete-extra        删除目标目录中不在清单内的 xml
  --dry-run             仅打印计划，不实际复制
  --strict              严格模式（默认，缺文件即失败）
  --non-strict          非严格模式（缺文件仅警告）
  -h, --help            显示帮助
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      SOURCE_DIR="$2"
      shift 2
      ;;
    --target)
      TARGET_DIR="$2"
      shift 2
      ;;
    --list)
      LIST_FILE="$2"
      shift 2
      ;;
    --mode)
      MODE="$2"
      shift 2
      ;;
    --delete-extra)
      DELETE_EXTRA=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --strict)
      STRICT=1
      shift
      ;;
    --non-strict)
      STRICT=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] 未知参数: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ "$MODE" != "minimal" && "$MODE" != "all" ]]; then
  echo "[ERROR] --mode 仅支持 minimal 或 all，当前: $MODE" >&2
  exit 2
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "[ERROR] 源目录不存在: $SOURCE_DIR" >&2
  exit 2
fi

mkdir -p "$TARGET_DIR"

declare -a managed_files
if [[ "$MODE" == "all" ]]; then
  mapfile -t managed_files < <(cd "$SOURCE_DIR" && ls -1 *.xml 2>/dev/null | sort)
else
  if [[ ! -f "$LIST_FILE" ]]; then
    echo "[ERROR] 清单文件不存在: $LIST_FILE" >&2
    exit 2
  fi
  while IFS= read -r raw || [[ -n "$raw" ]]; do
    line="${raw%%#*}"
    line="$(echo "$line" | xargs)"
    [[ -z "$line" ]] && continue
    managed_files+=("$line")
  done < "$LIST_FILE"
  mapfile -t managed_files < <(printf '%s\n' "${managed_files[@]}" | awk 'NF' | sort -u)
fi

if [[ ${#managed_files[@]} -eq 0 ]]; then
  echo "[ERROR] 未解析到任何需要同步的 xml 文件" >&2
  exit 2
fi

declare -A managed_map
for f in "${managed_files[@]}"; do
  managed_map["$f"]=1
done

copied=0
missing=0
for f in "${managed_files[@]}"; do
  src="$SOURCE_DIR/$f"
  dst="$TARGET_DIR/$f"
  if [[ ! -f "$src" ]]; then
    echo "[WARN] 源文件缺失: $src"
    missing=$((missing + 1))
    continue
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY-RUN] cp -f $src $dst"
  else
    cp -f "$src" "$dst"
  fi
  copied=$((copied + 1))
done

if [[ "$DELETE_EXTRA" -eq 1 ]]; then
  shopt -s nullglob
  for full in "$TARGET_DIR"/*.xml; do
    base="$(basename "$full")"
    if [[ -z "${managed_map[$base]:-}" ]]; then
      if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[DRY-RUN] rm -f $full"
      else
        rm -f "$full"
      fi
    fi
  done
  shopt -u nullglob
fi

if [[ "$missing" -gt 0 && "$STRICT" -eq 1 ]]; then
  echo "[ERROR] 同步失败: 源目录缺失 $missing 个文件（严格模式）" >&2
  exit 3
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[OK] dry-run 完成: mode=$MODE managed=${#managed_files[@]} copied=$copied missing=$missing"
  exit 0
fi

MANIFEST="$ROBOT_DIR/config/auto_manifest.tsv"
META="$ROBOT_DIR/config/auto_manifest.meta"
mkdir -p "$(dirname "$MANIFEST")"
: > "$MANIFEST"

for f in "${managed_files[@]}"; do
  file="$TARGET_DIR/$f"
  if [[ ! -f "$file" ]]; then
    echo "[WARN] 目标文件缺失，跳过 hash: $file"
    continue
  fi
  hash="$(sha256sum "$file" | awk '{print $1}')"
  printf '%s\t%s\n' "$hash" "$f" >> "$MANIFEST"
done

manifest_hash="$(sha256sum "$MANIFEST" | awk '{print $1}')"
generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

cat > "$META" <<EOF
script=sync_auto_configs.sh
generated_at=$generated_at
mode=$MODE
source_dir=$SOURCE_DIR
target_dir=$TARGET_DIR
managed_count=${#managed_files[@]}
manifest_file=$(basename "$MANIFEST")
manifest_hash=$manifest_hash
EOF

echo "[OK] 同步完成: mode=$MODE managed=${#managed_files[@]} copied=$copied missing=$missing"
echo "[OK] manifest: $MANIFEST"
echo "[OK] meta: $META"

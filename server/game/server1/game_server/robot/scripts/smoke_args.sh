#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROBOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() {
  echo "[FAIL] $1" >&2
  exit 1
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local file="$1"
  [[ -f "$file" ]] || fail "missing file: $file"
}

require_pattern() {
  local file="$1"
  local pattern="$2"
  local msg="$3"
  if grep -Eq "$pattern" "$file"; then
    pass "$msg"
  else
    fail "$msg"
  fi
}

start_script="$ROBOT_DIR/start_robot.sh"
main_java="$ROBOT_DIR/src/robot/Main.java"
parser_java="$ROBOT_DIR/src/robot/MainOptionParser.java"
build_xml="$ROBOT_DIR/build.xml"
run_bat="$ROBOT_DIR/run_robot.bat"

require_file "$start_script"
if [[ -f "$run_bat" ]]; then
  require_pattern "$run_bat" "set MAIN_JAR=robot\\.jar" "run_robot.bat uses root robot.jar as primary jar"
else
  pass "optional Windows launcher skipped: $run_bat"
fi

require_pattern "$start_script" 'GSXDB_JAR_PRIMARY="\$DIR/\.\./gsxdb\.jar"' "start_robot.sh uses runtime sibling gsxdb.jar as primary jar"
require_pattern "$start_script" 'OUTPUT_LOG_RAW="\$\{ROBOT_STDOUT_LOG:-\.\./logs/robot-bootstrap\.out\}"' "start_robot.sh writes stdout to game_server/logs/robot-bootstrap.out by default"
if grep -Eq 'gsxdb_source/dist/gsxdb\.jar' "$start_script"; then
  fail "start_robot.sh should not fallback to gsxdb_source/dist/gsxdb.jar in runtime tree"
else
  pass "start_robot.sh does not depend on gsxdb_source/dist/gsxdb.jar in runtime tree"
fi

if [[ -f "$main_java" && -f "$parser_java" && -f "$build_xml" ]]; then
  require_pattern "$parser_java" "isTaskTypeArg" "MainOptionParser.java contains taskType parser helper"
  require_pattern "$main_java" "robot_main_unknown_arg" "Main.java logs unknown optional args"
  require_pattern "$build_xml" "tofile=\"\\$\\{runtime\\.jar\\}\"" "build.xml syncs dist jar to runtime jar"
else
  pass "source-only smoke checks skipped in runtime tree"
fi

tmp_log="$(mktemp)"
set +e
bash "$start_script" --task-type bad --count 1 >"$tmp_log" 2>&1
rc=$?
set -e
if [[ $rc -eq 0 ]]; then
  cat "$tmp_log" >&2
  rm -f "$tmp_log"
  fail "start_robot.sh should reject invalid task type"
fi
if ! grep -q "invalid task type" "$tmp_log"; then
  cat "$tmp_log" >&2
  rm -f "$tmp_log"
  fail "start_robot.sh invalid task type message missing"
fi
rm -f "$tmp_log"
pass "start_robot.sh rejects invalid task type"

tmp_log="$(mktemp)"
set +e
bash "$start_script" --task-type 37 --delay bad --count 1 >"$tmp_log" 2>&1
rc=$?
set -e
if [[ $rc -eq 0 ]]; then
  cat "$tmp_log" >&2
  rm -f "$tmp_log"
  fail "start_robot.sh should reject invalid delay"
fi
if ! grep -q "invalid delay seconds" "$tmp_log"; then
  cat "$tmp_log" >&2
  rm -f "$tmp_log"
  fail "start_robot.sh invalid delay message missing"
fi
rm -f "$tmp_log"
pass "start_robot.sh rejects invalid delay"

pass "smoke args checks passed"

#!/bin/bash
set -euo pipefail

SERVICE_NAME="sdk_server"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/${SERVICE_NAME}.pid"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/${SERVICE_NAME}.log"

JAVA_BIN="${JAVA_BIN:-java}"
JAVA_HEAP_OPTS="${JAVA_HEAP_OPTS:-"-Xms256m -Xmx512m"}"
JAVA_SYSTEM_OPTS="${JAVA_SYSTEM_OPTS:-"-Djava.awt.headless=true -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"}"
SERVICE_PORT="${SERVICE_PORT:-8081}"
SERVICE_PORTS="${SERVICE_PORTS:-8081 2701 2702}"
PROCESS_PATTERN="${PROCESS_PATTERN:-sdkserver\\.jar|com\\.locojoy\\.sdk\\.SdkServer}"
SDK_LAUNCH_MODE="${SDK_LAUNCH_MODE:-classpath}"
SDK_MAIN_CLASS="${SDK_MAIN_CLASS:-com.locojoy.sdk.SdkServer}"
SDK_CLASSPATH="${SDK_CLASSPATH:-sdkserver.jar:libs/*:/home/game/common/name_server/lib/*:/home/game/server1/game_server/lib/*}"
SDK_EXTRA_ARGS="${SDK_EXTRA_ARGS:-}"

read_pid_file() {
    if [ -f "$PID_FILE" ]; then
        tr -cd '0-9' < "$PID_FILE" 2>/dev/null || true
    fi
}

process_matches_service() {
    local pid="$1"
    local cwd
    local cmdline
    [ -d "/proc/$pid" ] || return 1
    cwd="$(readlink -f "/proc/$pid/cwd" 2>/dev/null || true)"
    [ "$cwd" = "$SCRIPT_DIR" ] || return 1
    cmdline="$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || true)"
    [ -n "$cmdline" ] || return 1
    echo "$cmdline" | grep -Eq "$PROCESS_PATTERN"
}

discover_running_pid() {
    local proc
    local pid
    for proc in /proc/[0-9]*; do
        pid="${proc##*/}"
        if process_matches_service "$pid"; then
            echo "$pid"
            return 0
        fi
    done
    return 1
}

write_pid_file() {
    local pid="$1"
    if [ -n "$pid" ]; then
        echo "$pid" > "$PID_FILE"
    fi
}

is_running() {
    local pid
    local discovered_pid
    if [ -f "$PID_FILE" ]; then
        pid="$(read_pid_file)"
        if [ -n "$pid" ] && process_matches_service "$pid"; then
            return 0
        fi
    fi
    if discovered_pid="$(discover_running_pid)"; then
        write_pid_file "$discovered_pid"
        return 0
    fi
    rm -f "$PID_FILE"
    return 1
}

is_port_in_use() {
    local port="$1"
    if command -v ss >/dev/null 2>&1; then
        ss -lntH 2>/dev/null | awk -v p=":${port}" '$4 ~ p"$" {found=1} END{exit found?0:1}'
        return $?
    fi
    if command -v netstat >/dev/null 2>&1; then
        netstat -lnt 2>/dev/null | awk -v p=":${port}" '$4 ~ p"$" {found=1} END{exit found?0:1}'
        return $?
    fi
    if command -v lsof >/dev/null 2>&1; then
        lsof -iTCP:"$port" -sTCP:LISTEN -t >/dev/null 2>&1
        return $?
    fi
    return 1
}

ensure_ports_available() {
    local port
    for port in $SERVICE_PORTS; do
        if is_port_in_use "$port"; then
            echo "$SERVICE_NAME port $port is already in use; cancel start."
            return 1
        fi
    done
    return 0
}

start() {
    if is_running; then
        echo "$SERVICE_NAME already running (pid $(read_pid_file))."
        return 0
    fi
    ensure_ports_available

    cd "$SCRIPT_DIR"
    mkdir -p "$LOG_DIR"

      local cmd=("$JAVA_BIN" -server)
      cmd+=($JAVA_HEAP_OPTS)
      if [ -n "$JAVA_SYSTEM_OPTS" ]; then
          local system_args=()
          read -r -a system_args <<<"$JAVA_SYSTEM_OPTS"
          cmd+=("${system_args[@]}")
      fi
      local extra_args=()
    if [ -n "$SDK_EXTRA_ARGS" ]; then
        read -r -a extra_args <<<"$SDK_EXTRA_ARGS"
    fi
    if [ "$SDK_LAUNCH_MODE" = "classpath" ]; then
        cmd+=(-cp "$SDK_CLASSPATH" "$SDK_MAIN_CLASS")
    else
        cmd+=(-jar sdkserver.jar)
    fi
    if [ ${#extra_args[@]} -gt 0 ]; then
        cmd+=("${extra_args[@]}")
    fi

    nohup "${cmd[@]}" >>"$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"

    sleep 1
    if ! is_running; then
        echo "Failed to start $SERVICE_NAME. Check $LOG_FILE."
        exit 1
    fi

    echo "$SERVICE_NAME started (pid $(read_pid_file))."
}

stop() {
    local force="${1:-}"
    if ! is_running; then
        echo "$SERVICE_NAME not running."
        return 0
    fi

    local pid
    pid="$(read_pid_file)"
    if [ "$force" = "-f" ] || [ "$force" = "force" ]; then
        kill -9 "$pid" 2>/dev/null || true
        rm -f "$PID_FILE"
        echo "$SERVICE_NAME force stopped."
        return 0
    fi
    kill "$pid" 2>/dev/null || true

    for _ in $(seq 1 15); do
        if ! kill -0 "$pid" 2>/dev/null; then
            rm -f "$PID_FILE"
            echo "$SERVICE_NAME stopped."
            return 0
        fi
        sleep 1
    done

    echo "Force killing $SERVICE_NAME (pid $pid)..."
    kill -9 "$pid" 2>/dev/null || true
    rm -f "$PID_FILE"
}

status() {
    if is_running; then
        echo "$SERVICE_NAME running (pid $(read_pid_file))."
    else
        echo "$SERVICE_NAME not running."
    fi
}

case "${1:-start}" in
    start) start ;;
    stop) stop "${2:-}" ;;
    restart) stop; start ;;
    status) status ;;
    *) echo "Usage: $0 {start|stop|restart|status}"; exit 1 ;;
esac

#!/bin/bash
set -euo pipefail

SERVICE_NAME="gate_server"
DISPLAY_NAME="网关服务"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/${SERVICE_NAME}.pid"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/${SERVICE_NAME}.log"

BIN_PATH="${BIN_PATH:-./gateserver}"
CONF_FILE="${CONF_FILE:-gate.conf}"
ZONE_DIR_NAME="$(basename "$(dirname "$SCRIPT_DIR")")"
if [[ "$ZONE_DIR_NAME" =~ ^server([0-9]+)$ ]]; then
    ZONE_NUMBER="${BASH_REMATCH[1]}"
else
    ZONE_NUMBER="${ZONE_NUMBER:-1}"
fi
SERVICE_PORTS="${SERVICE_PORTS:-$((ZONE_NUMBER + 42000)) $((ZONE_NUMBER + 43000))}"

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
    echo "$cmdline" | grep -Eq '(^|/| )gateserver( |$)|gate\.conf'
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
            echo "$DISPLAY_NAME port $port is already in use; cancel start."
            return 1
        fi
    done
    return 0
}

start() {
    if is_running; then
        echo "$DISPLAY_NAME已在运行 (PID: $(read_pid_file))."
        return 0
    fi
    ensure_ports_available

    cd "$SCRIPT_DIR"
    mkdir -p "$LOG_DIR"

    if [ ! -x "$BIN_PATH" ]; then
        echo "$DISPLAY_NAME启动文件不存在或不可执行: $BIN_PATH"
        exit 1
    fi

    nohup "$BIN_PATH" "$CONF_FILE" >>"$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"

    sleep 1
    if ! is_running; then
        echo "$DISPLAY_NAME启动失败，请检查 $LOG_FILE。"
        exit 1
    fi

    echo "$DISPLAY_NAME已启动 (PID: $(cat "$PID_FILE"))."
}

stop() {
    local force="${1:-}"
    if ! is_running; then
        echo "$DISPLAY_NAME未运行。"
        return 0
    fi

    local pid
    pid="$(read_pid_file)"
    if [ "$force" = "-f" ] || [ "$force" = "force" ]; then
        kill -9 "$pid" 2>/dev/null || true
        rm -f "$PID_FILE"
        echo "$DISPLAY_NAME已强制停止。"
        return 0
    fi
    kill "$pid" 2>/dev/null || true

    for _ in $(seq 1 15); do
        if ! kill -0 "$pid" 2>/dev/null; then
            rm -f "$PID_FILE"
            echo "$DISPLAY_NAME已停止。"
            return 0
        fi
        sleep 1
    done

    echo "正在强制结束$DISPLAY_NAME (PID: $pid)..."
    kill -9 "$pid" 2>/dev/null || true
    rm -f "$PID_FILE"
}

status() {
    if is_running; then
        echo "$DISPLAY_NAME运行中 (PID: $(read_pid_file))."
    else
        echo "$DISPLAY_NAME未运行。"
    fi
}

case "${1:-start}" in
    start) start ;;
    stop) stop "${2:-}" ;;
    restart) stop; start ;;
    status) status ;;
    *) echo "用法: $0 {start|stop|restart|status}"; exit 1 ;;
esac

#!/bin/bash
set -euo pipefail

SERVICE_NAME="game_server"
DISPLAY_NAME="游戏服务"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/${SERVICE_NAME}.pid"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="${LOG_FILE:-/dev/null}"

JAVA_BIN="${JAVA_BIN:-java}"
GM_PORT="${GM_PORT:-41001}"
JAVA_HEAP_OPTS="${JAVA_HEAP_OPTS:-"-Xms512m -Xmx1024m -Xmn256m"}"
JAVA_ENCODING_OPTS="${JAVA_ENCODING_OPTS:-"-Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"}"
GAME_LAUNCH_MODE="${GAME_LAUNCH_MODE:-classpath}"
GAME_MAIN_CLASS="${GAME_MAIN_CLASS:-fire.pb.main.Gs}"
GAME_CLASSPATH="${GAME_CLASSPATH:-gsxdb.jar:lib/*:lib2/*}"
GAME_EXTRA_ARGS="${GAME_EXTRA_ARGS:--usemysql 1}"
ROBOT_AUTOSTOP="${ROBOT_AUTOSTOP:-1}"
ROBOT_DIR="${ROBOT_DIR:-$SCRIPT_DIR/robot}"
ROBOT_STOP_SCRIPT="${ROBOT_STOP_SCRIPT:-$ROBOT_DIR/stop_robot.sh}"

JDWP_ENABLE="${JDWP_ENABLE:-0}"
JDWP_PORT="${JDWP_PORT:-42998}"
SERVICE_PORTS="${SERVICE_PORTS:-$GM_PORT}"

LOGGING_JARS=(
    "lib/slf4j-api-1.7.30.jar"
    "lib/log4j-api-2.6.jar"
    "lib/log4j-core-2.6.jar"
    "lib/log4j-slf4j-impl-2.6.jar"
    "lib/log4j-1.2-api-2.6.jar"
    "lib/log4j-1.2.15.jar"
)

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
    echo "$cmdline" | grep -Eq 'gsxdb\.jar|fire\.pb\.main\.Gs'
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
            echo "端口 $port 已被占用，已取消启动$DISPLAY_NAME。"
            return 1
        fi
    done
    return 0
}

merge_logging_classpath() {
    local cp="$1"
    local jar
    for jar in "${LOGGING_JARS[@]}"; do
        if [ -f "$SCRIPT_DIR/$jar" ] && [[ ":$cp:" != *":$jar:"* ]]; then
            cp="${cp}:$jar"
        fi
    done
    echo "$cp"
}

build_logging_bootclasspath() {
    local entries=()
    local jar
    for jar in "${LOGGING_JARS[@]}"; do
        if [ -f "$SCRIPT_DIR/$jar" ]; then
            entries+=("$SCRIPT_DIR/$jar")
        fi
    done
    local IFS=":"
    echo "${entries[*]}"
}

stop_robot_if_enabled() {
    if [ "$ROBOT_AUTOSTOP" != "1" ]; then
        return 0
    fi
    if [ ! -f "$ROBOT_STOP_SCRIPT" ]; then
        return 0
    fi
    bash "$ROBOT_STOP_SCRIPT" || echo "[警告] 机器人停止失败"
}

start() {
    if is_running; then
        echo "$DISPLAY_NAME已在运行 (PID: $(read_pid_file))."
        return 0
    fi
    ensure_ports_available

    cd "$SCRIPT_DIR"
    mkdir -p "$LOG_DIR"
    rm -f "$SCRIPT_DIR/gs.log"
    rm -f "$LOG_DIR/bootstrap.out"

    local cmd=("$JAVA_BIN" -server)
    # 业务主链走 log4j 1.x；三方库里的 SLF4J 通过 log4j2 绑定后也写入 gs.log。
    cmd+=(-Dlog4j.configuration="file:$SCRIPT_DIR/log4j.xml")
    cmd+=(-Dlog4j.configurationFile="file:$SCRIPT_DIR/log4j2.xml")
    cmd+=(-Dlog4j2.configurationFile="file:$SCRIPT_DIR/log4j2.xml")
    local encoding_args=()
    if [ -n "$JAVA_ENCODING_OPTS" ]; then
        read -r -a encoding_args <<<"$JAVA_ENCODING_OPTS"
        cmd+=("${encoding_args[@]}")
    fi
    if [ "$JDWP_ENABLE" = "1" ]; then
        cmd+=(-Xdebug -Xrunjdwp:transport=dt_socket,address="$JDWP_PORT",server=y,suspend=n)
    fi
    cmd+=($JAVA_HEAP_OPTS)
    cmd+=(
        -XX:MetaspaceSize=128m
        -XX:MaxMetaspaceSize=192m
        -XX:CompressedClassSpaceSize=128m
        -XX:+UseG1GC
        -XX:MaxGCPauseMillis=200
        -XX:G1HeapRegionSize=16m
        -XX:InitiatingHeapOccupancyPercent=45
        -XX:+PrintGCDetails
        -XX:+PrintGCDateStamps
        -XX:+PrintGCTimeStamps
        -XX:+PrintGCApplicationStoppedTime
        -XX:+PrintStringDeduplicationStatistics
        -Xloggc:"$LOG_DIR/gc.log"
        -XX:+UseGCLogFileRotation
        -XX:NumberOfGCLogFiles=10
        -XX:GCLogFileSize=100M
        -XX:+HeapDumpOnOutOfMemoryError
        -XX:HeapDumpPath="$LOG_DIR/"
        -XX:ErrorFile="$LOG_DIR/hs_err_pid%p.log"
        -XX:+ExitOnOutOfMemoryError
        -Djdk.attach.allowAttachSelf=true
        -Dcom.sun.management.jmxremote.authenticate=true
    )
    local extra_args=()
    if [ -n "$GAME_EXTRA_ARGS" ]; then
        read -r -a extra_args <<<"$GAME_EXTRA_ARGS"
    fi
    if [ "$GAME_LAUNCH_MODE" = "classpath" ]; then
        local effective_classpath
        effective_classpath="$(merge_logging_classpath "$GAME_CLASSPATH")"
        cmd+=(-cp "$effective_classpath" "$GAME_MAIN_CLASS" -rmiport "$GM_PORT")
    else
        # jar 模式下 -jar 会忽略 -cp，这里把日志链路依赖补到 bootclasspath，避免三方日志丢失。
        local logging_boot_cp
        logging_boot_cp="$(build_logging_bootclasspath)"
        if [ -n "$logging_boot_cp" ]; then
            cmd+=(-Xbootclasspath/a:"$logging_boot_cp")
        fi
        cmd+=(-jar gsxdb.jar -rmiport "$GM_PORT")
    fi
    if [ ${#extra_args[@]} -gt 0 ]; then
        cmd+=("${extra_args[@]}")
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] start command: ${cmd[*]}" >>"$LOG_FILE"
    nohup "${cmd[@]}" >>"$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"

    sleep 1
    if ! is_running; then
        echo "$DISPLAY_NAME启动失败，请检查 $SCRIPT_DIR/gs.log。"
        exit 1
    fi

    echo "$DISPLAY_NAME已启动 (PID: $(cat "$PID_FILE"))."
}

stop() {
    local force="${1:-}"
    if ! is_running; then
        echo "$DISPLAY_NAME未运行。"
        stop_robot_if_enabled
        return 0
    fi

    local pid
    pid="$(read_pid_file)"
    if [ "$force" = "-f" ] || [ "$force" = "force" ]; then
        kill -9 "$pid" 2>/dev/null || true
        rm -f "$PID_FILE"
        echo "$DISPLAY_NAME已强制停止。"
        stop_robot_if_enabled
        return 0
    fi
    kill "$pid" 2>/dev/null || true

    for _ in $(seq 1 30); do
        if ! kill -0 "$pid" 2>/dev/null; then
            rm -f "$PID_FILE"
            echo "$DISPLAY_NAME已停止。"
            stop_robot_if_enabled
            return 0
        fi
        sleep 1
    done

    echo "正在强制结束$DISPLAY_NAME (PID: $pid)..."
    kill -9 "$pid" 2>/dev/null || true
    rm -f "$PID_FILE"
    stop_robot_if_enabled
}

status() {
    if is_running; then
        echo "$DISPLAY_NAME运行中 (PID: $(read_pid_file))."
    else
        echo "$DISPLAY_NAME未运行。"
    fi
    if [ -f "$ROBOT_DIR/robot.pid" ]; then
        local robot_pid
        robot_pid="$(cat "$ROBOT_DIR/robot.pid" 2>/dev/null || true)"
        if [ -n "$robot_pid" ] && kill -0 "$robot_pid" 2>/dev/null; then
            echo "机器人运行中 (PID: $robot_pid)。"
        else
            echo "机器人未运行（PID 文件已失效）。"
        fi
    else
        echo "机器人未运行。"
    fi
}

case "${1:-start}" in
    start) start ;;
    stop) stop "${2:-}" ;;
    restart) stop; start ;;
    status) status ;;
    *) echo "用法: $0 {start|stop|restart|status}"; exit 1 ;;
esac

#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZONE_DIR_NAME="$(basename "$SCRIPT_DIR")"
if [[ "$ZONE_DIR_NAME" =~ ^server([0-9]+)$ ]]; then
    ZONE_NUMBER="${BASH_REMATCH[1]}"
else
    echo "无法从目录推断大区编号: $SCRIPT_DIR"
    exit 1
fi
GM_PORT="${GM_PORT:-$((ZONE_NUMBER + 41000))}"

run_service() {
    local service="$1"
    local action="$2"
    local arg="${3:-}"
    local script="$SCRIPT_DIR/${service}/start.sh"

    if [ ! -f "$script" ]; then
        echo "缺少启动脚本: $script"
        return 1
    fi

    if [ "$service" = "game_server" ]; then
        if [ -n "$arg" ]; then
            GM_PORT="$GM_PORT" bash "$script" "$action" "$arg"
        else
            GM_PORT="$GM_PORT" bash "$script" "$action"
        fi
    elif [ -n "$arg" ]; then
        bash "$script" "$action" "$arg"
    else
        bash "$script" "$action"
      fi
  }

started_services=()

rollback_started_services() {
    local idx
    if [ "${#started_services[@]}" -eq 0 ]; then
        return 0
    fi
    echo "启动失败，正在回滚已启动服务..."
    for ((idx=${#started_services[@]}-1; idx>=0; idx--)); do
        run_service "${started_services[$idx]}" "stop" "-f" || true
    done
}

start_managed_service() {
    local service="$1"
    if run_service "$service" "start"; then
        started_services+=("$service")
        return 0
    fi
    rollback_started_services
    return 1
}

start_all() {
    started_services=()
    # 启动按网络入口到业务层顺序执行
    start_managed_service "gate_server"
    start_managed_service "proxy_server"
    start_managed_service "game_server"
    echo "大区 ${ZONE_NUMBER} 服务启动完成"
}

stop_all() {
    local force="${1:-}"
    # 停止按业务层到网络入口反向执行，避免链路残留
    run_service "game_server" "stop" "$force"
    run_service "proxy_server" "stop" "$force"
    run_service "gate_server" "stop" "$force"
    echo "大区 ${ZONE_NUMBER} 服务已停止"
}

status_all() {
    run_service "gate_server" "status"
    run_service "proxy_server" "status"
    run_service "game_server" "status"
}

restart_all() {
    local force="${1:-}"
    stop_all "$force"
    start_all
}

usage() {
    echo "用法: $0 {start|stop|restart|status} [force|-f]"
}

case "${1:-start}" in
    start)
        start_all
        ;;
    stop)
        stop_all "${2:-}"
        ;;
    restart)
        restart_all "${2:-}"
        ;;
    status)
        status_all
        ;;
    *)
        usage
        exit 1
        ;;
esac

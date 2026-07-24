#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

start_all() {
    "$SCRIPT_DIR/sdk_server/start.sh" start
    "$SCRIPT_DIR/name_server/start.sh" start
    echo "common services started via managed start.sh wrappers"
}

stop_all() {
    "$SCRIPT_DIR/name_server/start.sh" stop "${1:-}"
    "$SCRIPT_DIR/sdk_server/start.sh" stop "${1:-}"
    echo "common services stopped via managed start.sh wrappers"
}

status_all() {
    "$SCRIPT_DIR/sdk_server/start.sh" status
    "$SCRIPT_DIR/name_server/start.sh" status
}

restart_all() {
    stop_all "${1:-}"
    start_all
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
        echo "Usage: $0 {start|stop|restart|status} [force|-f]"
        exit 1
        ;;
esac

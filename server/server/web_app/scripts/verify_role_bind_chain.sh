#!/usr/bin/env bash
set -euo pipefail

# Quick end-to-end diagnostic for account -> role -> bind chain.
# Example:
#   ./scripts/verify_role_bind_chain.sh "http://114.132.57.3:88" "www123" "123abc" "AA818" "1000000001" "20481" "Role20481"

BASE_URL="${1:-http://127.0.0.1:88}"
ACCOUNT="${2:-diag123a}"
PASSWORD="${3:-diag123a}"
INVITECODE="${4:-AA818}"
SERVER_ID="${5:-1000000001}"
ROLE_ID="${6:-990001}"
ROLE_NAME="${7:-DiagRole}"

echo "== 1) register =="
curl -sS -X POST "${BASE_URL}/api/sdk/user_register" \
  -d "account=${ACCOUNT}&password=${PASSWORD}&invitecode=${INVITECODE}&captcha=123" || true
echo

echo "== 2) login =="
curl -sS -X POST "${BASE_URL}/api/sdk/user_login" \
  -d "account=${ACCOUNT}&password=${PASSWORD}&platform=windows" || true
echo

echo "== 3) bind via /api/game/bind =="
curl -sS -X POST "${BASE_URL}/api/game/bind" \
  -d "account=${ACCOUNT},020000000000&qu=${SERVER_ID}&roleid=${ROLE_ID}&name=${ROLE_NAME}" || true
echo

echo "== 4) legacy callback /enlist/submit_code =="
curl -sS "${BASE_URL}/enlist/submit_code?code=&new_serverid=${SERVER_ID}&new_roleid=${ROLE_ID}" || true
echo

echo "== 5) legacy callback /user/api/index.php/role/set =="
curl -sS "${BASE_URL}/user/api/index.php/role/set?userid=${ACCOUNT}&serverid=${SERVER_ID}&roleid=${ROLE_ID}&name=${ROLE_NAME}" || true
echo

if command -v mysql >/dev/null 2>&1; then
  DB_HOST="${DB_HOST:-127.0.0.1}"
  DB_PORT="${DB_PORT:-3306}"
  DB_NAME="${DB_NAME:-mhxy}"
  DB_USER="${DB_USER:-root}"
  DB_PASS="${DB_PASS:-}"

  echo "== 6) database snapshot =="
  if [[ -z "${DB_PASS}" ]]; then
    echo "skip mysql query: DB_PASS is empty"
    exit 0
  fi

  mysql -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" <<SQL
SET @account = '${ACCOUNT}';
SELECT id, username, bidserver FROM user_account WHERE username = @account;
SELECT roleid, name, userid, createtime, lastlogintime FROM role
WHERE userid = (SELECT id FROM user_account WHERE username = @account LIMIT 1)
ORDER BY roleid DESC;
SELECT id, userid, serverid, playerid, playername FROM user_bind
WHERE userid = (SELECT id FROM user_account WHERE username = @account LIMIT 1)
ORDER BY id DESC;
SELECT id, username, info, date, time FROM user_log
WHERE username = @account
ORDER BY id DESC
LIMIT 20;
SQL
else
  echo "skip mysql query: mysql client not installed"
fi

<?php
declare (strict_types = 1);

namespace app\api\controller;

use app\BaseController;
use app\model\User;
use app\service\BindTicketService;
use app\service\RoleBindService;
use think\Response;
use think\facade\Db;
use think\facade\Log;

/**
 * 旧版角色接口兼容层：
 * - /user/api/index.php/role/set
 * - /user/api/index.php/role/get
 */
class LegacyRole extends BaseController
{
    private function boolFlag($value, bool $default = false): bool
    {
        if (is_bool($value)) {
            return $value;
        }
        if ($value === null) {
            return $default;
        }
        $raw = strtolower(trim((string)$value));
        if ($raw === '') {
            return $default;
        }
        return !in_array($raw, ['0', 'false', 'off', 'no'], true);
    }

    private function bindTicketEnabled(): bool
    {
        return $this->boolFlag(config('security.bind_ticket.enabled', false), false);
    }

    private function bindTicketRequiredOnLegacyRoleSet(): bool
    {
        return $this->boolFlag(config('security.bind_ticket.required_on_legacy_role_set', false), false);
    }

    private function text(string $body): Response
    {
        return Response::create($body, 'html', 200);
    }

    private function parseAccount(): string
    {
        $account = trim((string)$this->request->param('userid', $this->request->param('account', '')));
        if ($account !== '' && strpos($account, ',') !== false) {
            $account = trim((string)explode(',', $account)[0]);
        }
        return strtolower($account);
    }

    public function set()
    {
        $account = $this->parseAccount();
        $bindTicket = trim((string)$this->request->param('bind_ticket', $this->request->param('ticket', $this->request->param('bindTicket', ''))));
        $serverId = intval($this->request->param('serverid', $this->request->param('qu', 0)));
        $roleId = intval($this->request->param('roleid', $this->request->param('new_roleid', $this->request->param('playerid', 0))));
        $roleName = trim((string)$this->request->param('name', $this->request->param('rolename', '')));
        $ticketUserId = 0;
        $enforceOwnerMatch = false;

        if ($serverId <= 0 || $roleId <= 0) {
            Log::warning('旧版role/set参数无效', [
                'userid' => (string)$this->request->param('userid', ''),
                'serverid' => (string)$this->request->param('serverid', ''),
                'roleid' => (string)$this->request->param('roleid', ''),
                'ip' => (string)$this->request->ip(),
            ]);
            return $this->text('0');
        }

        if ($this->bindTicketEnabled()) {
            if ($bindTicket === '' && $this->bindTicketRequiredOnLegacyRoleSet()) {
                Log::warning('旧版role/set缺少bind_ticket', [
                    'serverid' => $serverId,
                    'roleid' => $roleId,
                    'ip' => (string)$this->request->ip(),
                ]);
                return $this->text('0');
            }
            if ($bindTicket !== '') {
                $ticketService = new BindTicketService();
                $ticketResult = $ticketService->consume([
                    'ticket' => $bindTicket,
                    'account' => $account,
                    'server_id' => $serverId,
                    'role_id' => $roleId,
                ]);
                if (empty($ticketResult['ok'])) {
                    Log::warning('旧版role/set验票失败', [
                        'serverid' => $serverId,
                        'roleid' => $roleId,
                        'msg' => (string)($ticketResult['msg'] ?? 'unknown'),
                        'ip' => (string)$this->request->ip(),
                    ]);
                    return $this->text('0');
                }
                $ticketUserId = intval($ticketResult['user_id'] ?? 0);
                $ticketUsername = trim((string)($ticketResult['username'] ?? ''));
                if ($ticketUsername !== '') {
                    $account = $ticketUsername;
                }
                $enforceOwnerMatch = true;
            }
        }

        if ($account === '' && $ticketUserId <= 0) {
            Log::warning('旧版role/set参数无效：账号与票据均缺失', [
                'serverid' => $serverId,
                'roleid' => $roleId,
                'ip' => (string)$this->request->ip(),
            ]);
            return $this->text('0');
        }

        $bindService = new RoleBindService();
        $result = $bindService->bind([
            'account' => $account,
            'user_id' => $ticketUserId,
            'server_id' => $serverId,
            'role_id' => $roleId,
            'role_name' => $roleName,
            'allow_role_fallback_user' => false,
            'enforce_owner_match' => $enforceOwnerMatch,
        ], [
            'source' => 'api.legacy_role.set',
            'ip' => (string)$this->request->ip(),
            'ua' => (string)$this->request->header('user-agent', ''),
            'code' => $bindTicket !== '' ? 'bind_ticket' : '',
        ]);
        if (empty($result['ok'])) {
            Log::warning('旧版role/set绑定失败', [
                'username' => $account,
                'serverid' => $serverId,
                'roleid' => $roleId,
                'msg' => (string)($result['msg'] ?? 'unknown'),
                'ip' => (string)$this->request->ip(),
            ]);
            return $this->text('0');
        }

        Log::info('命中旧版role/set兼容接口', [
            'username' => (string)($result['username'] ?? $account),
            'userid' => intval($result['user_id'] ?? 0),
            'serverid' => intval($result['server_id'] ?? $serverId),
            'roleid' => intval($result['role_id'] ?? $roleId),
            'ip' => (string)$this->request->ip(),
        ]);

        return $this->text('1');
    }

    public function get()
    {
        $account = $this->parseAccount();
        if ($account === '') {
            return $this->text('[]');
        }

        $userModel = new User();
        $userRow = $userModel->getUsername($account);
        if (!$userRow) {
            return $this->text('[]');
        }

        $userId = intval($userRow['id'] ?? 0);
        if ($userId <= 0) {
            return $this->text('[]');
        }

        $rows = Db::name('user_bind')
            ->where('userid', $userId)
            ->field('serverid,playerid AS roleid,playername AS name')
            ->order('id', 'asc')
            ->select()
            ->toArray();

        if (empty($rows)) {
            $rows = Db::name('role')
                ->where('userid', $userId)
                ->where('roleid', '<', 9223372036854775807)
                ->fieldRaw('0 AS serverid, roleid, name')
                ->order('roleid', 'asc')
                ->select()
                ->toArray();
        }

        Log::info('命中旧版role/get兼容接口', [
            'username' => $account,
            'userid' => $userId,
            'count' => count($rows),
            'ip' => (string)$this->request->ip(),
        ]);

        return $this->text(json_encode($rows, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
    }
}

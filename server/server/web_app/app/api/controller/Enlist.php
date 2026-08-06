<?php
declare (strict_types = 1);

namespace app\api\controller;

use app\BaseController;
use app\service\BindTicketService;
use app\service\RoleBindService;
use think\facade\Log;
use think\Response;

/**
 * 兼容旧版 enlist 回调入口（角色绑定回调）
 * 旧客户端仍可能访问 /enlist/submit_code，并只携带 new_serverid/new_roleid。
 */
class Enlist extends BaseController
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

    private function bindTicketRequiredOnEnlistSubmitCode(): bool
    {
        return $this->boolFlag(config('security.bind_ticket.required_on_enlist_submit_code', false), false);
    }

    private function text(string $body): Response
    {
        return Response::create($body, 'html', 200);
    }

    private function parseAccount(): string
    {
        $account = trim((string)$this->request->param('account', $this->request->param('userid', '')));
        if ($account !== '' && strpos($account, ',') !== false) {
            $account = trim((string)explode(',', $account)[0]);
        }
        return strtolower($account);
    }

    /**
     * 兼容旧接口：角色登录后绑定回调。
     * 返回纯文本 1/0，兼容老客户端和 Java 回调方。
     */
    public function submitCode()
    {
        $code = trim((string)$this->request->param('code', ''));
        $bindTicket = trim((string)$this->request->param('bind_ticket', $this->request->param('ticket', $this->request->param('bindTicket', ''))));
        $serverId = intval($this->request->param('new_serverid', $this->request->param('serverid', $this->request->param('qu', 0))));
        $roleId = intval($this->request->param('new_roleid', $this->request->param('roleid', $this->request->param('playerid', 0))));
        $roleName = trim((string)$this->request->param('name', $this->request->param('rolename', '')));
        $account = $this->parseAccount();
        $ticketUserId = 0;
        $enforceOwnerMatch = false;

        if ($serverId <= 0 || $roleId <= 0) {
            Log::warning('旧版enlist回调参数无效', [
                'code' => $code,
                'serverid' => $serverId,
                'roleid' => $roleId,
                'ip' => (string)$this->request->ip(),
            ]);
            return $this->text('0');
        }

        if ($this->bindTicketEnabled()) {
            if ($bindTicket === '' && $this->bindTicketRequiredOnEnlistSubmitCode()) {
                Log::warning('旧版enlist回调缺少bind_ticket', [
                    'serverid' => $serverId,
                    'roleid' => $roleId,
                    'code' => $code,
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
                    Log::warning('旧版enlist回调验票失败', [
                        'serverid' => $serverId,
                        'roleid' => $roleId,
                        'code' => $code,
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
            Log::warning(
                sprintf(
                    '旧版enlist回调缺少账号与票据参数 serverid=%d roleid=%d code=%s ip=%s ua=%s',
                    $serverId,
                    $roleId,
                    $code,
                    (string)$this->request->ip(),
                    (string)$this->request->header('user-agent', '')
                )
            );
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
            'source' => 'api.enlist.submit_code',
            'ip' => (string)$this->request->ip(),
            'ua' => (string)$this->request->header('user-agent', ''),
            'code' => $bindTicket !== '' ? 'bind_ticket:' . $code : $code,
        ]);
        if (empty($result['ok'])) {
            Log::warning(
                sprintf(
                    '旧版enlist回调绑定失败 serverid=%d roleid=%d account=%s code=%s msg=%s ip=%s ua=%s',
                    $serverId,
                    $roleId,
                    $account,
                    $code,
                    (string)($result['msg'] ?? ''),
                    (string)$this->request->ip(),
                    (string)$this->request->header('user-agent', '')
                )
            );
            return $this->text('0');
        }

        Log::info('命中旧版enlist回调并已完成角色绑定兼容', [
            'account' => (string)($result['username'] ?? $account),
            'userid' => intval($result['user_id'] ?? 0),
            'serverid' => intval($result['server_id'] ?? $serverId),
            'roleid' => intval($result['role_id'] ?? $roleId),
            'code' => $code,
            'ip' => (string)$this->request->ip(),
            'ua' => (string)$this->request->header('user-agent', ''),
        ]);

        return $this->text('1');
    }
}

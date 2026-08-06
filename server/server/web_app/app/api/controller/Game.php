<?php
declare(strict_types=1);

namespace app\api\controller;

use app\BaseController;
use app\gm\Gm;
use app\model\Agent as AG;
use app\model\Bind;
use app\model\Fankui as F;
use app\model\Server;
use app\model\User;
use app\model\UserLog as UL;
use app\model\UserOrder as UO;
use app\service\BindTicketService;
use app\service\RoleBindService;
use think\facade\Log;

class Game extends BaseController
{
    private function sdkLegacyRawEnabled(): bool
    {
        $raw = strtolower(trim((string) env('API_SDK_LEGACY_RAW', '0')));
        return !in_array($raw, ['0', 'false', 'off', 'no'], true);
    }

    private function sdkResponse(array $payload)
    {
        if ($this->sdkLegacyRawEnabled()) {
            return json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        }

        return api_json($payload);
    }

    private function sdkFail()
    {
        return $this->sdkResponse(['Code' => '2']);
    }

    private function sdkFailWithReason(string $reason, array $context = [])
    {
        Log::warning('SDK login rejected', array_merge([
            'reason' => $reason,
            'ip' => (string) $this->request->ip(),
            'ua' => (string) $this->request->header('user-agent', ''),
        ], $context));

        return $this->sdkFail();
    }

    private function parseSdkAccount(array $tokenParam): string
    {
        $account = trim((string) ($tokenParam['account'] ?? ''));
        if ($account !== '' && strpos($account, ',') !== false) {
            $account = trim((string) explode(',', $account)[0]);
        }

        return $account;
    }

    private function parseSdkPassword(array $tokenParam): string
    {
        $password = trim((string) ($tokenParam['password'] ?? ''));
        if ($password !== '' && strpos($password, '|') !== false) {
            $parts = explode('|', $password, 2);
            $password = isset($parts[1]) ? trim((string) $parts[1]) : '';
        }

        return $password;
    }

    private function boolFlag($value, bool $default = false): bool
    {
        if (is_bool($value)) {
            return $value;
        }
        if ($value === null) {
            return $default;
        }

        $raw = strtolower(trim((string) $value));
        if ($raw === '') {
            return $default;
        }

        return !in_array($raw, ['0', 'false', 'off', 'no'], true);
    }

    private function bindTicketEnabled(): bool
    {
        return $this->boolFlag(config('security.bind_ticket.enabled', false), false);
    }

    private function bindTicketRequiredOnBind(): bool
    {
        return $this->boolFlag(config('security.bind_ticket.required_on_api_bind', false), false);
    }

    /**
     * 控制 bind 接口的兼容返回格式。
     * - true: 返回 json_encode(0/1)
     * - false: 返回标准 JSON 结构
     */
    private function bindLegacyScalarEnabled(): bool
    {
        $raw = strtolower(trim((string) env('API_BIND_LEGACY_SCALAR', '0')));
        return !in_array($raw, ['0', 'false', 'off', 'no'], true);
    }

    private function bindResponse(int $code, string $msg = '')
    {
        if ($this->bindLegacyScalarEnabled()) {
            return json_encode($code > 0 ? 1 : 0);
        }

        return api_json([
            'code' => $code > 0 ? 1 : 0,
            'msg' => $msg !== '' ? $msg : ($code > 0 ? '绑定成功' : '绑定失败'),
        ]);
    }

    /**
     * 控制返利关闭时的兼容返回格式。
     * - true: 返回纯文本
     * - false: 返回 notify JSON
     */
    private function rebateLegacyTextEnabled(): bool
    {
        $raw = strtolower(trim((string) env('API_REBATE_LEGACY_TEXT', '0')));
        return !in_array($raw, ['0', 'false', 'off', 'no'], true);
    }

    private function rebateClosedResponse()
    {
        if ($this->rebateLegacyTextEnabled()) {
            return '返利功能已关闭';
        }

        return notify(0, '返利功能已关闭');
    }

    private function defaultKefu(): array
    {
        return [
            'qq' => 123456,
            'group' => 'http://baidu.com',
            'info' => '请联系客服',
        ];
    }

    public function sdk()
    {
        $tokenParam = $this->request->param();
        $user = new User();
        $accountExp = $this->parseSdkAccount($tokenParam);
        $passwordExp = $this->parseSdkPassword($tokenParam);
        $serverId = trim((string) ($tokenParam['serverId'] ?? ''));

        if ($accountExp === '' || $passwordExp === '' || $serverId === '') {
            return $this->sdkFailWithReason('missing_params', [
                'account_empty' => $accountExp === '' ? 1 : 0,
                'password_empty' => $passwordExp === '' ? 1 : 0,
                'server_id' => $serverId,
            ]);
        }

        $userData = $user->getUsername($accountExp);
        if (!$userData) {
            return $this->sdkFailWithReason('account_not_found', [
                'account' => $accountExp,
                'server_id' => $serverId,
            ]);
        }

        $getBidServer = $user->getBidServer($userData['id'], $serverId);
        if ($getBidServer) {
            Log::warning('SDK login hit existing bound server but was allowed', [
                'account' => $accountExp,
                'user_id' => intval($userData['id'] ?? 0),
                'server_id' => $serverId,
            ]);
        }

        if ($serverId === '1000000999') {
            if (intval($userData['zhiboqu'] ?? 0) !== 1) {
                return $this->sdkFailWithReason('zhiboqu_permission_denied', [
                    'account' => $accountExp,
                    'user_id' => intval($userData['id'] ?? 0),
                    'server_id' => $serverId,
                ]);
            }
        }

        if (password($passwordExp, $userData['password']) == false) {
            return $this->sdkFailWithReason('password_mismatch', [
                'account' => $accountExp,
                'user_id' => intval($userData['id'] ?? 0),
                'server_id' => $serverId,
            ]);
        }

        if ($userData['status'] != 1) {
            return $this->sdkFailWithReason('account_status_invalid', [
                'account' => $accountExp,
                'user_id' => intval($userData['id'] ?? 0),
                'status' => intval($userData['status'] ?? -1),
                'server_id' => $serverId,
            ]);
        }

        $userLog = new UL();
        $info = '登录游戏';
        $userLog->addUserLog($accountExp, $info, $this->genericVariable);

        $sessionSecret = (string) config('player.op_secret_salt', '');
        if ($sessionSecret === '') {
            Log::error('SDK login rejected: OP_SECRET_SALT not configured', [
                'account' => $accountExp,
                'user_id' => intval($userData['id'] ?? 0),
                'server_id' => $serverId,
            ]);

            return $this->sdkFailWithReason('security_config_missing', [
                'reason' => 'missing_op_secret_salt',
                'server_id' => $serverId,
            ]);
        }

        $safeSession = hash_hmac('sha256', $accountExp . '|' . $serverId . '|' . $this->genericVariable['time'], $sessionSecret);
        $bindTicket = '';
        $bindTicketExpire = 0;

        if ($this->bindTicketEnabled()) {
            if (!class_exists(BindTicketService::class)) {
                Log::error('SDK bind_ticket issue failed: service missing', [
                    'account' => $accountExp,
                    'userid' => intval($userData['id'] ?? 0),
                    'serverid' => intval($serverId),
                ]);
            } else {
                try {
                    $ticketService = new BindTicketService();
                    $ticketResult = $ticketService->issue([
                        'user_id' => intval($userData['id'] ?? 0),
                        'username' => $accountExp,
                        'server_id' => intval($serverId),
                        'request_ip' => (string) $this->request->ip(),
                        'request_ua' => (string) $this->request->header('user-agent', ''),
                    ]);

                    if (!empty($ticketResult['ok'])) {
                        $bindTicket = (string) ($ticketResult['ticket'] ?? '');
                        $bindTicketExpire = intval($ticketResult['expires_at'] ?? 0);
                    } else {
                        Log::warning('SDK bind_ticket issue failed', [
                            'account' => $accountExp,
                            'userid' => intval($userData['id'] ?? 0),
                            'serverid' => intval($serverId),
                            'msg' => (string) ($ticketResult['msg'] ?? 'unknown'),
                        ]);
                    }
                } catch (\Throwable $e) {
                    Log::error('SDK bind_ticket issue exception', [
                        'account' => $accountExp,
                        'userid' => intval($userData['id'] ?? 0),
                        'serverid' => intval($serverId),
                        'error' => $e->getMessage(),
                    ]);
                }
            }
        }

        return $this->sdkResponse([
            'Code' => '1',
            'Channel' => '1',
            'PlatformId' => '1',
            'Account' => $accountExp,
            'Message' => '登录成功!',
            'Session' => $safeSession,
            'BindTicket' => $bindTicket,
            'BindTicketExpire' => $bindTicketExpire,
        ]);
    }

    public function bind()
    {
        $InviteParam = $this->request->post();
        $bindTicket = trim((string) ($InviteParam['bind_ticket'] ?? $InviteParam['ticket'] ?? $InviteParam['bindTicket'] ?? ''));
        $accountExp = trim((string) ($InviteParam['account'] ?? ''));

        if (strpos($accountExp, ',') !== false) {
            $accountExp = trim((string) explode(',', $accountExp)[0]);
        }

        $ticketUserId = 0;
        $ticketUsername = '';
        $enforceOwnerMatch = false;

        if ($this->bindTicketEnabled()) {
            if ($bindTicket === '' && $this->bindTicketRequiredOnBind()) {
                return $this->bindResponse(0, '缺少 bind_ticket 参数');
            }

            if ($bindTicket !== '') {
                $ticketService = new BindTicketService();
                $ticketResult = $ticketService->consume([
                    'ticket' => $bindTicket,
                    'account' => $accountExp,
                    'server_id' => intval($InviteParam['qu'] ?? 0),
                    'role_id' => intval($InviteParam['roleid'] ?? 0),
                ]);

                if (empty($ticketResult['ok'])) {
                    return $this->bindResponse(0, '绑定票据校验失败：' . (string) ($ticketResult['msg'] ?? 'unknown'));
                }

                $ticketUserId = intval($ticketResult['user_id'] ?? 0);
                $ticketUsername = trim((string) ($ticketResult['username'] ?? ''));
                if ($ticketUsername !== '') {
                    $accountExp = $ticketUsername;
                }
                $enforceOwnerMatch = true;
            }
        }

        if ($accountExp === '' && $ticketUserId <= 0) {
            return $this->bindResponse(0, '缺少 account 或 bind_ticket 参数');
        }

        $bindService = new RoleBindService();
        $result = $bindService->bind([
            'account' => $accountExp,
            'user_id' => $ticketUserId,
            'server_id' => intval($InviteParam['qu'] ?? 0),
            'role_id' => intval($InviteParam['roleid'] ?? 0),
            'role_name' => (string) ($InviteParam['name'] ?? ''),
            'allow_role_fallback_user' => true,
            'enforce_owner_match' => $enforceOwnerMatch,
        ], [
            'source' => 'api.game.bind',
            'ip' => (string) $this->request->ip(),
            'ua' => (string) $this->request->header('user-agent', ''),
            'code' => $bindTicket !== '' ? 'bind_ticket' : '',
        ]);

        if (empty($result['ok'])) {
            return $this->bindResponse(0, (string) ($result['msg'] ?? '绑定失败'));
        }

        $userLog = new UL();
        $infoType = (($result['bind_action'] ?? '') === 'created') ? '绑定新角色' : '刷新角色绑定';
        $info = $infoType . '：' . json_encode([
            'userid' => intval($result['user_id'] ?? 0),
            'serverid' => intval($result['server_id'] ?? 0),
            'playerid' => intval($result['role_id'] ?? 0),
            'playername' => (string) ($result['role_name'] ?? ''),
        ], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
        $userLog->addUserLog((string) ($result['username'] ?? $accountExp), $info, $this->genericVariable);

        return $this->bindResponse(1, '绑定成功');
    }

    public function kefu()
    {
        $username = $this->request->param('username', null);
        if ($username != null) {
            $user = new User();
            $userData = $user->getUsername($username);
            if ($userData) {
                $AG = new AG();
                $getById = $AG->getById($userData['lastagent']);
                $kefuRaw = (string) ($getById['kefu'] ?? '');
                if (isJson($kefuRaw)) {
                    $kefu = json_decode($kefuRaw, true);
                    if (!is_array($kefu) || empty($kefu)) {
                        $kefu = $this->defaultKefu();
                    }
                } else {
                    $kefu = $this->defaultKefu();
                }
            } else {
                $kefu = $this->defaultKefu();
            }
        } else {
            $kefu = $this->defaultKefu();
        }

        return view('kefu', ['kefu' => $kefu, 'username' => $username]);
    }

    public function zhuanqu()
    {
        $username = $this->request->param('username', null);
        if ($username == null) {
            return notify(0, '缺少账号参数');
        }

        $referer = $this->request->header('referer', '');
        if (empty($referer) || strpos($referer, $this->request->host()) === false) {
            // Keep compatibility with historical flow and do not block here.
        }

        $user = new User();
        $getUser = $user->getUsername($username);
        if (!$getUser) {
            return notify(0, '账号不存在');
        }

        $bind = new Bind();
        $server = new Server();
        $userOrder = new UO();
        $getAllBindListUID = $bind->getAllBindListUID($getUser['id']);
        foreach ($getAllBindListUID as $key => $val) {
            $val['servername'] = $server->getServerId($val['serverid'])['name'];
            // $val['chargemoney'] = $userOrder->getServerRoleMoney($val['playerid']);
            $val['chargemoney'] = $val['charge'];
            $getAllBindListUID[$key] = $val;
        }

        return view('zhuanqu', ['username' => $username, 'getAllBindListUID' => $getAllBindListUID]);
    }

    public function zhuanquSub()
    {
        $zhuanqu = $this->request->post();
        if (isset($zhuanqu['oldrole'])) {
            $oldrole = $zhuanqu['oldrole'];
        } else {
            return notify(0, '缺少 oldrole 参数');
        }

        if (isset($zhuanqu['newrole'])) {
            $newrole = $zhuanqu['newrole'];
        } else {
            return notify(0, '缺少 newrole 参数');
        }

        $bind = new Bind();
        $user = new User();
        $server = new Server();
        $userOrder = new UO();

        $newroleData = $bind->getPlayerById($newrole);
        if (!$newroleData) {
            return notify(0, '新区角色不存在');
        }

        $oldroleData = $bind->getPlayerById($oldrole);
        if (!$oldroleData) {
            return notify(0, '旧区角色不存在');
        }

        if ($newroleData['userid'] != $oldroleData['userid']) {
            return notify(0, '角色不属于同一账号，无法转区');
        }

        $getBidServer = $user->getBidServer($oldroleData['userid'], $oldroleData['serverid']);
        if ($newrole == $oldrole) {
            return notify(0, '新区角色不能与旧区角色相同');
        }

        if ($newroleData['zhuanqu'] == 1) {
            return notify(0, '新区角色已领取过转区福利，无法使用');
        }

        if ($getBidServer) {
            return notify(0, '该账号在对应区服已存在绑定记录，无法转区');
        }

        $getBidServer = $user->getBidServer($newroleData['userid'], $newroleData['serverid']);
        if ($getBidServer) {
            return notify(0, '该账号在对应区服已存在绑定记录，无法转区');
        }

        if ($oldroleData['charge'] < 1000) {
            return notify(0, '旧区角色累计充值不足 1000，无法领取转区福利');
        }

        if ($newroleData['charge'] < $oldroleData['charge'] * 0.5) {
            return notify(0, '新区角色累计充值需达到旧区角色的一半以上');
        }

        \think\facade\Db::startTrans();
        try {
            $gm = new Gm();
            $serverDataOld = $server->getServerId($oldroleData['serverid']);
            $data1 = [
                'serverip' => $serverDataOld['serverip'],
                'gmlocal' => $serverDataOld['gmlocal'],
                'gmport' => $serverDataOld['gmport'],
                'playerid' => $oldroleData['playerid'],
            ];
            $gameNotify1 = $gm->kick($data1);

            $serverData = $server->getServerId($newroleData['serverid']);
            $xianyu = $oldroleData['charge'] * 600;
            $data = [
                'serverip' => $serverData['serverip'],
                'gmlocal' => $serverData['gmlocal'],
                'gmport' => $serverData['gmport'],
                'playerid' => $newroleData['playerid'],
                'number' => $xianyu,
            ];

            $gameNotifyXianyu = $gm->addqian($data);
            $vip = $oldroleData['charge'] * 3;
            $data['number'] = $vip;
            $gameNotifyVip = $gm->addvipexp($data);

            if (isset($gameNotifyXianyu[0]) && isset($gameNotifyVip[0])) {
                if (strpos($gameNotifyXianyu[0], 'success') !== false && strpos($gameNotifyVip[0], 'success') !== false) {
                    $upBidServer = $user->upBidServer($oldroleData['userid'], $oldroleData['serverid']);
                    $upBindZhuanqu = $bind->upBindZhuanqu($oldrole);
                    \think\facade\Db::commit();
                    return notify(1, '转区成功');
                }

                \think\facade\Db::rollback();
                return notify(0, '转区失败：GM 执行失败');
            }

            \think\facade\Db::rollback();
            return notify(0, '转区失败：GM 返回异常');
        } catch (\Exception $e) {
            \think\facade\Db::rollback();
            return notify(0, '转区失败：' . $e->getMessage());
        }
    }

    public function rebate()
    {
        return $this->rebateClosedResponse();
    }

    public function fankui()
    {
        $username = $this->request->param('username', null);
        if ($username == null) {
            return notify(0, '缺少账号参数');
        }

        $user = new User();
        $getUser = $user->getUsername($username);
        if (!$getUser) {
            return notify(0, '账号不存在');
        }

        $bind = new Bind();
        $server = new Server();
        $userOrder = new UO();
        $getAllBindListUID = $bind->getAllBindListUID($getUser['id']);
        foreach ($getAllBindListUID as $key => $val) {
            $val['servername'] = $server->getServerId($val['serverid'])['name'];
            // $val['chargemoney'] = $userOrder->getServerRoleMoney($val['playerid']);
            $val['chargemoney'] = $val['charge'];
            $getAllBindListUID[$key] = $val;
        }

        return view('fankui', ['username' => $username, 'getAllBindListUID' => $getAllBindListUID]);
    }

    public function fankuiSub()
    {
        $role = $this->request->post('role', null);
        $info = $this->request->post('info', null);

        if ($role == null) {
            return notify(0, '请选择接收答复的角色');
        }

        if ($info == null) {
            return notify(0, '请输入反馈内容');
        }

        $fankui = new F();
        $getFankuiRole = $fankui->getFankuiRole($role);
        if (isset($getFankuiRole[0]['status'])) {
            if ($getFankuiRole[0]['status'] != 1 && strtotime($getFankuiRole[0]['time']) + 86400 > time()) {
                return notify(0, '您已提交过反馈，请在 24 小时后再次提交。');
            }
        }

        $uid = 0;
        $username = '';
        $bind = new Bind();
        $getPlayerById = $bind->getPlayerById($role);
        if ($getPlayerById) {
            $uid = intval($getPlayerById['userid'] ?? 0);
            if ($uid > 0) {
                $user = new User();
                $getUserById = $user->getById($uid);
                if ($getUserById) {
                    $username = (string) ($getUserById['username'] ?? '');
                }
            }
        }

        $now = $this->genericVariable['date'] ?? date('Y-m-d H:i:s');
        $data = [
            'uid' => $uid,
            'username' => $username,
            'role' => $role,
            'info' => $info,
            'time' => $now,
            'created_at' => $now,
            'updated_at' => $now,
        ];
        $insFankui = $fankui->insFankui($data);

        return notify(1, '反馈已提交，请耐心等待客服回复');
    }
}

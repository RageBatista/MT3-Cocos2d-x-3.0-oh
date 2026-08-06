<?php
declare (strict_types = 1);

namespace app\service;

use app\model\User;
use think\facade\Db;
use think\facade\Log;

/**
 * 统一处理“账号-角色绑定”写入逻辑，避免多入口实现漂移。
 *
 * 适用入口：
 * - /api/game/bind
 * - /user/api/index.php/role/set
 * - /enlist/submit_code（无账号时允许按角色回查）
 */
class RoleBindService
{
    private function acquireRoleBindLock(int $roleId): array
    {
        $lockKey = 'role_bind_lock:' . $roleId;
        $token = CacheLockService::acquire($lockKey, 8, 'redis');
        if ($token !== null) {
            return ['key' => $lockKey, 'token' => $token, 'store' => 'redis'];
        }
        // Redis 不可用时降级到 file 锁，避免绑定链路完全不可用
        $token = CacheLockService::acquire($lockKey, 8, 'file');
        if ($token !== null) {
            return ['key' => $lockKey, 'token' => $token, 'store' => 'file'];
        }
        return ['key' => $lockKey, 'token' => null, 'store' => 'none'];
    }

    private function releaseRoleBindLock(array $lock): void
    {
        $key = (string)($lock['key'] ?? '');
        $token = (string)($lock['token'] ?? '');
        $store = (string)($lock['store'] ?? '');
        if ($key === '' || $token === '' || $store === '' || $store === 'none') {
            return;
        }
        CacheLockService::release($key, $token, $store);
    }

    private function failResult(string $msg, array $extra = []): array
    {
        return array_merge([
            'ok' => false,
            'msg' => $msg,
        ], $extra);
    }

    private function successResult(
        int $userId,
        string $username,
        int $serverId,
        int $roleId,
        string $roleName,
        string $bindAction,
        bool $roleExists,
        bool $roleSynced,
        bool $roleConflict
    ): array {
        return [
            'ok' => true,
            'msg' => '绑定成功',
            'user_id' => $userId,
            'username' => $username,
            'server_id' => $serverId,
            'role_id' => $roleId,
            'role_name' => $roleName,
            'bind_action' => $bindAction,
            'role_exists' => $roleExists,
            'role_synced' => $roleSynced,
            'role_conflict' => $roleConflict,
        ];
    }

    private function cleanupDuplicateBindingsByRole(int $roleId): int
    {
        if ($roleId <= 0) {
            return 0;
        }
        $rows = Db::name('user_bind')
            ->where('playerid', $roleId)
            ->order('id', 'asc')
            ->field('id')
            ->select()
            ->toArray();
        if (count($rows) <= 1) {
            return 0;
        }
        $keepId = intval($rows[0]['id'] ?? 0);
        if ($keepId <= 0) {
            return 0;
        }
        $deleteIds = [];
        foreach ($rows as $row) {
            $id = intval($row['id'] ?? 0);
            if ($id > 0 && $id !== $keepId) {
                $deleteIds[] = $id;
            }
        }
        if (empty($deleteIds)) {
            return 0;
        }
        return intval(Db::name('user_bind')->whereIn('id', $deleteIds)->delete());
    }

    private function normalizeAccount(string $account): string
    {
        $account = trim($account);
        if ($account !== '' && strpos($account, ',') !== false) {
            $account = trim((string)explode(',', $account)[0]);
        }
        return strtolower($account);
    }

    /**
     * 判断是否为唯一键冲突（MySQL 1062 / SQLSTATE 23000）。
     */
    private function isDuplicateKeyException(\Throwable $e): bool
    {
        $code = (string)$e->getCode();
        $message = strtolower($e->getMessage());
        if ($code === '1062' || $code === '23000') {
            return true;
        }
        return strpos($message, 'duplicate') !== false
            || strpos($message, 'duplicate entry') !== false
            || strpos($message, '1062') !== false;
    }

    /**
     * 兼容角色时间戳为秒或毫秒两种格式，统一转换为秒。
     */
    private function normalizeUnixTimeSec($raw): int
    {
        $value = intval($raw);
        if ($value <= 0) {
            return 0;
        }

        // 10 位通常是秒；11 位及以上按毫秒处理，避免秒制被错误缩小
        if ($value > 9999999999) {
            $value = intval(floor($value / 1000));
        }

        return $value > 0 ? $value : 0;
    }

    /**
     * 通过 role 表和 user_log 回查账号（用于老回调缺失 account 的场景）。
     */
    private function resolveUserByRole(int $roleId): ?array
    {
        if ($roleId <= 0) {
            return null;
        }

        $roleRow = Db::name('role')
            ->where('roleid', $roleId)
            ->field('roleid,userid,lastlogintime')
            ->find();
        if (!$roleRow) {
            return null;
        }

        $roleUserId = intval($roleRow['userid'] ?? 0);
        if ($roleUserId > 0) {
            $userRow = Db::name('user_account')
                ->where('id', $roleUserId)
                ->field('id,username')
                ->find();
            if ($userRow) {
                return $userRow;
            }
        }

        $lastLoginTimeRaw = intval($roleRow['lastlogintime'] ?? 0);
        $loginTimeSec = $this->normalizeUnixTimeSec($lastLoginTimeRaw);
        if ($loginTimeSec <= 0) {
            return null;
        }

        $windowStart = max(0, $loginTimeSec - 600);
        $windowEnd = $loginTimeSec + 600;
        foreach (['登陆游戏%', '登录游戏客户端%'] as $pattern) {
            try {
                $row = Db::name('user_log')->alias('l')
                    ->join('user_account u', 'u.username = l.username')
                    ->whereRaw('CAST(l.time AS UNSIGNED) >= ? AND CAST(l.time AS UNSIGNED) <= ?', [$windowStart, $windowEnd])
                    ->whereLike('l.info', $pattern)
                    ->orderRaw('ABS(CAST(l.time AS SIGNED) - ' . $loginTimeSec . ') ASC')
                    ->field('u.id,u.username')
                    ->find();
                if ($row) {
                    return $row;
                }
            } catch (\Throwable $e) {
                Log::warning('RoleBindService回查账号失败', [
                    'roleid' => $roleId,
                    'pattern' => $pattern,
                    'error' => $e->getMessage(),
                ]);
                break;
            }
        }

        return null;
    }

    /**
     * 老回调缺少 account 且 role 记录尚未落库时的保守兜底：
     * 仅当最近窗口内可唯一确定一个登录账号时才回填，避免错绑。
     */
    private function resolveRecentUniqueLoginUser(int $seconds = 180): ?array
    {
        $window = max(30, min(900, intval($seconds)));
        $now = time();

        $rows = Db::name('user_log')
            ->whereRaw('CAST(time AS UNSIGNED) >= ?', [$now - $window])
            ->where(function ($query) {
                $query->whereLike('info', '登陆游戏%')
                    ->whereOr('info', 'like', '登录游戏客户端%')
                    ->whereOr('info', 'like', '登录游戏%');
            })
            ->field('username')
            ->order('id', 'desc')
            ->limit(20)
            ->select()
            ->toArray();
        if (empty($rows)) {
            return null;
        }

        $usernames = [];
        foreach ($rows as $row) {
            $username = $this->normalizeAccount((string)($row['username'] ?? ''));
            if ($username !== '') {
                $usernames[$username] = $username;
            }
        }

        if (count($usernames) !== 1) {
            return null;
        }

        $username = array_values($usernames)[0];
        if ($username === '') {
            return null;
        }

        return Db::name('user_account')
            ->where('username', $username)
            ->field('id,username')
            ->find();
    }

    /**
     * 二次兜底：使用 player_event_log 中 login 类成功记录回查账号。
     * 优先唯一账号；若存在多账号，仅在“最近一条明显领先”时使用最近登录账号。
     */
    private function resolveRecentLoginUserByPlayerLog(int $seconds = 180): ?array
    {
        $window = max(30, min(900, intval($seconds)));
        $startTime = date('Y-m-d H:i:s', time() - $window);

        $rows = Db::name('player_event_log')
            ->where('category', 'login')
            ->where('success', 1)
            ->where('created_at', '>=', $startTime)
            ->whereNotNull('username')
            ->where('username', '<>', '')
            ->field('id,uid AS user_id,username,created_at')
            ->order('id', 'desc')
            ->limit(30)
            ->select()
            ->toArray();
        if (empty($rows)) {
            return null;
        }

        $distinct = [];
        foreach ($rows as $row) {
            $name = $this->normalizeAccount((string)($row['username'] ?? ''));
            if ($name !== '') {
                $distinct[$name] = $name;
            }
        }

        if (count($distinct) === 1) {
            $name = array_values($distinct)[0];
            return Db::name('user_account')
                ->where('username', $name)
                ->field('id,username')
                ->find();
        }

        $latest = $rows[0] ?? null;
        if (!$latest) {
            return null;
        }
        $latestName = $this->normalizeAccount((string)($latest['username'] ?? ''));
        $latestId = intval($latest['user_id'] ?? 0);
        if ($latestName === '' || $latestId <= 0) {
            return null;
        }

        // 当最近两条记录间隔至少 30 秒时，认为不是高并发混登，可安全采用最近登录账号
        $second = $rows[1] ?? null;
        if ($second) {
            $t1 = strtotime((string)($latest['created_at'] ?? ''));
            $t2 = strtotime((string)($second['created_at'] ?? ''));
            if ($t1 > 0 && $t2 > 0 && ($t1 - $t2) < 30) {
                return null;
            }
        }

        return Db::name('user_account')
            ->where('id', $latestId)
            ->where('username', $latestName)
            ->field('id,username')
            ->find();
    }

    private function resolveUserRow(
        int $roleId,
        int $userId,
        string $account,
        bool $allowFallbackUser
    ): ?array {
        $userModel = new User();
        $userRow = null;
        if ($userId > 0) {
            $userRow = Db::name('user_account')->where('id', $userId)->field('id,username')->find();
        }
        if (!$userRow && $account !== '') {
            $modelResult = $userModel->getUsername($account);
            $userRow = is_array($modelResult) ? $modelResult : ($modelResult ? $modelResult->toArray() : null);
        }
        if (!$userRow && $allowFallbackUser) {
            $userRow = $this->resolveUserByRole($roleId);
            if (!$userRow) {
                $userRow = $this->resolveRecentUniqueLoginUser(180);
            }
            if (!$userRow) {
                $userRow = $this->resolveRecentLoginUserByPlayerLog(180);
            }
        }
        return $userRow;
    }

    private function buildBindInsertData(int $userId, int $serverId, int $roleId, string $roleName): array
    {
        return [
            'userid' => $userId,
            'serverid' => $serverId,
            'playerid' => $roleId,
            'playername' => $roleName !== '' ? $roleName : ('角色' . $roleId),
            'charge' => '0.00',
            'fb_sc' => 0,
            'zhuanqu' => 0,
            'lq_daycharge' => null,
            'lq_rolecharge' => null,
            'daycharge' => '0.00',
            'chargedate' => '0'
        ];
    }

    private function performBindTransaction(
        int $userId,
        int $serverId,
        int $roleId,
        string &$roleName,
        bool $enforceOwnerMatch,
        array &$state
    ): void {
        Db::transaction(function () use ($userId, $serverId, $roleId, &$roleName, $enforceOwnerMatch, &$state) {
            $userModel = new User();
            try {
                $userModel->upBidServer($userId, $serverId);
            } catch (\Throwable $e) {
                Log::warning('RoleBindService写入bidserver失败', [
                    'userid' => $userId,
                    'serverid' => $serverId,
                    'error' => $e->getMessage(),
                ]);
            }

            $roleRow = Db::name('role')
                ->where('roleid', $roleId)
                ->field('roleid,userid,name')
                ->find();
            if ($roleRow) {
                $state['role_exists'] = true;
                if ($roleName === '') {
                    $roleName = trim((string)($roleRow['name'] ?? ''));
                }
                $roleUserId = intval($roleRow['userid'] ?? 0);
                $roleUserExists = $roleUserId > 0
                    ? Db::name('user_account')->where('id', $roleUserId)->value('id')
                    : null;
                if ($roleUserId <= 0 || !$roleUserExists) {
                    Db::name('role')->where('roleid', $roleId)->update(['userid' => $userId]);
                    $state['role_synced'] = true;
                } elseif ($roleUserId !== $userId) {
                    $state['role_conflict'] = true;
                    if ($enforceOwnerMatch) {
                        throw new \RuntimeException('角色归属账号冲突，拒绝覆盖绑定');
                    }
                }
                if ($roleName !== '' && trim((string)($roleRow['name'] ?? '')) === '') {
                    Db::name('role')->where('roleid', $roleId)->update(['name' => $roleName]);
                    $state['role_synced'] = true;
                }
            }

            $bindRow = Db::name('user_bind')
                ->where('playerid', $roleId)
                ->field('id,userid,serverid,playername')
                ->find();
            if ($bindRow) {
                $bindUserId = intval($bindRow['userid'] ?? 0);
                if ($enforceOwnerMatch && $bindUserId > 0 && $bindUserId !== $userId) {
                    $state['role_conflict'] = true;
                    throw new \RuntimeException('角色已绑定其他账号，拒绝覆盖');
                }
                $update = [];
                if ($bindUserId !== $userId) {
                    $update['userid'] = $userId;
                }
                if (intval($bindRow['serverid'] ?? 0) !== $serverId) {
                    $update['serverid'] = $serverId;
                }
                if ($roleName !== '' && trim((string)($bindRow['playername'] ?? '')) !== $roleName) {
                    $update['playername'] = $roleName;
                }
                if (!empty($update)) {
                    Db::name('user_bind')->where('id', intval($bindRow['id']))->update($update);
                    Db::name('role')->where('roleid', $roleId)->update(['userid' => $userId]);
                    $state['bind_action'] = 'updated';
                }
                return;
            }

            $insertData = $this->buildBindInsertData($userId, $serverId, $roleId, $roleName);
            try {
                Db::name('user_bind')->insert($insertData);
                $state['bind_action'] = 'created';
            } catch (\Throwable $e) {
                if (!$this->isDuplicateKeyException($e)) {
                    throw $e;
                }
                if ($enforceOwnerMatch) {
                    $current = Db::name('user_bind')
                        ->where('playerid', $roleId)
                        ->field('userid')
                        ->find();
                    $currentUserId = intval($current['userid'] ?? 0);
                    if ($currentUserId > 0 && $currentUserId !== $userId) {
                        $state['role_conflict'] = true;
                        throw new \RuntimeException('角色已绑定其他账号，拒绝覆盖');
                    }
                }
                Db::name('user_bind')
                    ->where('playerid', $roleId)
                    ->update([
                        'userid' => $userId,
                        'serverid' => $serverId,
                        'playername' => $insertData['playername'],
                    ]);
                Db::name('role')->where('roleid', $roleId)->update(['userid' => $userId]);
                $state['bind_action'] = 'updated';
                Log::warning('RoleBindService命中重复插入冲突，已自动转为更新', [
                    'roleid' => $roleId,
                    'userid' => $userId,
                    'serverid' => $serverId,
                    'error' => $e->getMessage(),
                ]);
            }
        });
    }

    private function logBindCompleted(
        array $context,
        string $username,
        int $userId,
        int $serverId,
        int $roleId,
        array $state
    ): void {
        $source = (string)($context['source'] ?? 'unknown');
        $ip = (string)($context['ip'] ?? '');
        $ua = (string)($context['ua'] ?? '');
        $code = (string)($context['code'] ?? '');

        if (!empty($state['role_conflict'])) {
            Log::warning('RoleBindService检测到角色归属冲突，已将role.userid同步为当前绑定账号', [
                'source' => $source,
                'roleid' => $roleId,
                'bind_userid' => $userId,
                'ip' => $ip,
            ]);
        }

        Log::info('RoleBindService绑定完成', [
            'source' => $source,
            'username' => $username,
            'userid' => $userId,
            'serverid' => $serverId,
            'roleid' => $roleId,
            'role_exists' => !empty($state['role_exists']) ? 1 : 0,
            'role_synced' => !empty($state['role_synced']) ? 1 : 0,
            'bind_action' => (string)($state['bind_action'] ?? 'unchanged'),
            'ip' => $ip,
            'ua' => $ua,
            'code' => $code,
        ]);
    }

    /**
     * 统一绑定入口。
     *
     * payload:
     * - account: string (可选)
     * - user_id: int (可选)
     * - server_id: int (必填)
     * - role_id: int (必填)
     * - role_name: string (可选)
     * - allow_role_fallback_user: bool (可选，默认 false)
     */
    public function bind(array $payload, array $context = []): array
    {
        $source = (string)($context['source'] ?? 'unknown');
        $ip = (string)($context['ip'] ?? '');
        $code = (string)($context['code'] ?? '');

        $serverId = intval($payload['server_id'] ?? 0);
        $roleId = intval($payload['role_id'] ?? 0);
        $roleName = trim((string)($payload['role_name'] ?? ''));
        $account = $this->normalizeAccount((string)($payload['account'] ?? ''));
        $userId = intval($payload['user_id'] ?? 0);
        $allowFallbackUser = !empty($payload['allow_role_fallback_user']);
        $enforceOwnerMatch = !empty($payload['enforce_owner_match']);

        if ($serverId <= 0 || $roleId <= 0) {
            return $this->failResult('参数异常：server_id/role_id 必填');
        }

        $lock = $this->acquireRoleBindLock($roleId);
        if (($lock['token'] ?? null) === null) {
            Log::warning('RoleBindService绑定锁获取失败，拒绝并发写入', [
                'source' => $source,
                'roleid' => $roleId,
                'serverid' => $serverId,
                'ip' => $ip,
                'lock_store' => (string)($lock['store'] ?? 'none'),
            ]);
            return $this->failResult('绑定处理中，请稍后重试');
        }

        try {
            $userRow = $this->resolveUserRow($roleId, $userId, $account, $allowFallbackUser);
            if (!$userRow) {
                Log::warning(sprintf(
                    'RoleBindService绑定失败：未解析到账号 source=%s serverid=%d roleid=%d account=%s ip=%s code=%s',
                    $source,
                    $serverId,
                    $roleId,
                    $account,
                    $ip,
                    $code
                ));
                Log::warning('RoleBindService绑定失败上下文', [
                    'source' => $source,
                    'serverid' => $serverId,
                    'roleid' => $roleId,
                    'account' => $account,
                    'ip' => $ip,
                    'allow_fallback_user' => $allowFallbackUser ? 1 : 0,
                ]);
                return $this->failResult('账号不存在或未同步');
            }

            $userId = intval($userRow['id'] ?? 0);
            $username = $this->normalizeAccount((string)($userRow['username'] ?? ''));
            if ($userId <= 0 || $username === '') {
                return $this->failResult('账号数据异常');
            }

            $state = [
                'bind_action' => 'unchanged',
                'role_conflict' => false,
                'role_exists' => false,
                'role_synced' => false,
            ];

            try {
                $this->performBindTransaction($userId, $serverId, $roleId, $roleName, $enforceOwnerMatch, $state);
            } catch (\RuntimeException $e) {
                Log::warning('RoleBindService绑定拒绝：检测到归属冲突', [
                    'source' => $source,
                    'userid' => $userId,
                    'serverid' => $serverId,
                    'roleid' => $roleId,
                    'ip' => $ip,
                    'error' => $e->getMessage(),
                ]);
                return $this->failResult($e->getMessage(), ['role_conflict' => true]);
            } catch (\Throwable $e) {
                Log::error('RoleBindService绑定异常', [
                    'source' => $source,
                    'userid' => $userId,
                    'serverid' => $serverId,
                    'roleid' => $roleId,
                    'ip' => $ip,
                    'error' => $e->getMessage(),
                ]);
                return $this->failResult('绑定失败，请稍后重试');
            }

            $deleted = $this->cleanupDuplicateBindingsByRole($roleId);
            if ($deleted > 0) {
                Log::warning('RoleBindService已清理重复绑定记录', [
                    'roleid' => $roleId,
                    'deleted_rows' => $deleted,
                ]);
            }

            $this->logBindCompleted($context, $username, $userId, $serverId, $roleId, $state);

            return $this->successResult(
                $userId,
                $username,
                $serverId,
                $roleId,
                $roleName,
                (string)$state['bind_action'],
                (bool)$state['role_exists'],
                (bool)$state['role_synced'],
                (bool)$state['role_conflict']
            );
        } finally {
            $this->releaseRoleBindLock($lock);
        }
    }
}

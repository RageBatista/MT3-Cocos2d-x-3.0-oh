<?php
namespace app\player\model;

use think\Model;

/**
 * PlayerLoginLog 模型
 * 向后兼容 player_login_log 历史调用，当前实际写入 player_event_log
 */
class PlayerLoginLog extends Model
{
    protected $table = 'player_event_log';

    private const CATEGORY = 'login';
    private const EVENT_SUCCESS = 'login_success';
    private const EVENT_FAILED = 'login_failed';

    public function addLoginLog($userId, $username, $ip, $platform = 'web')
    {
        $uid = intval($userId);
        if ($uid <= 0) {
            return false;
        }

        return $this->writeLoginEvent($uid, (string)$username, (string)$ip, (string)$platform, true, '');
    }

    public function addFailedLog($username, $ip, $reason = '')
    {
        return $this->writeLoginEvent(0, (string)$username, (string)$ip, 'web', false, (string)$reason);
    }

    public function getLoginLogs($userId, $page = 1, $limit = 20)
    {
        $uid = intval($userId);
        if ($uid <= 0) {
            return [];
        }

        $page = max(1, intval($page));
        $limit = max(1, intval($limit));

        $rows = $this->buildLoginQuery()
            ->where('uid', $uid)
            ->order('id', 'desc')
            ->page($page, $limit)
            ->select()
            ->toArray();
        $total = $this->countByUserId($uid);

        return [
            'list' => $this->mapRowsToLegacy($rows),
            'total' => $total,
            'page' => $page,
            'limit' => $limit,
            'pages' => $total > 0 ? ceil($total / $limit) : 0,
        ];
    }

    public function getRecentLogs($userId, $limit = 5)
    {
        $uid = intval($userId);
        if ($uid <= 0) {
            return [];
        }

        $rows = $this->buildLoginQuery()
            ->where('uid', $uid)
            ->where('success', 1)
            ->order('id', 'desc')
            ->limit(max(1, intval($limit)))
            ->select()
            ->toArray();

        return $this->mapRowsToLegacy($rows);
    }

    public function getFailedCountByIP($ip, $timeRange = 300)
    {
        if (empty($ip)) {
            return 0;
        }

        $startTime = date('Y-m-d H:i:s', time() - max(1, intval($timeRange)));

        return intval($this->buildLoginQuery()
            ->where('ip', (string)$ip)
            ->where('success', 0)
            ->where('created_at', '>=', $startTime)
            ->count());
    }

    public function getFailedCountByUsername($username, $timeRange = 300)
    {
        if (empty($username)) {
            return 0;
        }

        $startTime = date('Y-m-d H:i:s', time() - max(1, intval($timeRange)));

        return intval($this->buildLoginQuery()
            ->where('username', (string)$username)
            ->where('success', 0)
            ->where('created_at', '>=', $startTime)
            ->count());
    }

    public function cleanOldLogs($days = 90)
    {
        $expireDate = date('Y-m-d H:i:s', time() - (max(1, intval($days)) * 86400));

        return $this->buildLoginQuery()
            ->where('created_at', '<', $expireDate)
            ->delete();
    }

    public function countByUserId($userId): int
    {
        $uid = intval($userId);
        if ($uid <= 0) {
            return 0;
        }

        return intval($this->buildLoginQuery()
            ->where('uid', $uid)
            ->count());
    }

    public function countAllLoginEvents(): int
    {
        return intval($this->buildLoginQuery()->count());
    }

    public function getLatestSuccessfulUsernameByUserId(int $userId): string
    {
        if ($userId <= 0) {
            return '';
        }

        return trim((string)$this->buildLoginQuery()
            ->where('uid', $userId)
            ->where('success', 1)
            ->whereNotNull('username')
            ->where('username', '<>', '')
            ->order('id', 'desc')
            ->value('username'));
    }

    public function countUserEventsForCleanup(int $userId, string $username = ''): int
    {
        $query = $this->buildCleanupQuery($userId, $username);
        return $query ? intval($query->count()) : 0;
    }

    public function deleteUserEventsForCleanup(int $userId, string $username = ''): int
    {
        $query = $this->buildCleanupQuery($userId, $username);
        return $query ? intval($query->delete()) : 0;
    }

    private function writeLoginEvent(int $userId, string $username, string $ip, string $platform, bool $success, string $reason): bool
    {
        $log = new self();
        return (bool)$log->save([
            'category' => self::CATEGORY,
            'event_type' => $success ? self::EVENT_SUCCESS : self::EVENT_FAILED,
            'uid' => $userId,
            'username' => $username,
            'ip' => $ip,
            'success' => $success ? 1 : 0,
            'status' => $success ? 'success' : 'failed',
            'message' => $reason,
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
            'extra' => json_encode([
                'platform' => $platform,
                'client' => $platform,
            ], JSON_UNESCAPED_UNICODE),
            'created_at' => date('Y-m-d H:i:s'),
        ]);
    }

    private function buildLoginQuery()
    {
        return self::where('category', self::CATEGORY);
    }

    private function buildCleanupQuery(int $userId, string $username = '')
    {
        $uid = max(0, intval($userId));
        $username = trim($username);
        if ($uid <= 0 && $username === '') {
            return null;
        }

        $query = self::where('uid', '>=', 0);
        if ($uid > 0 && $username !== '') {
            $query->where(function ($builder) use ($uid, $username) {
                $builder->where('uid', $uid)
                    ->whereOr(function ($subQuery) use ($username) {
                        $subQuery->where('uid', 0)
                            ->where('username', $username);
                    });
            });
            return $query;
        }

        if ($uid > 0) {
            return $query->where('uid', $uid);
        }

        return $query->where('username', $username);
    }

    private function mapRowsToLegacy(array $rows): array
    {
        $mapped = [];
        foreach ($rows as $row) {
            $extra = $this->decodeExtra($row['extra'] ?? '');
            $mapped[] = [
                'id' => intval($row['id'] ?? 0),
                'user_id' => intval($row['uid'] ?? 0),
                'username' => (string)($row['username'] ?? ''),
                'ip' => (string)($row['ip'] ?? ''),
                'platform' => (string)($extra['platform'] ?? $extra['client'] ?? 'web'),
                'user_agent' => (string)($row['user_agent'] ?? ''),
                'status' => intval($row['success'] ?? 0),
                'remark' => (string)($row['message'] ?? $row['detail'] ?? ''),
                'created_at' => (string)($row['created_at'] ?? ''),
            ];
        }

        return $mapped;
    }

    private function decodeExtra($value): array
    {
        if (is_array($value)) {
            return $value;
        }

        $decoded = json_decode((string)$value, true);
        return is_array($decoded) ? $decoded : [];
    }
}

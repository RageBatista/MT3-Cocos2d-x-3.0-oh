<?php
declare(strict_types=1);

namespace app\player\service;

use app\model\AdminLog as AdminAuditLog;
use app\model\UserLog;
use think\facade\Db;
use think\facade\Log;

/**
 * LogService - 统一日志服务类
 * 整合玩家服务中心和梦幻授权控制台的日志记录功能
 */
class LogService
{
    private const TABLE_EVENT_LOG = 'player_event_log';
    private const CATEGORY_PLAYER_ACTION = 'player_action';

    /**
     * 不可用数据表缓存，避免每次请求重复打到数据库抛同类异常
     * @var array<string,bool>
     */
    private static array $disabledTables = [];

    /**
     * 缺表自动建表仅尝试一次，避免在无DDL权限时反复尝试
     */
    private static bool $eventLogTableCreateTried = false;

    /**
     * 日志类型常量
     */
    const TYPE_LOGIN = 'login';
    const TYPE_LOGOUT = 'logout';
    const TYPE_REGISTER = 'register';
    const TYPE_CDK_AUTH = 'cdk_auth';
    const TYPE_PASSWORD_RESET = 'password_reset';
    const TYPE_PROFILE_UPDATE = 'profile_update';
    const TYPE_RECHARGE = 'recharge';
    const TYPE_FEEDBACK = 'feedback';
    const TYPE_ADMIN = 'admin';
    const TYPE_SECURITY = 'security';

    /**
     * 记录玩家登录日志
     * @param int $uid 用户ID
     * @param string $username 用户名
     * @param string $ip IP地址
     * @param string $client 客户端类型
     * @param bool $success 是否成功
     * @param string $message 消息
     */
    public function logLogin(int $uid, string $username, string $ip, string $client = 'web', bool $success = true, string $message = ''): void
    {
        $this->writeEventLog('login', [
            'category' => self::TYPE_LOGIN,
            'event_type' => $success ? 'login_success' : 'login_failed',
            'uid' => $uid,
            'username' => $username,
            'ip' => $ip,
            'success' => $success,
            'status' => $success ? 'success' : 'failed',
            'message' => $message,
            'extra' => [
                'client' => $client,
            ],
        ]);
    }

    /**
     * 记录登录失败日志
     * @param string $username 用户名
     * @param string $ip IP地址
     * @param string $reason 失败原因
     */
    public function logLoginFailed(string $username, string $ip, string $reason): void
    {
        $this->logLogin(0, $username, $ip, 'web', false, $reason);
    }

    /**
     * 记录CDK授权日志
     * @param int $uid 用户ID
     * @param string $cdk CDK码
     * @param int $serverId 服务器ID
     * @param bool $success 是否成功
     * @param string $message 消息
     */
    public function logCdkAuth(int $uid, string $cdk, int $serverId, bool $success = true, string $message = ''): void
    {
        $this->writeEventLog('cdk_auth', [
            'category' => self::TYPE_CDK_AUTH,
            'event_type' => self::TYPE_CDK_AUTH,
            'uid' => $uid,
            'serverid' => $serverId,
            'resource_type' => 'cdk',
            'resource_id' => $cdk,
            'ip' => $this->getClientIp(),
            'success' => $success,
            'status' => $success ? 'success' : 'failed',
            'message' => $message,
            'extra' => [
                'cdk' => $cdk,
                'serverid' => $serverId,
            ],
        ]);
    }

    /**
     * 记录玩家操作日志
     * @param int $uid 用户ID
     * @param string $action 操作类型
     * @param string $detail 操作详情
     * @param array $extra 额外信息
     */
    public function logPlayerAction(int $uid, string $action, string $detail = '', array $extra = []): void
    {
        $this->writeEventLog('player_action', [
            'category' => self::CATEGORY_PLAYER_ACTION,
            'event_type' => $action,
            'uid' => $uid,
            'detail' => $detail,
            'ip' => $this->getClientIp(),
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
            'extra' => $extra,
        ]);
    }

    /**
     * 记录管理员操作日志
     * @param string $username 管理员用户名
     * @param string $action 操作类型
     * @param string $detail 操作详情
     * @param array $extra 额外信息
     */
    public function logAdminAction(string $username, string $action, string $detail = '', array $extra = []): void
    {
        $infoData = [];
        if ($detail !== '') {
            $infoData['detail'] = $detail;
        }
        if (!empty($extra)) {
            $infoData['extra'] = $extra;
        }

        $data = [
            'username' => $username,
            'info' => UserLog::formatLogInfo('ADMIN_AUDIT', $action, $infoData),
            'date' => date('Y-m-d H:i:s'),
            'time' => (string)time(),
            'ip' => $this->getClientIp(),
            'city' => '未知',
        ];

        try {
            $log = new AdminAuditLog();
            $log->addAdminLog($data['username'], $data['info'], $data);
        } catch (\Throwable $e) {
            $this->logToFile('admin_action', $data, $e->getMessage());
        }
    }

    /**
     * 记录安全事件日志
     * @param string $event 事件类型
     * @param string $ip IP地址
     * @param string $detail 详情
     * @param array $extra 额外信息
     */
    public function logSecurityEvent(string $event, string $ip, string $detail = '', array $extra = []): void
    {
        $this->writeEventLog('security', [
            'category' => self::TYPE_SECURITY,
            'event_type' => $event,
            'ip' => $ip,
            'detail' => $detail,
            'extra' => $extra,
        ]);
    }

    /**
     * 记录充值日志
     * @param int $uid 用户ID
     * @param string $orderId 订单号
     * @param float $amount 金额
     * @param string $status 状态
     * @param array $extra 额外信息
     */
    public function logRecharge(int $uid, string $orderId, float $amount, string $status, array $extra = []): void
    {
        $normalizedStatus = strtolower($status);
        $success = in_array($normalizedStatus, ['success', 'paid', 'completed', 'complete', 'ok'], true);

        $this->writeEventLog('recharge', [
            'category' => self::TYPE_RECHARGE,
            'event_type' => self::TYPE_RECHARGE,
            'uid' => $uid,
            'order_id' => $orderId,
            'amount' => $amount,
            'status' => $status,
            'success' => $success,
            'ip' => $this->getClientIp(),
            'extra' => $extra,
        ]);
    }

    /**
     * 记录反馈日志
     * @param int $uid 用户ID
     * @param int $feedbackId 反馈ID
     * @param string $type 反馈类型
     * @param string $content 内容
     */
    public function logFeedback(int $uid, int $feedbackId, string $type, string $content): void
    {
        $this->writeEventLog('feedback', [
            'category' => self::TYPE_FEEDBACK,
            'event_type' => $type,
            'uid' => $uid,
            'resource_type' => 'feedback',
            'resource_id' => (string)$feedbackId,
            'detail' => $content,
            'ip' => $this->getClientIp(),
            'extra' => [
                'feedback_id' => $feedbackId,
            ],
        ]);
    }

    /**
     * 获取玩家登录历史
     * @param int $uid 用户ID
     * @param int $limit 限制条数
     * @return array 登录历史
     */
    public function getLoginHistory(int $uid, int $limit = 10): array
    {
        try {
            return Db::name(self::TABLE_EVENT_LOG)
                ->where('category', self::TYPE_LOGIN)
                ->where('uid', $uid)
                ->field('id, uid, username, ip, event_type, success, status, message, extra, created_at')
                ->order('created_at', 'desc')
                ->limit($limit)
                ->select()
                ->toArray();
        } catch (\Throwable $e) {
            $this->disableTableIfMissing(self::TABLE_EVENT_LOG, $e);
            return [];
        }
    }

    /**
     * 获取玩家操作历史
     * @param int $uid 用户ID
     * @param int $limit 限制条数
     * @return array 操作历史
     */
    public function getActionHistory(int $uid, int $limit = 20): array
    {
        try {
            return Db::name(self::TABLE_EVENT_LOG)
                ->where('category', self::CATEGORY_PLAYER_ACTION)
                ->where('uid', $uid)
                ->field('id, uid, event_type AS action, detail, ip, user_agent, extra, created_at')
                ->order('created_at', 'desc')
                ->limit($limit)
                ->select()
                ->toArray();
        } catch (\Throwable $e) {
            $this->disableTableIfMissing(self::TABLE_EVENT_LOG, $e);
            return [];
        }
    }

    /**
     * 获取安全事件列表
     * @param string $ip IP地址（可选）
     * @param int $limit 限制条数
     * @return array 安全事件列表
     */
    public function getSecurityEvents(string $ip = '', int $limit = 50): array
    {
        try {
            $query = Db::name(self::TABLE_EVENT_LOG)
                ->where('category', self::TYPE_SECURITY);

            if ($ip !== '') {
                $query->where('ip', $ip);
            }

            return $query
                ->field('id, event_type AS event, ip, detail, extra, created_at')
                ->order('created_at', 'desc')
                ->limit($limit)
                ->select()
                ->toArray();
        } catch (\Throwable $e) {
            $this->disableTableIfMissing(self::TABLE_EVENT_LOG, $e);
            return [];
        }
    }

    /**
     * 统计登录失败次数
     * @param string $ip IP地址
     * @param int $hours 时间范围（小时）
     * @return int 失败次数
     */
    public function countLoginFailed(string $ip, int $hours = 24): int
    {
        try {
            $startTime = date('Y-m-d H:i:s', strtotime("-{$hours} hours"));

            return Db::name(self::TABLE_EVENT_LOG)
                ->where('category', self::TYPE_LOGIN)
                ->where('ip', $ip)
                ->where('success', 0)
                ->where('created_at', '>=', $startTime)
                ->count();
        } catch (\Throwable $e) {
            $this->disableTableIfMissing(self::TABLE_EVENT_LOG, $e);
            return 0;
        }
    }

    /**
     * 清理过期日志
     * @param int $days 保留天数
     */
    public function cleanOldLogs(int $days = 30): void
    {
        $cutoffTime = date('Y-m-d H:i:s', strtotime("-{$days} days"));

        if ($this->isTableDisabled(self::TABLE_EVENT_LOG)) {
            return;
        }

        try {
            Db::name(self::TABLE_EVENT_LOG)
                ->where('created_at', '<', $cutoffTime)
                ->delete();
        } catch (\Throwable $e) {
            $this->disableTableIfMissing(self::TABLE_EVENT_LOG, $e);
            Log::error('Failed to clean old logs for table ' . self::TABLE_EVENT_LOG . ': ' . $e->getMessage());
        }
    }

    /**
     * 写入玩家侧通用事件日志，数据库不可用时降级为文件日志。
     */
    private function writeEventLog(string $fallbackType, array $data): void
    {
        $row = [
            'trace_id' => $this->limitString((string)($data['trace_id'] ?? ($_SERVER['TRACE_ID'] ?? '')), 64),
            'category' => $this->limitString((string)($data['category'] ?? $fallbackType), 32),
            'event_type' => $this->limitString((string)($data['event_type'] ?? $fallbackType), 64),
            'uid' => max(0, intval($data['uid'] ?? 0)),
            'username' => $this->limitString((string)($data['username'] ?? ''), 64),
            'serverid' => max(0, intval($data['serverid'] ?? 0)),
            'resource_type' => $this->limitString((string)($data['resource_type'] ?? ''), 32),
            'resource_id' => $this->limitString((string)($data['resource_id'] ?? ''), 128),
            'order_id' => $this->limitString((string)($data['order_id'] ?? ''), 64),
            'amount' => round(floatval($data['amount'] ?? 0), 2),
            'success' => array_key_exists('success', $data) ? ($data['success'] ? 1 : 0) : 1,
            'status' => $this->limitString((string)($data['status'] ?? ''), 32),
            'message' => $this->limitString((string)($data['message'] ?? ''), 255),
            'detail' => $this->limitString((string)($data['detail'] ?? ''), 500),
            'ip' => $this->limitString((string)($data['ip'] ?? $this->getClientIp()), 45),
            'user_agent' => $this->limitString((string)($data['user_agent'] ?? ($_SERVER['HTTP_USER_AGENT'] ?? '')), 255),
            'extra' => $this->encodeExtra($data['extra'] ?? []),
            'created_at' => (string)($data['created_at'] ?? date('Y-m-d H:i:s')),
        ];

        if ($this->isTableDisabled(self::TABLE_EVENT_LOG)) {
            $this->logToFile($fallbackType, $row, self::TABLE_EVENT_LOG . ' disabled, fallback to file');
            return;
        }

        try {
            Db::name(self::TABLE_EVENT_LOG)->insert($row);
        } catch (\Throwable $e) {
            $this->disableTableIfMissing(self::TABLE_EVENT_LOG, $e);

            if ($this->isTableDisabled(self::TABLE_EVENT_LOG) && $this->ensurePlayerEventLogTable()) {
                try {
                    Db::name(self::TABLE_EVENT_LOG)->insert($row);
                    self::$disabledTables[self::TABLE_EVENT_LOG] = false;
                    return;
                } catch (\Throwable $retryException) {
                    $this->disableTableIfMissing(self::TABLE_EVENT_LOG, $retryException);
                    $this->logToFile($fallbackType, $row, $retryException->getMessage());
                    return;
                }
            }

            $this->logToFile($fallbackType, $row, $e->getMessage());
        }
    }

    /**
     * 写入文件日志（降级方案）
     * @param string $type 日志类型
     * @param array $data 日志数据
     * @param string $error 错误信息
     */
    private function logToFile(string $type, array $data, string $error = ''): void
    {
        $logDir = runtime_path('log' . DIRECTORY_SEPARATOR . 'player');
        if (!is_dir($logDir)) {
            mkdir($logDir, 0755, true);
        }

        $logFile = $logDir . DIRECTORY_SEPARATOR . $type . '_' . date('Ymd') . '.log';

        $logEntry = [
            'time' => date('Y-m-d H:i:s'),
            'type' => $type,
            'data' => $data,
            'error' => $error
        ];

        $logLine = json_encode($logEntry, JSON_UNESCAPED_UNICODE) . PHP_EOL;
        file_put_contents($logFile, $logLine, FILE_APPEND);
    }

    /**
     * 获取客户端IP
     * @return string IP地址
     */
    private function getClientIp(): string
    {
        $request = request();

        if (!empty($request->server('HTTP_X_FORWARDED_FOR'))) {
            $ips = explode(',', $request->server('HTTP_X_FORWARDED_FOR'));
            $ip = trim($ips[0]);
        } elseif (!empty($request->server('HTTP_CLIENT_IP'))) {
            $ip = $request->server('HTTP_CLIENT_IP');
        } elseif (!empty($request->server('HTTP_X_REAL_IP'))) {
            $ip = $request->server('HTTP_X_REAL_IP');
        } else {
            $ip = $request->ip();
        }

        if (!filter_var($ip, FILTER_VALIDATE_IP)) {
            return '0.0.0.0';
        }

        return $ip;
    }

    private function isTableDisabled(string $table): bool
    {
        return (bool)(self::$disabledTables[$table] ?? false);
    }

    private function disableTableIfMissing(string $table, \Throwable $exception): void
    {
        if ($this->isMissingTableException($exception)) {
            self::$disabledTables[$table] = true;
        }
    }

    private function isMissingTableException(\Throwable $exception): bool
    {
        $msg = strtolower($exception->getMessage());
        return strpos($msg, 'base table or view not found') !== false
            || strpos($msg, "doesn't exist") !== false
            || strpos($msg, '1146') !== false;
    }

    private function ensurePlayerEventLogTable(): bool
    {
        if (self::$eventLogTableCreateTried) {
            return false;
        }
        self::$eventLogTableCreateTried = true;

        try {
            $defaultConn = (string)config('database.default', 'mysql');
            $prefix = (string)config('database.connections.' . $defaultConn . '.prefix', '');
            $table = str_replace('`', '``', $prefix . self::TABLE_EVENT_LOG);
            $sql = "CREATE TABLE IF NOT EXISTS `{$table}` (
                `id` bigint unsigned NOT NULL AUTO_INCREMENT,
                `trace_id` varchar(64) NOT NULL DEFAULT '',
                `category` varchar(32) NOT NULL DEFAULT '',
                `event_type` varchar(64) NOT NULL DEFAULT '',
                `uid` bigint unsigned NOT NULL DEFAULT 0,
                `username` varchar(64) NOT NULL DEFAULT '',
                `serverid` int unsigned NOT NULL DEFAULT 0,
                `resource_type` varchar(32) NOT NULL DEFAULT '',
                `resource_id` varchar(128) NOT NULL DEFAULT '',
                `order_id` varchar(64) NOT NULL DEFAULT '',
                `amount` decimal(12,2) NOT NULL DEFAULT 0.00,
                `success` tinyint(1) NOT NULL DEFAULT 1,
                `status` varchar(32) NOT NULL DEFAULT '',
                `message` varchar(255) NOT NULL DEFAULT '',
                `detail` varchar(500) NOT NULL DEFAULT '',
                `ip` varchar(45) NOT NULL DEFAULT '',
                `user_agent` varchar(255) NOT NULL DEFAULT '',
                `extra` text NULL,
                `created_at` datetime NOT NULL,
                PRIMARY KEY (`id`),
                KEY `idx_category_created_at` (`category`,`created_at`),
                KEY `idx_uid_category_created_at` (`uid`,`category`,`created_at`),
                KEY `idx_username_category_created_at` (`username`,`category`,`created_at`),
                KEY `idx_category_success_created_at` (`category`,`success`,`created_at`),
                KEY `idx_event_type` (`event_type`),
                KEY `idx_ip_created_at` (`ip`,`created_at`),
                KEY `idx_resource` (`resource_type`,`resource_id`),
                KEY `idx_order_id` (`order_id`),
                KEY `idx_success` (`success`),
                KEY `idx_trace_id` (`trace_id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";

            Db::execute($sql);
            Log::warning(self::TABLE_EVENT_LOG . ' 缺失，已自动建表并恢复数据库日志写入');
            return true;
        } catch (\Throwable $e) {
            Log::error('自动建表 ' . self::TABLE_EVENT_LOG . ' 失败: ' . $e->getMessage());
            return false;
        }
    }

    private function encodeExtra($extra): string
    {
        if (is_string($extra)) {
            return $extra;
        }

        $json = json_encode($extra, JSON_UNESCAPED_UNICODE);
        return $json === false ? '{}' : $json;
    }

    private function limitString($value, int $maxLength): string
    {
        $value = (string)$value;
        if (function_exists('mb_substr')) {
            return mb_substr($value, 0, $maxLength, 'UTF-8');
        }

        return substr($value, 0, $maxLength);
    }
}

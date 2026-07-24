<?php
declare(strict_types=1);

namespace app\player\service;

use think\facade\Db;
use think\facade\Log;

/**
 * LogService - 统一日志服务类
 * 整合玩家服务中心和梦幻授权控制台的日志记录功能
 */
class LogService
{
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
        $data = [
            'uid' => $uid,
            'username' => $username,
            'ip' => $ip,
            'client' => $client,
            'success' => $success ? 1 : 0,
            'message' => $message,
            'created_at' => date('Y-m-d H:i:s')
        ];
        
        try {
            Db::name('player_login_log')->insert($data);
        } catch (\Throwable $e) {
            $this->logToFile('login', $data, $e->getMessage());
        }
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
        $data = [
            'uid' => $uid,
            'cdk' => $cdk,
            'serverid' => $serverId,
            'success' => $success ? 1 : 0,
            'message' => $message,
            'ip' => $this->getClientIp(),
            'created_at' => date('Y-m-d H:i:s')
        ];
        
        try {
            Db::name('player_cdk_log')->insert($data);
        } catch (\Throwable $e) {
            $this->logToFile('cdk_auth', $data, $e->getMessage());
        }
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
        $data = [
            'uid' => $uid,
            'action' => $action,
            'detail' => $detail,
            'ip' => $this->getClientIp(),
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
            'extra' => json_encode($extra, JSON_UNESCAPED_UNICODE),
            'created_at' => date('Y-m-d H:i:s')
        ];
        
        try {
            Db::name('player_action_log')->insert($data);
        } catch (\Throwable $e) {
            $this->logToFile('player_action', $data, $e->getMessage());
        }
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
        $data = [
            'username' => $username,
            'action' => $action,
            'detail' => $detail,
            'ip' => $this->getClientIp(),
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
            'extra' => json_encode($extra, JSON_UNESCAPED_UNICODE),
            'created_at' => date('Y-m-d H:i:s')
        ];
        
        try {
            Db::name('admin_log')->insert($data);
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
        $data = [
            'event' => $event,
            'ip' => $ip,
            'detail' => $detail,
            'extra' => json_encode($extra, JSON_UNESCAPED_UNICODE),
            'created_at' => date('Y-m-d H:i:s')
        ];
        
        try {
            Db::name('security_log')->insert($data);
        } catch (\Throwable $e) {
            $this->logToFile('security', $data, $e->getMessage());
        }
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
        $data = [
            'uid' => $uid,
            'order_id' => $orderId,
            'amount' => $amount,
            'status' => $status,
            'ip' => $this->getClientIp(),
            'extra' => json_encode($extra, JSON_UNESCAPED_UNICODE),
            'created_at' => date('Y-m-d H:i:s')
        ];
        
        try {
            Db::name('recharge_log')->insert($data);
        } catch (\Throwable $e) {
            $this->logToFile('recharge', $data, $e->getMessage());
        }
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
        $data = [
            'uid' => $uid,
            'feedback_id' => $feedbackId,
            'type' => $type,
            'content' => mb_substr($content, 0, 500),
            'ip' => $this->getClientIp(),
            'created_at' => date('Y-m-d H:i:s')
        ];
        
        try {
            Db::name('feedback_log')->insert($data);
        } catch (\Throwable $e) {
            $this->logToFile('feedback', $data, $e->getMessage());
        }
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
            return Db::name('player_login_log')
                ->where('uid', $uid)
                ->order('created_at', 'desc')
                ->limit($limit)
                ->select()
                ->toArray();
        } catch (\Throwable $e) {
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
            return Db::name('player_action_log')
                ->where('uid', $uid)
                ->order('created_at', 'desc')
                ->limit($limit)
                ->select()
                ->toArray();
        } catch (\Throwable $e) {
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
            $query = Db::name('security_log');
            
            if ($ip !== '') {
                $query->where('ip', $ip);
            }
            
            return $query->order('created_at', 'desc')
                ->limit($limit)
                ->select()
                ->toArray();
        } catch (\Throwable $e) {
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
            
            return Db::name('player_login_log')
                ->where('ip', $ip)
                ->where('success', 0)
                ->where('created_at', '>=', $startTime)
                ->count();
        } catch (\Throwable $e) {
            return 0;
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
    
    /**
     * 清理过期日志
     * @param int $days 保留天数
     */
    public function cleanOldLogs(int $days = 30): void
    {
        $cutoffTime = date('Y-m-d H:i:s', strtotime("-{$days} days"));
        
        $tables = [
            'player_login_log',
            'player_action_log',
            'player_cdk_log',
            'security_log'
        ];
        
        foreach ($tables as $table) {
            try {
                Db::name($table)
                    ->where('created_at', '<', $cutoffTime)
                    ->delete();
            } catch (\Throwable $e) {
                Log::error("Failed to clean old logs for table {$table}: " . $e->getMessage());
            }
        }
    }
}

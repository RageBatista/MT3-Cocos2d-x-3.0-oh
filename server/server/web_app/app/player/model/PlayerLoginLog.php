<?php
namespace app\player\model;

use think\Model;

/**
 * PlayerLoginLog模型 - 玩家登录日志模型
 * 记录玩家登录日志
 */
class PlayerLoginLog extends Model
{
    protected $table = 'player_login_log';
    
    protected $autoWriteTimestamp = 'datetime';
    
    protected $createTime = 'created_at';
    protected $updateTime = false;
    
    /**
     * 添加登录日志
     * @param int $userId 用户ID
     * @param string $username 用户名
     * @param string $ip IP地址
     * @param string $platform 平台
     * @return bool 添加结果
     */
    public function addLoginLog($userId, $username, $ip, $platform = 'web')
    {
        if (empty($userId) || $userId <= 0) {
            return false;
        }
        
        $log = new PlayerLoginLog();
        $log->user_id = $userId;
        $log->username = $username;
        $log->ip = $ip;
        $log->platform = $platform;
        $log->user_agent = $_SERVER['HTTP_USER_AGENT'] ?? '';
        $log->status = 1; // 1: 成功, 0: 失败
        
        return $log->save();
    }
    
    /**
     * 添加登录失败日志
     * @param string $username 用户名
     * @param string $ip IP地址
     * @param string $reason 失败原因
     * @return bool 添加结果
     */
    public function addFailedLog($username, $ip, $reason = '')
    {
        $log = new PlayerLoginLog();
        $log->user_id = 0;
        $log->username = $username;
        $log->ip = $ip;
        $log->platform = 'web';
        $log->user_agent = $_SERVER['HTTP_USER_AGENT'] ?? '';
        $log->status = 0; // 失败
        $log->remark = $reason;
        
        return $log->save();
    }
    
    /**
     * 获取登录日志
     * @param int $userId 用户ID
     * @param int $page 页码
     * @param int $limit 每页数量
     * @return array 登录日志列表
     */
    public function getLoginLogs($userId, $page = 1, $limit = 20)
    {
        if (empty($userId) || $userId <= 0) {
            return [];
        }
        
        $query = $this->where('user_id', $userId);
        
        $list = $query->order('id', 'desc')
            ->page($page, $limit)
            ->select();
        
        $total = $this->where('user_id', $userId)->count();
        
        return [
            'list' => $list,
            'total' => $total,
            'page' => $page,
            'limit' => $limit,
            'pages' => ceil($total / $limit)
        ];
    }
    
    /**
     * 获取最近的登录记录
     * @param int $userId 用户ID
     * @param int $limit 数量限制
     * @return array 登录记录
     */
    public function getRecentLogs($userId, $limit = 5)
    {
        if (empty($userId) || $userId <= 0) {
            return [];
        }
        
        return $this->where('user_id', $userId)
            ->where('status', 1)
            ->order('id', 'desc')
            ->limit($limit)
            ->select()
            ->toArray();
    }
    
    /**
     * 获取IP登录失败次数
     * @param string $ip IP地址
     * @param int $timeRange 时间范围（秒）
     * @return int 失败次数
     */
    public function getFailedCountByIP($ip, $timeRange = 300)
    {
        if (empty($ip)) {
            return 0;
        }
        
        $startTime = date('Y-m-d H:i:s', time() - $timeRange);
        
        return $this->where('ip', $ip)
            ->where('status', 0)
            ->where('created_at', '>=', $startTime)
            ->count();
    }
    
    /**
     * 获取用户登录失败次数
     * @param string $username 用户名
     * @param int $timeRange 时间范围（秒）
     * @return int 失败次数
     */
    public function getFailedCountByUsername($username, $timeRange = 300)
    {
        if (empty($username)) {
            return 0;
        }
        
        $startTime = date('Y-m-d H:i:s', time() - $timeRange);
        
        return $this->where('username', $username)
            ->where('status', 0)
            ->where('created_at', '>=', $startTime)
            ->count();
    }
    
    /**
     * 清理旧的登录日志
     * @param int $days 保留天数
     * @return int 删除的记录数
     */
    public function cleanOldLogs($days = 90)
    {
        $expireDate = date('Y-m-d H:i:s', time() - ($days * 86400));
        
        return $this->where('created_at', '<', $expireDate)->delete();
    }
}

<?php
namespace app\player\model;

use app\model\User as BaseUser;
use think\facade\Db;
use think\facade\Cache;
use think\facade\Log;

/**
 * Player模型 - 玩家模型
 * 继承User模型，添加玩家特定方法
 */
class Player extends BaseUser
{
    /**
     * 获取玩家信息
     * @param int $userId 用户ID
     * @return array|null 玩家信息
     */
    public function getPlayerInfo($userId)
    {
        if (empty($userId) || $userId <= 0) {
            return null;
        }
        
        $user = $this->getById($userId);
        if (!$user) {
            return null;
        }
        
        // 获取玩家个人资料（可选数据，查询失败时降级）
        $profile = null;
        try {
            $profileModel = new PlayerProfile();
            $profile = $profileModel->getProfile($userId);
        } catch (\Throwable $e) {
            Log::debug('Player::getPlayerInfo profile query failed', [
                'user_id' => $userId,
                'error' => $e->getMessage()
            ]);
        }
        
        // 合并信息
        $playerInfo = is_object($user) && method_exists($user, 'toArray')
            ? $user->toArray()
            : (array)$user;

        if ($profile) {
            $playerInfo['profile'] = $profile;
        }
        
        // 获取绑定的服务器（批量查询，避免N+1问题）
        $playerInfo['servers'] = [];
        if (!empty($playerInfo['bidserver'])) {
            try {
                $servers = json_decode((string)$playerInfo['bidserver'], true);
                if (is_array($servers) && !empty($servers)) {
                    $serverModel = new \app\model\Server();
                    // 批量查询服务器信息（bidserver存储的是serverid，不是主键id）
                    $serverList = $serverModel->where('serverid', 'in', $servers)->select();
                    if ($serverList) {
                        $playerInfo['servers'] = $serverList->toArray();
                    }
                }
            } catch (\Throwable $e) {
                Log::debug('Player::getPlayerInfo servers query failed', [
                    'user_id' => $userId,
                    'error' => $e->getMessage()
                ]);
            }
        }

        // P3安全增强：过滤敏感字段，防止密码哈希等敏感数据泄露到上层
        $sensitiveFields = ['password', 'pay_password', 'secret_key', 'pay_key', 'salt'];
        foreach ($sensitiveFields as $field) {
            unset($playerInfo[$field]);
        }
        
        return $playerInfo;
    }
    
    /**
     * 更新玩家信息
     * @param int $userId 用户ID
     * @param array $data 更新数据
     * @return bool 更新结果
     */
    public function updatePlayerInfo($userId, $data)
    {
        if (empty($userId) || $userId <= 0) {
            return false;
        }
        
        $user = $this->getById($userId);
        if (!$user) {
            return false;
        }
        
        // 允许更新的字段
        $allowedFields = ['platform', 'login_ip'];
        
        foreach ($allowedFields as $field) {
            if (isset($data[$field])) {
                $user->$field = $data[$field];
            }
        }
        
        return $user->save();
    }
    
    /**
     * 获取玩家订单列表
     * @param int $userId 用户ID
     * @param int $page 页码
     * @param int $limit 每页数量
     * @return array 订单列表
     */
    public function getPlayerOrders($userId, $page = 1, $limit = 20)
    {
        if (empty($userId) || $userId <= 0) {
            return [
                'list' => [],
                'total' => 0,
                'page' => $page,
                'limit' => $limit,
                'pages' => 0
            ];
        }
        
        // user_order表没有uid字段，用户信息存储在user JSON字段中
        // 先获取玩家所有角色的playerid
        $playerIds = Db::name('user_bind')
            ->where('userid', $userId)
            ->column('playerid');
        
        if (empty($playerIds)) {
            return [
                'list' => [],
                'total' => 0,
                'page' => $page,
                'limit' => $limit,
                'pages' => 0
            ];
        }
        
        // P2优化：使用common.php中的公共方法，消除重复代码
        $buildQueryCondition = buildPlayerOrderWhere($playerIds);
        
        // 使用同一个条件闭包构建查询，避免N+1和重复构建
        $orderModel = new \app\model\UserOrder();
        
        // 先获取总数
        $total = $orderModel->where($buildQueryCondition)->count();
        
        // 如果总数为0，直接返回空结果
        if ($total == 0) {
            return [
                'list' => [],
                'total' => 0,
                'page' => $page,
                'limit' => $limit,
                'pages' => 0
            ];
        }
        
        // 获取分页数据
        $list = $orderModel->where($buildQueryCondition)
            ->order('id', 'desc')
            ->page($page, $limit)
            ->select();
        
        return [
            'list' => $list,
            'total' => $total,
            'page' => $page,
            'limit' => $limit,
            'pages' => $total > 0 ? ceil($total / $limit) : 0
        ];
    }
    
    /**
     * 获取玩家角色列表
     * @param int $userId 用户ID
     * @return array 角色列表
     */
    public function getPlayerRoles($userId)
    {
        if (empty($userId) || $userId <= 0) {
            return [];
        }
        
        // 从缓存中获取角色信息
        $cacheKey = 'player_roles:' . $userId;
        $roles = Cache::get($cacheKey);
        
        if ($roles !== null) {
            return $roles;
        }
        
        // 从数据库获取角色信息（可选数据，查询失败时降级）
        try {
            // 使用user_bind表（玩家角色绑定表，非role表）
            $roles = Db::name('user_bind')
                ->where('userid', $userId)
                ->select()
                ->toArray();
        } catch (\Throwable $e) {
            Log::debug('Player::getPlayerRoles query failed', [
                'user_id' => $userId,
                'error' => $e->getMessage()
            ]);
            return [];
        }
        
        // 缓存角色信息（缓存1小时）
        Cache::set($cacheKey, $roles, 3600);
        
        return $roles;
    }
    
    /**
     * 检查玩家状态
     * @param int $userId 用户ID
     * @return array ['valid' => bool, 'message' => string]
     */
    public function checkPlayerStatus($userId)
    {
        if (empty($userId) || $userId <= 0) {
            return ['valid' => false, 'message' => '玩家ID无效'];
        }
        
        $user = $this->getById($userId);
        if (!$user) {
            return ['valid' => false, 'message' => '玩家不存在'];
        }
        
        // 检查账号状态
        if (isset($user['status']) && intval($user['status']) !== 1) {
            return ['valid' => false, 'message' => '账号已被禁用'];
        }
        
        return ['valid' => true, 'message' => ''];
    }
    
    /**
     * 获取玩家统计数据
     * @param int $userId 用户ID
     * @return array 统计数据
     */
    public function getPlayerStats($userId)
    {
        if (empty($userId) || $userId <= 0) {
            return [];
        }
        
        $stats = [
            'total_orders' => 0,
            'total_amount' => 0,
            'total_recharge' => 0,
            'role_count' => 0,
            'login_count' => 0
        ];
        
        // 获取订单统计（通过playerid列表匹配user JSON字段）
        $playerIds = Db::name('user_bind')
            ->where('userid', $userId)
            ->column('playerid');
        
        if (!empty($playerIds)) {
            $orderModel = new \app\model\UserOrder();
            
            // 构建安全查询条件，兼容 JSON 数字/字符串两种 playerid 结构
            $safePlayerIds = [];
            foreach ($playerIds as $pid) {
                $pid = preg_replace('/[^0-9]/', '', (string)$pid);
                if ($pid !== '') {
                    $safePlayerIds[] = $pid;
                }
            }

            if (!empty($safePlayerIds)) {
                $buildStatsCondition = function($q) use ($safePlayerIds) {
                    foreach ($safePlayerIds as $idx => $pid) {
                        $numericPattern = '%"playerid":' . $pid . '%';
                        $stringPattern = '%"playerid":"' . $pid . '"%';

                        if ($idx === 0) {
                            $q->where(function($subQuery) use ($numericPattern, $stringPattern) {
                                $subQuery->whereLike('user', $numericPattern)
                                    ->whereOr('user', 'like', $stringPattern);
                            });
                        } else {
                            $q->whereOr(function($subQuery) use ($numericPattern, $stringPattern) {
                                $subQuery->whereLike('user', $numericPattern)
                                    ->whereOr('user', 'like', $stringPattern);
                            });
                        }
                    }
                };

                $stats['total_orders'] = $orderModel->where($buildStatsCondition)->count();
                $stats['total_amount'] = $orderModel->where($buildStatsCondition)
                    ->where('status', 1)
                    ->sum('realmoney');
            }
        }
        
        // 获取角色数量
        $stats['role_count'] = count($this->getPlayerRoles($userId));
        
        // 获取登录次数
        $loginLogModel = new PlayerLoginLog();
        $stats['login_count'] = $loginLogModel->countByUserId($userId);
        
        return $stats;
    }
    
    /**
     * 清除玩家缓存
     * @param int $userId 用户ID
     */
    public function clearPlayerCache($userId)
    {
        if (empty($userId) || $userId <= 0) {
            return;
        }
        
        // 清除角色缓存
        Cache::delete('player_roles:' . $userId);
        
        // 清除其他相关缓存
        Cache::delete('player_info:' . $userId);
    }
}

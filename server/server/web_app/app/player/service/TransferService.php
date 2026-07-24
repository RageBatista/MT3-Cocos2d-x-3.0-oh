<?php
namespace app\player\service;

use app\model\Transfer as TransferModel;
use app\model\Server;
use app\model\Bind;
use app\model\User;
use think\facade\Log;

/**
 * 转区服务类
 * 
 * @package app\player\service
 */
class TransferService
{
    /**
     * 验证转区申请数据
     *
     * @param array $player 玩家信息
     * @param array $data 提交的数据
     * @return array 错误信息数组
     */
    public function validateTransferData(array $player, array $data): array
    {
        $errors = [];
        
        if (empty($data['source_server_id'])) {
            $errors[] = '请选择源服务器';
        }
        
        if (empty($data['target_server_id'])) {
            $errors[] = '请选择目标服务器';
        }
        
        if (!empty($data['source_server_id']) && !empty($data['target_server_id']) 
            && $data['source_server_id'] == $data['target_server_id']) {
            $errors[] = '源服务器和目标服务器不能相同';
        }
        
        if (empty($data['role_id'])) {
            $errors[] = '请选择要转区的角色';
        }
        
        if (empty($data['contact'])) {
            $errors[] = '请填写联系方式';
        }
        
        if (empty($data['reason']) || strlen($data['reason']) < 10) {
            $errors[] = '转区原因至少需要10个字符';
        }
        
        return $errors;
    }
    
    /**
     * 检查服务器是否开放转区
     *
     * @param int $serverId 服务器ID
     * @return bool
     */
    public function isServerOpenForTransfer(int $serverId): bool
    {
        try {
            $server = Server::find($serverId);
            if (!$server) {
                return false;
            }
            
            $serverData = $server->toArray();
            
            if (isset($serverData['allow_transfer'])) {
                return $serverData['allow_transfer'] == 1;
            }
            
            return true;
        } catch (\Exception $e) {
            Log::error('检查服务器转区状态失败: ' . $e->getMessage(), [
                'server_id' => $serverId,
                'trace' => $e->getTraceAsString()
            ]);
            return true;
        }
    }
    
    /**
     * 检查角色是否可以转区
     *
     * @param int $roleId 角色ID
     * @param int $serverId 服务器ID
     * @param int|null $userId 用户ID（可选，用于旧系统互锁校验）
     * @return array 返回数组包含以下键：
     *               - success: bool 是否可以转区
     *               - message: string 提示信息
     *               - role: array|null 角色信息（成功时返回）
     */
    public function canRoleTransfer(int $roleId, int $serverId, ?int $userId = null): array
    {
        try {
            $role = Bind::where('playerid', $roleId)
                ->where('serverid', $serverId)
                ->find();
            
            if (!$role) {
                return ['success' => false, 'message' => '角色不存在'];
            }
            
            $roleData = $role->toArray();

            // 【互锁检查】旧系统是否已标记该角色为"已转区"
            if (isset($roleData['zhuanqu']) && $roleData['zhuanqu'] == 1) {
                return ['success' => false, 'message' => '该角色已在旧系统中完成过转区，不可重复申请'];
            }
            
            // 【互锁检查】旧系统是否已封禁该用户在该区的操作
            if ($userId) {
                $user = User::where('id', $userId)->find();
                if ($user && !empty($user['bidserver'])) {
                    $bidServers = json_decode($user['bidserver'], true);
                    if (is_array($bidServers) && in_array($serverId, $bidServers)) {
                        return ['success' => false, 'message' => '该角色所在区服已被旧系统标记为已转区'];
                    }
                }
            }
            
            if ($userId && isset($roleData['userid']) && intval($roleData['userid']) !== intval($userId)) {
                return ['success' => false, 'message' => '该角色不属于您'];
            }
            
            $rules = $this->getTransferRules();
            
            if (isset($roleData['level']) && $rules['min_level'] > 0) {
                if ($roleData['level'] < $rules['min_level']) {
                    return ['success' => false, 'message' => '角色等级不足' . $rules['min_level'] . '级，无法转区'];
                }
            }
            
            if ($userId && $rules['max_transfer_per_month'] > 0) {
                $monthlyCount = TransferModel::where('uid', $userId)
                    ->where('type', TransferModel::TYPE_TRANSFER)
                    ->where('status', '<>', TransferModel::STATUS_REJECTED)
                    ->whereTime('created_at', 'month')
                    ->count();
                
                if ($monthlyCount >= $rules['max_transfer_per_month']) {
                    return ['success' => false, 'message' => '本月转区次数已达上限（' . $rules['max_transfer_per_month'] . '次）'];
                }
            }
            
            if ($userId && $rules['cooldown_days'] > 0) {
                $lastTransfer = TransferModel::where('uid', $userId)
                    ->where('type', TransferModel::TYPE_TRANSFER)
                    ->where('status', TransferModel::STATUS_COMPLETED)
                    ->order('created_at', 'desc')
                    ->find();
                
                if ($lastTransfer) {
                    $lastTime = strtotime($lastTransfer->created_at);
                    $cooldownEnd = $lastTime + ($rules['cooldown_days'] * 86400);
                    
                    if (time() < $cooldownEnd) {
                        $remainingDays = ceil(($cooldownEnd - time()) / 86400);
                        return ['success' => false, 'message' => '转区冷却中，还需等待' . $remainingDays . '天'];
                    }
                }
            }
            
            return ['success' => true, 'role' => $roleData];
            
        } catch (\Exception $e) {
            Log::error('检查角色转区资格失败: ' . $e->getMessage(), [
                'role_id' => $roleId,
                'server_id' => $serverId,
                'user_id' => $userId,
                'trace' => $e->getTraceAsString()
            ]);
            return ['success' => false, 'message' => '系统错误，请稍后重试'];
        }
    }
    
    /**
     * 获取转区规则配置
     * 
     * @return array
     */
    public function getTransferRules(): array
    {
        $defaultRules = [
            'min_level' => 0,
            'min_recharge' => 0,
            'max_transfer_per_month' => 0,
            'cooldown_days' => 0
        ];
        
        try {
            $config = config('transfer.rules');
            if (is_array($config)) {
                return array_merge($defaultRules, $config);
            }
        } catch (\Exception $e) {
            Log::error('获取转区规则配置失败: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);
        }
        
        return $defaultRules;
    }
    
    /**
     * 获取可转区的服务器列表
     * 
     * @return array
     */
    public function getAvailableServers(): array
    {
        try {
            $server = new Server();
            $result = $server->where('status', 1)
                ->order('id', 'asc')
                ->select();
            
            if ($result) {
                return $result->toArray();
            }
        } catch (\Exception $e) {
            Log::error('获取可转区服务器列表失败: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);
        }
        
        return [];
    }
    
    /**
     * 获取玩家在指定服务器的角色列表
     * 
     * @param int $playerId 玩家ID
     * @param int $serverId 服务器ID
     * @return array
     */
    public function getPlayerRolesByServer(int $playerId, int $serverId): array
    {
        try {
            $roles = Bind::where('userid', $playerId)
                ->where('serverid', $serverId)
                ->order('playerid', 'asc')
                ->select();
            
            if ($roles) {
                return $roles->toArray();
            }
        } catch (\Exception $e) {
            Log::error('获取玩家角色列表失败: ' . $e->getMessage(), [
                'player_id' => $playerId,
                'server_id' => $serverId,
                'trace' => $e->getTraceAsString()
            ]);
        }
        
        return [];
    }
}

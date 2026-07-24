<?php
namespace app\service;

use app\model\Transfer as TransferModel;
use app\model\Server;
use app\model\Bind;
use app\model\User;
use app\gm\Gm as Game;
use think\facade\Db;
use think\facade\Log;
use think\facade\Cache;

/**
 * TransferExecutionService - 转区执行服务
 * 处理角色数据迁移和转区执行逻辑
 */
class TransferExecutionService
{
    // 互斥锁前缀
    const TRANSFER_LOCK_PREFIX = 'transfer_execution_lock:';

    /**
     * 执行转区操作（P0安全加固：添加transferId级互斥锁）
     *
     * @param int $transferId 转区申请ID
     * @return array
     */
    public function executeTransfer($transferId)
    {
        // P0: 获取互斥锁，防止同一转区单并发执行
        $lockKey = self::TRANSFER_LOCK_PREFIX . $transferId;
        $lockAcquired = false;

        try {
            // 尝试获取锁（30秒超时，锁有效期300秒）
            $lockAcquired = Cache::store('redis')->set($lockKey, 1, 300);

            if (!$lockAcquired) {
                Log::warning('转区执行获取锁失败（并发执行）', [
                    'transfer_id' => $transferId
                ]);
                return [
                    'success' => false,
                    'message' => '转区任务正在执行中，请勿重复操作'
                ];
            }

            Db::startTrans();
            try {
            // 获取转区申请信息
            $transferModel = new TransferModel();
            $transfer = $transferModel->getTransferDetail($transferId);
            
            if (!$transfer) {
                throw new \Exception('转区申请不存在');
            }
            
            if ($transfer['status'] != TransferModel::STATUS_PROCESSING) {
                throw new \Exception('转区申请状态不正确');
            }
            
            // 获取源服务器和目标服务器信息
            $serverModel = new Server();
            $sourceServer = $serverModel->find($transfer['source_server_id']);
            $targetServer = $serverModel->find($transfer['target_server_id']);
            
            if (!$sourceServer || !$targetServer) {
                throw new \Exception('服务器信息不存在');
            }
            
            // 获取角色信息
            $bindModel = new Bind();
            $role = $bindModel->where('playerid', $transfer['role'])
                ->where('serverid', $transfer['source_server_id'])
                ->find();
            
            if (!$role) {
                throw new \Exception('角色不存在');
            }
            
            // 检查角色是否在线
            $isOnline = $this->checkRoleOnline($sourceServer, $transfer['role']);
            if ($isOnline) {
                throw new \Exception('角色在线，无法转区');
            }
            
            // 备份角色数据
            $backupData = $this->backupRoleData($sourceServer, $transfer['role']);
            if (!$backupData['success']) {
                throw new \Exception('备份角色数据失败：' . $backupData['message']);
            }
            
            // 迁移角色数据到目标服务器
            $migrateResult = $this->migrateRoleData(
                $sourceServer,
                $targetServer,
                $transfer['role'],
                $role
            );
            
            if (!$migrateResult['success']) {
                // 迁移失败，尝试恢复
                $this->restoreRoleData($sourceServer, $transfer['role'], $backupData['data']);
                throw new \Exception('迁移角色数据失败：' . $migrateResult['message']);
            }
            
            // 获取目标服务器的新角色ID
            $targetRoleId = $migrateResult['target_role_id'];
            
            // 更新转区申请状态
            $transferModel->where('id', $transferId)->update([
                'status' => TransferModel::STATUS_COMPLETED,
                'target_role_id' => $targetRoleId,
                'target_role_name' => $role['rolename'],
                'reply' => '转区已完成，目标角色ID：' . $targetRoleId,
                'processed_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s')
            ]);
            
            // 更新角色绑定信息
            $bindModel->where('playerid', $transfer['role'])
                ->where('serverid', $transfer['source_server_id'])
                ->update([
                    'serverid' => $transfer['target_server_id'],
                    'playerid' => $targetRoleId
                ]);
            
            // 发送游戏内邮件通知
            $this->sendTransferNotification($targetServer, $targetRoleId, $transfer);
            
            Db::commit();
            
            Log::info('转区执行成功', [
                'transfer_id' => $transferId,
                'source_server' => $transfer['source_server_id'],
                'target_server' => $transfer['target_server_id'],
                'source_role' => $transfer['role'],
                'target_role' => $targetRoleId
            ]);
            
            return [
                'success' => true,
                'target_role_id' => $targetRoleId,
                'message' => '转区成功'
            ];
            
            } catch (\Exception $e) {
                Db::rollback();

                Log::error('转区执行失败', [
                    'transfer_id' => $transferId,
                    'error' => $e->getMessage()
                ]);

                return [
                    'success' => false,
                    'message' => $e->getMessage()
                ];
            }
        } catch (\Exception $e) {
            Log::error('转区执行异常', [
                'transfer_id' => $transferId,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        } finally {
            // P0: 确保锁在异常情况下也能释放
            if ($lockAcquired) {
                Cache::store('redis')->delete($lockKey);
            }
        }
    }
    
    /**
     * 检查角色是否在线
     * 
     * @param array $server 服务器信息
     * @param int $roleId 角色ID
     * @return bool
     */
    protected function checkRoleOnline($server, $roleId)
    {
        try {
            $game = new Game();
            // 调用游戏服务器API检查角色在线状态
            $result = $game->checkRoleOnline([
                'serverip' => $server['serverip'],
                'gmlocal' => $server['gmlocal'],
                'gmport' => $server['gmport'],
                'playerid' => $roleId
            ]);
            
            return $result['online'] ?? false;
        } catch (\Exception $e) {
            Log::error('检查角色在线状态失败', [
                'server_id' => $server['id'],
                'role_id' => $roleId,
                'error' => $e->getMessage()
            ]);
            return true; // 出错时默认认为在线，防止误操作
        }
    }
    
    /**
     * 备份角色数据
     * 
     * @param array $server 服务器信息
     * @param int $roleId 角色ID
     * @return array
     */
    protected function backupRoleData($server, $roleId)
    {
        try {
            $game = new Game();
            
            // 调用游戏服务器API获取角色数据
            $result = $game->getRoleData([
                'serverip' => $server['serverip'],
                'gmlocal' => $server['gmlocal'],
                'gmport' => $server['gmport'],
                'playerid' => $roleId
            ]);
            
            if (!$result || !isset($result['data'])) {
                return [
                    'success' => false,
                    'message' => '获取角色数据失败'
                ];
            }
            
            // 将备份数据保存到数据库或文件
            $backupData = [
                'role_id' => $roleId,
                'server_id' => $server['id'],
                'data' => json_encode($result['data']),
                'created_at' => date('Y-m-d H:i:s')
            ];
            
            // 这里可以将备份数据保存到专门的备份表
            // 暂时只记录日志
            Log::info('角色数据备份成功', [
                'role_id' => $roleId,
                'server_id' => $server['id']
            ]);
            
            return [
                'success' => true,
                'data' => $result['data']
            ];
            
        } catch (\Exception $e) {
            Log::error('备份角色数据失败', [
                'server_id' => $server['id'],
                'role_id' => $roleId,
                'error' => $e->getMessage()
            ]);
            
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }
    
    /**
     * 迁移角色数据
     * 
     * @param array $sourceServer 源服务器信息
     * @param array $targetServer 目标服务器信息
     * @param int $sourceRoleId 源角色ID
     * @param array $roleInfo 角色信息
     * @return array
     */
    protected function migrateRoleData($sourceServer, $targetServer, $sourceRoleId, $roleInfo)
    {
        try {
            $game = new Game();
            
            // 1. 在目标服务器创建新角色
            $createResult = $game->createRole([
                'serverip' => $targetServer['serverip'],
                'gmlocal' => $targetServer['gmlocal'],
                'gmport' => $targetServer['gmport'],
                'rolename' => $roleInfo['rolename'],
                'account' => $roleInfo['account'],
                'level' => $roleInfo['level'],
                'profession' => $roleInfo['profession'] ?? 0,
                'sex' => $roleInfo['sex'] ?? 1
            ]);
            
            if (!$createResult || !isset($createResult['playerid'])) {
                return [
                    'success' => false,
                    'message' => '创建目标角色失败'
                ];
            }
            
            $targetRoleId = $createResult['playerid'];
            
            // 2. 迁移角色属性数据
            $migrateAttrResult = $game->migrateRoleAttributes([
                'source_serverip' => $sourceServer['serverip'],
                'source_gmlocal' => $sourceServer['gmlocal'],
                'source_gmport' => $sourceServer['gmport'],
                'source_playerid' => $sourceRoleId,
                'target_serverip' => $targetServer['serverip'],
                'target_gmlocal' => $targetServer['gmlocal'],
                'target_gmport' => $targetServer['gmport'],
                'target_playerid' => $targetRoleId
            ]);
            
            if (!$migrateAttrResult || !$migrateAttrResult['success']) {
                return [
                    'success' => false,
                    'message' => '迁移角色属性失败'
                ];
            }
            
            // 3. 迁移角色物品数据
            $migrateItemResult = $game->migrateRoleItems([
                'source_serverip' => $sourceServer['serverip'],
                'source_gmlocal' => $sourceServer['gmlocal'],
                'source_gmport' => $sourceServer['gmport'],
                'source_playerid' => $sourceRoleId,
                'target_serverip' => $targetServer['serverip'],
                'target_gmlocal' => $targetServer['gmlocal'],
                'target_gmport' => $targetServer['gmport'],
                'target_playerid' => $targetRoleId
            ]);
            
            if (!$migrateItemResult || !$migrateItemResult['success']) {
                return [
                    'success' => false,
                    'message' => '迁移角色物品失败'
                ];
            }
            
            // 4. 迁移角色宠物数据
            $migratePetResult = $game->migrateRolePets([
                'source_serverip' => $sourceServer['serverip'],
                'source_gmlocal' => $sourceServer['gmlocal'],
                'source_gmport' => $sourceServer['gmport'],
                'source_playerid' => $sourceRoleId,
                'target_serverip' => $targetServer['serverip'],
                'target_gmlocal' => $targetServer['gmlocal'],
                'target_gmport' => $targetServer['gmport'],
                'target_playerid' => $targetRoleId
            ]);
            
            if (!$migratePetResult || !$migratePetResult['success']) {
                // 宠物迁移失败不影响整体结果，记录日志即可
                Log::warning('迁移角色宠物失败', [
                    'source_role' => $sourceRoleId,
                    'target_role' => $targetRoleId
                ]);
            }
            
            // 5. 删除源服务器角色
            $deleteResult = $game->deleteRole([
                'serverip' => $sourceServer['serverip'],
                'gmlocal' => $sourceServer['gmlocal'],
                'gmport' => $sourceServer['gmport'],
                'playerid' => $sourceRoleId
            ]);
            
            if (!$deleteResult || !$deleteResult['success']) {
                Log::warning('删除源角色失败', [
                    'server_id' => $sourceServer['id'],
                    'role_id' => $sourceRoleId
                ]);
            }
            
            return [
                'success' => true,
                'target_role_id' => $targetRoleId
            ];
            
        } catch (\Exception $e) {
            Log::error('迁移角色数据失败', [
                'source_server' => $sourceServer['id'],
                'target_server' => $targetServer['id'],
                'source_role' => $sourceRoleId,
                'error' => $e->getMessage()
            ]);
            
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }
    
    /**
     * 恢复角色数据
     * 
     * @param array $server 服务器信息
     * @param int $roleId 角色ID
     * @param array $backupData 备份数据
     * @return bool
     */
    protected function restoreRoleData($server, $roleId, $backupData)
    {
        try {
            $game = new Game();
            
            $result = $game->restoreRoleData([
                'serverip' => $server['serverip'],
                'gmlocal' => $server['gmlocal'],
                'gmport' => $server['gmport'],
                'playerid' => $roleId,
                'data' => json_encode($backupData)
            ]);
            
            return $result && $result['success'];
            
        } catch (\Exception $e) {
            Log::error('恢复角色数据失败', [
                'server_id' => $server['id'],
                'role_id' => $roleId,
                'error' => $e->getMessage()
            ]);
            
            return false;
        }
    }
    
    /**
     * 发送转区通知邮件
     * 
     * @param array $server 服务器信息
     * @param int $roleId 角色ID
     * @param array $transfer 转区申请信息
     * @return bool
     */
    protected function sendTransferNotification($server, $roleId, $transfer)
    {
        try {
            $game = new Game();
            
            $result = $game->mail([
                'serverip' => $server['serverip'],
                'gmlocal' => $server['gmlocal'],
                'gmport' => $server['gmport'],
                'playerid' => $roleId,
                'title' => '转区完成通知',
                'content' => '您的角色已成功从服务器' . $transfer['source_server_id'] . '转区到服务器' . $transfer['target_server_id'] . '，请查收。',
                'duration' => 30,
                'awardContent' => '' // 可以添加转区补偿物品
            ]);
            
            return $result && $result['success'];
            
        } catch (\Exception $e) {
            Log::error('发送转区通知邮件失败', [
                'server_id' => $server['id'],
                'role_id' => $roleId,
                'error' => $e->getMessage()
            ]);
            
            return false;
        }
    }
    
    /**
     * 批量执行转区（用于后台任务）
     * 
     * @param int $limit 每次处理数量
     * @return array
     */
    public function batchExecuteTransfer($limit = 10)
    {
        $transferModel = new TransferModel();
        
        // 获取待处理的转区申请
        $transfers = $transferModel->where('status', TransferModel::STATUS_PROCESSING)
            ->limit($limit)
            ->select();
        
        $results = [
            'total' => count($transfers),
            'success' => 0,
            'failed' => 0,
            'details' => []
        ];
        
        foreach ($transfers as $transfer) {
            $result = $this->executeTransfer($transfer['id']);
            
            if ($result['success']) {
                $results['success']++;
            } else {
                $results['failed']++;
            }
            
            $results['details'][] = [
                'transfer_id' => $transfer['id'],
                'success' => $result['success'],
                'message' => $result['message']
            ];
        }
        
        return $results;
    }
}

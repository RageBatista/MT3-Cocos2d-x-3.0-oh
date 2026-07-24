<?php
namespace app\model;

use think\Model;
use think\facade\Db;
use think\facade\Cache;

/**
 * 转区申请模型
 *
 * @package app\model
 */
class Transfer extends Model
{
    protected $table = 'user_transfer';
    
    protected $autoWriteTimestamp = 'datetime';
    
    protected $createTime = 'created_at';
    protected $updateTime = 'updated_at';
    
    protected $type = [
        'id' => 'integer',
        'uid' => 'integer',
        'role' => 'integer',
        'source_server_id' => 'integer',
        'target_server_id' => 'integer',
        'target_role_id' => 'integer',
        'type' => 'integer',
        'status' => 'integer',
        'admin_id' => 'integer'
    ];
    
    const TYPE_FEEDBACK = 1;
    const TYPE_TRANSFER = 2;
    
    const STATUS_PENDING = 0;
    const STATUS_APPROVED = 1;
    const STATUS_REJECTED = 2;
    const STATUS_PROCESSING = 3;
    const STATUS_COMPLETED = 4;
    
    // ===== P1-B: 合法状态迁移表 =====
    const STATUS_TRANSITIONS = [
        self::STATUS_PENDING => [
            self::STATUS_APPROVED,    // 待审核 -> 审核通过
            self::STATUS_REJECTED     // 待审核 -> 审核拒绝
        ],
        self::STATUS_APPROVED => [
            self::STATUS_PROCESSING,  // 审核通过 -> 处理中
            self::STATUS_REJECTED      // 审核通过 -> 审核拒绝（撤销）
        ],
        self::STATUS_REJECTED => [
            // 审核拒绝不允许再变更
        ],
        self::STATUS_PROCESSING => [
            self::STATUS_COMPLETED    // 处理中 -> 已完成
        ],
        self::STATUS_COMPLETED => [
            // 已完成不允许再变更
        ]
    ];
    
    /**
     * 创建转区申请
     * 
     * @param array $data 转区申请数据
     * @return bool
     */
    public function createTransfer($data)
    {
        $insertData = [
            'uid' => $data['uid'] ?? 0,
            'username' => $data['username'] ?? '',
            'source_server_id' => $data['source_server_id'] ?? 0,
            'target_server_id' => $data['target_server_id'] ?? 0,
            'role' => $data['role'] ?? 0,
            'contact' => $data['contact'] ?? '',
            'reason' => $data['info'] ?? ($data['reason'] ?? ''),
            'type' => self::TYPE_TRANSFER,
            'status' => self::STATUS_PENDING,
            'created_at' => date('Y-m-d H:i:s'),
            'updated_at' => date('Y-m-d H:i:s')
        ];
        
        if (isset($data['time'])) {
            $insertData['created_at'] = $data['time'];
        }
        
        return $this->save($insertData);
    }
    
    /**
     * 获取用户的转区申请列表
     * 
     * @param int $uid 用户ID
     * @param int $page 页码
     * @param int $limit 每页数量
     * @return array
     */
    public function getUserTransfers($uid, $page = 1, $limit = 20)
    {
        try {
            $result = $this->where('uid', $uid)
                ->where('type', self::TYPE_TRANSFER)
                ->order('id', 'desc')
                ->page($page, $limit)
                ->select();
            
            if ($result) {
                return $result->toArray();
            }
        } catch (\Exception $e) {
        }
        
        return [];
    }
    
    /**
     * 获取转区申请详情
     * 
     * @param int $id 申请ID
     * @return array|null
     */
    public function getTransferDetail($id)
    {
        try {
            $result = $this->where('id', $id)
                ->where('type', self::TYPE_TRANSFER)
                ->find();
            
            if ($result) {
                return $result->toArray();
            }
        } catch (\Exception $e) {
        }
        
        return null;
    }
    
    /**
     * 更新转区状态（P1-B: 状态机校验 + 并发安全）
     *
     * @param int $id 申请ID
     * @param int $status 状态
     * @param int|null $adminId 管理员ID
     * @param string|null $reply 回复内容
     * @return array ['success' => bool, 'message' => string]
     */
    public function updateStatus($id, $status, $adminId = null, $reply = null)
    {
        // 使用分布式锁防止并发修改
        $lockKey = 'transfer_status_lock:' . $id;
        $lockAcquired = Cache::store('redis')->set($lockKey, 1, 30);
        
        if (!$lockAcquired) {
            return [
                'success' => false,
                'message' => '转区状态更新中，请稍后重试'
            ];
        }
        
        try {
            Db::startTrans();
            
            // 查询当前转区申请
            $transfer = $this->where('id', $id)->find();
            if (!$transfer) {
                Db::rollback();
                return [
                    'success' => false,
                    'message' => '转区申请不存在'
                ];
            }
            
            $oldStatus = $transfer->status;
            
            // ===== P1-B: 状态机校验 =====
            if ($oldStatus != $status) {
                if (!isset(self::STATUS_TRANSITIONS[$oldStatus])) {
                    Db::rollback();
                    return [
                        'success' => false,
                        'message' => '当前状态不允许变更'
                    ];
                }
                
                if (!in_array($status, self::STATUS_TRANSITIONS[$oldStatus])) {
                    Db::rollback();
                    return [
                        'success' => false,
                        'message' => '非法的状态迁移：从状态 ' . $oldStatus . ' 到 ' . $status
                    ];
                }
            }
            
            // 构建更新数据
            $data = [
                'status' => $status,
                'updated_at' => date('Y-m-d H:i:s')
            ];
            
            if ($adminId) {
                $data['admin_id'] = $adminId;
            }
            
            if ($reply) {
                $data['reply'] = $reply;
            }
            
            if ($status == self::STATUS_PROCESSING || $status == self::STATUS_COMPLETED) {
                $data['processed_at'] = date('Y-m-d H:i:s');
            }
            
            // ===== P1-B: 并发安全更新（CAS 风格）=====
            $affectedRows = $this->where('id', $id)
                ->where('status', $oldStatus)
                ->update($data);
            
            if ($affectedRows === 0) {
                Db::rollback();
                return [
                    'success' => false,
                    'message' => '转区状态已被修改，请刷新后重试'
                ];
            }
            
            Db::commit();
            
            return [
                'success' => true,
                'message' => '状态更新成功'
            ];
        } catch (\Exception $e) {
            Db::rollback();
            return [
                'success' => false,
                'message' => '状态更新异常：' . $e->getMessage()
            ];
        } finally {
            // 释放锁
            Cache::store('redis')->delete($lockKey);
        }
    }
    
    /**
     * 获取转区申请列表（管理端）
     * 
     * @param int $page 页码
     * @param int $limit 每页数量
     * @param array $filters 过滤条件
     * @return array
     */
    public function getTransferList($page = 1, $limit = 10, $filters = [])
    {
        $query = $this->where('type', self::TYPE_TRANSFER);
        
        if (isset($filters['status']) && $filters['status'] !== '') {
            $query->where('status', intval($filters['status']));
        }
        
        if (!empty($filters['source_server_id'])) {
            $query->where('source_server_id', $filters['source_server_id']);
        }
        
        if (!empty($filters['target_server_id'])) {
            $query->where('target_server_id', $filters['target_server_id']);
        }
        
        if (!empty($filters['keyword'])) {
            $query->where('username|contact', 'like', '%' . $filters['keyword'] . '%');
        }
        
        $total = $query->count();
        $rows = $query->order('id', 'desc')
            ->page($page, $limit)
            ->select();
        
        return [
            'total' => $total,
            'rows' => $rows
        ];
    }
    
    /**
     * 获取状态文本
     * 
     * @param int $status 状态值
     * @return string
     */
    public static function getStatusText($status)
    {
        $statusMap = [
            self::STATUS_PENDING => '待审核',
            self::STATUS_APPROVED => '审核通过',
            self::STATUS_REJECTED => '审核拒绝',
            self::STATUS_PROCESSING => '处理中',
            self::STATUS_COMPLETED => '已完成'
        ];
        return $statusMap[$status] ?? '未知';
    }
    
    /**
     * 获取状态徽章样式
     * 
     * @param int $status 状态值
     * @return string
     */
    public static function getStatusBadge($status)
    {
        $badgeMap = [
            self::STATUS_PENDING => 'badge-secondary',
            self::STATUS_APPROVED => 'badge-success',
            self::STATUS_REJECTED => 'badge-danger',
            self::STATUS_PROCESSING => 'badge-warning',
            self::STATUS_COMPLETED => 'badge-primary'
        ];
        return $badgeMap[$status] ?? 'badge-secondary';
    }
}

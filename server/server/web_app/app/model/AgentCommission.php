<?php
namespace app\model;
use think\Model;

/**
 * 代理佣金明细模型
 * 用于记录每笔订单的佣金分配
 */
class AgentCommission extends Model
{
    protected $table = 'agent_commission';
    
    // 佣金类型常量
    const TYPE_DIRECT_PLAYER = 1;  // 直属玩家70%
    const TYPE_LEVEL_1 = 2;        // 一级下级5%
    const TYPE_LEVEL_2 = 3;        // 二级下级5%
    
    // 状态常量
    const STATUS_PENDING = 0;      // 待结算
    const STATUS_SETTLED = 1;      // 已结算
    const STATUS_CANCELLED = 2;    // 已取消
    
    /**
     * 创建佣金记录
     * @param array $data
     * @return bool
     */
    public function createCommission($data)
    {
        $commission = new AgentCommission();
        foreach ($data as $key => $value) {
            $commission->$key = $value;
        }
        return $commission->save();
    }
    
    /**
     * 根据订单ID获取所有佣金记录
     * @param int $orderId
     * @return array
     */
    public function getByOrderId($orderId)
    {
        $commissions = AgentCommission::where('order_id', $orderId)->select();
        return $commissions ? $commissions->toArray() : [];
    }
    
    /**
     * 获取代理的佣金统计
     * @param int $agentId
     * @param string|null $startDate
     * @param string|null $endDate
     * @return array
     */
    public function getAgentCommissionStats($agentId, $startDate = null, $endDate = null)
    {
        $condition = [['agent_id', '=', $agentId]];
        
        if ($startDate && $endDate) {
            $condition[] = ['order_date', 'between', [$startDate . ' 00:00:00', $endDate . ' 23:59:59']];
        }
        
        // 按类型统计
        $directPlayer = AgentCommission::where($condition)
            ->where('commission_type', self::TYPE_DIRECT_PLAYER)
            ->sum('commission_amount');
            
        $level1 = AgentCommission::where($condition)
            ->where('commission_type', self::TYPE_LEVEL_1)
            ->sum('commission_amount');
            
        $level2 = AgentCommission::where($condition)
            ->where('commission_type', self::TYPE_LEVEL_2)
            ->sum('commission_amount');
        
        $total = $directPlayer + $level1 + $level2;
        
        return [
            'direct_player' => round($directPlayer, 2),
            'level_1' => round($level1, 2),
            'level_2' => round($level2, 2),
            'total' => round($total, 2)
        ];
    }
    
    /**
     * 获取代理指定日期的佣金明细
     * @param int $agentId
     * @param string $date
     * @return array
     */
    public function getAgentDailyCommission($agentId, $date)
    {
        $commissions = AgentCommission::where('agent_id', $agentId)
            ->where('order_date', 'like', $date . '%')
            ->select();
        
        return $commissions ? $commissions->toArray() : [];
    }
    
    /**
     * 获取代理的待结算佣金
     * @param int $agentId
     * @return float
     */
    public function getPendingCommission($agentId)
    {
        $amount = AgentCommission::where([
            ['agent_id', '=', $agentId],
            ['status', '=', self::STATUS_PENDING]
        ])->sum('commission_amount');
        
        return round($amount, 2);
    }
    
    /**
     * 标记佣金为已结算
     * @param int $agentId
     * @param string $settlementDate
     * @return int 影响行数
     */
    public function markAsSettled($agentId, $settlementDate)
    {
        return AgentCommission::where([
            ['agent_id', '=', $agentId],
            ['status', '=', self::STATUS_PENDING]
        ])->update([
            'status' => self::STATUS_SETTLED,
            'settlement_date' => $settlementDate
        ]);
    }
    
    /**
     * 获取佣金列表（分页）
     * @param int $agentId
     * @param array $post
     * @return array
     */
    public function getCommissionList($agentId, $post = [])
    {
        $page = isset($post['page']) ? $post['page'] : 1;
        $limit = isset($post['limit']) ? $post['limit'] : 10;
        $sortOrder = isset($post['sortOrder']) ? $post['sortOrder'] : 'desc';
        $sort = isset($post['sort']) ? $post['sort'] : 'id';
        
        $condition = [['agent_id', '=', $agentId]];
        
        $commissions = AgentCommission::where($condition)
            ->limit($limit)
            ->page($page)
            ->order($sort, $sortOrder)
            ->select();
            
        $total = AgentCommission::where($condition)->count();
        $data = $commissions ? $commissions->toArray() : [];
        
        return [
            'total' => $total,
            'rows' => $data
        ];
    }
    
    /**
     * 获取佣金类型名称
     * @param int $type
     * @return string
     */
    public static function getTypeName($type)
    {
        $names = [
            self::TYPE_DIRECT_PLAYER => '直属玩家(70%)',
            self::TYPE_LEVEL_1 => '一级下级(5%)',
            self::TYPE_LEVEL_2 => '二级下级(5%)'
        ];
        
        return isset($names[$type]) ? $names[$type] : '未知';
    }
    
    /**
     * 获取状态名称
     * @param int $status
     * @return string
     */
    public static function getStatusName($status)
    {
        $names = [
            self::STATUS_PENDING => '待结算',
            self::STATUS_SETTLED => '已结算',
            self::STATUS_CANCELLED => '已取消'
        ];
        
        return isset($names[$status]) ? $names[$status] : '未知';
    }
}


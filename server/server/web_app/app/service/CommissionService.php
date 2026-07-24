<?php
namespace app\service;

use app\model\Agent;
use think\facade\Db;

/**
 * 佣金计算服务（简化版）
 * 直接在代理账户累加金额，不记录详细明细
 */
class CommissionService
{
    /**
     * 订单支付成功后，累加佣金到代理账户 + 记录详细佣金明细
     * @param array $orderData 订单数据
     * @return bool
     */
    public function distributeCommission($orderData)
    {
        $orderAmount = $orderData['realmoney'];
        $orderId = $orderData['orderid'] ?? $orderData['id'] ?? 0;
        $agentInfo = $orderData['agent']; // 格式: "12|["@1@","@5@","@12@"]"
        
        // 解析代理信息
        $agentData = $this->parseAgentInfo($agentInfo);
        if (!$agentData) {
            return false;
        }
        
        $directAgentId = $agentData['direct_agent_id'];
        
        // 获取直属代理信息
        $agentModel = new Agent();
        $directAgent = $agentModel->getById($directAgentId);
        
        if (!$directAgent) {
            return false;
        }
        
        // 1. 直属代理获得 70% 佣金
        $directCommission = round($orderAmount * 0.70, 2);
        Db::table('admin_account')
            ->where('id', $directAgentId)
            ->inc('direct_commission', $directCommission)  // 累加直属玩家提成
            ->inc('total_commission', $directCommission)   // 累加总提成
            ->inc('direct_player_amount', $orderAmount)    // 累加直属玩家流水
            ->update();
        
        // 记录佣金明细到 agent_commission 表
        $this->recordCommission($orderId, $directAgentId, $directCommission, 'direct', $orderAmount);
        
        // 检查是否达到5000元，开通创建下级权限
        $newAmount = Db::table('admin_account')
            ->where('id', $directAgentId)
            ->value('direct_player_amount');
        
        if ($newAmount >= 5000) {
            Db::table('admin_account')
                ->where('id', $directAgentId)
                ->update(['can_create_agent' => 1]);
        }
        
        // 2. 查找一级上级代理
        $level1ParentId = $directAgent['lastagent'];
        if ($level1ParentId && $level1ParentId != 1) {
            $level1Commission = round($orderAmount * 0.05, 2);
            Db::table('admin_account')
                ->where('id', $level1ParentId)
                ->inc('sub_commission', $level1Commission)     // 累加下级代理提成
                ->inc('total_commission', $level1Commission)   // 累加总提成
                ->update();
            
            // 记录佣金明细
            $this->recordCommission($orderId, $level1ParentId, $level1Commission, 'level1', $orderAmount, $directAgentId);
            
            // 3. 查找二级上级代理
            $level1Agent = $agentModel->getById($level1ParentId);
            if ($level1Agent) {
                $level2ParentId = $level1Agent['lastagent'];
                if ($level2ParentId && $level2ParentId != 1) {
                    $level2Commission = round($orderAmount * 0.05, 2);
                    Db::table('admin_account')
                        ->where('id', $level2ParentId)
                        ->inc('sub_commission', $level2Commission)     // 累加下级代理提成
                        ->inc('total_commission', $level2Commission)   // 累加总提成
                        ->update();
                    
                    // 记录佣金明细
                    $this->recordCommission($orderId, $level2ParentId, $level2Commission, 'level2', $orderAmount, $directAgentId);
                }
            }
        }
        
        return true;
    }
    
    /**
     * 记录佣金明细到 agent_commission 表
     * @param string $orderIdStr 订单号字符串
     * @param int $agentId 代理ID
     * @param float $commission 佣金金额
     * @param string $typeStr 佣金类型 (direct=直属玩家, level1=一级下级, level2=二级下级)
     * @param float $orderAmount 订单金额
     * @param int $sourceAgentId 来源代理ID（对于level1和level2）
     * @return bool
     */
    private function recordCommission($orderIdStr, $agentId, $commission, $typeStr, $orderAmount, $sourceAgentId = 0)
    {
        try {
            // 转换类型字符串为数字
            $typeMap = [
                'direct' => 1,  // 直属玩家70%
                'level1' => 2,  // 一级下级5%
                'level2' => 3   // 二级下级5%
            ];
            $commissionType = $typeMap[$typeStr] ?? 1;
            
            // 计算佣金比例
            $rateMap = [
                'direct' => 70.00,
                'level1' => 5.00,
                'level2' => 5.00
            ];
            $commissionRate = $rateMap[$typeStr] ?? 0;
            
            $data = [
                'order_id' => 0,  // 如果有实际的order ID可以传入
                'orderid' => $orderIdStr,  // 订单号
                'agent_id' => $agentId,
                'commission_type' => $commissionType,
                'order_amount' => $orderAmount,
                'commission_rate' => $commissionRate,
                'commission_amount' => $commission,
                'from_agent_id' => $sourceAgentId,
                'from_user_id' => 0,  // 可以后续扩展
                'status' => 1,  // 1=已发放
                'settlement_date' => null,
                'order_date' => date('Y-m-d H:i:s'),
                'created_at' => date('Y-m-d H:i:s')
            ];
            
            Db::table('agent_commission')->insert($data);
            return true;
        } catch (\Exception $e) {
            // 记录失败不影响主流程，但可以记录日志
            // trace('佣金记录失败: ' . $e->getMessage(), 'error');
            return false;
        }
    }
    
    /**
     * 解析订单中的代理信息
     * @param string $agentInfo 格式: "12|["@1@","@5@","@12@"]"
     * @return array|false
     */
    private function parseAgentInfo($agentInfo)
    {
        if (empty($agentInfo)) {
            return false;
        }
        
        // 分割获取直属代理ID和代理树
        $parts = explode('|', $agentInfo);
        if (count($parts) < 1) {
            return false;
        }
        
        $directAgentId = intval($parts[0]);
        $agentTree = isset($parts[1]) ? $parts[1] : null;
        
        return [
            'direct_agent_id' => $directAgentId,
            'agent_tree' => $agentTree
        ];
    }

    /**
     * 统计代理在时间范围内的佣金明细（兼容 AgentRelation::commissionStats 调用）
     * @param int $agentId
     * @param string|null $startDate YYYY-mm-dd
     * @param string|null $endDate YYYY-mm-dd
     * @return array
     */
    public function calculateAgentCommission($agentId, $startDate = null, $endDate = null)
    {
        $agentId = intval($agentId);
        if ($agentId <= 0) {
            return [
                'direct_commission' => 0.0,
                'level1_commission' => 0.0,
                'level2_commission' => 0.0,
                'sub_commission' => 0.0,
                'total_commission' => 0.0,
                'order_count' => 0,
            ];
        }

        try {
            $query = Db::table('agent_commission')->where('agent_id', $agentId);

            if (!empty($startDate)) {
                $query->where('order_date', '>=', $startDate . ' 00:00:00');
            }
            if (!empty($endDate)) {
                $query->where('order_date', '<=', $endDate . ' 23:59:59');
            }

            $rows = $query
                ->field('commission_type, COUNT(*) AS cnt, SUM(commission_amount) AS amount')
                ->group('commission_type')
                ->select()
                ->toArray();

            $direct = 0.0;
            $level1 = 0.0;
            $level2 = 0.0;
            $count = 0;
            foreach ($rows as $row) {
                $type = intval($row['commission_type'] ?? 0);
                $amount = floatval($row['amount'] ?? 0);
                $count += intval($row['cnt'] ?? 0);
                if ($type === 1) {
                    $direct += $amount;
                } elseif ($type === 2) {
                    $level1 += $amount;
                } elseif ($type === 3) {
                    $level2 += $amount;
                }
            }

            return [
                'direct_commission' => round($direct, 2),
                'level1_commission' => round($level1, 2),
                'level2_commission' => round($level2, 2),
                'sub_commission' => round($level1 + $level2, 2),
                'total_commission' => round($direct + $level1 + $level2, 2),
                'order_count' => $count,
            ];
        } catch (\Throwable $e) {
            $fallback = $this->getAgentCommission($agentId);
            return [
                'direct_commission' => floatval($fallback['direct_commission'] ?? 0),
                'level1_commission' => 0.0,
                'level2_commission' => floatval($fallback['sub_commission'] ?? 0),
                'sub_commission' => floatval($fallback['sub_commission'] ?? 0),
                'total_commission' => floatval($fallback['total_commission'] ?? 0),
                'order_count' => 0,
            ];
        }
    }
    
    /**
     * 获取代理的佣金统计（从账户字段读取）
     * @param int $agentId
     * @return array
     */
    public function getAgentCommission($agentId)
    {
        $agent = Db::table('admin_account')
            ->where('id', $agentId)
            ->find();
        
        if (!$agent) {
            return [
                'direct_commission' => 0,
                'sub_commission' => 0,
                'total_commission' => 0,
                'direct_player_amount' => 0,
                'can_create_agent' => false,
                'pending_withdrawal' => 0
            ];
        }
        
        return [
            'direct_commission' => round($agent['direct_commission'] ?? 0, 2),
            'sub_commission' => round($agent['sub_commission'] ?? 0, 2),
            'total_commission' => round($agent['total_commission'] ?? 0, 2),
            'direct_player_amount' => round($agent['direct_player_amount'] ?? 0, 2),
            'can_create_agent' => (bool)($agent['can_create_agent'] ?? 0),
            'pending_withdrawal' => round($agent['pending_withdrawal'] ?? 0, 2)
        ];
    }
    
    /**
     * 检查代理是否可以创建下级
     * @param int $agentId
     * @return array ['can_create' => bool, 'reason' => string, 'current_amount' => float, 'required_amount' => float]
     */
    public function checkCanCreateAgent($agentId)
    {
        $agent = Db::table('admin_account')
            ->where('id', $agentId)
            ->find();
        
        if (!$agent) {
            return [
                'can_create' => false,
                'reason' => '代理不存在',
                'current_amount' => 0,
                'required_amount' => 5000
            ];
        }
        
        $currentAmount = $agent['direct_player_amount'] ?? 0;
        $requiredAmount = 5000;
        
        if ($currentAmount >= $requiredAmount) {
            return [
                'can_create' => true,
                'reason' => '已满足条件',
                'current_amount' => $currentAmount,
                'required_amount' => $requiredAmount
            ];
        } else {
            $diff = $requiredAmount - $currentAmount;
            return [
                'can_create' => false,
                'reason' => "还需要直属玩家充值 {$diff} 元",
                'current_amount' => $currentAmount,
                'required_amount' => $requiredAmount
            ];
        }
    }
}


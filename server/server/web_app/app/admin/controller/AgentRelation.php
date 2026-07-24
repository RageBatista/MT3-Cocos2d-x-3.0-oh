<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use app\model\AgentRelation as AR;
use app\model\Agent as AG;
use app\model\AgentCommission as AC;
use think\facade\Db;

/**
 * 代理关系管理控制器
 */
class AgentRelation extends BaseController
{
    /**
     * 初始化代理关系数据
     * 访问地址：/admin/agentrelation/initRelation
     */
    public function initRelation()
    {
        if ($this->request->isPost()) {
            try {
                require_once app()->getRootPath() . 'database/migrations/init_agent_relation_data.php';
                $result = \database\migrations\InitAgentRelationData::migrate();
                
                return json([
                    'code' => 1,
                    'msg' => '迁移成功',
                    'data' => $result
                ]);
            } catch (\Exception $e) {
                return json([
                    'code' => 0,
                    'msg' => '迁移失败：' . $e->getMessage()
                ]);
            }
        }
        
        // 显示页面
        $agentCount = Db::table('admin_account')->where('type', 2)->count();
        $relationCount = Db::table('agent_relation')->count();
        $canCreateCount = Db::table('agent_relation')->where('can_create_agent', 1)->count();
        
        return view('init', [
            'agentCount' => $agentCount,
            'relationCount' => $relationCount,
            'canCreateCount' => $canCreateCount
        ]);
    }
    
    /**
     * 查看代理关系树
     */
    public function viewTree()
    {
        $agentId = $this->request->param('id', 0);
        
        if (!$agentId) {
            return json(['code' => 0, 'msg' => '参数错误']);
        }
        
        $ar = new AR();
        $stats = $ar->getAgentStats($agentId);
        
        $ag = new AG();
        $agent = $ag->getById($agentId);
        
        return json([
            'code' => 1,
            'data' => [
                'agent' => $agent,
                'stats' => $stats
            ]
        ]);
    }
    
    /**
     * 手动更新代理流水
     */
    public function updateAmount()
    {
        if (!$this->request->isPost()) {
            return json(['code' => 0, 'msg' => '非法请求']);
        }
        
        $agentId = $this->request->post('agent_id', 0);
        
        if (!$agentId) {
            return json(['code' => 0, 'msg' => '参数错误']);
        }
        
        try {
            // 重新计算该代理的直属玩家流水
            $directPlayerAmount = Db::table('user_order')
                ->where('agent', 'like', $agentId . '|%')
                ->where('status', 1)
                ->sum('realmoney');
            
            // 更新
            Db::table('agent_relation')
                ->where('agent_id', $agentId)
                ->update([
                    'direct_player_amount' => $directPlayerAmount,
                    'can_create_agent' => $directPlayerAmount >= 5000 ? 1 : 0
                ]);
            
            return json([
                'code' => 1,
                'msg' => '更新成功',
                'data' => [
                    'amount' => $directPlayerAmount,
                    'can_create' => $directPlayerAmount >= 5000
                ]
            ]);
        } catch (\Exception $e) {
            return json(['code' => 0, 'msg' => '更新失败：' . $e->getMessage()]);
        }
    }
    
    /**
     * 佣金统计
     */
    public function commissionStats()
    {
        $agentId = $this->request->param('id', 0);
        $startDate = $this->request->param('start_date', date('Y-m-01'));
        $endDate = $this->request->param('end_date', date('Y-m-d'));
        
        if (!$agentId) {
            return json(['code' => 0, 'msg' => '参数错误']);
        }
        
        $commissionService = new \app\service\CommissionService();
        $stats = $commissionService->calculateAgentCommission($agentId, $startDate, $endDate);
        
        $ag = new AG();
        $agent = $ag->getById($agentId);
        
        return json([
            'code' => 1,
            'data' => [
                'agent' => $agent,
                'stats' => $stats,
                'start_date' => $startDate,
                'end_date' => $endDate
            ]
        ]);
    }
    
    /**
     * 批量重新计算所有代理流水
     */
    public function recalculateAll()
    {
        if (!$this->request->isPost()) {
            return json(['code' => 0, 'msg' => '非法请求']);
        }
        
        try {
            $agents = Db::table('agent_relation')->select()->toArray();
            $successCount = 0;
            
            foreach ($agents as $agent) {
                $directPlayerAmount = Db::table('user_order')
                    ->where('agent', 'like', $agent['agent_id'] . '|%')
                    ->where('status', 1)
                    ->sum('realmoney');
                
                Db::table('agent_relation')
                    ->where('agent_id', $agent['agent_id'])
                    ->update([
                        'direct_player_amount' => $directPlayerAmount,
                        'can_create_agent' => $directPlayerAmount >= 5000 ? 1 : 0
                    ]);
                
                $successCount++;
            }
            
            return json([
                'code' => 1,
                'msg' => '重新计算完成',
                'data' => ['count' => $successCount]
            ]);
        } catch (\Exception $e) {
            return json(['code' => 0, 'msg' => '计算失败：' . $e->getMessage()]);
        }
    }
}


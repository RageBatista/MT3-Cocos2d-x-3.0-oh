<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use app\model\UserOrder as UO;
use app\model\User as U;
use app\model\Agent as AG;
use app\model\Bind as B;
use app\model\Server;
use think\facade\Db;

/**
 * 模拟支付回调测试页面
 * 用于开发测试，无需真实充值
 */
class TestPay extends BaseController
{
    /**
     * 测试页面
     */
    public function index()
    {
        // 获取所有待支付订单
        $orders = Db::table('user_order')
            ->where('status', 0)
            ->order('id', 'desc')
            ->limit(50)
            ->select()
            ->toArray();
        
        // 获取所有玩家
        $users = Db::table('user_account')
            ->select()
            ->toArray();
        
        // 获取所有代理
        $agents = Db::table('admin_account')
            ->where('type', 2)
            ->select()
            ->toArray();
        
        return view('index', [
            'orders' => $orders,
            'users' => $users,
            'agents' => $agents
        ]);
    }
    
    /**
     * 模拟支付成功回调
     */
    public function callback()
    {
        if (!$this->request->isPost()) {
            return json(['code' => 0, 'msg' => '非法请求']);
        }
        
        $orderId = $this->request->post('order_id', 0);
        
        if (!$orderId) {
            return json(['code' => 0, 'msg' => '订单ID不能为空']);
        }
        
        // 查询订单
        $order = Db::table('user_order')->where('id', $orderId)->find();
        
        if (!$order) {
            return json(['code' => 0, 'msg' => '订单不存在']);
        }
        
        if ($order['status'] == 1) {
            return json(['code' => 0, 'msg' => '订单已支付，请勿重复操作']);
        }
        
        try {
            // 开启事务
            Db::startTrans();
            
            // 1. 更新订单状态
            Db::table('user_order')
                ->where('id', $orderId)
                ->update(['status' => 1]);
            
            // 2. 触发佣金分配（在 UserOrder model 的 upOrderStatus 方法中会自动触发）
            // 这里我们手动触发
            $commissionService = new \app\service\CommissionService();
            $commissionService->distributeCommission($order);
            
            // 提交事务
            Db::commit();
            
            return json([
                'code' => 1,
                'msg' => '支付成功！佣金已分配',
                'data' => [
                    'order_id' => $orderId,
                    'amount' => $order['realmoney']
                ]
            ]);
            
        } catch (\Exception $e) {
            // 回滚事务
            Db::rollback();
            
            return json([
                'code' => 0,
                'msg' => '支付失败：' . $e->getMessage()
            ]);
        }
    }
    
    /**
     * 快速创建测试订单
     */
    public function createOrder()
    {
        if (!$this->request->isPost()) {
            return json(['code' => 0, 'msg' => '非法请求']);
        }
        
        $userId = $this->request->post('user_id', 0);
        $amount = $this->request->post('amount', 0);
        
        if (!$userId || !$amount) {
            return json(['code' => 0, 'msg' => '参数错误']);
        }
        
        // 查询玩家
        $user = Db::table('user_account')->where('id', $userId)->find();
        if (!$user) {
            return json(['code' => 0, 'msg' => '玩家不存在']);
        }
        
        // 查询代理
        $agent = Db::table('admin_account')->where('id', $user['lastagent'])->find();
        if (!$agent) {
            return json(['code' => 0, 'msg' => '代理不存在']);
        }
        
        // 生成订单号
        $orderNo = 'test' . date('YmdHis') . str_pad((string)mt_rand(1, 9999), 4, '0', STR_PAD_LEFT);
        
        // 构造代理链
        $agentTree = $agent['agent_tree'];
        $agentInfo = $agent['id'] . '|' . $agentTree;
        
        // 构造玩家信息
        $userInfo = json_encode([
            'username' => $user['username'],
            'userid' => $user['id']
        ], JSON_UNESCAPED_UNICODE);
        
        // 构造商品信息
        $itemInfo = json_encode([
            'name' => '测试商品',
            'price' => $amount
        ], JSON_UNESCAPED_UNICODE);
        
        try {
            $orderId = Db::table('user_order')->insertGetId([
                'orderid' => $orderNo,
                'agent' => $agentInfo,
                'ordertype' => 1,
                'user' => $userInfo,
                'item' => $itemInfo,
                'channel' => 1,
                'paytype' => 1,
                'realmoney' => $amount,
                'date' => date('Y-m-d H:i:s'),
                'time' => time(),
                'ip' => $this->request->ip(),
                'city' => '测试',
                'status' => 0
            ]);
            
            return json([
                'code' => 1,
                'msg' => '订单创建成功',
                'data' => [
                    'order_id' => $orderId,
                    'order_no' => $orderNo,
                    'amount' => $amount
                ]
            ]);
            
        } catch (\Exception $e) {
            return json([
                'code' => 0,
                'msg' => '订单创建失败：' . $e->getMessage()
            ]);
        }
    }
    
    /**
     * 查看佣金分配情况
     */
    public function viewCommission()
    {
        $orderId = $this->request->param('order_id', 0);
        
        if (!$orderId) {
            return json(['code' => 0, 'msg' => '订单ID不能为空']);
        }
        
        $order = Db::table('user_order')->where('id', $orderId)->find();
        
        if (!$order) {
            return json(['code' => 0, 'msg' => '订单不存在']);
        }
        
        // 解析代理信息
        $agentInfo = explode('|', $order['agent']);
        $directAgentId = intval($agentInfo[0]);
        
        // 获取直属代理
        $directAgent = Db::table('admin_account')->where('id', $directAgentId)->find();
        
        $result = [
            'order' => $order,
            'direct_agent' => $directAgent,
            'level_1_parent' => null,
            'level_2_parent' => null,
            'commission' => []
        ];
        
        if ($directAgent) {
            // 计算直属代理佣金
            $directCommission = round($order['realmoney'] * 0.70, 2);
            $result['commission'][] = [
                'agent_id' => $directAgentId,
                'agent_name' => $directAgent['username'],
                'type' => '直属玩家(70%)',
                'amount' => $directCommission
            ];
            
            // 查找一级上级
            if ($directAgent['lastagent'] && $directAgent['lastagent'] != 1) {
                $level1Parent = Db::table('admin_account')->where('id', $directAgent['lastagent'])->find();
                $result['level_1_parent'] = $level1Parent;
                
                if ($level1Parent) {
                    $level1Commission = round($order['realmoney'] * 0.05, 2);
                    $result['commission'][] = [
                        'agent_id' => $level1Parent['id'],
                        'agent_name' => $level1Parent['username'],
                        'type' => '一级下级(5%)',
                        'amount' => $level1Commission
                    ];
                    
                    // 查找二级上级
                    if ($level1Parent['lastagent'] && $level1Parent['lastagent'] != 1) {
                        $level2Parent = Db::table('admin_account')->where('id', $level1Parent['lastagent'])->find();
                        $result['level_2_parent'] = $level2Parent;
                        
                        if ($level2Parent) {
                            $level2Commission = round($order['realmoney'] * 0.05, 2);
                            $result['commission'][] = [
                                'agent_id' => $level2Parent['id'],
                                'agent_name' => $level2Parent['username'],
                                'type' => '二级下级(5%)',
                                'amount' => $level2Commission
                            ];
                        }
                    }
                }
            }
        }
        
        return json([
            'code' => 1,
            'data' => $result
        ]);
    }
}


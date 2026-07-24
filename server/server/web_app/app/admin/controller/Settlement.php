<?php
namespace app\admin\controller;
use app\BaseController;
use app\model\Agent as AG;
use think\facade\View;
use think\facade\Db;

class Settlement extends BaseController
{
    /**
     * 结算审核列表页面
     */
    public function index()
    {
        return View::fetch();
    }

    /**
     * 获取待结算列表数据（AJAX）
     */
    public function list_table()
    {
        $post = $this->request->post();
        $limit = max(1, min(200, intval($post['limit'] ?? 15)));
        $page = intval($post['page'] ?? 0);
        $offset = intval($post['offset'] ?? 0);
        if ($page <= 0) {
            $page = intval(floor($offset / $limit)) + 1;
        }
        $page = max(1, $page);

        $query = Db::table('admin_account')
            ->where('type', 2)
            ->where('pending_withdrawal', '>', 0);

        if (!empty($post['username'])) {
            $query->whereLike('username', '%' . trim($post['username']) . '%');
        }

        $total = (clone $query)->count();
        $pendingAgents = $query
            ->order('id', 'desc')
            ->limit(($page - 1) * $limit, $limit)
            ->select()
            ->toArray();

        $data = [];
        foreach ($pendingAgents as $agent) {
            // 解析提现信息
            $kefu = $agent['kefu'] ?? '';
            $kefuData = json_decode($kefu, true);
            
            $paymentMethod = [];
            $zfbName = '';
            $zfbAccount = '';
            $usdtAddress = '';
            
            if ($kefuData) {
                $zfbName = $kefuData['zfbname'] ?? '';
                $zfbAccount = $kefuData['zfbzh'] ?? '';
                $usdtAddress = $kefuData['usdt'] ?? '';
                
                if (!empty($zfbName) && !empty($zfbAccount)) {
                    $paymentMethod[] = "支付宝：{$zfbName} ({$zfbAccount})";
                }
                if (!empty($usdtAddress) && $usdtAddress != '暂未设置') {
                    $paymentMethod[] = "USDT：{$usdtAddress}";
                }
            }
            
            $paymentMethodStr = !empty($paymentMethod) ? implode('<br>', $paymentMethod) : '<span class="text-danger">未设置</span>';
            
        $item = [
            'id' => $agent['id'],
            'username' => $agent['username'],
            'pending_withdrawal' => number_format($agent['pending_withdrawal'], 2),
            'direct_commission' => number_format($agent['direct_commission'] ?? 0, 2),
            'sub_commission' => number_format($agent['sub_commission'] ?? 0, 2),
            'payment_method' => $paymentMethodStr,
            'zfb_name' => $zfbName,
            'zfb_account' => $zfbAccount,
            'usdt_address' => $usdtAddress,
            'created_at' => $agent['withdrawal_apply_time'] ?? '-',
        ];
            
            $data[] = $item;
        }

        return json([
            'total' => $total,
            'rows' => $data,
            'page' => $page,
        ]);
    }

    /**
     * 结算审核（支持批量）
     */
    public function settle()
    {
        $post = $this->request->post();
        $agentIds = $post['agent_ids'] ?? '';
        $remark = $post['remark'] ?? '';

        // 验证 CSRF Token
        if (!$this->checkToken($post['csrf_token'] ?? '')) {
            return notify(0, '非法请求：CSRF令牌无效');
        }

        if (empty($agentIds)) {
            return notify(0, '请选择要结算的代理');
        }

        // 转换为数组
        if (is_string($agentIds)) {
            $agentIds = explode(',', $agentIds);
        }
        $agentIds = array_filter(array_map('intval', $agentIds));

        if (empty($agentIds)) {
            return notify(0, '代理ID格式错误');
        }

        // 开启事务
        Db::startTrans();
        try {
            $settledCount = 0;
            $errors = [];

            $agentRows = Db::table('admin_account')
                ->whereIn('id', $agentIds)
                ->field('id,username,pending_withdrawal,direct_commission,sub_commission,kefu,withdrawal_apply_time')
                ->select()
                ->toArray();
            $agentMap = [];
            foreach ($agentRows as $agentRow) {
                $agentMap[intval($agentRow['id'])] = $agentRow;
            }

            $settlementRows = [];
            $clearedAgentIds = [];
            $operationLogs = [];
            $now = date('Y-m-d H:i:s');

            foreach ($agentIds as $agentId) {
                $agent = $agentMap[$agentId] ?? null;

                if (!$agent) {
                    $errors[] = "代理ID {$agentId} 不存在";
                    continue;
                }

                if (floatval($agent['pending_withdrawal']) <= 0) {
                    $errors[] = "代理 {$agent['username']} 没有待审核的提现";
                    continue;
                }

                // 解析提现信息
                $kefuData = json_decode((string)($agent['kefu'] ?? ''), true);
                $paymentMethod = [];
                $zfbName = '';
                $zfbAccount = '';
                $usdtAddress = '';

                if (is_array($kefuData)) {
                    $zfbName = (string)($kefuData['zfbname'] ?? '');
                    $zfbAccount = (string)($kefuData['zfbzh'] ?? '');
                    $usdtAddress = (string)($kefuData['usdt'] ?? '');

                    if ($zfbName !== '' && $zfbAccount !== '') {
                        $paymentMethod[] = "支付宝：{$zfbName}({$zfbAccount})";
                    }
                    if ($usdtAddress !== '' && $usdtAddress !== '暂未设置') {
                        $paymentMethod[] = "USDT：{$usdtAddress}";
                    }
                }

                $paymentMethodStr = !empty($paymentMethod) ? implode(', ', $paymentMethod) : '未设置';

                $settlementRows[] = [
                    'agent_id' => $agent['id'],
                    'agent_username' => $agent['username'],
                    'withdrawal_amount' => $agent['pending_withdrawal'],
                    'direct_commission' => $agent['direct_commission'] ?? 0,
                    'sub_commission' => $agent['sub_commission'] ?? 0,
                    'payment_method' => $paymentMethodStr,
                    'zfb_name' => $zfbName,
                    'zfb_account' => $zfbAccount,
                    'usdt_address' => $usdtAddress,
                    'apply_time' => $agent['withdrawal_apply_time'] ?: $now,
                    'settlement_time' => $now,
                    'settlement_admin' => $this->myAdmin['username'],
                    'settlement_admin_id' => $this->myAdmin['id'],
                    'remark' => $remark,
                    'status' => 1
                ];
                $clearedAgentIds[] = intval($agent['id']);
                $operationLogs[] = "结算提现 - 代理：{$agent['username']}，金额：{$agent['pending_withdrawal']}元，收款方式：{$paymentMethodStr}";
            }

            if (!empty($settlementRows)) {
                Db::table('withdrawal_records')->insertAll($settlementRows);
            }
            if (!empty($clearedAgentIds)) {
                Db::table('admin_account')
                    ->whereIn('id', $clearedAgentIds)
                    ->update([
                        'pending_withdrawal' => 0,
                        'withdrawal_apply_time' => null
                    ]);
                $settledCount = count($clearedAgentIds);
            }

            if (!empty($operationLogs)) {
                $userLog = new \app\model\UserLog();
                foreach ($operationLogs as $logMessage) {
                    $userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
                }
            }

            // 提交事务
            Db::commit();

            $message = "成功结算 {$settledCount} 个代理";
            if (!empty($errors)) {
                $message .= "<br>错误信息：<br>" . implode('<br>', $errors);
            }

            return notify(1, $message);

        } catch (\Exception $e) {
            // 回滚事务
            Db::rollback();
            return notify(0, '结算失败：' . $e->getMessage());
        }
    }

    /**
     * 结算记录列表页面
     */
    public function records()
    {
        return View::fetch();
    }

    /**
     * 获取结算记录列表数据（AJAX）
     */
    public function records_table()
    {
        $post = $this->request->post();
        $page = max(1, intval($post['page'] ?? 1));
        $limit = max(1, min(200, intval($post['limit'] ?? 15)));

        // 搜索条件
        $where = [];
        if (!empty($post['agent_username'])) {
            $where[] = ['agent_username', 'like', '%' . $this->validateInput($post['agent_username']) . '%'];
        }
        if (!empty($post['start_date'])) {
            $where[] = ['settlement_time', '>=', $post['start_date'] . ' 00:00:00'];
        }
        if (!empty($post['end_date'])) {
            $where[] = ['settlement_time', '<=', $post['end_date'] . ' 23:59:59'];
        }

        // 查询总数
        $count = Db::table('withdrawal_records')
            ->where($where)
            ->count();

        // 查询数据
        $records = Db::table('withdrawal_records')
            ->where($where)
            ->order('id', 'desc')
            ->limit(($page - 1) * $limit, $limit)
            ->select()
            ->toArray();

        $data = [];
        foreach ($records as $record) {
            $data[] = [
                'id' => $record['id'],
                'agent_username' => $record['agent_username'],
                'withdrawal_amount' => number_format($record['withdrawal_amount'], 2),
                'direct_commission' => number_format($record['direct_commission'], 2),
                'sub_commission' => number_format($record['sub_commission'], 2),
                'payment_method' => $record['payment_method'] ?? '-',
                'settlement_time' => $record['settlement_time'],
                'settlement_admin' => $record['settlement_admin'] ?? '-',
                'remark' => $record['remark'] ?? '-',
                'status' => $record['status'] == 1 ? '<span class="badge badge-success">已结算</span>' : '<span class="badge badge-danger">已取消</span>'
            ];
        }

        // Bootstrap Table 期望的格式
        return json([
            'total' => $count,
            'rows' => $data
        ]);
    }

    /**
     * 获取统计数据
     */
    public function statistics()
    {
        try {
            // 总结算笔数
            $totalCount = Db::table('withdrawal_records')
                ->where('status', 1)
                ->count();

            // 总结算金额
            $totalAmount = Db::table('withdrawal_records')
                ->where('status', 1)
                ->sum('withdrawal_amount');

            // 今日结算笔数
            $todayCount = Db::table('withdrawal_records')
                ->where('status', 1)
                ->whereDay('settlement_time')
                ->count();

            // 今日结算金额
            $todayAmount = Db::table('withdrawal_records')
                ->where('status', 1)
                ->whereDay('settlement_time')
                ->sum('withdrawal_amount');

            return json([
                'code' => 0,
                'msg' => 'success',
                'data' => [
                    'total_count' => $totalCount,
                    'total_amount' => number_format($totalAmount, 2),
                    'today_count' => $todayCount,
                    'today_amount' => number_format($todayAmount, 2)
                ]
            ]);

        } catch (\Exception $e) {
            return json([
                'code' => 1,
                'msg' => $e->getMessage()
            ]);
        }
    }
}


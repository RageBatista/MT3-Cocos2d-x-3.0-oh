<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use app\model\UserOrder as UO;
use app\model\Agent as AG;
use think\Response;

class Order extends BaseController
{
    public function list()
    {
		$status = $this->request->param('status','all');
        return view('order',['status'=>$status]);
    }
    public function list_table()
    {
		$status = $this->request->param('status','all');
		$post = $this->request->param();
		$table_order = $this->buildOrderFilters($post);
		$order = new UO();
		$getLogList = $order->getOrderList($post,$status,$table_order);
        $rows = $getLogList['rows'] ?? [];

        $agentIds = [];
        foreach ($rows as $row) {
            $agentRaw = (string)($row['agent'] ?? '');
            $parts = explode('|', $agentRaw);
            $agentId = intval($parts[0] ?? 0);
            if ($agentId > 0) {
                $agentIds[$agentId] = $agentId;
            }
        }

        $agentNameMap = [];
        if (!empty($agentIds)) {
            $agents = AG::whereIn('id', array_values($agentIds))
                ->field('id,username')
                ->select()
                ->toArray();
            foreach ($agents as $agent) {
                $agentNameMap[intval($agent['id'])] = $agent['username'];
            }
        }

		foreach($rows as $key=>$val){
            $agentRaw = (string)($val['agent'] ?? '');
            $parts = explode('|', $agentRaw);
            $agentId = intval($parts[0] ?? 0);
			$val['agent_name'] = $agentNameMap[$agentId] ?? 'unknown';
			$getLogList['rows'][$key]=$val;
		}
		
		
        return jsonp($getLogList);
    }

	private function buildOrderFilters(array $data)
	{
		$filters = [];

		$orderid = isset($data['orderid']) ? trim((string)$data['orderid']) : '';
		if ($orderid !== '') {
			$filters[] = ['orderid', 'like', '%' . $this->validateInput($orderid) . '%'];
		}

		$agent = isset($data['agent']) ? trim((string)$data['agent']) : '';
		if ($agent !== '') {
			$getUsername = (new AG())->getUsername($this->validateInput($agent));
			if ($getUsername) {
				$filters[] = ['agent', 'like', '%' . $getUsername['id'] . '|%'];
			}
		}

		$user = isset($data['user']) ? trim((string)$data['user']) : '';
		if ($user !== '') {
			$filters[] = ['user', 'like', '%' . $this->validateInput($user) . '%'];
		}

		return $filters ?: null;
	}
    public function tuikuan()
    {
		// 权限检查：仅超级管理员可执行退款操作
		if(!isset($this->myAdmin['type']) || $this->myAdmin['type'] != 1){
			return notify(0,'权限不足：仅超级管理员可执行退款操作');
		}
		
		$post = $this->request->post();
		if(isset($post['id'])&&$post['id']!=null){
			$id = $post['id'];
			$order = new UO();
			$getOrderById = $order->getOrderById($id);
			if(!$getOrderById){
				return notify(0,'订单不存在！');
			}
			if($getOrderById['status']==0){
				return notify(0,'订单未支付');
			}
			if($getOrderById['status']==0){
				return notify(0,'订单未支付');
			}
			// 验证 CSRF Token
			if (!$this->checkToken($post['csrf_token'] ?? '')) {
				return notify(0, '非法请求：CSRF令牌无效');
			}
			$tuikuan = $order->tuikuan($id);
			
			// 记录退款操作日志
			$userLog = new \app\model\UserLog();
			$orderInfo = is_array($getOrderById) ? $getOrderById : $getOrderById->toArray();
			$logMessage = "退款操作 - 订单ID:{$id}, 订单号:{$orderInfo['orderid']}, 金额:{$orderInfo['realmoney']}, 操作结果:{$tuikuan}";
			$userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
			
			return notify(1,$tuikuan);
		}else{
			return notify(0,'订单信息有误');
		}
    }
}

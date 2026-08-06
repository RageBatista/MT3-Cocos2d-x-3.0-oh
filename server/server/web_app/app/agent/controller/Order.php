<?php
declare (strict_types = 1);

namespace app\agent\controller;

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
		$getLogList = $order->getOrderList($post,$status,$table_order,$this->myAdmin['id']);
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

		foreach ($rows as $key => $val) {
			$agentRaw = (string)($val['agent'] ?? '');
			$parts = explode('|', $agentRaw);
			$agentId = intval($parts[0] ?? 0);
			$val['agent_name'] = $agentNameMap[$agentId] ?? 'unknown';
			$getLogList['rows'][$key] = $val;
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

		$user = isset($data['user']) ? trim((string)$data['user']) : '';
		if ($user !== '') {
			$filters[] = ['user', 'like', '%' . $this->validateInput($user) . '%'];
		}

		return $filters ?: null;
	}
	
}

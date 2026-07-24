<?php
declare (strict_types = 1);

namespace app\agent\controller;

use app\BaseController;
use app\model\UserOrder as UO;
use app\model\Agent as AG;
use think\Response;
use think\facade\Session;

class Order extends BaseController
{
    public function list()
    {
		$status = $this->request->param('status','all');
		$get = $this->request->get();
		$table_order		= null;
		if(isset($get['orderid'])&&isset($get['agent'])&&isset($get['user'])){
			if($get['orderid']!=null){
				$orderid = $this->validateInput($get['orderid']);
				$table_order[] = ['orderid','like','%'.$orderid.'%'];
			}
			if($get['user']!=null){
				$user = $this->validateInput($get['user']);
				$table_order[] = ['user','like','%'.$user.'%'];
			}
			Session::set('table_order', $table_order);
		}else{
			$table_order = null;
			Session::delete('table_order');
		}
        return view('order',['status'=>$status]);
    }
    public function list_table()
    {
		$table_order = Session::get('table_order');
		$status = $this->request->param('status','all');
		$post = $this->request->post();
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
	
}

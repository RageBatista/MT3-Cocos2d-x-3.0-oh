<?php
declare (strict_types = 1);

namespace app\agent\controller;

use app\BaseController;
use app\model\Agent as AG;
use think\facade\Session;
use think\facade\Db;

class Agent extends BaseController
{
    public function list()
    {
		$get = $this->request->get();
		$table_agent = null;
		if(isset($get['username'])&&isset($get['lv'])&&isset($get['invite'])){
			if($get['username']!=null){
				$username = $this->validateInput($get['username']);
				$table_agent[] = ['username','like','%'.$username.'%'];
			}
			if($get['invite']!=null){
				$invite = $this->validateInput($get['invite']);
				$table_agent[] = ['invite','like','%'.$invite.'%'];
			}
			if($get['lv']!=0){
				$lv = intval($get['lv']);
				$table_agent[] = ['lv','=',$lv];
			}
			Session::set('table_agent', $table_agent);
		}else{
			$table_agent = null;
			Session::delete('table_agent');
		}
        return view('list');
    }
    public function list_table()
    {
	$table_agent = Session::get('table_agent');
	$table_agent[] = ['agent_tree','like','%@'.$this->myAdmin['id'].'@%'];
	$post = $this->request->post();
	$AG = new AG();
	$day = [
		'today'=>date("Y-m-d"),
		'lastday'=>date("Y-m-d",strtotime("-1 day"))
	];
	
	// ===== 新佣金计算服务 =====
	
	$getAgentList = $AG->getAgentList($post,$table_agent);
	$rows = $getAgentList['rows'] ?? [];
	$parentIds = [];
	foreach ($rows as $row) {
		$parentId = intval($row['lastagent'] ?? 0);
		if ($parentId > 0) {
			$parentIds[$parentId] = $parentId;
		}
	}

	$parentNameMap = [];
	if (!empty($parentIds)) {
		$parentRows = AG::whereIn('id', array_values($parentIds))
			->field('id,username')
			->select()
			->toArray();
		foreach ($parentRows as $parentRow) {
			$parentNameMap[intval($parentRow['id'])] = $parentRow['username'];
		}
	}

	$agentIdMap = [];
	foreach ($rows as $row) {
		$agentId = intval($row['id'] ?? 0);
		if ($agentId > 0) {
			$agentIdMap[$agentId] = $agentId;
		}
	}
	$agentIdList = array_values($agentIdMap);
	$totalMoneyMap = $this->batchOrderMoney($agentIdList, true);
	$directMoneyMap = $this->batchOrderMoney($agentIdList, false);
	$directUserCountMap = $this->batchUserCount($agentIdList, false);
	$totalUserCountMap = $this->batchUserCount($agentIdList, true);

	foreach($rows as $key=>$val){
		$parentId = intval($val['lastagent'] ?? 0);
		$val['last_username'] = $parentNameMap[$parentId] ?? 'unknown';
		
		// 使用新的佣金统计（从账户字段读取）
		$commission = [
			'direct_commission' => round(floatval($val['direct_commission'] ?? 0), 2),
			'sub_commission' => round(floatval($val['sub_commission'] ?? 0), 2),
			'total_commission' => round(floatval($val['total_commission'] ?? 0), 2),
			'direct_player_amount' => round(floatval($val['direct_player_amount'] ?? 0), 2),
			'can_create_agent' => intval($val['can_create_agent'] ?? 0) === 1,
			'pending_withdrawal' => round(floatval($val['pending_withdrawal'] ?? 0), 2),
		];
		
		// 流水统计（使用新的佣金字段，更准确）
		$directPlayerAmount = $commission['direct_player_amount'] ?? 0;  // 直属玩家流水
		
		// 下级流水 = 所有流水 - 直属流水
		$agentId = intval($val['id'] ?? 0);
		$money = floatval($totalMoneyMap[$agentId] ?? 0);
		$myMoney = floatval($directMoneyMap[$agentId] ?? 0);
		
		// 如果查询有问题，使用佣金字段计算
		if ($myMoney > 0 && $directPlayerAmount > 0) {
			$myMoney = $directPlayerAmount;  // 使用更准确的直属流水数据
		}
		
		$subMoney = $money > $myMoney ? ($money - $myMoney) : 0;  // 避免负数
		$totalMoney = $myMoney + $subMoney;
		
		// 格式化显示
		$val['all_money'] = '<b>总流水：'.$totalMoney.'元</b><br>'.
			'<small>直属：'.$myMoney.'元 | 下级：'.$subMoney.'元</small>';
			
		// 佣金显示（分开显示直属和下级）
		$val['commission_info'] = '<b>总佣金：'.$commission['total_commission'].'元</b><br>'.
			'<span class="text-success">直属提成：'.$commission['direct_commission'].'元</span><br>'.
			'<span class="text-primary">下级提成：'.$commission['sub_commission'].'元</span>';
		
		$myUserNum = intval($directUserCountMap[$agentId] ?? 0);
		$userNum = intval($totalUserCountMap[$agentId] ?? $myUserNum);
		$subUserNum = $userNum - $myUserNum;           // 下级玩家数 = 总数 - 直属
		$val['user_num'] = '<b>玩家：'.$userNum.'</b><br>'.
			'<small>直属:'.$myUserNum.' | 下级:'.$subUserNum.'</small>';
		
		// 创建下级权限提示
		$canCreate = $commission['can_create_agent'] ? 
			'<span class="badge bg-success">可创建</span>' : 
			'<span class="badge bg-warning">未达标('.number_format($commission['direct_player_amount'], 2).'/5000)</span>';
		$val['create_status'] = $canCreate;
		
		$getAgentList['rows'][$key] = $val;
	}
	
        return jsonp($getAgentList);
    }

	/**
	 * 批量统计代理订单金额
	 * includeSub=true: 匹配代理树 %@id@%
	 * includeSub=false: 仅直属 id|%
	 */
	private function batchOrderMoney(array $agentIds, bool $includeSub): array
	{
		$result = [];
		if (empty($agentIds)) {
			return $result;
		}

		$agentIds = array_values(array_unique(array_filter(array_map('intval', $agentIds))));
		if (empty($agentIds)) {
			return $result;
		}

		foreach ($agentIds as $agentId) {
			$result[$agentId] = 0.0;
		}

		$selectParts = [];
		$bindings = [];
		foreach ($agentIds as $agentId) {
			$alias = 'a_' . $agentId;
			$selectParts[] = 'SUM(CASE WHEN `agent` LIKE ? THEN `realmoney` ELSE 0 END) AS `' . $alias . '`';
			$bindings[] = $includeSub ? ('%@' . $agentId . '@%') : ($agentId . '|%');
		}

		$sql = 'SELECT ' . implode(', ', $selectParts)
			. ' FROM `' . $this->physicalTable('user_order') . '` WHERE `status` = 1';

		$queryRows = Db::query($sql, $bindings);
		$row = $queryRows[0] ?? [];
		foreach ($agentIds as $agentId) {
			$alias = 'a_' . $agentId;
			$result[$agentId] = isset($row[$alias]) ? floatval($row[$alias]) : 0.0;
		}

		return $result;
	}

	/**
	 * 批量统计代理玩家数量
	 * includeSub=true: 直属+下级
	 * includeSub=false: 仅直属
	 */
	private function batchUserCount(array $agentIds, bool $includeSub): array
	{
		$result = [];
		if (empty($agentIds)) {
			return $result;
		}

		$agentIds = array_values(array_unique(array_filter(array_map('intval', $agentIds))));
		if (empty($agentIds)) {
			return $result;
		}

		foreach ($agentIds as $agentId) {
			$result[$agentId] = 0;
		}

		if (!$includeSub) {
			$rows = Db::table($this->physicalTable('user_account'))
				->whereIn('lastagent', $agentIds)
				->field('lastagent, COUNT(*) AS cnt')
				->group('lastagent')
				->select()
				->toArray();

			foreach ($rows as $row) {
				$result[intval($row['lastagent'])] = intval($row['cnt']);
			}
			return $result;
		}

		$selectParts = [];
		$bindings = [];
		foreach ($agentIds as $agentId) {
			$alias = 'a_' . $agentId;
			$selectParts[] = 'SUM(CASE WHEN (`a`.`id` = ? OR `a`.`agent_tree` LIKE ?) THEN 1 ELSE 0 END) AS `' . $alias . '`';
			$bindings[] = $agentId;
			$bindings[] = '%@' . $agentId . '@%';
		}

		$sql = 'SELECT ' . implode(', ', $selectParts)
			. ' FROM `' . $this->physicalTable('user_account') . '` AS `u`'
			. ' INNER JOIN `' . $this->physicalTable('admin_account') . '` AS `a` ON `u`.`lastagent` = `a`.`id`';

		$queryRows = Db::query($sql, $bindings);
		$row = $queryRows[0] ?? [];
		foreach ($agentIds as $agentId) {
			$alias = 'a_' . $agentId;
			$result[$agentId] = isset($row[$alias]) ? intval($row[$alias]) : 0;
		}

		return $result;
	}

	private function physicalTable(string $baseTable): string
	{
		$defaultConn = (string)config('database.default', 'mysql');
		$prefix = (string)config('database.connections.' . $defaultConn . '.prefix', '');
		return $prefix . $baseTable;
	}
    public function add()
    {
        // 检查是否可以创建下级
        $commissionService = new \app\service\CommissionService();
        $checkResult = $commissionService->checkCanCreateAgent($this->myAdmin['id']);
        
        return view('add', [
            'checkResult' => $checkResult
        ]);
    }
    public function addSubmit()
    {
	$AG = new AG();
	$post = $this->request->post();
	$pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
	$pattern_invite = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{4,8}$/';
	
	// ===== 新规则：检查是否满足创建下级的条件 =====
	$commissionService = new \app\service\CommissionService();
	$checkResult = $commissionService->checkCanCreateAgent($this->myAdmin['id']);
	
	if (!$checkResult['can_create']) {
		return notify(0, '您还不满足创建下级代理的条件：' . $checkResult['reason'] . 
			'（当前：' . $checkResult['current_amount'] . '元，需要：' . $checkResult['required_amount'] . '元）');
	}
	// ===== 条件检查通过 =====
	
	if(isset($post['username'])&&$post['username']!=null){
		$username = strtolower($post['username']);
		if(!preg_match($pattern, $username)){
			return notify(0,'账号必须为6-18位字母+数字');
		}
		$getUsername = $AG->getUsername($username);
		if($getUsername){
			return notify(0,'账号已存在');
		}
	}else{
		return notify(0,'账号不能为空');
	}
	if(isset($post['password'])&&$post['password']!=null){
		$password = strtolower($post['password']);
		if(!preg_match($pattern, $password)){
			return notify(0,'密码必须为6-18位字母+数字');
		}
	}else{
		return notify(0,'密码不能为空');
	}
	if(isset($post['invite'])&&$post['invite']!=null){
		$invite = strtolower($post['invite']);
		if(!preg_match($pattern_invite, $invite)){
			return notify(0,'邀请码必须为4-8位字母+数字');
		}
		$getInvite = $AG->getInvite($invite);
		if($getInvite){
			return notify(0,'邀请码已存在');
		}
	}else{
		return notify(0,'邀请码不能为空');
	}
	
	// ===== 新规则：所有代理分成固定为70% =====
	$fencheng = 70;
	
	$status = isset($post['status'])?$post['status']:1;
	$agent_tree = agentTree($this->myAdmin);
	if(!$agent_tree){
		return notify(0,'上级代理选择错误');
	}
	$data = [
		"username"=>$username,
		"password"=>password($password),
		"type"=>2,
		"lastagent"=>$this->myAdmin['id'],
		"lv"=>$this->myAdmin['lv']+1,
		"agent_tree"=>$agent_tree,
		"fencheng"=>$fencheng,  // 固定70%
		"invite"=>$invite,
		"status"=>$status,
	];
	
	$addAgent = $AG->addAgent($data);
	
	// ===== 创建代理关系记录 =====
	$agentRelation = new \app\model\AgentRelation();
	$newAgentId = $AG->getByUsername($username)['id'];
	$agentRelation->createRelation($newAgentId, $this->myAdmin['id']);
	// ===== 关系创建完成 =====
	
	return notify(1,'新增成功');
    }
    public function edit()
    {
		$AG = new AG();
		$get = $this->request->get();
		if(isset($get['id'])){
			$getById = $AG->getById($get['id']);
			if(!$getById){
				 return '代理信息异常<br/><a href="#" onclick="history.back();return false;">返回上一页</a>';
			}
		}
        return view('edit',['getById'=>$getById]);
    }
	
    public function editSubmit()
    {
	// ===== 涓存椂鍏抽棴鏀瑰瘑鍔熻兘 =====
	return notify(0,'系统维护中：改密功能暂时未开启，如需修改请联系系统管理员');
	// ===== 以下代码暂时禁用 =====
	/*
	$AG = new AG();
	$post = $this->request->post();
	$pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
	$pattern_invite = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{4,8}$/';
	
	// ===== 安全修复：防止越权漏洞 =====
	if(isset($post['id'])&&$post['id']!=null){
		$id = $post['id'];
		$getByIdAgent = $AG->getById($id);
		if(!$getByIdAgent){
			return notify(0,'代理信息有误');
		}
		
		// 严格验证：只能修改自己的下级代理
		// 检查目标代理的agent_tree是否包含当前代理ID
		$myAgentTree = $this->myAdmin['id'].',';
		if(strpos($getByIdAgent['agent_tree'], $myAgentTree) === false){
			// 不是下级代理，记录越权尝试
			$userLog = new \app\model\UserLog();
			$logMessage = "越权尝试：试图修改非下级代理 - 当前ID:{$this->myAdmin['id']}, 目标ID:{$id}, IP:{$this->genericVariable['ip']}";
			$userLog->addAgentLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
			return notify(0,'权限不足：只能修改自己的下级代理');
		}
		
		// 验证不能修改管理员账号
		if($getByIdAgent['type'] == 1){
			$userLog = new \app\model\UserLog();
			$logMessage = "越权尝试：试图修改管理员账号 - 目标ID:{$id}, IP:{$this->genericVariable['ip']}";
			$userLog->addAgentLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
			return notify(0,'权限不足：无法修改管理员账号');
		}
	}else{
		return notify(0,'代理信息有误');
	}
		if(isset($post['username'])&&$post['username']!=null){
			$username = strtolower($post['username']);
			if(!preg_match($pattern, $username)){
				return notify(0,'账号必须为6-18位字母+数字');
			}
			$checkAgentId = $AG->checkAgentId($id,$username);
			if($checkAgentId){
				return notify(0,'账号已存在');
			}
		}else{
			return notify(0,'账号不能为空');
		}
		if(isset($post['password'])&&$post['password']!=null){
			$password = strtolower($post['password']);
			if(!preg_match($pattern, $password)){
				return notify(0,'密码必须为6-18位字母+数字');
			}
			$password = password($password);
		}else{
			$password = $getByIdAgent['password'];
		}
		if(isset($post['invite'])&&$post['invite']!=null){
			$invite = strtolower($post['invite']);
			if(!preg_match($pattern_invite, $invite)){
				return notify(0,'邀请码必须为4-8位字母+数字');
			}
			$checkInviteById = $AG->checkInviteById($id,$invite);
			if($checkInviteById){
				return notify(0,'邀请码已存在');
			}
		}else{
			return notify(0,'邀请码不能为空');
		}
		
		// 新规则：固定70%分成
		$fencheng = 70;
		
		$data = [
			"id"=>$id,
			"username"=>$username,
			"password"=>$password,
			"fencheng"=>$fencheng,
			"invite"=>$invite,
		];
	$upAgent = $AG->upAgent($data);
	
	return notify(1,'修改成功');
	*/
	// ===== 改密功能暂时禁用结束 =====
    }
    public function kefu()
    {
		$kefu = $this->myAdmin['kefu'];
		if($kefu != null){
			$kefu = json_decode($kefu,true);
		}else{
			$kefu = [
				'qq'=>123456,
				'group'=>"http://baidu.com",
				'info'=>"暂未设置",
				'zfbname'=>"张三",
				'zfbzh'=>"18888888888",
				'usdt'=>"暂未设置",
			];
		}
        return view('kefu',['kefu'=>$kefu]);
    }
    public function kefuSubmit()
    {
		$post = $this->request->post();
		$kefu = [];
		foreach($post as $key=>$val){
			$kefu[$key]=$val;
		}
		$kefu = json_encode($kefu);
		
		$AG = new AG();
		$upAgentKefu = $AG->upAgentKefu($this->myAdmin['id'],$kefu);
		return notify(1,'修改成功');
    }
}

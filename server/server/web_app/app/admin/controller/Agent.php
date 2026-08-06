<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use app\model\Agent as AG;
use app\model\Agentjs as AGJS;
use app\model\User as U;
use app\model\UserOrder as UO;
use app\model\Config as C;
use think\facade\Db;

class Agent extends BaseController
{
    public function list()
    {
        return view('list');
    }
    public function jiesuanlist()
    {
        return view('jiesuanlist');
    }
    public function list_jiesuan()
    {
            $AGJS = new AGJS();
            $post = $this->request->param();
            $getAgentjsList = $AGJS->getAgentjsList($post, null);

            $rows = $getAgentjsList['rows'] ?? [];
            $uidMap = [];
            foreach ($rows as $row) {
                $uid = intval($row['uid'] ?? 0);
                if ($uid > 0) {
                    $uidMap[$uid] = $uid;
                }
            }

            $agentInfoMap = [];
            if (!empty($uidMap)) {
                $agentRows = AG::whereIn('id', array_values($uidMap))
                    ->field('id,username,kefu')
                    ->select()
                    ->toArray();
                foreach ($agentRows as $agentRow) {
                    $agentInfoMap[intval($agentRow['id'])] = $agentRow;
                }
            }

            foreach ($rows as $key => $val) {
                $uid = intval($val['uid'] ?? 0);
                $agentInfo = $agentInfoMap[$uid] ?? null;
                $val['username'] = $agentInfo['username'] ?? 'unknown';
                if (!$agentInfo || $agentInfo['kefu'] === '') {
                    $val['zfbname'] = '暂未设置';
                    $val['zfbzh'] = '暂未设置';
                    $val['usdt'] = '暂未设置';
                } else {
                    $data = json_decode($agentInfo['kefu'], true);
                    $val['zfbname'] = $data['zfbname'] ?? '暂未设置';
                    $val['zfbzh'] = $data['zfbzh'] ?? '暂未设置';
                    $val['usdt'] = $data['usdt'] ?? '暂未设置';
                }
                $getAgentjsList['rows'][$key] = $val;
            }
            return jsonp($getAgentjsList);

    }
    //{"qq":"123456","group":"http:\/\/baidu.com","info":"\u6682\u672a\u8bbe\u7f6e","zfbname":"\u8d56\u6768","zfbzh":"13980182282","usdt":"TXgNwxFAhpERzbAYLggze7JB9FkdWewaKR"}
    
    
    public function list_table()
    {
        $post = $this->request->param();
        $table_agent = $this->buildAgentFilters($post);
        $AG = new AG();
        $day = [
            'today' => date("Y-m-d"),
            'lastday' => date("Y-m-d", strtotime("-1 day")),
        ];

        $getAgentList = $AG->getAgentList($post, $table_agent);
        $rows = $getAgentList['rows'] ?? [];
        if (empty($rows)) {
            return jsonp($getAgentList);
        }

        $agentIds = [];
        $parentIds = [];
        foreach ($rows as $row) {
            $agentId = intval($row['id'] ?? 0);
            if ($agentId > 0) {
                $agentIds[$agentId] = $agentId;
            }
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

        $agentIdList = array_values($agentIds);
        $totalMoneyMap = $this->batchOrderMoney($agentIdList, true, null);
        $todayTotalMoneyMap = $this->batchOrderMoney($agentIdList, true, $day['today']);
        $lastDayTotalMoneyMap = $this->batchOrderMoney($agentIdList, true, $day['lastday']);
        $directMoneyMap = $this->batchOrderMoney($agentIdList, false, null);
        $todayDirectMoneyMap = $this->batchOrderMoney($agentIdList, false, $day['today']);
        $lastDayDirectMoneyMap = $this->batchOrderMoney($agentIdList, false, $day['lastday']);

        $directUserCountMap = $this->batchUserCount($agentIdList, false);
        $totalUserCountMap = $this->batchUserCount($agentIdList, true);

        foreach ($rows as $key => $val) {
            $agentId = intval($val['id'] ?? 0);
            $parentId = intval($val['lastagent'] ?? 0);
            $val['last_username'] = $parentNameMap[$parentId] ?? 'unknown';

            $directPlayerAmount = floatval($val['direct_player_amount'] ?? 0);
            $money = floatval($totalMoneyMap[$agentId] ?? 0);
            $todayMoney = floatval($todayTotalMoneyMap[$agentId] ?? 0);
            $lastMoney = floatval($lastDayTotalMoneyMap[$agentId] ?? 0);

            $myMoney = floatval($directMoneyMap[$agentId] ?? 0);
            $myTodayMoney = floatval($todayDirectMoneyMap[$agentId] ?? 0);
            $myLastMoney = floatval($lastDayDirectMoneyMap[$agentId] ?? 0);

            if ($directPlayerAmount > 0) {
                $myMoney = $directPlayerAmount;
            }

            $subMoney = $money > $myMoney ? ($money - $myMoney) : 0;
            $totalMoney = $myMoney + $subMoney;

            $val['all_money'] = '含下级：' . number_format($totalMoney, 2) . '元<br>不含下级：' . number_format($myMoney, 2) . '元';
            $val['today_money'] = '含下级：' . number_format($todayMoney, 2) . '元<br>不含下级：' . number_format($myTodayMoney, 2) . '元';
            $val['lastday_money'] = '含下级：' . number_format($lastMoney, 2) . '元<br>不含下级：' . number_format($myLastMoney, 2) . '元';
            $val['balance'] = number_format(floatval($val['total_commission'] ?? 0), 2);

            $myUserNum = intval($directUserCountMap[$agentId] ?? 0);
            $userNum = intval($totalUserCountMap[$agentId] ?? $myUserNum);
            $val['user_num'] = '<b>包含下级：' . $userNum . '</b><br>不含下级：' . $myUserNum;

            $getAgentList['rows'][$key] = $val;
        }

        return jsonp($getAgentList);
    }

    /**
     * 批量统计代理订单金额
     * includeSub=true: 匹配代理树 %@id@%
     * includeSub=false: 仅直属 id|%
     */
    private function batchOrderMoney(array $agentIds, bool $includeSub, ?string $date = null): array
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

        if ($date !== null && $date !== '') {
            $sql .= ' AND `date` LIKE ?';
            $bindings[] = '%' . $date . '%';
        }

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

    private function buildAgentFilters(array $data)
    {
        $filters = [];

        $username = isset($data['username']) ? trim((string)$data['username']) : '';
        if ($username !== '') {
            $filters[] = ['username', 'like', '%' . $this->validateInput($username) . '%'];
        }

        $invite = isset($data['invite']) ? trim((string)$data['invite']) : '';
        if ($invite !== '') {
            $filters[] = ['invite', 'like', '%' . $this->validateInput($invite) . '%'];
        }

        $lv = isset($data['lv']) ? intval($data['lv']) : 0;
        if ($lv > 0) {
            $filters[] = ['lv', '=', $lv];
        }

        return $filters ?: null;
    }

	public function jiesuan()
    {
            $currentDate = date('Y-m-d');
        	$config = new C();
        	$cxConfig = $config->getConfig();
        	
        	if ($currentDate == $cxConfig['jiesuan']){
        	    	return notify(1,'今日已结算');
        	}else{
        // 验证 CSRF Token
        // jiesuan is called via POST with no data usually, so we need to ensure token is passed
        $token = $this->request->post('csrf_token', '');
        if (!$this->checkToken($token)) {
            return notify(0, '非法请求：CSRF令牌无效');
        }        		
		// 使用事务保护结算过程，防止部分结算
		\think\facade\Db::startTrans();
		try {
			$data = [
				'keys'=>'jiesuan',
				'values'=>$currentDate
			];
			$upConfig = $config->upConfig($data);
			$AG = new AG();
			$UO = new UO();
			$day = [
				'today'=>date("Y-m-d"),
				'lastday'=>date("Y-m-d",strtotime("-1 day"))
			];
			$getAgentList = $AG->getAgentjiesuan();
			foreach($getAgentList['rows'] as $key=>$val){
				$getById = $AG->getById($val['id']);
				$lastMoney = $UO->getOrdermoney($val['id'],true,$day['lastday']);
				$xlastMoney = ($val['fencheng'] / 100) * $lastMoney;
				$xlastMoney = (float)round($xlastMoney, 2);
				$jsxmoney = $xlastMoney + $getById['wmoney'];
				$agentData = [
					"id"=>$val['id'],
					"wmoney"=>$jsxmoney,
					"wtime"=>$currentDate,
				];
				$upAgent = $AG->upAgent($agentData);
			}
			\think\facade\Db::commit();
			return notify(1,'结算成功');
		} catch (\Throwable $e) {
			\think\facade\Db::rollback();
			return notify(0,'结算失败：' . $e->getMessage());
		}
        	}
    }
    public function add()
    {
		$AG = new AG();
		$getAllAgentList = $AG->getAllAgentList();
        return view('add',['getAgentList'=>$getAllAgentList]);
    }
    public function addSubmit()
    {
		$AG = new AG();
		$post = $this->request->post();
		// 验证 CSRF Token
		if (!$this->checkToken($post['csrf_token'] ?? '')) {
			return notify(0, '非法请求：CSRF令牌无效');
		}
		$pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
		$pattern_invite = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{4,8}$/';
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
		if(isset($post['lastagent'])&&$post['lastagent']!=null){
			$lastagent = $post['lastagent'];
			$getById = $AG->getById($lastagent);
			if(!$getById){
				return notify(0,'未查询到此代理');
			}
		}else{
			return notify(0,'上级代理信息有误');
		}
		
		// 新规则：固定70%分成
		$fencheng = 70;
		
		$status = isset($post['status'])?$post['status']:1;
		$agent_tree = agentTree($getById);
		if(!$agent_tree){
			return notify(0,'上级代理选择错误');
		}
		$data = [
			"username"=>$username,
			"password"=>password($password),
			"type"=>2,
			"lastagent"=>$getById['id'],
			"lv"=>$getById['lv']+1,
			"agent_tree"=>$agent_tree,
			"fencheng"=>$fencheng,
			"invite"=>$invite,
			"status"=>$status,
		];
		
		$addAgent = $AG->addAgent($data);
		return notify(1,'新增成功');
    }
    public function edit()
    {
		$AG = new AG();
		$get = $this->request->get();
		$getAllAgentList = $AG->getAllAgentList();
		if(isset($get['id'])){
			$getById = $AG->getById($get['id']);
			if(!$getById){
				 return '代理信息异常<br/><a href="#" onclick="history.back();return false;">返回上一页</a>';
			}
		}
        return view('edit',['getAgentList'=>$getAllAgentList,'getById'=>$getById]);
    }
	
    public function editSubmit()
    {
	// ===== 临时关闭改密功能 =====
	return notify(0,'系统维护中：改密功能暂时未开启，如需修改请联系系统管理员');
	// ===== 以下代码暂时禁用 =====
	/*
	// ===== 第二层防护：硬编码主密码验证（防止账号被盗后修改其他管理员密码） =====
	$confirmPassword = $this->request->post('confirm_password', '');
		if(empty($confirmPassword)){
			return notify(0,'请输入安全验证密码以确认修改操作');
		}
		
		// 验证硬编码主密码
		if(!$this->verifyMasterPassword($confirmPassword)){
			// 记录失败的验证尝试
			$userLog = new \app\model\UserLog();
			$userLog->addAdminLog($this->myAdmin['username'],'修改代理信息二次验证失败（硬编码验证），IP:'.$this->genericVariable['ip'],$this->genericVariable);
			return notify(0,'验证密码错误，操作已拒绝');
		}
	// ===== 二次验证通过 =====
	
	$AG = new AG();
	$post = $this->request->post();
	// 验证 CSRF Token
	if (!$this->checkToken($post['csrf_token'] ?? '')) {
		return notify(0, '非法请求：CSRF令牌无效');
	}
	$pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
	$pattern_invite = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{4,8}$/';
	
	// ===== 安全修复：防止越权漏洞 =====
	if(isset($post['id'])&&$post['id']!=null){
		$id = $post['id'];
		$getByIdAgent = $AG->getById($id);
		if(!$getByIdAgent){
			return notify(0,'代理信息有误');
		}
		
		// 严格验证：不能修改管理员账号（type=1）
		if($getByIdAgent['type'] == 1){
			$userLog = new \app\model\UserLog();
			$logMessage = "越权尝试：试图修改管理员账号 - 目标ID:{$id}, 目标用户:{$getByIdAgent['username']}, IP:{$this->genericVariable['ip']}";
			$userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
			return notify(0,'权限不足：不能修改管理员账号');
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
		if(isset($post['lastagent'])&&$post['lastagent']!=null){
			$lastagent = $post['lastagent'];
			$getById = $AG->getById($lastagent);
			if(!$getById){
				return notify(0,'未查询到此代理');
			}
		}else{
			return notify(0,'上级代理信息有误');
		}
		
		// 新规则：固定70%分成
		$fencheng = 70;
		
		$status = isset($post['status'])?$post['status']:1;
		$agent_tree = agentTree($getById,$id);
		
		if($agent_tree===false){
			return notify(0,'上级代理选择错误');
		}
		$data = [
			"id"=>$id,
			"username"=>$username,
			"password"=>$password,
			"type"=>2,
			"lastagent"=>$getById['id'],
			"lv"=>$getById['lv']+1,
			"agent_tree"=>$agent_tree,
			"fencheng"=>$fencheng,
			"invite"=>$invite,
			"status"=>$status,
		];
		$upAgent = $AG->upAgent($data);
		
	// 记录成功的修改操作
	$userLog = new \app\model\UserLog();
	$logMessage = "修改代理信息（已二次验证）- 代理ID:{$id}, 账号:{$username}, 邀请码:{$invite}, IP:{$this->genericVariable['ip']}";
	$userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
	
	return notify(1,'修改成功');
	*/
	// ===== 改密功能暂时禁用结束 =====
    }
    public function status()
    {
 $AG = new AG();
	$post = $this->request->post();
	// 验证 CSRF Token
	if (!$this->checkToken($post['csrf_token'] ?? '')) {
		return notify(0, '非法请求：CSRF令牌无效');
	}
	if(isset($post['id'])&&$post['id']!=null&&$post['id']!=1){
		$id = $post['id'];
		$getByIdAgent = $AG->getById($id);
		if(!$getByIdAgent){
			return notify(0,'代理不存在！');
		}
		$status = $AG->status($id);
		
		// 记录成功的操作
		$userLog = new \app\model\UserLog();
		$logMessage = "修改代理状态 - 代理ID:{$id}, 代理账号:{$getByIdAgent['username']}, IP:{$this->genericVariable['ip']}";
		$userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
		
		return notify(1,$status);
	}else{
		return notify(0,'代理信息有误');
	}
    }
    public function tixian()
    {
		$AGJS = new AGJS();
		$post = $this->request->post();
		// 验证 CSRF Token
		if (!$this->checkToken($post['csrf_token'] ?? '')) {
			return notify(0, '非法请求：CSRF令牌无效');
		}
		if(isset($post['id'])&&$post['id']!=null&&$post['id']!=1){
			$id = $post['id'];
			$getByIdAgent = $AGJS->getById($id);
			if(!$getByIdAgent){
				return notify(0,'审核订单不存在！');
			}
			$tixianshenhe = $AGJS->tixianshenhe($id);
			return notify(1,$tixianshenhe);
		}else{
			return notify(0,'审核订单有误');
		}
    }
    public function quanxian()
    {
 $AG = new AG();
	$post = $this->request->post();
	// 验证 CSRF Token
	if (!$this->checkToken($post['csrf_token'] ?? '')) {
		return notify(0, '非法请求：CSRF令牌无效');
	}
	if(isset($post['id'])&&$post['id']!=null&&$post['id']!=1){
		$id = $post['id'];
		$getByIdAgent = $AG->getById($id);
		if(!$getByIdAgent){
			return notify(0,'代理不存在！');
		}
		$quanxian = $AG->quanxian($id);
		
		// 记录成功的操作
		$userLog = new \app\model\UserLog();
		$logMessage = "修改代理权限 - 代理ID:{$id}, 代理账号:{$getByIdAgent['username']}, IP:{$this->genericVariable['ip']}";
		$userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
		
		return notify(1,$quanxian);
	}else{
		return notify(0,'代理信息有误');
	}
    }
    
}

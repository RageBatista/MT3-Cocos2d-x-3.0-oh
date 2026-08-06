<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use app\model\User as U;
use app\model\Bind as B;
use app\model\Agent as AG;
use app\gm\Gm as Game;
use think\facade\Session;
use app\model\Server;
use app\model\UserLog as ULog;
use app\model\BlackIP as BIP;
use app\model\Voice as V;
use DateTime;
use think\facade\Log;

class Player extends BaseController
{
    public function list()
    {
		$AG = new AG();
		$getAgentList = $AG->getAllAgentList();
		
        return view('list',['getAgentList'=>$getAgentList]);
    }
    public function list_table()
    {
		$post = $this->request->post();
		
		// 重构：从请求参数直接获取搜索条件（不再依赖 Session，避免多标签页冲突）
		$table_player = null;
		if(isset($post['username']) && $post['username'] != ''){
			$username = $this->validateInput($post['username']);
			$table_player[] = ['username','like','%'.$username.'%'];
		}
		if(isset($post['lastagent']) && intval($post['lastagent']) != 0){
			$lastagent = intval($post['lastagent']);
			$table_player[] = ['lastagent','=',$lastagent];
		}
		
		$user = new U();
		$getPlayerList = $user->getPlayerList($post,$table_player);

        $rows = $getPlayerList['rows'] ?? [];
        $agentIds = [];
        foreach ($rows as $row) {
            $agentId = intval($row['lastagent'] ?? 0);
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
            $agentId = intval($val['lastagent'] ?? 0);
			$val['last_username'] = $agentNameMap[$agentId] ?? 'unknown';
			$getPlayerList['rows'][$key] = $val;
		}
        return json($getPlayerList);
    }
    public function edit()
    {
		$user = new U();
		$AG = new AG();
		$get = $this->request->get();
		$getAllAgentList = $AG->getAllAgentList();
		if(!isset($get['id'])){
			return '参数异常<br/><a href="#" onclick="history.back();return false;">返回上一页</a>';
		}
		$getById = $user->getById($get['id']);
		if(!$getById){
			 return '玩家账号不存在<br/><a href="#" onclick="history.back();return false;">返回上一页</a>';
		}
        return view('edit',['getAllAgentList'=>$getAllAgentList,'getById'=>$getById]);
    }
	
public function modify(){
    $post = $this->request->post();
    // 验证 CSRF Token
    if (!$this->checkToken($post['csrf_token'] ?? '')) {
        return notify(0, '非法请求：CSRF令牌无效');
    }
   $bind = new B();

    if(!isset($post['id']) || !isset($post['money'])){
        return notify(0,'玩家信息或金额有误！');
    }
	
     $id=intval($post['id']);
     $money=$post['money'];
     
     // 金额验证：必须为数字，非负，且不超过合理上限
     if(!is_numeric($money)){
         return notify(0,'金额必须为数字！');
     }
     $money = (float)$money;
     if($money < 0){
         return notify(0,'金额不能为负数！');
     }
     if($money > 999999){
         return notify(0,'单次充值金额不能超过999999！');
     }
	   
     $modifyuser=$bind->getPlayerById($id);
	 if(!$modifyuser){
		 return notify(0,'角色不存在！');
	 }
	     $charegedate=$modifyuser['chargedate'];
	     if($charegedate!=0){
    	     $today=new DateTime();
    	     $dateFormatString=new DateTime($charegedate);
    	     if($today->format('Y-m-d')===$dateFormatString->format('Y-m-d')){
    	        $daycharge=$modifyuser['daycharge']+$money;
    	     }else{
    	         $daycharge=$money;
    	     }
	     }else{
	           $daycharge=$money;
	     }
  
	$upUser = $bind->upBindCharge($id,$money,$daycharge);
	
	// 记录成功的补充充值操作
	$userLog = new ULog();
	$logMessage = "补充充值成功 - 绑定ID:{$id}, 金额:{$money}, 今日充值:{$daycharge}, IP:{$this->genericVariable['ip']}";
	$userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
	
	 return notify(1,'修改成功');
	}
	
    public function editSubmit()
    {
 $user = new U();
	$AG = new AG();
	$post = $this->request->post();
	// 验证 CSRF Token
	if (!$this->checkToken($post['csrf_token'] ?? '')) {
		return notify(0, '非法请求：CSRF令牌无效');
	}
	$pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
	if(isset($post['id'])&&$post['id']!=null){
		$id = intval($post['id']);
		$getByIdAgent = $user->getById($id);
		if(!$getByIdAgent){
			return notify(0,'玩家信息有误！');
		}
	}else{
		return notify(0,'玩家信息有误');
	}
		if(isset($post['username'])&&$post['username']!=null){
			$username = strtolower($post['username']);
			// 修复：验证账号格式
			if(!preg_match($pattern, $username)){
				return notify(0,'账号必须为6-18位字母+数字');
			}
			$username = $this->validateInput($username);
			$checkUserId = $user->checkUserId($id,$username);
			if($checkUserId){
				return notify(0,'账号已存在');
			}
		}else{
			return notify(0,'账号不能为空');
		}
		if(isset($post['password'])&&$post['password']!=null){
			// 修复：移除 strtolower，允许密码包含大写字母，增强安全性
			$password = $post['password'];
			if(!preg_match($pattern, $password)){
				return notify(0,'密码必须为6-18位字母+数字');
			}
			$password = password($password);
		}else{
			$password = $getByIdAgent['password'];
		}
		if(isset($post['lastagent'])&&$post['lastagent']!=null){
			$lastagent = intval($post['lastagent']);
			$getById = $AG->getById($lastagent);
			if(!$getById){
				return notify(0,'未查询到此代理');
			}
		}else{
			return notify(0,'上级代理信息有误');
		}
	$data = [
		"id"=>$id,
		"username"=>$username,
		"password"=>$password,
		"lastagent"=>$lastagent
	];
	$upUser = $user->upUser($data);
	
	// 记录成功的修改操作
	$userLog = new ULog();
	$logMessage = "修改玩家信息 - 玩家ID:{$id}, 账号:{$username}, IP:{$this->genericVariable['ip']}";
	$userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
	
	return notify(1,'修改成功');
	   }
    public function del()
    {
 $user = new U();
	$post = $this->request->post();
	// 验证 CSRF Token
	if (!$this->checkToken($post['csrf_token'] ?? '')) {
		return notify(0, '非法请求：CSRF令牌无效');
	}
	if(isset($post['id'])&&$post['id']!=null&&$post['id']!=1){
		$id = intval($post['id']);
		$getByIdAgent = $user->getById($id);
		if(!$getByIdAgent){
			return notify(0,'玩家账号不存在！');
		}
		
		// 记录删除前的玩家信息
		$username = $getByIdAgent['username'];
		
		$del = $user->del($id);
		
		// 记录成功的删除操作
		$userLog = new ULog();
		$logMessage = "删除玩家 - 玩家ID:{$id}, 账号:{$username}, IP:{$this->genericVariable['ip']}";
		$userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
	}else{
		return notify(0,'代理信息有误');
	}
        return notify(1,'删除成功');
    }
    
 public function bindList()
    {
        return view('bind_list');
    }
	public function bind_list_table()
    {
		$post = $this->request->post();
		$bind = new B();
		
		// 重构：从请求参数直接获取搜索条件（不再依赖 Session，避免多标签页冲突）
		$table_bind = null;
		if(isset($post['username']) && $this->hasSearchValue($post['username'])){
			$username = $this->validateInput($post['username']);
			if ($username !== '') {
			$table_bind[] = ['u.username','like','%'.$username.'%'];
			}
		}
		if(isset($post['playerid']) && $this->hasSearchValue($post['playerid'])){
			$playerid = $this->validateInput($post['playerid']);
			if ($playerid !== '') {
			$table_bind[] = ['b.playerid','like','%'.$playerid.'%'];
			}
		}
		if(isset($post['playername']) && $this->hasSearchValue($post['playername'])){
			$playername = $this->validateInput($post['playername']);
			if ($playername !== '') {
			$table_bind[] = ['b.playername','=',$playername];
			}
		}
		
		$getBindList = $bind->getBindList($post,$table_bind);
		Log::info('后台绑定列表接口返回', [
			'total' => intval($getBindList['total'] ?? 0),
			'rows' => count($getBindList['rows'] ?? []),
			'has_username' => isset($post['username']) && $this->hasSearchValue($post['username']) ? 1 : 0,
			'has_playerid' => isset($post['playerid']) && $this->hasSearchValue($post['playerid']) ? 1 : 0,
			'has_playername' => isset($post['playername']) && $this->hasSearchValue($post['playername']) ? 1 : 0,
		]);
        return json($getBindList);
    }

	private function hasSearchValue($value): bool
	{
		$raw = trim((string)$value);
		if ($raw === '') {
			return false;
		}
		return trim($raw, " \t\n\r\0\x0B\"'") !== '';
	}
    public function status()
    {
		$user = new U();
		$post = $this->request->post();
		// 验证 CSRF Token
		if (!$this->checkToken($post['csrf_token'] ?? '')) {
			return notify(0, '非法请求：CSRF令牌无效');
		}
		if(isset($post['id'])){
			$id = intval($post['id']);
			$getById = $user->getById($id);
			if(!$getById){
				 return notify(0,'玩家账号不存在');
			}else{
				if($getById['status']==1){
					$bind = new B();
					$server = new Server();
					$Game = new Game();
					
					// 先检查 IP 再改状态，避免状态不一致
					$getUserIP = $user->getUserIP($id);
					if($getUserIP && $getUserIP==$this->genericVariable['ip']){
						return notify(0,'当前封禁IP与本机IP相同，请确认账号是否选择正确');
					}
					
					$status = $user->status($post['id']);
					$getAllBindListUID = $bind->getAllBindListUID($post['id']);
					foreach($getAllBindListUID as $key=>$val){
						$serverData = $server->getServerId($val['serverid']);
						$data = array(
							'serverip'  => $serverData['serverip'],
							'gmlocal'  => $serverData['gmlocal'],
							'gmport'  => $serverData['gmport'],
							'playerid'  => $val['playerid'],
						);
						$gameNotify = $Game->kick($data);
					}
					$userLog = new ULog();
					$BIP = new BIP();
					if($getUserIP){
						$addIP = $BIP->addIP($getUserIP,'封禁账号');
					}
					
					$userLog->addAdminLog($this->myAdmin['username'],'对玩家账号【'.$getById['username'].'】执行操作：'.$status,$this->genericVariable);
					return notify(1,$status);
				}else{
					$status = $user->status($id);
					$userLog = new ULog();
					$getUserIP = $user->getUserIP($getById['id']);
					$BIP = new BIP();
					$delIP = $BIP->delIP($getUserIP);
					$userLog->addAdminLog($this->myAdmin['username'],'对玩家账号【'.$getById['username'].'】执行操作：'.$status,$this->genericVariable);
					return notify(1,$status);
				}
			}
		}else{
			return notify(0,'玩家信息有误');
		}
    }
	
    public function zhiboqu()
    {
		$user = new U();
		$post = $this->request->post();
		// 验证 CSRF Token
		if (!$this->checkToken($post['csrf_token'] ?? '')) {
			return notify(0, '非法请求：CSRF令牌无效');
		}
		if(isset($post['id'])){
			$id = intval($post['id']);
			$getById = $user->getById($id);
			if(!$getById){
				 return notify(0,'玩家账号不存在');
			}else{
				$status = $user->zhiboqu($id);
				$userLog = new ULog();
				$userLog->addAdminLog($this->myAdmin['username'],'对玩家账号【'.$getById['username'].'】执行操作：'.$status,$this->genericVariable);
				return notify(1,$status);
			}
		}else{
			return notify(0,'玩家信息有误');
		}
    }
	
	
	public function voiceList()
    {
		
        return view('voice_list');
    }
    public function voice_list_table()
    {
		$post = $this->request->post();
		
		// 新增：支持搜索参数
		$searchCondition = null;
		if(isset($post['uuid']) && $post['uuid'] != ''){
			$uuid = $this->validateInput($post['uuid']);
			$searchCondition[] = ['uuid','like','%'.$uuid.'%'];
		}
		if(isset($post['text']) && $post['text'] != ''){
			$text = $this->validateInput($post['text']);
			$searchCondition[] = ['text','like','%'.$text.'%'];
		}
		
		$voice = new V();
		$getBindList = $voice->getVoiceList($post, $searchCondition);
		if(isset($getBindList['rows']) && !empty($getBindList['rows'])){
			foreach($getBindList['rows'] as $key=>$val){
				$getBindList['rows'][$key]['time'] = date("Y-m-d H:i:s", intval($val['time']));
			}
		}
        return json($getBindList);
    }

    /**
     * 角色管理页面
     */
    public function roleList()
    {
        return view('role_list');
    }

    /**
     * 角色管理 - AJAX数据接口
     */
    public function role_table()
    {
        $get = $this->request->get();
        $offset = isset($get['offset']) ? intval($get['offset']) : 0;
        $limit = isset($get['limit']) ? intval($get['limit']) : 20;

        $filter = [];
        if (!empty($get['roleid'])) {
            $filter['roleid'] = $this->validateInput($get['roleid']);
        }
        if (!empty($get['name'])) {
            $filter['name'] = $this->validateInput($get['name']);
        }
        if (!empty($get['username'])) {
            $filter['username'] = $this->validateInput($get['username']);
        }

        $role = new \app\model\Role();
        $result = $role->getListForTable($filter, $offset, $limit);

        return json($result);
    }
}

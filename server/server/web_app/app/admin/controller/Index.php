<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use think\Response;
use app\model\Agent as AG;
use app\model\User as U;
use app\model\Bind as B;
use app\model\Server as S;
use app\model\UserOrder as UO;

class Index extends BaseController
{
    public function logout()
    {
		return adminLogout();
    }
    public function index()
    {
        return view('index');
    }
    public function my()
    {
	// 检查是否是超级管理员（ID=1为超级管理员）
	$isSuperAdmin = ($this->myAdmin['id'] == 1);
        return view('my', [
		'isSuperAdmin' => $isSuperAdmin
	]);
    }
    public function editMy()
    {
 // ===== 临时关闭改密功能 =====
 return notify(0,'系统维护中：改密功能暂时未开启，如需修改请联系系统管理员');
 // ===== 以下代码暂时禁用 =====
 /*
 // ===== 安全限制：超级管理员不允许修改信息 =====
 if($this->myAdmin['id'] == 1){
  return notify(0,'超级管理员账号不允许在网页修改信息，请通过数据库或命令行修改');
 }
 // ===== 安全检查通过 =====
 
 $AG = new AG();
 $post = $this->request->post();
 $pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
 $pattern_invite = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{4,8}$/';
 
 // ===== 安全修复：防止越权漏洞（只能修改自己） =====
 if(isset($post['id'])&&$post['id']!=null){
  $id = $post['id'];
  
  // 严格验证：只能修改自己的账号
  if($id != $this->myAdmin['id']){
   $userLog = new \app\model\UserLog();
   $logMessage = "越权尝试：试图修改他人信息 - 当前ID:{$this->myAdmin['id']}, 目标ID:{$id}, IP:{$this->genericVariable['ip']}";
   $userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
   return notify(0,'权限不足：只能修改自己的信息');
  }
  
  $getByIdAgent = $AG->getById($id);
  if(!$getByIdAgent){
   return notify(0,'代理信息有误！');
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
  
  $data = [
   "id"=>$id,
   "username"=>$username,
   "password"=>$password,
   "invite"=>$invite
  ];
  $upAgent = $AG->upAgent($data);
  
 // 记录成功的修改操作
 $userLog = new \app\model\UserLog();
 $logMessage = "修改自己的信息 - 账号:{$username}, 邀请码:{$invite}, IP:{$this->genericVariable['ip']}";
 $userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
 
 return notify(1,'修改成功');
 */
 // ===== 改密功能暂时禁用结束 =====
}
    public function worker()
    {
		$AG = new AG();
		$getAgentNum = $AG->getAgentNum();
		$U = new U();
		$getUserNum = $U->getUserNum();
		$B = new B();
		$getBindNum = $B->getBindNum();
		
		// 新增：真实角色总数（从role表）
		$Role = new \app\model\Role();
		$getRoleCount = $Role->getRoleCount();
		
		$UO = new UO();
		$day = [
			'today'=>date("Y-m-d"),
			'lastday'=>date("Y-m-d",strtotime("-1 day"))
		];
		$money = $UO->getOrdermoney(null,null,null);
		$todayMoney = $UO->getOrdermoney(null,null,$day['today']);
		$lastMoney = $UO->getOrdermoney(null,null,$day['lastday']);
		
		// 新增：最近充值记录
		$recentOrders = $UO->getRecentOrders(5);
		
	$S = new S();
	$getAllServerList = $S->getAllServerList();
	$serverCount = count($getAllServerList);
	foreach ($getAllServerList as $key=>$val) {
		// 安全修复: 严格验证端口号，防止命令注入
		if (!is_numeric($val['serverport'])) {
			$getAllServerList[$key]['online'] = 0;
			continue;
		}
		$port = intval($val['serverport']);
		if ($port < 1 || $port > 65535) {
			$getAllServerList[$key]['online'] = 0;
			continue;
		}
		$getAllServerList[$key]['online'] = exec('netstat -nat|grep -i '.escapeshellarg((string)$port).'|wc -l');
	}
	

        return view('worker',[
			'getUserNum'=>$getUserNum,
			'getAgentNum'=>$getAgentNum,
			'getBindNum'=>$getBindNum,
			'getRoleCount'=>$getRoleCount,
			'money'=>$money,
			'todayMoney'=>$todayMoney,
			'lastMoney'=>$lastMoney,
			'serverCount'=>$serverCount,
			'recentOrders'=>$recentOrders,
			'getAllServerList'=>$getAllServerList,
			'js_server_names'=>json_encode(array_column($getAllServerList, 'name'), JSON_UNESCAPED_UNICODE|JSON_HEX_APOS|JSON_HEX_QUOT),
			'js_server_onlines'=>json_encode(array_column($getAllServerList, 'online'), JSON_HEX_APOS|JSON_HEX_QUOT),
		]);
    }
	
}

<?php
declare (strict_types = 1);

namespace app\agent\controller;

use app\BaseController;
use think\Response;
use app\model\Agent as AG;
use app\model\Agentjs as AGJS;
use app\model\User as U;
use app\model\Bind as B;
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
        return view('my');
    }
    public function editMy()
    {
	// ===== 临时关闭改密功能 =====
	return notify(0,'系统维护中：改密功能暂时未开启，如需修改请联系系统管理员');
	// ===== 以下代码暂时禁用 =====
	/*
	$AG = new AG();
	$post = $this->request->post();
	$pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
	$pattern_invite = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{4,8}$/';
	
	// ===== 安全修复：防止越权漏洞 =====
	// 只能修改自己的信息，不能修改其他人的
	if(isset($post['id'])&&$post['id']!=null){
		$id = $post['id'];
		
		// 严格验证：只能修改自己的账号
		if($id != $this->myAdmin['id']){
			// 记录越权尝试
			$userLog = new \app\model\UserLog();
			$logMessage = "越权尝试：试图修改他人信息 - 当前ID:{$this->myAdmin['id']}, 目标ID:{$id}, IP:{$this->genericVariable['ip']}";
			$userLog->addAgentLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
			return notify(0,'权限不足：只能修改自己的信息');
		}
		
		$getByIdAgent = $AG->getById($id);
		if(!$getByIdAgent){
			return notify(0,'代理信息有误！');
		}
		
		// 再次验证账号类型（防止修改管理员账号）
		if($getByIdAgent['type'] != 2){
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
		
		$data = [
			"id"=>$id,
			"username"=>$username,
			"password"=>$password,
			"invite"=>$invite
		];
	$upAgent = $AG->upAgent($data);
	
	return notify(1,'修改成功');
	*/
	// ===== 改密功能暂时禁用结束 =====
}
	/**
	 * 新的提现申请功能（所有代理可用）
	 */
	public function applyWithdrawal()
	{
		$AG = new AG();
		$getByIdAgent = $AG->getById($this->myAdmin['id']);
		
		if(!$getByIdAgent){
			return notify(0,'代理信息有误！');
		}
		
		// ===== 检查提现信息是否完整 =====
		$kefu = $getByIdAgent['kefu'];
		if (empty($kefu)) {
			return notify(0,'提现信息不完整！<br>请先在"基础设置"页面完善您的收款信息（支付宝账号/USDT地址）');
		}
		
		// 解析提现信息
		$kefuData = json_decode($kefu, true);
		if (!$kefuData) {
			return notify(0,'提现信息格式错误！<br>请先在"基础设置"页面完善您的收款信息');
		}
		
		// 检查支付宝信息或USDT地址
		$zfbname = $kefuData['zfbname'] ?? '';
		$zfbzh = $kefuData['zfbzh'] ?? '';
		$usdt = $kefuData['usdt'] ?? '';
		
		$hasAlipay = !empty($zfbname) && !empty($zfbzh);
		$hasUsdt = !empty($usdt) && $usdt != '暂未设置';
		
		if (!$hasAlipay && !$hasUsdt) {
			return notify(0,'提现信息不完整！<br>请至少设置一种收款方式：<br>1. 支付宝（姓名+账号）<br>2. USDT地址<br><br>请前往"基础设置"页面完善');
		}
		// ===== 提现信息检查通过 =====
		
		// 获取当前佣金统计
		$commissionService = new \app\service\CommissionService();
		$commission = $commissionService->getAgentCommission($this->myAdmin['id']);
		
		$totalCommission = $commission['total_commission'] ?? 0;
		$directCommission = $commission['direct_commission'] ?? 0;
		$subCommission = $commission['sub_commission'] ?? 0;
		$pendingWithdrawal = $commission['pending_withdrawal'] ?? 0;
		
		// 检查是否有待审核的提现（重要：防止覆盖）
		if ($pendingWithdrawal > 0) {
			return notify(0,'您有待审核的提现申请！<br><strong>待审核金额：'.$pendingWithdrawal.'元</strong><br><br>请等待管理员审核完成后再提交新的申请<br>（多次提交会导致之前的申请被覆盖）');
		}
		
		// 检查最低提现金额
		if ($totalCommission < 200) {
			return notify(0,'提现金额不足！<br>最低提现金额：<strong>200元</strong><br>当前余额：<strong>'.$totalCommission.'元</strong><br><br>还需要：<strong>'.number_format(200 - $totalCommission, 2).'元</strong>');
		}
		
	// 将佣金转移到待审核字段
	$AG->upAgent([
		'id' => $this->myAdmin['id'],
		'direct_commission' => 0,
		'sub_commission' => 0,
		'total_commission' => 0,
		'pending_withdrawal' => $totalCommission,
		'withdrawal_apply_time' => date('Y-m-d H:i:s')
	]);
		
		// 记录提现申请日志
		$userLog = new \app\model\UserLog();
		$receiveMethod = [];
		if ($hasAlipay) {
			$receiveMethod[] = "支付宝({$zfbname}:{$zfbzh})";
		}
		if ($hasUsdt) {
			$receiveMethod[] = "USDT({$usdt})";
		}
		$receiveMethodStr = implode(', ', $receiveMethod);
		
		$logMessage = "提现申请 - 金额：{$totalCommission}元（直属：{$directCommission}元，下级：{$subCommission}元），收款方式：{$receiveMethodStr}";
		$userLog->addAgentLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
		
		return notify(1,'提现申请提交成功！<br>提现金额：<strong>'.$totalCommission.'元</strong><br>收款方式：'.$receiveMethodStr.'<br><br>请等待管理员审核');
	}
	
	/**
	 * 旧的结算功能（已废弃，仅保留兼容）
	 */
	public function jiesuan()
    {
		// 新系统已废弃此功能，统一使用 applyWithdrawal
		return notify(0,'此功能已升级，请使用新的"申请提现"功能！');
    }
    public function worker()
    {
	$AG = new AG();
	$getAgentNum = $AG->getAgentNum($this->myAdmin['id']);
	$U = new U();
	$getUserNum = $U->getUserNum($this->myAdmin['id'],true);
	
	// ===== 新佣金计算服务 =====
	$commissionService = new \app\service\CommissionService();
	
	// 获取佣金统计（从账户字段读取）
	$commission = $commissionService->getAgentCommission($this->myAdmin['id']);
	$checkResult = $commissionService->checkCanCreateAgent($this->myAdmin['id']);
	
	$UO = new UO();
	$day = [
		'today'=>date("Y-m-d"),
		'lastday'=>date("Y-m-d",strtotime("-1 day"))
	];
	$money = $UO->getOrdermoney($this->myAdmin['id'],true,null);
	$todayMoney = $UO->getOrdermoney($this->myAdmin['id'],true,$day['today']);
	$lastMoney = $UO->getOrdermoney($this->myAdmin['id'],true,$day['lastday']);
	
        return view('worker',[
		'getUserNum'=>$getUserNum,
		'getAgentNum'=>$getAgentNum,
		'money'=>$money,
		'todayMoney'=>$todayMoney,
		'lastMoney'=>$lastMoney,
		// 新增佣金信息
		'commission'=>$commission,
		'checkResult'=>$checkResult,
	]);
    }
	
}

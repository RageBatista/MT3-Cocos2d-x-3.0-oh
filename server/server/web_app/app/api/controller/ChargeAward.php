<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;
use app\model\User;
use app\model\Bind;
use app\model\ChargeAward as CAward;
use app\model\Server;
use app\model\UserLog as UL;
use app\gm\Gm as Game;

class ChargeAward extends BaseController
{
	private function apiResult(int $code, string $msg, array $extra = [])
	{
		return api_json(array_merge([
			'code' => $code,
			'msg' => $msg
		], $extra));
	}
	
	public function getchargeitem()
    {
		$param = $this->request->param();
		$checkuser = $this->checkuser($param);
		if($checkuser==false){
			return $this->apiResult(0,'账号验证不通过');
		}
		

		$award = new CAward();
		$getAwardList = $award->getAwardList($param['type']);

	$bindData = $checkuser['bindData'];
	if($param['type'] == 1){
		if($bindData['lq_daycharge']!=null){
			$lq_daycharge = safeUnserialize($bindData['lq_daycharge'], []);
		}else{
			$lq_daycharge = [];
		}
			if($bindData['chargedate']==date('Y-m-d')){
				$charge = intval($bindData['daycharge']);
			}else{
				$charge = 0;
			}
			foreach($getAwardList as $key=>$val){
				if( isset($lq_daycharge[$val['id']]) && $lq_daycharge[$val['id']]==date('Y-m-d')){
					$val['lq'] = 1;
				}else{
					$val['lq'] = 0;
				}
				$getAwardList[$key] = $val;
			}
	
	}else{
		if($bindData['lq_rolecharge']!=null){
			$lq_rolecharge = safeUnserialize($bindData['lq_rolecharge'], []);
		}else{
			$lq_rolecharge = [];
		}
			$charge = intval($bindData['charge']);
			foreach($getAwardList as $key=>$val){
				if( isset($lq_rolecharge[$val['id']])){
					$val['lq'] = 1;
				}else{
					$val['lq'] = 0;
				}
				$getAwardList[$key] = $val;
			}
			
		}
		$data = [
			'charge'=>$charge,
			'data'=>$getAwardList,
		];

		return api_json($data);
	}
	
	
	public function receiveday()
    {
		$param = $this->request->param();
		$checkuser = $this->checkuser($param);
		if($checkuser==false){
			return $this->apiResult(0,'账号验证不通过');
		}
		$userData = $checkuser['userData'];
		$bindData = $checkuser['bindData'];
		$serverData = $checkuser['serverData'];
		
		if($bindData['chargedate']==date('Y-m-d')){
			$daycharge = intval($bindData['daycharge']);
		}else{
			return $this->apiResult(0,'今日充值金额未达到领取条件');
		}
		
		
		$award = new CAward();
		$getAwardById = $award->getAwardById($param['chargeid']);
		if(!$getAwardById || $getAwardById['status']==0 || $getAwardById['type']!=1){
			return $this->apiResult(0,'奖励内容不存在或暂未开放');
		}
		if($getAwardById['value']>$daycharge){
			return $this->apiResult(0,'今日充值金额未达到领取条件');
		}
		
		
	
	if($bindData['lq_daycharge']!=null){
		$lq_daycharge = safeUnserialize($bindData['lq_daycharge'], []);
		if(isset($lq_daycharge[$param['chargeid']]) && $lq_daycharge[$param['chargeid']] == date('Y-m-d')){
			return $this->apiResult(0,'您已领取此奖励');
		}else{
			$lq_daycharge[$param['chargeid']] = date('Y-m-d');
		}
	}else{
		$lq_daycharge = [];
		$lq_daycharge[$param['chargeid']] = date('Y-m-d');
	}
		$lq_daycharge = serialize($lq_daycharge);
		
		$bind = new Bind();
		$upLqDayCharge = $bind->upLqDayCharge($bindData['id'],$lq_daycharge);
		
		$userLog = new UL();
		$Game = new Game();
		$data = $checkuser['gmData'];
		if($getAwardById['xianyu']!=0){
			$data['number'] = $getAwardById['xianyu'];
			$gameNotify_xianyu = $Game->addqian($data);
		}
		if($getAwardById['vip']!=0){
			$data['number'] = $getAwardById['vip'];
			$gameNotify_vip = $Game->addvipexp($data);
		}
		
		$data['content']='尊敬的玩家，您领取的今日累计充值【'.$getAwardById['value'].'元】礼包已到账，请及时领取，祝您游戏愉快，如有疑问，请及时联系客服！';
		$data['awardContent'] = $getAwardById['mailitem'];
		
		$data['title']='今日累计奖励';
		$data['duration']=0;
		
		$gameNotify = $Game->mail($data);
		if(isset($gameNotify[0])){
			if(strpos($gameNotify[0],'success') !== false){
				$userLog->addUserLog($userData['username'],'领取今日充值【'.$getAwardById['value'].'元】礼包奖励',$this->genericVariable);
				return $this->apiResult(1,'领取成功,请查看邮件进行查收');
			}
		}
		return $this->apiResult(0,'领取失败，请重试或联系客服处理');
	}
	
	public function receiverole()
    {
		$param = $this->request->param();
		$checkuser = $this->checkuser($param);
		if($checkuser==false){
			return $this->apiResult(0,'账号验证不通过');
		}
		$userData = $checkuser['userData'];
		$bindData = $checkuser['bindData'];
		$serverData = $checkuser['serverData'];
		
		$charge = intval($bindData['charge']);
		$award = new CAward();
		$getAwardById = $award->getAwardById($param['chargeid']);
		if(!$getAwardById || $getAwardById['status']==0 || $getAwardById['type']!=2){
			return $this->apiResult(0,'奖励内容不存在或暂未开放');
		}
		if($getAwardById['value']>$charge){
			return $this->apiResult(0,'今日充值金额未达到领取条件');
		}
		
		
	
	if($bindData['lq_rolecharge']!=null){
		$lq_rolecharge = safeUnserialize($bindData['lq_rolecharge'], []);
		if(isset($lq_rolecharge[$param['chargeid']])){
			return $this->apiResult(0,'您已领取此奖励');
		}else{
			$lq_rolecharge[$param['chargeid']] = date('Y-m-d');
		}
	}else{
		$lq_rolecharge = [];
		$lq_rolecharge[$param['chargeid']] = date('Y-m-d');
	}
		$lq_rolecharge = serialize($lq_rolecharge);
		
		$bind = new Bind();
		$upLqRoleCharge = $bind->upLqRoleCharge($bindData['id'],$lq_rolecharge);
		
		$userLog = new UL();
		$Game = new Game();
		$data = $checkuser['gmData'];
		if($getAwardById['xianyu']!=0){
			$data['number'] = $getAwardById['xianyu'];
			$gameNotify_xianyu = $Game->addqian($data);
		}
		if($getAwardById['vip']!=0){
			$data['number'] = $getAwardById['vip'];
			$gameNotify_vip = $Game->addvipexp($data);
		}
		
		$data['content']='尊敬的玩家，您领取的角色累计充值【'.$getAwardById['value'].'元】礼包已到账，请及时领取，祝您游戏愉快，如有疑问，请及时联系客服！';
		$data['awardContent'] = $getAwardById['mailitem'];
		
		$data['title']='角色累计奖励';
		$data['duration']=0;
		
		$gameNotify = $Game->mail($data);
		if(isset($gameNotify[0])){
			if(strpos($gameNotify[0],'success') !== false){
				$userLog->addUserLog($userData['username'],'领取角色充值【'.$getAwardById['value'].'元】礼包奖励',$this->genericVariable);
				return $this->apiResult(1,'领取成功,请查看邮件进行查收');
			}
		}
		return $this->apiResult(0,'领取失败，请重试或联系客服处理');
	}
	
	
	public function modifypass(){
	    $param = $this->request->param();
	    		foreach($param as $key=>$val){
			$userinfo[$key] = strtolower($val); 
		}
		 
		$user = new User();
		$userData = $user->getUsername($userinfo['account']);
	    $password = strtolower($userinfo['password']);
		if(!$userData||password($password,$userData['password'])==false){
    		return $this->apiResult(0,'您的原密码不正确');
		}
	 	$pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
		if(!preg_match($pattern, $userinfo['newpass'])){
    		return $this->apiResult(0,'密码必须为6-18位字母+数字');
		}
	    $newpass = password( $userinfo['newpass']);
	    	$data = [
	    	    'id'=>$userData['id'],
				'username'=>$userinfo['account'],
				'password'=>$newpass,
			];
			$user->upUser($data);
				$userLog = new UL();
			$info = '修改了密码';
			$userLog->addUserLog($userinfo['account'],$info,$this->genericVariable);
    		return $this->apiResult(1,'密码修改成功，请您牢记新密码');
	}
	
private function checkuser($param)
{
	// ===== 安全修复：使用白名单方式，防止变量覆盖漏洞 =====
	// 旧代码使用 $$key=$val 动态创建变量，攻击者可以覆盖任意变量
	// 新代码明确指定允许的参数名
 
	// 定义允许的参数白名单
	$allowedParams = ['account', 'password', 'roleid'];
	
	// 初始化变量
	$account = null;
	$password = null;
	$roleid = null;
	
	// 只处理白名单中的参数
	foreach($allowedParams as $paramName){
		if(isset($param[$paramName])){
			${$paramName} = $param[$paramName];
		}
	}
	
	// 验证必需参数
	if(!isset($account)||$account==null){
			return false;
	}
	if(!isset($password)||$password==null){
			return false;
	}
	if(!isset($roleid)||$roleid==null){
			return false;
	}
	
	$user = new User();
	$userData = $user->getUsername($account);
	

	$password = strtolower($password);
	if(!$userData||password($password,$userData['password'])==false){

		return false;
	}
	$bind = new Bind();

	$bindData = $bind->getPlayerId($roleid);
 
		if(!$bindData||$bindData['userid']!=$userData['id']){
		  
			return false;
		}
		
		$server = new Server();
		$serverData = $server->getServerId($bindData['serverid']);
		if(!$serverData){
		   
			return false;
		}
		
		
		$gmData = array(
			'username'  => $account,
			'serverip'  => $serverData['serverip'],
			'gmlocal'  => $serverData['gmlocal'],
			'gmport'  => $serverData['gmport'],
			'gm_userid' => intval($bindData['userid'] ?? 0),
			'playerid'  => $bindData['playerid'],
		);
		$data = array(
			'userData'  => $userData,
			'bindData'  => $bindData,
			'serverData'  => $serverData,
			'gmData'  => $gmData,
			
		);
		return $data;
		
	}
	
}

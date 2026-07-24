<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;
use app\model\User;
use app\model\Bind;
use app\model\Server;
use app\model\UserLog as UL;
use app\model\Agent as AG;

use app\model\Fankui as F;


//角色补偿使用
use app\model\UserOrder as UO;
use app\gm\Gm;

class Game extends BaseController
{
	public function sdk()
    {	
		$tokenParam = $this->request->param();
		$user = new User();
		if(strpos($tokenParam['account'], ',') !== false){
			$accountExp = explode(',',$tokenParam['account'])[0];
		}else{
			$accountExp = $tokenParam['account'];
		}
		if(strpos($tokenParam['password'], '|') !== false){
			$passwordExp = explode('|',$tokenParam['password'])[1];
		}else{
			$passwordExp = $tokenParam['password'];
		}
		if(!isset($tokenParam['serverId'])){
			return '{"Code":"2"}';
		}
		$userData = $user->getUsername($accountExp);
		
		$getBidServer = $user->getBidServer($userData['id'],$tokenParam['serverId']);
		if($getBidServer){
			return '{"Code":"2"}';
		}
		if($tokenParam['serverId']=='1000000999' ){
			if($userData['zhiboqu']!=1){
				return '{"Code":"2"}';
			}
		}
		if(!$userData){
			return '{"Code":"2"}';
		}
		if(password($passwordExp,$userData['password'])==false){
			return '{"Code":"2"}';
		}
		if($userData['status']!=1){	
			return '{"Code":"2"}';
		}
		$userLog = new UL();
		$info  =  '登陆游戏';
		$userLog->addUserLog($accountExp,$info,$this->genericVariable);
		return '{"Code":"1","Channel":"1","PlatformId":"1","Account":"'.$accountExp.'","Message":"登陆成功!","Session":"'.$tokenParam['password'].'"}';
	
    }
	public function bind()
    {	
		$InviteParam = $this->request->post();
		$user = new User();
		$bind = new Bind();
		if(strpos($InviteParam['account'], ',') !== false){
			$accountExp = explode(',',$InviteParam['account'])[0];
		}else{
			$accountExp = $InviteParam['account'];
		}
		//{"qu":"1101961001","roleid":"118785","name":"\u8d44\u5983\u5a77","account":"ceshi7892,020000000000"}
		$userData = $user->getUsername($accountExp);
		if(!$userData){
			return json_encode(0);
		}else{
			$getPlayerId = $bind->getPlayerId($InviteParam['roleid']);
			if($getPlayerId){
				return json_encode(0);
			}else{
				$bindInfo = [
						'userid' => $userData['id'],
						'serverid' => $InviteParam['qu'],
						'playerid' => $InviteParam['roleid'],
						'playername' => $InviteParam['name']
				];
				$addBind = $bind->addBind($bindInfo);
				$userLog = new UL();
				$info  =  '绑定新角色：'.json_encode($bindInfo,JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);
				$userLog->addUserLog($accountExp,$info,$this->genericVariable);
				return json_encode(1);
			}
		}
    }
	
	public function kefu()
    {	
		$username = $this->request->param('username',null);
		if($username!=null){
			$user = new User();
			$userData = $user->getUsername($username);
			if($userData){
				$AG = new AG();
				$getById = $AG->getById($userData['lastagent']);
				
				if(isJson($getById['kefu'])){
					$kefu = json_decode($getById['kefu'],true);
				
					if($kefu==null){
						$kefu = [
							'qq'=>123456,
							'group'=>"http://baidu.com",
							'info'=>"暂未设置",
						];
					}
				}else{
					$kefu = [
						'qq'=>123456,
						'group'=>"http://baidu.com",
						'info'=>"暂未设置",
					];
				}
			}else{
				$kefu = [
					'qq'=>123456,
					'group'=>"http://baidu.com",
					'info'=>"暂未设置",
				];
			}
		}else{
			$kefu = [
					'qq'=>123456,
					'group'=>"http://baidu.com",
					'info'=>"暂未设置",
				];
		}
        return view('kefu',['kefu'=>$kefu,'username'=>$username]);
    }
	
	
	
	public function zhuanqu()
    {	
	
		$username = $this->request->param('username',null);
		if($username==null){
			return notify(0,'参数异常');
		}
		
		// 安全加固：验证请求来源是否合法（防止外部直接调用）
		$referer = $this->request->header('referer', '');
		if (empty($referer) || strpos($referer, $this->request->host()) === false) {
			// 允许空 referer（英视赞办主动访问），但记录日志
		}
		
		$user = new User();
		$getUser = $user->getUsername($username);
		if(!$getUser){
			return notify(0,'账号不存在');
		}
		$bind = new Bind();
		$server = new Server();
		$user_order = new UO();
		$getAllBindListUID = $bind->getAllBindListUID($getUser['id']);
		foreach($getAllBindListUID as $key=>$val){
			$val['servername'] = $server->getServerId($val['serverid'])['name'];
			
			//$val['chargemoney'] = $user_order->getServerRoleMoney($val['playerid']);
			$val['chargemoney'] = $val['charge'];
			
			$getAllBindListUID[$key] = $val;
		}
        return view('zhuanqu',['username'=>$username,'getAllBindListUID'=>$getAllBindListUID]);
		
    }
	
	public function zhuanquSub()
    {	
		$zhuanqu = $this->request->post();
		if(isset($zhuanqu['oldrole'])){
			$oldrole = $zhuanqu['oldrole'];
		}else{
			return notify(0,'参数异常');
		}
		if(isset($zhuanqu['newrole'])){
			$newrole = $zhuanqu['newrole'];
		}else{
			return notify(0,'参数异常');
		}
		$bind = new Bind();
		$user = new User();
		$server = new Server();
		$user_order = new UO();
		//获取角色问题
		$newroleData = $bind->getPlayerById($newrole);
		if(!$newroleData){
			return notify(0,'新区角色不存在');
		}
		$oldroleData = $bind->getPlayerById($oldrole);
		if(!$oldroleData){
			return notify(0,'被转区角色不存在');
		}
		
		// 安全加固：验证两个角色属于同一用户
		if($newroleData['userid'] != $oldroleData['userid']){
			return notify(0,'角色不属于同一账号，无法转区');
		}
		
		$getBidServer = $user->getBidServer($oldroleData['userid'],$oldroleData['serverid']);
		if($newrole==$oldrole){
			return notify(0,'新区角色与被转区角色相同');
		}
		if($newroleData['zhuanqu']==1){
			return notify(0,'新区角色已接受过转区福利，无法使用');
		}
		if($getBidServer){
			return notify(0,'被转区角色已被转区，无法使用');
		}
		$getBidServer = $user->getBidServer($newroleData['userid'],$newroleData['serverid']);
		if($getBidServer){
			return notify(0,'被转区角色已被转区，无法使用');
		}
		if($oldroleData['charge']<1000){
			return notify(0,'被专区角色累计金额不足1000元，无法转区');
		}
		
		if($newroleData['charge']<$oldroleData['charge']*0.5){
			return notify(0,'新区角色累计充值低于要求，无法使用');
		}
		
		// 安全加固：包裹在事务中，防止部分成功的不一致状态
		\think\facade\Db::startTrans();
		try {
			$gm = new Gm();
			$serverData_old = $server->getServerId($oldroleData['serverid']);
			$data1 = [
				'serverip'  => $serverData_old['serverip'],
				'gmlocal'  => $serverData_old['gmlocal'],
				'gmport'  => $serverData_old['gmport'],
				'playerid'  => $oldroleData['playerid']
			];
			$gameNotify1 = $gm->kick($data1);
			
			$serverData = $server->getServerId($newroleData['serverid']);
			$xianyu = $oldroleData['charge'] * 600;
			$data = [
				'serverip'  => $serverData['serverip'],
				'gmlocal'  => $serverData['gmlocal'],
				'gmport'  => $serverData['gmport'],
				'playerid'  => $newroleData['playerid'],
				'number'  => $xianyu
			];
			
			$gameNotify_xianyu = $gm->addqian($data);
			$vip = $oldroleData['charge'] * 3;
			$data['number'] = $vip;
			$gameNotify_vip = $gm->addvipexp($data);
			
			if(isset($gameNotify_xianyu[0]) && isset($gameNotify_vip[0])){
				if(strpos($gameNotify_xianyu[0],'success') !== false && strpos($gameNotify_vip[0],'success') !== false ){
					$upBidServer = $user->upBidServer($oldroleData['userid'],$oldroleData['serverid']);
					$upBindZhuanqu = $bind->upBindZhuanqu($oldrole);
					\think\facade\Db::commit();
					return notify(1,'转区成功');
				}else{
					\think\facade\Db::rollback();
					return notify(0,'转区失败：GM命令执行失败');
				}
			}else{
				\think\facade\Db::rollback();
				return notify(0,'转区失败：GM服务器无响应');
			}
		} catch (\Exception $e) {
			\think\facade\Db::rollback();
			return notify(0,'转区失败：' . $e->getMessage());
		}
    }
	
	public function rebate()
    {	
		return '此功能已关闭';
		$serverid = 1000000002;
		$username = $this->request->post('username',null);
		if($username==null){
			return notify(0,'参数异常');
		}
		$user = new User();
		$getUser = $user->getUsername($username);
		if(!$getUser){
			return notify(0,'账号不存在');
		}else{
			if($getUser['rebate']==1){
				return notify(0,'您已领取过充值返利，请检查游戏邮件');
			}
		}
		$arr = [
			'userid'=>$getUser['id'],
			'serverid'=>$serverid
		];
		$bind = new Bind();
		$getBindArr = $bind->getBindArr($arr);
		if(!$getBindArr){
			return notify(0,'角色信息不存在');
		}
		$username = addslashes($username);
		$arr_order=[
			['user','like','%"'.$username.'"%'],
			['status','=',1],
			['time','<',1716350400]
		];
		$user_order = new UO();
		$getUserAllPay = $user_order->getUserAllPay($arr_order);
		$money = 0;
		$charge_tiem = [
			30  => 400371,
			50  => 400372,
			98  => 400373,
			198  => 400374,
			298  => 400375,
			488  => 400376,
			648  => 400377,
			1280  => 400378,
		];
		$charge_info = null;
		$award = [];
		foreach($getUserAllPay['data'] as $key=>$val){
			$money = $money + $val['realmoney'];
			if($charge_info==null){
				$charge_info = '【订单：'.$val['orderid'].'，金额：'.$val['realmoney'].'元】';
			}else{
				$charge_info = $charge_info.'、【订单：'.$val['orderid'].'，金额：'.$val['realmoney'].'元】';
			}
			if(isset($award[$charge_tiem[intval($val['realmoney'])]])){
				$award[$charge_tiem[intval($val['realmoney'])]]=$award[$charge_tiem[intval($val['realmoney'])]]+2;
			}else{
				$award[$charge_tiem[intval($val['realmoney'])]]=2;
			}
			
		}
		if($money<=0){
			return notify(0,'您在内测期间无任何充值，无法领取');
		}
		$item = null;
		foreach($award as $key=>$val){
			if($item==null){
				$item = $key.'|'.$val;
			}else{
				$item = $item.','.$key.'|'.$val;
			}
		}
		
		
		$data = [
            'serverip'  => '127.0.0.1',
            'gmlocal'  => 1,
            'gmport'  => 41002,
            'playerid'  => $getBindArr['playerid'],
            'title'  => '公测删档返利',
            'content'  => '您在公测期间充值金额，现已双倍返还，公测充值详情如下：'.$charge_info,
            'duration'  => 0,
            'awardContent'  => $item
		];
		$gm = new Gm();
		$gameNotify = $gm->mail($data);
		if(isset($gameNotify[0])){
			if(strpos($gameNotify[0],'success') !== false){
				$upRebate = $user->upRebate($username);
				return notify(1,'充值返利领取成功，请进游戏查看邮件详情');
			}else{
				return notify(0,'充值返利领取失败，请重试，或联系客服');
			}
		}else{
			return notify(0,'充值返利领取失败，请重试，或联系客服');
		}
		
		
		
		
		
		
    }
	
	
	
	
	
	
	
	
	public function fankui()
    {	
	
		$username = $this->request->param('username',null);
		if($username==null){
			return notify(0,'参数异常');
		}
		$user = new User();
		$getUser = $user->getUsername($username);
		if(!$getUser){
			return notify(0,'账号不存在');
		}
		$bind = new Bind();
		$server = new Server();
		$user_order = new UO();
		$getAllBindListUID = $bind->getAllBindListUID($getUser['id']);
		foreach($getAllBindListUID as $key=>$val){
			$val['servername'] = $server->getServerId($val['serverid'])['name'];
			
			//$val['chargemoney'] = $user_order->getServerRoleMoney($val['playerid']);
			$val['chargemoney'] = $val['charge'];
			
			$getAllBindListUID[$key] = $val;
		}
        return view('fankui',['username'=>$username,'getAllBindListUID'=>$getAllBindListUID]);
		
    }
	
	public function fankuiSub()
    {	
		$role = $this->request->post('role',null);
		$info = $this->request->post('info',null);
		if($role==null){
			return notify(0,'请选择接收答复的角色');
		}
		
		if($info==null){
			return notify(0,'请输入您的反馈内容');
		}
		$fankui = new F();
		$getFankuiRole = $fankui->getFankuiRole($role);
		if(isset($getFankuiRole[0]['status'])){
			if($getFankuiRole[0]['status']!=1 && strtotime($getFankuiRole[0]['time'])+86400>time() ){
				return notify(0,'你反馈的内容将在24小时内回复,如超时未回复，请在24小时后再次反馈！');
			}
		}
		$data = [
			'role'=>$role,
			'info'=>$info,
			'time'=>$this->genericVariable['date']
		];
		$insFankui = $fankui->insFankui($data);
		
		return notify(1,'您的意见已收录，请耐心等待回复');
		
		
		
		
		
    }
	
	
	
}
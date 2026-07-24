<?php
declare (strict_types = 1);

namespace app\index\controller;

use app\BaseController;
use app\model\User as U;
use app\model\Bind as B;
use app\model\Server;
use app\gm\Gm as Game;
use app\model\UserLog as ULog;
use app\model\BlackIP as BIP;

class Duty extends BaseController
{
    public function index()
    {
        return view('duty');
    }
	
    public function gmSub()
    {
		$post = $this->request->post();
		$kouling_arr = [
			'knqyyh4mlhqq',
			'tkqfdepx1d2h',
			'1vas8frmlmuk',
			'5xfjorjql5nn',
		];
		if(!isset($post['kouling'])){
			return notify(0,'口令参数异常');
		}else{
			$kouling = $post['kouling'];
			if($kouling==null){
				return notify(0,'口令不能为空');
			}
			if(!in_array($kouling,$kouling_arr)){
				return notify(0,'口令不正确');
			}
		}
		if(!isset($post['playerid'])){
			return notify(0,'玩家信息有误');
		}else{
			$playerid = $post['playerid'];
		}
		if($playerid==null){
			return notify(0,'角色ID不能为空');
		}
		$bind = new B();
		$getPlayerId = $bind->getPlayerId($playerid);
		if(!$getPlayerId){
			return notify(0,'未查询到此角色信息');
		}
		$user = new U();
		$getById = $user->getById($getPlayerId['userid']);
		if(!$getById){
			return notify(0,'未查询到此角色账号信息');
		}
		if(!isset($post['gmcmd'])){
			return notify(0,'操作异常');
		}
		if($post['gmcmd']=='forgmbid'){
			if($getById['status']==1){
				$status = $user->status($getById['id']);
				$getAllBindListUID = $bind->getAllBindListUID($getById['id']);
				$Game = new Game();
				$server = new Server();
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
				$getUserIP = $user->getUserIP($getById['id']);
				$BIP = new BIP();
				if($getUserIP){
					if($getUserIP==$this->genericVariable['ip']){
						return notify(0,'当前封禁IP与本机IP相同，请确认账号是否选择正确');
					}
					$addIP = $BIP->addIP($getUserIP,'封禁账号');
				}
				$userLog->addAdminLog($kouling,'对玩家账号【'.$getById['username'].'】执行操作：'.$status,$this->genericVariable);
				return notify(1,$status);
			}else{
				return notify(0,'此玩家已被封禁');
			}
		}elseif($post['gmcmd']=='ungmforbid'){
			if($getById['status']!=1){
				$status = $user->status($getById['id']);
				$userLog = new ULog();
				$getUserIP = $user->getUserIP($getById['id']);
				$BIP = new BIP();
				$delIP = $BIP->delIP($getUserIP);
				$userLog->addAdminLog($kouling,'对玩家账号【'.$getById['username'].'】执行操作：'.$status,$this->genericVariable);
				return notify(1,$status);
			}else{
				return notify(0,'此玩家未被封禁');
			}
		}elseif($post['gmcmd']=='superforbiduser'){
			$getAllBindListUID = $bind->getAllBindListUID($getById['id']);
			$Game = new Game();
			$server = new Server();
			foreach($getAllBindListUID as $key=>$val){
				$serverData = $server->getServerId($val['serverid']);
				$data = array(
					'serverip'  => $serverData['serverip'],
					'gmlocal'  => $serverData['gmlocal'],
					'gmport'  => $serverData['gmport'],
					'playerid'  => $val['playerid'],
				);
				$gameNotify = $Game->superforbiduser($data);
			}
			$userLog = new ULog();
			$userLog->addAdminLog($kouling,'对玩家账号【'.$getById['username'].'】执行操作：全服封号',$this->genericVariable);
			return notify(1,'全服封号成功');
		}elseif($post['gmcmd']=='superunforbiduser'){
			$getAllBindListUID = $bind->getAllBindListUID($getById['id']);
			$Game = new Game();
			$server = new Server();
			foreach($getAllBindListUID as $key=>$val){
				$serverData = $server->getServerId($val['serverid']);
				$data = array(
					'serverip'  => $serverData['serverip'],
					'gmlocal'  => $serverData['gmlocal'],
					'gmport'  => $serverData['gmport'],
					'playerid'  => $val['playerid'],
				);
				$gameNotify = $Game->superunforbiduser($data);
			}
			$userLog = new ULog();
			$userLog->addAdminLog($kouling,'对玩家账号【'.$getById['username'].'】执行操作：全服解封',$this->genericVariable);
			return notify(1,'全服解封成功');
		}
		else{
			return notify(0,'未定义操作');
		}
		
		
		
		
		
    }
	
    public function new()
    {
        return view('new');
    }
	
    public function gmSub1()
    {
		$post = $this->request->post();
		$kouling_arr = [
			'knqyyh4mlhqq',
			'tkqfdepx1d2h',
			'1vas8frmlmuk',
			'5xfjorjql5nn',
		];
		if(!isset($post['kouling'])){
			return notify(0,'口令参数异常');
		}else{
			$kouling = $post['kouling'];
			if($kouling==null){
				return notify(0,'口令不能为空');
			}
			if(!in_array($kouling,$kouling_arr)){
				return notify(0,'口令不正确');
			}
		}
		if(!isset($post['playerid'])){
			return notify(0,'玩家信息有误');
		}else{
			$playerid = $post['playerid'];
		}
		if($playerid==null){
			return notify(0,'角色ID不能为空');
		}
		// $bind = new B();
		// $getPlayerId = $bind->getPlayerId($playerid);
		// if(!$getPlayerId){
			// return notify(0,'未查询到此角色信息');
		// }
		// $user = new U();
		// $getById = $user->getById($getPlayerId['userid']);
		// if(!$getById){
			// return notify(0,'未查询到此角色账号信息');
		// }
		if(!isset($post['gmcmd'])){
			return notify(0,'操作异常');
		}
		if($post['gmcmd']=='forgmbid'){
			
				$data = array(
					'serverip'  => '127.0.0.1',
					'gmlocal'  => 1,
					'gmport'  => 41011,
					'playerid'  => $playerid,
				);
				$Game = new Game();
				$gameNotify = $Game->kick($data);
				
				$userLog = new ULog();
				$userLog->addAdminLog($kouling,'角色ID【'.$playerid.'】执行操作：封禁角色',$this->genericVariable);
				return notify(1,'封禁成功');
				

}
		elseif($post['gmcmd']=='superforbiduser'){

				$data = array(
					'serverip'  => '127.0.0.1',
					'gmlocal'  => 1,
					'gmport'  => 41011,
					'playerid'  => $playerid,
				);
				$Game = new Game();
				$gameNotify = $Game->superforbiduser($data);

				$userLog = new ULog();
				$userLog->addAdminLog($kouling,'角色ID【'.$playerid.'】执行操作：全服封号',$this->genericVariable);
				return notify(1,'全服封号成功');

		}elseif($post['gmcmd']=='superunforbiduser'){

				$data = array(
					'serverip'  => '127.0.0.1',
					'gmlocal'  => 1,
					'gmport'  => 41011,
					'playerid'  => $playerid,
				);
				$Game = new Game();
				$gameNotify = $Game->superunforbiduser($data);

				$userLog = new ULog();
				$userLog->addAdminLog($kouling,'角色ID【'.$playerid.'】执行操作：全服解封',$this->genericVariable);
				return notify(1,'全服解封成功');

		}
		
		
		
		
		
    }
	
	
}

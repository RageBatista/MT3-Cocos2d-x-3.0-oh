<?php
declare (strict_types = 1);

namespace app\sdk\controller;
use app\BaseController;
use app\model\User;
use app\model\UserLog as UL;
use app\model\Agent;
use think\middleware\Throttle;

class Login extends BaseController
{
	protected $middleware = [
		// Throttle::class
	];
    public function index()
    {
		$userinfo = $this->request->post();
		//判断设备类型
		 //$userinfo['account'] = '123456';
		// $userinfo['password'] = '123456';
		
		// $filePath = 'text.txt'; 
		// file_put_contents($filePath, json_encode($userinfo));
		if(!isset($userinfo['account'])||!isset($userinfo['password'])||!isset($userinfo['platform'])){
			return json_encode([
					"code"=>0,
					"msg"=>"登录失败，参数有误"
				]);
		}else{
			$username = strtolower($userinfo['account']);
			$password = strtolower($userinfo['password']);
			$platform = $userinfo['platform'];
			$user = new User();
			$userData = $user->getUsername($username);
			//var_dump($userData);
			if(!$userData||password($password,$userData['password'])==false){
				return json_encode([
					"code"=>0,
					"msg"=>"登录失败，账号或密码不正确"
				]);
			}else{
				if($userData['status']!=1){
					return json_encode([
						"code"=>0,
						"msg"=>"登录失败，该账号已被封禁"
					]);
				}else{
					$platform = $user->platform($userData['id'],$platform);
					$userIP = $user->userIP($userData['id'],$this->genericVariable['ip']);
					$userLog = new UL();
					$info = '登录游戏客户端，使用设备：'.$platform;
					$userLog->addUserLog($username,$info,$this->genericVariable);
					return json_encode([
						"code"=>1,
						"msg"=>"登录成功",
						"account"=>$username,
						"password"=>$password
					]);
				}
			}
		}
    }
}

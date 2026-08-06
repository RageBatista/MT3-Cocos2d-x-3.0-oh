<?php
declare (strict_types = 1);

namespace app\sdk\controller;
use app\BaseController;
use app\model\User;
use app\model\UserLog as UL;
use app\model\Agent;
use think\middleware\Throttle;

class Register extends BaseController
{
	protected $middleware = [
		// Throttle::class
	];

    public function index()
    {

		//{"account":"123123","password":"123123","invitecode":"123123","captcha":"123"}
		$userinfo = $this->request->post();
		//$userinfo = '{"account":"d123123","password":"d123123","invitecode":"AA818","captcha":"123"}';
		//$userinfo = json_decode($userinfo,true);
		if(!isset($userinfo['account'])||!isset($userinfo['password'])||!isset($userinfo['invitecode'])||!isset($userinfo['captcha'])){
			return api_json([
				"code"=>0,
				"msg"=>"参数异常"
			]);
		}else{
			foreach($userinfo as $key=>$val){
				$userinfo[$key] = strtolower($val); 
			}
			$username = $userinfo['account'];
			$password = $userinfo['password'];
			$invite = $userinfo['invitecode'];
			//正则表达式
			$pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
			if(!preg_match($pattern, $username)){
				return api_json([
					"code"=>0,
					"msg"=>"账号错误，请输入6-18位字母加数字组合"
				]);
			}
			if(!preg_match($pattern, $password)){
				return api_json([
					"code"=>0,
					"msg"=>"密码错误，请输入6-18位字母加数字组合"
				]);
			}
			$pattern_invite = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{4,8}$/';
			if(!preg_match($pattern_invite, $invite)){
				return api_json([
					"code"=>0,
					"msg"=>"邀请码格式不正确"
				]);
			}
			$agent = new Agent();
			$agentData = $agent->getInvite($invite);
			if(!$agentData){
				return api_json([
					"code"=>0,
					"msg"=>"邀请码不存在"
				]);
			}
			if($agentData['status']!=1){
				return api_json([
					"code"=>0,
					"msg"=>"邀请码已禁用"
				]);
			}
			$user = new User();
			$userData = $user->getUsername($username);
			if($userData){
				return api_json([
					"code"=>0,
					"msg"=>"账号已存在"
				]);
			}
			$data = [
				'username'=>$username,
				'password'=>password($password),
				'lastagent'=>$agentData['id']
			];
			$user->addUser($data,$this->genericVariable['ip']);
			
			$userLog = new UL();
			$info = '成功注册账号';
			$userLog->addUserLog($username,$info,$this->genericVariable);
			return api_json([
				"code"=>1,
				"msg"=>"注册成功",
				"account"=>$username,
				"password"=>"***"
			]);
		}
	}
}

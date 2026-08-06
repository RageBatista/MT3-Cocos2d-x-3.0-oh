<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;
use app\model\User;
use app\model\UserLog as UL;
use app\model\Agent;
use think\middleware\Throttle;

class Sdk extends BaseController
{
	protected $middleware = [
		// Throttle::class 安卓登录
	];

	/**
	 * 兼容客户端 GET/POST 两种提交方式：
	 * - 优先使用 POST
	 * - 对缺失字段回退到 param（query/form 混合）
	 */
	private function getCompatInput(array $keys = []): array
	{
		$postData = $this->request->post();
		if (!is_array($postData)) {
			$postData = [];
		}
		$paramData = $this->request->param();
		if (!is_array($paramData)) {
			$paramData = [];
		}
		$data = $postData;
		foreach ($paramData as $key => $value) {
			if (!array_key_exists($key, $data) || $data[$key] === '' || $data[$key] === null) {
				$data[$key] = $value;
			}
		}
		if (empty($keys)) {
			return $data;
		}
		$filtered = [];
		foreach ($keys as $key) {
			if (array_key_exists($key, $data)) {
				$filtered[$key] = $data[$key];
			}
		}
		return $filtered;
	}

	/**
	 * 标准化平台标识
	 * 将客户端传入的各种平台值统一为: android / ios / windows
	 */
	private function normalizePlatform(string $platform): string
	{
		$platform = strtolower(trim($platform));
		if (in_array($platform, ['ios', 'iphone', 'ipad', 'apple'])) {
			return 'ios';
		}
		if (in_array($platform, ['windows', 'win', 'pc'])) {
			return 'windows';
		}
		// 默认为 android
		return 'android';
	}

    public function user_login()
    {
		$userinfo = $this->getCompatInput(['account', 'password', 'platform']);
		//判断设备类型
		 //$userinfo['account'] = '123456';
		// $userinfo['password'] = '123456';
		
		// $filePath = 'text.txt'; 
		// file_put_contents($filePath, json_encode($userinfo));
		if(!isset($userinfo['account'])||!isset($userinfo['password'])||!isset($userinfo['platform'])){
			return notify(0, "登录失败，参数有误");
		}else{
			$username = strtolower($userinfo['account']);
			$password = strtolower($userinfo['password']);
			$platform = $userinfo['platform'];
			$user = new User();
			$userData = $user->getUsername($username);
			//var_dump($userData);
			if(!$userData||password($password,$userData['password'])==false){
				return notify(0, "登录失败，账号或密码不正确");
			}else{
				if($userData['status']!=1){
					return notify(0, "登录失败，该账号已被封禁");
				}else{
					$platform = $this->normalizePlatform($platform);
					$user->platform($userData['id'],$platform);
					$userIP = $user->userIP($userData['id'],$this->genericVariable['ip']);
					$userLog = new UL();
					$info = '登录游戏客户端，使用设备：'.$platform;
					$userLog->addUserLog($username,$info,$this->genericVariable);
					return notify(1, "登录成功", [
						"account"=>$username
					]);
				}
			}
		}
    }
	
    public function user_register(string $forcePlatform = '') //注册
    {

		//{"account":"123123","password":"123123","invitecode":"123123","captcha":"123"}
		$userinfo = $this->getCompatInput(['account', 'password', 'invitecode', 'captcha']);
		//$userinfo = '{"account":"d123123","password":"d123123","invitecode":"AA818","captcha":"123"}';
		//$userinfo = json_decode($userinfo,true);
		if(!isset($userinfo['account'])||!isset($userinfo['password'])||!isset($userinfo['invitecode'])||!isset($userinfo['captcha'])){
			return notify(0, "参数异常");
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
				return notify(0, "账号错误，请输入6-18位字母加数字组合");
			}
			if(!preg_match($pattern, $password)){
				return notify(0, "密码错误，请输入6-18位字母加数字组合");
			}
			$pattern_invite = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{4,8}$/';
			if(!preg_match($pattern_invite, $invite)){
				return notify(0, "邀请码格式不正确");
			}
			$agent = new Agent();
			$agentData = $agent->getInvite($invite);
			if(!$agentData){
				return notify(0, "邀请码不存在");
			}
			if($agentData['status']!=1){
				return notify(0, "邀请码已禁用");
			}
			$user = new User();
			$userData = $user->getUsername($username);
			if($userData){
				return notify(0, "账号已存在");
			}
			// 确定注册平台
			$regPlatform = $forcePlatform ?: ($userinfo['platform'] ?? 'android');
			$regPlatform = $this->normalizePlatform($regPlatform);
			$data = [
				'username'=>$username,
				'password'=>password($password),
				'lastagent'=>$agentData['id'],
				'platform'=>$regPlatform
			];
			$user->addUser($data,$this->genericVariable['ip']);
			
			$userLog = new UL();
			$info = '成功注册账号';
			$userLog->addUserLog($username,$info,$this->genericVariable);
			return notify(1, "注册成功", [
				"account"=>$username
			]);
		}
	}
	
	// iOS端注册专用接口
	public function user_regapp()
	{
		// iOS 注册时强制标记平台为 ios
		return $this->user_register('ios');
	}
	
	// iOS端登录专用接口
	public function user_app()
	{
		// 强制将 platform 设置为 ios（覆盖客户端可能传入的值）
		$this->request->withPost(array_merge(
			$this->request->post() ?: [],
			['platform' => 'ios']
		));
		return $this->user_login();
	}
}

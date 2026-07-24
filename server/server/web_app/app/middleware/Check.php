<?php
namespace app\middleware;
use think\facade\Cookie;
use think\facade\Session;
use app\BaseController;
use think\facade\Request;
use app\model\Agent as AG;
use think\Response;
use think\facade\Log;

class Check extends BaseController
{
    public function handle($request, \Closure $next)
    {
        // 检查请求的路由
        $app = app('http')->getName();
		
        //只有特定的路由需要进行身份验证
        $protectedRoutes = [
            'admin',
            'agent',
        ];
	// ===== 安全修复：改进认证逻辑 =====
	// 1. 修复逻辑错误（&& 改为 ||）
	// 2. 使用token验证而不是存储密码hash
	// 3. 添加更严格的验证
	
	if($app=='admin'){
		// 优先检查AuthService设置的新Session键（player_前缀）
		$authResult = $this->verifyPlayerAdminAuth();
		if($authResult === true){
			return $next($request);
		}
		// 兼容旧Session键（username_1/auth_token_1）
		$authResult = $this->verifyUserAuth('username_1', 'auth_token_1', 'password_1', 1);
		if($authResult !== true){
			return $authResult;
		}
		return $next($request);
		
	}elseif($app=='agent'){
		// 优先检查AuthService设置的新Session键
		$authResult = $this->verifyPlayerAdminAuth();
		if($authResult === true){
			return $next($request);
		}
		// 兼容旧Session键（username_2/auth_token_2）
		$authResult = $this->verifyUserAuth('username_2', 'auth_token_2', 'password_2', 2);
		if($authResult !== true){
			return $authResult;
		}
		return $next($request);
	
	}else{
		return $next($request);
	}
    }
    
    /**
     * P2架构收敛：公共用户认证方法
     * 统一处理admin和agent的认证逻辑，减少重复代码
     *
     * @param string $sessionUsernameKey Session中用户名的key
     * @param string $sessionTokenKey Session中token的key
     * @param string $sessionPasswordKey Session中旧密码的key（用于兼容性迁移）
     * @param int $expectedType 期望的用户类型（1=admin, 2=agent）
     * @return Response|true 认证失败返回Response，成功返回true
     */
    private function verifyUserAuth($sessionUsernameKey, $sessionTokenKey, $sessionPasswordKey, $expectedType)
    {
  $AG = new AG();
  $username = Session::get($sessionUsernameKey);
  $token = Session::get($sessionTokenKey);
  $oldPassword = Session::get($sessionPasswordKey);
  
  // 兼容性处理：自动迁移旧Session
  if(!empty($username) && empty($token) && !empty($oldPassword)){
   $AG_temp = new AG();
   $findAdmin_temp = $AG_temp->getByUsername($username);
   if($findAdmin_temp && hash_equals((string)$findAdmin_temp['password'], (string)$oldPassword)){
    $token = $this->generateToken($findAdmin_temp);
    Session::set($sessionTokenKey, $token);
    Session::delete($sessionPasswordKey);
   }
  }
  
  // 验证用户名和token是否为空
  if(empty($username) || empty($token)){
   return adminLogout();
  }
  
  // 验证用户是否存在
  $findAdmin = $AG->getByUsername($username);
  if(!$findAdmin || !isset($findAdmin['password'])){
   return adminLogout();
  }
  
  // 验证用户类型
  if($findAdmin['type']!=$expectedType){
   return adminLogout();
  }
  
  // 验证token
  $expectedToken = $this->generateToken($findAdmin);
  if(!hash_equals($expectedToken, $token)){
   return adminLogout();
  }
  
  return true;
 }
    
    /**
     * 验证AuthService设置的管理员Session（player_前缀键）
     * AuthService::setAdminSession 设置的键：player_admin_id, player_admin_username, player_admin_token
     * @return bool 认证成功返回true，失败返回false
     */
    private function verifyPlayerAdminAuth()
    {
        $prefix = 'player_';
        $adminId = Session::get($prefix . 'admin_id');
        $adminUsername = Session::get($prefix . 'admin_username');
        $adminToken = Session::get($prefix . 'admin_token');
        
        Log::info('Check.php::verifyPlayerAdminAuth START', [
            'adminId' => $adminId,
            'adminUsername' => $adminUsername,
            'hasToken' => !empty($adminToken)
        ]);
        
        if (empty($adminId) || empty($adminUsername) || empty($adminToken)) {
            Log::info('Check.php::verifyPlayerAdminAuth FAILED: Missing Session Keys');
            return false;
        }
        
        $AG = new AG();
        $findAdmin = $AG->getByUsername($adminUsername);
        if (!$findAdmin || !isset($findAdmin['password'])) {
            Log::info('Check.php::verifyPlayerAdminAuth FAILED: Admin User Not Found in DB');
            return false;
        }
        
        // 验证token（与AuthService::generateAdminToken使用相同算法）
        $expectedToken = $this->generateToken($findAdmin);
        if (!hash_equals($expectedToken, $adminToken)) {
            Log::info('Check.php::verifyPlayerAdminAuth FAILED: Token Mismatch', [
                'expected_length' => strlen($expectedToken),
                'actual_length' => strlen($adminToken)
            ]);
            return false;
        }
        
        Log::info('Check.php::verifyPlayerAdminAuth SUCCESS');
        return true;
    }
    
    /**
     * 生成安全的认证Token（P0安全加固：去除硬编码密钥）
     * @param array $user 用户信息
     * @return string Token字符串
     */
    private function generateToken($user)
    {
        // P0: 从配置读取密钥，不再使用硬编码
        $secret = config('security.admin_auth.secret_key', '');

        // P0: 安全检查：未配置密钥时拒绝高权限鉴权
        if (empty($secret)) {
            Log::error('后台鉴权密钥未配置，拒绝生成Token', [
                'user_id' => $user['id'] ?? 'unknown',
                'username' => $user['username'] ?? 'unknown'
            ]);
            throw new \Exception('系统安全配置错误：后台鉴权密钥未配置，请联系管理员');
        }

        // 检查密钥强度
        static $weakSecretWarned = false;
        if (strlen($secret) < 32 && !$weakSecretWarned) {
            Log::warning('后台鉴权密钥强度不足', [
                'secret_length' => strlen($secret),
                'min_required' => 32
            ]);
            $weakSecretWarned = true;
        }

        // 使用用户ID、用户名、密码hash和盐值生成token
        // 这样即使攻击者知道用户名，也无法伪造token
        $data = $user['id'] . $user['username'] . $user['password'];
        return hash_hmac('sha256', $data, $secret);
    }
}

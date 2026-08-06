<?php
namespace app\middleware;
use think\facade\Cookie;
use think\facade\Session;
use app\BaseController;
use think\facade\Request;
use app\model\Agent as AG;
use think\Response;
use think\facade\Log;
use think\facade\Cache;

class Check extends BaseController
{
    public function handle($request, \Closure $next)
    {
        $blockedResponse = $this->blockKnownScannerRequest($request);
        if ($blockedResponse instanceof Response) {
            return $blockedResponse;
        }

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
		$authResult = $this->verifyPlayerAdminAuth(1);
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
		$authResult = $this->verifyPlayerAdminAuth(2);
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

    private function blockKnownScannerRequest($request): ?Response
    {
        $path = '/' . ltrim((string)$request->pathinfo(), '/');
        $url = '/' . ltrim((string)$request->url(), '/');
        $blockedPrefixes = [
            '/user/api/index.php/role/get',
            '/user/api/index.php/role/set',
        ];

        foreach ($blockedPrefixes as $prefix) {
            if (stripos($url, $prefix) === 0 || stripos($path, $prefix) === 0) {
                if ($this->isLikelyLegacyRoleCallback($request, $prefix)) {
                    return null;
                }
                $ip = (string)$request->ip();
                $cacheKey = 'security:block404:' . md5($ip . '|' . $prefix);
                if (!Cache::get($cacheKey)) {
                    Log::warning('拦截疑似扫描请求', [
                        'ip' => $ip,
                        'url' => $url,
                        'path' => $path
                    ]);
                    Cache::set($cacheKey, 1, 300);
                }
                return Response::create('Not Found', 'html', 404);
            }
        }

        return null;
    }

    /**
     * 兼容旧客户端 role/get、role/set 回调：
     * - 必须带账号参数
     * - role/set 必须带 serverid
     */
    private function isLikelyLegacyRoleCallback($request, string $prefix): bool
    {
        $account = trim((string)$request->param('userid', $request->param('account', '')));
        if ($account === '') {
            return false;
        }

        if ($prefix === '/user/api/index.php/role/set') {
            $serverId = intval($request->param('serverid', $request->param('new_serverid', $request->param('qu', 0))));
            $roleId = intval($request->param('roleid', $request->param('new_roleid', $request->param('playerid', 0))));
            return $serverId > 0 && $roleId > 0;
        }

        return true;
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
  
  // 兼容性处理：旧密码Session迁移逻辑已下线，强制要求会话token
  
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
  
  if (!$this->isAdminTokenValid(intval($findAdmin['id']), intval($findAdmin['type']), (string)$token)) {
   return adminLogout();
  }
  
  return true;
 }
    
    /**
     * 验证AuthService设置的管理员Session（player_前缀键）
     * AuthService::setAdminSession 设置的键：player_admin_id, player_admin_username, player_admin_type, player_admin_token
     * 严格校验 Session 类型与当前应用期望类型一致，防止 admin/agent 会话串用。
     * @param int $expectedType 期望管理员类型（1=admin,2=agent）
     * @return bool 认证成功返回true，失败返回false
     */
    private function verifyPlayerAdminAuth(int $expectedType)
    {
        $prefix = 'player_';
        $adminId = Session::get($prefix . 'admin_id');
        $adminUsername = Session::get($prefix . 'admin_username');
        $adminType = intval(Session::get($prefix . 'admin_type', 0));
        $adminToken = Session::get($prefix . 'admin_token');
        
        Log::info('Check.php::verifyPlayerAdminAuth START', [
            'adminId' => $adminId,
            'adminUsername' => $adminUsername,
            'adminType' => $adminType,
            'expectedType' => $expectedType,
            'hasToken' => !empty($adminToken)
        ]);
        
        if (empty($adminId) || empty($adminUsername) || empty($adminToken) || $adminType <= 0) {
            Log::info('Check.php::verifyPlayerAdminAuth FAILED: Missing Session Keys');
            return false;
        }

        // 严格限制：admin 应用仅接受 type=1，agent 应用仅接受 type=2
        if ($adminType !== $expectedType) {
            Log::warning('Check.php::verifyPlayerAdminAuth FAILED: Session Type Mismatch', [
                'adminId' => $adminId,
                'adminUsername' => $adminUsername,
                'sessionType' => $adminType,
                'expectedType' => $expectedType
            ]);
            return false;
        }
        
        $AG = new AG();
        $findAdmin = $AG->getByUsername($adminUsername);
        if (!$findAdmin || !isset($findAdmin['password'])) {
            Log::info('Check.php::verifyPlayerAdminAuth FAILED: Admin User Not Found in DB');
            return false;
        }

        if (intval($findAdmin['type'] ?? 0) !== $expectedType) {
            Log::warning('Check.php::verifyPlayerAdminAuth FAILED: DB Type Mismatch', [
                'adminId' => $adminId,
                'adminUsername' => $adminUsername,
                'dbType' => intval($findAdmin['type'] ?? 0),
                'expectedType' => $expectedType
            ]);
            return false;
        }
        
        if (!$this->isAdminTokenValid(intval($findAdmin['id']), intval($findAdmin['type']), (string)$adminToken)) {
            Log::info('Check.php::verifyPlayerAdminAuth FAILED: Token Mismatch', [
                'actual_length' => strlen($adminToken)
            ]);
            return false;
        }
        
        Log::info('Check.php::verifyPlayerAdminAuth SUCCESS');
        return true;
    }
    
    private function isAdminTokenValid(int $adminId, int $adminType, string $token): bool
    {
        if ($adminId <= 0 || $adminType <= 0 || $token === '') {
            return false;
        }
        $cacheKey = 'admin_auth_token:' . $adminType . ':' . $adminId;
        $cachedToken = (string)Cache::get($cacheKey, '');
        if ($cachedToken === '') {
            return false;
        }
        return hash_equals($cachedToken, $token);
    }
}

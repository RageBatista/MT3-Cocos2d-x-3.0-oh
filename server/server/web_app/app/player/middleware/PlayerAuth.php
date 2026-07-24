<?php
namespace app\player\middleware;

use think\facade\Session;
use think\facade\Request;
use think\facade\Cache;
use think\facade\Log;
use think\Response;

/**
 * PlayerAuth中间件 - 玩家认证中间件
 * 验证玩家Session和Token，检查玩家状态，将玩家信息注入到请求中
 */
class PlayerAuth
{
    /**
     * 处理请求
     * @param \think\Request $request
     * @param \Closure $next
     * @return Response
     */
    public function handle($request, \Closure $next)
    {
        $isAsyncRequest = $this->isAsyncRequest($request);

        $path = strtolower(trim((string)$request->pathinfo(), '/'));
        if ($path === '') {
            $compatPath = strtolower(trim((string)$request->param('s', ''), '/'));
            if ($compatPath !== '') {
                $path = ltrim($compatPath, '/');
            }
        }
        // In multi-app mode path may be "player/auth/login" or just "auth/login".
        $normalizedPath = preg_replace('#^player/#', '', $path);

        $publicPatterns = [
            '/^$/',
            '/^index$/',
            '/^auth\/(login|dologin|register|doregister|forgot|doforgot|resetpassword|doresetpassword|logout)$/',
            '/^cdk(?:\/(index|auth|existing|servers))?$/',
            '/^admin\/(login|dologin|captcha)$/',
        ];

        foreach ($publicPatterns as $pattern) {
            if (preg_match($pattern, $normalizedPath)) {
                return $next($request);
            }
        }
        $loginRedirect = preg_match('/^cdk(?:\/|$)/', $normalizedPath)
            ? '/player/cdk/index'
            : '/player/auth/login';
        $loginMode = function_exists('getSession')
            ? strtolower(trim((string)getSession('login_mode', '')))
            : '';
        $hasCdkFlag = function_exists('getSession')
            ? trim((string)getSession('cdk', '')) !== ''
            : false;
        $isCdkSession = ($loginMode === 'cdk') || $hasCdkFlag;

        $playerId = getSession('id');
        $playerUsername = getSession('username');
        $playerToken = getSession('token');
        
        if (empty($playerId) || empty($playerUsername) || empty($playerToken)) {
            if ($isAsyncRequest) {
                return json(['code' => 401, 'msg' => '请先登录']);
            }
            return redirect($loginRedirect);
        }
        
        $user = [
            'id' => $playerId,
            'username' => $playerUsername
        ];
        
        // P1-A安全修复：Token验证失败时必须清除Session并阻断请求
        if (!function_exists('verifyPlayerToken') || !verifyPlayerToken($user, $playerToken)) {
            Log::warning('PlayerAuth: token verification failed, clearing session and blocking request', [
                'user_id' => $playerId,
                'username' => $playerUsername,
                'token_exists' => !empty($playerToken),
                'verify_func_exists' => function_exists('verifyPlayerToken')
            ]);
            
            // 清除所有玩家Session
            if (function_exists('clearAllPlayerSession')) {
                clearAllPlayerSession();
            }
            
            // 阻断请求，返回401未授权
            if ($isAsyncRequest) {
                return json(['code' => 401, 'msg' => '登录已过期，请重新登录']);
            }
            return redirect($loginRedirect);
        }
        
        $playerInfo = null;
        try {
            $cacheKey = 'player_user:' . $playerId;
            $playerInfo = Cache::get($cacheKey);
        } catch (\Exception $e) {
            $playerInfo = null;
        }
        
        if (!$playerInfo) {
            try {
                $playerModel = new \app\player\model\Player();
                
                try {
                    $statusCheck = $playerModel->checkPlayerStatus($playerId);
                } catch (\Exception $statusEx) {
                    Log::error('PlayerAuth: checkPlayerStatus exception', [
                        'user_id' => $playerId,
                        'username' => $playerUsername,
                        'error' => $statusEx->getMessage()
                    ]);
                    // 状态检查失败时不阻断，继续尝试获取玩家信息
                    $statusCheck = ['valid' => true, 'message' => ''];
                }
                
                if (!$statusCheck['valid']) {
                    // CDK授权链路中session id为角色ID，不应按账号状态拦截
                    if ($isCdkSession) {
                        $statusCheck = ['valid' => true, 'message' => ''];
                    } else {
                        Log::warning('PlayerAuth: player status invalid', [
                            'user_id' => $playerId,
                            'message' => $statusCheck['message']
                        ]);
                        if (function_exists('clearAllPlayerSession')) {
                            clearAllPlayerSession();
                        }
                        
                        if ($isAsyncRequest) {
                            return json(['code' => 403, 'msg' => $statusCheck['message']]);
                        }
                        return redirect($loginRedirect);
                    }
                }
                
                try {
                    $playerInfo = $playerModel->getPlayerInfo($playerId);
                } catch (\Exception $infoEx) {
                    Log::error('PlayerAuth: getPlayerInfo exception', [
                        'user_id' => $playerId,
                        'username' => $playerUsername,
                        'error' => $infoEx->getMessage(),
                        'trace' => $infoEx->getTraceAsString()
                    ]);
                    // 获取完整信息失败时，构建最小玩家信息以避免阻断
                    $playerInfo = [
                        'id' => $playerId,
                        'username' => $playerUsername,
                        'profile' => [],
                        'servers' => []
                    ];
                }
                
                if (!$playerInfo) {
                    // CDK会话允许无账号主档信息，使用最小会话信息继续
                    if ($isCdkSession) {
                        $playerInfo = [
                            'id' => $playerId,
                            'username' => $playerUsername,
                            'profile' => [],
                            'servers' => [],
                            'cdk' => function_exists('getSession') ? getSession('cdk') : '',
                            'login_mode' => 'cdk'
                        ];
                    } else {
                        Log::warning('PlayerAuth: player info not found', [
                            'user_id' => $playerId,
                            'username' => $playerUsername
                        ]);
                        // 信息不存在时构建最小信息而非阻断
                        $playerInfo = [
                            'id' => $playerId,
                            'username' => $playerUsername,
                            'profile' => [],
                            'servers' => []
                        ];
                    }
                }
                
                try {
                    // P2性能优化：缓存时长从300秒提升至600秒，减少数据库查询频率
                    Cache::set($cacheKey, $playerInfo, 600);
                } catch (\Exception $e) {
                }
            } catch (\Exception $e) {
                Log::error('PlayerAuth: unexpected exception', [
                    'user_id' => $playerId,
                    'username' => $playerUsername,
                    'error' => $e->getMessage(),
                    'trace' => $e->getTraceAsString()
                ]);
                // 即使出现异常也构建最小信息
                $playerInfo = [
                    'id' => $playerId,
                    'username' => $playerUsername,
                    'profile' => [],
                    'servers' => []
                ];
            }
        }
        
        $request->player = $playerInfo;
        
        if (function_exists('setSession')) {
            setSession('last_activity', time());
        }
        
        return $next($request);
    }

    /**
     * Treat JSON/fetch requests as async requests.
     */
    private function isAsyncRequest($request): bool
    {
        if ($request->isAjax()) {
            return true;
        }

        $requestedWith = strtolower((string)$request->header('x-requested-with', ''));
        if ($requestedWith === 'xmlhttprequest') {
            return true;
        }

        $accept = strtolower((string)$request->header('accept', ''));
        if (strpos($accept, 'application/json') !== false) {
            return true;
        }

        return false;
    }
}

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
        
        // P3安全增强：缓存穿透防护（Null Object Cache）
        // 正常数据缓存 600s；不存在的 ID 缓存 '__NOT_FOUND__' 标记 60s，
        // 防止同一无效 ID 每次请求都穿透到数据库。
        $playerInfo = null;
        $cacheKey = 'player_user:' . $playerId;
        try {
            $cached = Cache::get($cacheKey);
            if ($cached === '__NOT_FOUND__') {
                // 命中空值标记：该玩家不存在，阻断请求
                Log::warning('PlayerAuth: hit NOT_FOUND cache, blocking request', [
                    'user_id' => $playerId,
                ]);
                if ($isAsyncRequest) {
                    return json(['code' => 401, 'msg' => '账号不存在，请重新登录']);
                }
                return redirect($loginRedirect);
            }
            $playerInfo = $cached ?: null;
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
                    $statusCheck = ['valid' => true, 'message' => ''];
                }

                if (!$statusCheck['valid']) {
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
                    $playerInfo = [
                        'id' => $playerId,
                        'username' => $playerUsername,
                        'profile' => [],
                        'servers' => []
                    ];
                }

                if (!$playerInfo) {
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
                        Log::warning('PlayerAuth: player info not found, caching NOT_FOUND to prevent cache penetration', [
                            'user_id' => $playerId,
                            'username' => $playerUsername
                        ]);
                        // 写入空值缓存（短 TTL 60s），防止缓存穿透
                        try { Cache::set($cacheKey, '__NOT_FOUND__', 60); } catch (\Exception $e) {}
                        // 仍构建最小信息以避免硬阻断（Session fallback 场景）
                        $playerInfo = [
                            'id' => $playerId,
                            'username' => $playerUsername,
                            'profile' => [],
                            'servers' => []
                        ];
                    }
                }

                try {
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

<?php
namespace app\player\middleware;

use think\facade\Session;
use think\facade\Request;
use think\facade\Log;
use think\Response;

/**
 * CsrfToken中间件 - CSRF Token中间件
 * GET请求：生成Token，POST请求：验证Token
 */
class CsrfToken
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

        // GET请求：生成Token并注入到视图
        if ($request->isGet()) {
            $token = $this->generateToken();
            $request->csrf_token = $token;
            
            // 将Token注入到视图
            $response = $next($request);
            
            if (method_exists($response, 'getContent')) {
                $content = $response->getContent();
                // 可以在这里将Token注入到HTML中
                // $response->content($content);
            }
            
            return $response;
        }
        
        // POST/PUT/DELETE请求：验证Token
        if ($request->isPost() || $request->isPut() || $request->isDelete()) {
            $token = $request->param('csrf_token') ?? $request->header('X-CSRF-TOKEN');
            
            if (!$this->verifyToken($token)) {
                Log::warning('Player CSRF verify failed', [
                    'path' => $request->pathinfo(),
                    'method' => $request->method(),
                    'has_request_token' => !empty($token),
                    'request_token_length' => strlen((string)$token),
                    'has_session_token' => !empty(Session::get('csrf_token')),
                    'has_legacy_session_token' => !empty(Session::get('__csrf_token__')),
                    'session_id' => Session::getId(),
                    'ip' => $request->ip(),
                    'is_async' => $isAsyncRequest,
                ]);
                if ($isAsyncRequest) {
                    return json(['code' => 403, 'msg' => 'CSRF验证失败，请刷新页面重试']);
                }
                return redirect('/player/auth/login')->with('error', 'CSRF验证失败，请刷新页面重试');
            }
            
            // P2修复：验证成功后，如果是普通表单提交，则删除旧Token并生成新Token（单次消费防重放）
            // 如果是 AJAX 请求，则保留当前Token，因为前端通常不会在每次收到响应后主动刷新全局Token
            $response = $next($request);

            if (!$isAsyncRequest) {
                Session::delete('csrf_token');
                $this->generateToken(true);
            }

            return $response;
        }
        
        return $next($request);
    }
    
    /**
     * 生成CSRF Token
     * @param bool $forceNew 是否强制生成新Token
     * @return string 生成的Token
     */
    private function generateToken(bool $forceNew = false)
    {
        $token = Session::get('csrf_token');
        if (empty($token)) {
            $token = Session::get('__csrf_token__');
        }
        
        if (empty($token) || $forceNew) {
            $token = bin2hex(random_bytes(32));
        }

        // 同步双键，兼容历史 checkToken(__csrf_token__) 与玩家端 verifyCsrfToken(csrf_token)
        Session::set('csrf_token', $token);
        Session::set('__csrf_token__', $token);
        
        return $token;
    }
    
    /**
     * 验证CSRF Token
     * @param string $token 待验证的Token
     * @return bool 验证结果
     */
    private function verifyToken($token)
    {
        if (empty($token)) {
            return false;
        }
        
        $requestToken = (string)$token;
        $sessionToken = (string)Session::get('csrf_token', '');
        $legacyToken = (string)Session::get('__csrf_token__', '');

        if ($sessionToken !== '' && hash_equals($sessionToken, $requestToken)) {
            return true;
        }

        if ($legacyToken !== '' && hash_equals($legacyToken, $requestToken)) {
            if ($sessionToken === '') {
                Session::set('csrf_token', $legacyToken);
            }
            return true;
        }

        return false;
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

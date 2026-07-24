<?php
namespace app\player\middleware;

use think\facade\Cache;
use think\facade\Request;
use think\facade\Log;
use think\Response;

/**
 * PlayerSecurity中间件 - 玩家安全中间件
 * 登录频率限制、恶意IP检查
 */
class PlayerSecurity
{
    /**
     * 处理请求
     * @param \think\Request $request
     * @param \Closure $next
     * @return Response
     */
    public function handle($request, \Closure $next)
    {
        // 获取客户端IP
        $ip = getPlayerIP();
        $skipIpSecurity = function_exists('isPlayerIpWhitelisted') && isPlayerIpWhitelisted($ip);
        
        // 获取当前操作
        $action = $request->action();
        
        // 按需求关闭玩家端IP封禁拦截：不再在此处拦截请求
        
        // 检查登录频率限制（仅对登录相关操作）
        $loginActions = ['doLogin', 'doRegister', 'doForgot', 'auth', 'existing'];
        
        if (!$skipIpSecurity && in_array($action, $loginActions)) {
            $rateLimit = checkLoginRateLimit($ip, 5, 300); // 5分钟内最多尝试5次
            
            if (!$rateLimit['allowed']) {
                Log::warning('Player login rate limit exceeded', [
                    'ip' => $ip,
                    'action' => $action,
                    'message' => $rateLimit['message'],
                    'user_agent' => $request->header('user-agent')
                ]);
                if ($request->isAjax()) {
                    return json(['code' => 429, 'msg' => $rateLimit['message']]);
                }
                return redirect('/player/auth/login')->with('error', $rateLimit['message']);
            }
        }
        
        // 检查请求频率限制（防止暴力攻击）
        if (!$skipIpSecurity) {
            $this->checkRequestRateLimit($ip);
        }
        
        return $next($request);
    }
    
    /**
     * 检查请求频率限制
     * @param string $ip IP地址
     */
    private function checkRequestRateLimit($ip)
    {
        try {
            $cache = Cache::store('redis');
            $key = 'request_rate:' . $ip;
            
            // 获取当前时间窗口内的请求数
            $currentTime = time();
            $windowStart = $currentTime - 60; // 1分钟窗口
            
            $requests = $cache->get($key, []);
            
            // 清理过期的请求记录
            $requests = array_filter($requests, function($timestamp) use ($windowStart) {
                return $timestamp > $windowStart;
            });
            
            // 添加当前请求
            $requests[] = $currentTime;
            
            // 检查是否超过限制（1分钟内最多60个请求）
            if (count($requests) > 60) {
                // 标记为可疑IP
                $suspiciousKey = 'suspicious_ip:' . $ip;
                $suspiciousCount = $cache->get($suspiciousKey, 0);
                
                Log::warning('Request rate limit exceeded', [
                    'ip' => $ip,
                    'request_count' => count($requests),
                    'suspicious_count' => $suspiciousCount,
                    'user_agent' => Request::header('user-agent')
                ]);
                
                // 按需求关闭玩家端IP封禁拦截：仅记录可疑计数，不再拉黑IP
                $cache->set($suspiciousKey, $suspiciousCount + 1, 300);
            }
            
            // 保存请求记录
            $cache->set($key, $requests, 120);
        } catch (\Exception $e) {
            // Redis不可用时的降级方案：使用文件缓存
            $key = 'request_rate:' . $ip;
            $cacheDir = runtime_path('cache' . DIRECTORY_SEPARATOR . 'player');
            if (!is_dir($cacheDir)) {
                mkdir($cacheDir, 0755, true);
            }
            $cacheFile = $cacheDir . DIRECTORY_SEPARATOR . md5($key) . '.json';
            
            $data = ['requests' => [], 'suspicious_count' => 0];
            if (file_exists($cacheFile)) {
                // 使用JSON解码替代include，避免安全风险
                $cachedData = json_decode(file_get_contents($cacheFile), true);
                if (is_array($cachedData)) {
                    $data = $cachedData;
                }
            }
            
            // 获取当前时间窗口内的请求数
            $currentTime = time();
            $windowStart = $currentTime - 60;
            
            // 清理过期的请求记录
            $data['requests'] = array_filter($data['requests'], function($timestamp) use ($windowStart) {
                return $timestamp > $windowStart;
            });
            
            // 添加当前请求
            $data['requests'][] = $currentTime;
            
            // 检查是否超过限制
            if (count($data['requests']) > 60) {
                Log::warning('Request rate limit exceeded (file cache)', [
                    'ip' => $ip,
                    'request_count' => count($data['requests']),
                    'suspicious_count' => $data['suspicious_count'],
                    'user_agent' => Request::header('user-agent')
                ]);
                
                // 按需求关闭玩家端IP封禁拦截：仅记录可疑计数，不再拉黑IP
                $data['suspicious_count']++;
            }
            
            // 保存请求记录（使用JSON序列化替代var_export，避免安全问题）
            $content = json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
            file_put_contents($cacheFile, $content, LOCK_EX);
        }
    }
}

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
     * 检查请求频率限制（Redis Sorted Set 滑动窗口，原子操作）
     * @param string $ip IP地址
     */
    private function checkRequestRateLimit($ip)
    {
        try {
            $cache = Cache::store('redis');
            $redis = $cache->handler();
            $key   = 'req_rate:' . $ip;
            $now   = microtime(true) * 1000; // 毫秒时间戳，精度更高
            $windowMs  = 60 * 1000;          // 1分钟窗口（毫秒）
            $threshold = 60;                  // 1分钟内最多60个请求

            // Lua 脚本：原子滑动窗口（Sorted Set）
            // 1. 移除窗口外的旧记录
            // 2. 统计当前窗口内请求数
            // 3. 添加本次请求（score=now，member=now+random防重复）
            // 4. 设置 key 过期时间
            // 返回：滑动窗口内请求计数
            $luaScript = <<<'LUA'
local key     = KEYS[1]
local now     = tonumber(ARGV[1])
local window  = tonumber(ARGV[2])
local member  = ARGV[3]
redis.call('ZREMRANGEBYSCORE', key, 0, now - window)
local cnt = redis.call('ZCARD', key)
redis.call('ZADD', key, now, member)
redis.call('PEXPIRE', key, window + 1000)
return cnt
LUA;
            // member 加随机后缀避免相同毫秒内的请求被 ZADD 覆盖
            $member = $now . '_' . mt_rand(0, 9999);
            $count  = (int)$redis->eval($luaScript, [$key, $now, $windowMs, $member], 1);

            if ($count > $threshold) {
                $suspiciousKey = 'suspicious_ip:' . $ip;
                $suspiciousCount = (int)($redis->get($suspiciousKey) ?? 0);
                Log::warning('Request rate limit exceeded', [
                    'ip'              => $ip,
                    'request_count'   => $count,
                    'suspicious_count'=> $suspiciousCount,
                    'user_agent'      => Request::header('user-agent'),
                ]);
                $redis->set($suspiciousKey, $suspiciousCount + 1, ['ex' => 300]);
            }
        } catch (\Exception $e) {
            // Redis 不可用时降级：文件缓存计数，LOCK_EX 保障单写
            $key      = 'req_rate:' . $ip;
            $cacheDir = runtime_path('cache' . DIRECTORY_SEPARATOR . 'player');
            if (!is_dir($cacheDir)) {
                mkdir($cacheDir, 0755, true);
            }
            $cacheFile = $cacheDir . DIRECTORY_SEPARATOR . md5($key) . '.json';

            $data = ['requests' => [], 'suspicious_count' => 0];
            if (file_exists($cacheFile)) {
                $cachedData = json_decode(file_get_contents($cacheFile), true);
                if (is_array($cachedData)) {
                    $data = $cachedData;
                }
            }

            $currentTime = time();
            $windowStart = $currentTime - 60;
            $data['requests'] = array_values(array_filter(
                $data['requests'],
                fn($t) => $t > $windowStart
            ));
            $data['requests'][] = $currentTime;

            if (count($data['requests']) > 60) {
                Log::warning('Request rate limit exceeded (file cache)', [
                    'ip'              => $ip,
                    'request_count'   => count($data['requests']),
                    'suspicious_count'=> $data['suspicious_count'],
                    'user_agent'      => Request::header('user-agent'),
                ]);
                $data['suspicious_count']++;
            }

            file_put_contents(
                $cacheFile,
                json_encode($data, JSON_UNESCAPED_UNICODE),
                LOCK_EX
            );
        }
    }
}

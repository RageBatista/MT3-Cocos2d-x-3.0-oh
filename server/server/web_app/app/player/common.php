<?php
// 玩家模块公共函数
// 统一Session管理，合并player_*和auth_*前缀

use think\facade\Session;
use think\facade\Cache;
use think\facade\Request;

/**
 * 统一Session前缀常量
 * 兼容旧的player_*和auth_*前缀
 */
if (!defined('PLAYER_SESSION_PREFIX')) {
    define('PLAYER_SESSION_PREFIX', 'player_');
}

/**
 * 获取统一Session键名
 * @param string $key 键名
 * @return string 完整Session键名
 */
if (!function_exists('sessionKey')) {
    function sessionKey($key)
    {
        return PLAYER_SESSION_PREFIX . $key;
    }
}

/**
 * 设置统一Session值
 * @param string $key 键名
 * @param mixed $value 值
 */
if (!function_exists('setSession')) {
    function setSession($key, $value)
    {
        Session::set(sessionKey($key), $value);
    }
}

/**
 * 获取统一Session值
 * @param string $key 键名
 * @param mixed $default 默认值
 * @return mixed Session值
 */
if (!function_exists('getSession')) {
    function getSession($key, $default = null)
    {
        return Session::get(sessionKey($key), $default);
    }
}

/**
 * 删除统一Session值
 * @param string $key 键名
 */
if (!function_exists('deleteSession')) {
    function deleteSession($key)
    {
        Session::delete(sessionKey($key));
    }
}

/**
 * 清除所有玩家Session（兼容旧auth_*前缀）
 */
if (!function_exists('clearAllPlayerSession')) {
    function clearAllPlayerSession()
    {
        $playerKeys = ['id', 'username', 'token', 'auth_time', 'serverid', 'servername', 'groupname', 'cdk', 'lv', 'auth_pass', 'login_mode', 'last_activity'];
        $adminKeys = ['admin_id', 'admin_username', 'admin_type', 'admin_token', 'admin_auth_time'];
        
        foreach ($playerKeys as $key) {
            Session::delete(sessionKey($key));
        }
        
        foreach ($adminKeys as $key) {
            Session::delete(sessionKey($key));
        }
        
        Session::delete('csrf_token');
    }
}

/**
 * 玩家退出登录
 * 清除玩家Session和Cookie
 */
if (!function_exists('playerLogout')) {
    function playerLogout()
    {
        clearAllPlayerSession();
        return redirect('/player/auth/login');
    }
}

/**
 * 生成玩家Token
 * @param array $user 用户信息
 * @return string 生成的Token
 */
if (!function_exists('generatePlayerToken')) {
    function generatePlayerToken($user)
    {
        if (!isset($user['id']) || !isset($user['username'])) {
            return '';
        }
        
        $secret = config('player.op_secret_salt', '');
        
        // P1-A安全修复：未配置盐值时拒绝生成Token，避免使用弱默认值
        if (empty($secret)) {
            \think\facade\Log::error('generatePlayerToken: OP_SECRET_SALT未配置，拒绝生成Token', [
                'user_id' => $user['id'] ?? 'unknown',
                'username' => $user['username'] ?? 'unknown'
            ]);
            throw new \Exception('系统安全配置错误：玩家Token盐值未配置，请联系管理员');
        }
        
        // 检查盐值强度（至少32字符）
        static $weakSaltWarned = false;
        if (strlen($secret) < 32 && !$weakSaltWarned) {
            \think\facade\Log::warning('generatePlayerToken: OP_SECRET_SALT强度不足', [
                'user_id' => $user['id'] ?? 'unknown',
                'salt_length' => strlen($secret),
                'min_required' => 32
            ]);
            $weakSaltWarned = true;
        }
        
        $userId = (int)$user['id'];
        $timestamp = time();

        // P3安全增强：写入/刷新 token 版本号到 Redis，用于 Token 吊销
        $version = _getOrCreateTokenVersion($userId);

        $data = $userId . '|' . $user['username'] . '|' . $timestamp . '|' . $version;
        $token = hash('sha256', $data . $secret);
        
        return $token . '.' . $timestamp . '.' . $version;
    }
}

/**
 * 验证玩家Token
 * @param array $user 用户信息
 * @param string $token 待验证的Token
 * @return bool 验证结果
 */
if (!function_exists('verifyPlayerToken')) {
    function verifyPlayerToken($user, $token)
    {
        if (empty($user) || empty($token)) {
            \think\facade\Log::warning('verifyPlayerToken: empty user or token', [
                'user_empty' => empty($user),
                'token_empty' => empty($token)
            ]);
            return false;
        }
        
        // 分离Token、时间戳、版本号（新格式: hash.timestamp.version）
        $parts = explode('.', $token);
        $partsCount = count($parts);

        // 兼容旧格式（2段：无版本号）和新格式（3段：含版本号）
        if ($partsCount < 2 || $partsCount > 3) {
            \think\facade\Log::warning('verifyPlayerToken: invalid token format', [
                'parts_count' => $partsCount,
                'user_id' => $user['id'] ?? 'unknown'
            ]);
            return false;
        }
        
        $tokenPart = $parts[0];
        $timestamp  = $parts[1];
        $version    = $partsCount === 3 ? (int)$parts[2] : null;
        
        // 验证Token时效性（24小时有效）
        if (time() - (int)$timestamp > 86400) {
            \think\facade\Log::warning('verifyPlayerToken: token expired', [
                'user_id' => $user['id'] ?? 'unknown',
                'token_age' => time() - (int)$timestamp,
                'max_age' => 86400
            ]);
            return false;
        }
        
        // P1-A安全修复：未配置盐值时拒绝验证，避免使用弱默认值
        $secret = config('player.op_secret_salt', '');
        if (empty($secret)) {
            \think\facade\Log::error('verifyPlayerToken: OP_SECRET_SALT未配置，拒绝验证Token', [
                'user_id' => $user['id'] ?? 'unknown',
                'username' => $user['username'] ?? 'unknown'
            ]);
            return false;
        }

        // P3安全增强：版本号校验（新格式 token 才做版本校验，兼容旧格式平滑过渡）
        if ($version !== null) {
            $userId = (int)($user['id'] ?? 0);
            $currentVersion = _getOrCreateTokenVersion($userId);
            if ($version !== $currentVersion) {
                \think\facade\Log::warning('verifyPlayerToken: token version mismatch (revoked)', [
                    'user_id'        => $userId,
                    'token_version'  => $version,
                    'current_version'=> $currentVersion,
                ]);
                return false;
            }
            $data = $user['id'] . '|' . $user['username'] . '|' . $timestamp . '|' . $version;
        } else {
            // 旧格式兼容：无版本号，不做版本校验，但记录警告
            \think\facade\Log::info('verifyPlayerToken: legacy token format (no version), skip revocation check', [
                'user_id' => $user['id'] ?? 'unknown',
            ]);
            $data = $user['id'] . '|' . $user['username'] . '|' . $timestamp;
        }

        $expectedToken = hash('sha256', $data . $secret);
        
        $result = hash_equals($expectedToken, $tokenPart);
        if (!$result) {
            \think\facade\Log::warning('verifyPlayerToken: hash mismatch', [
                'user_id' => $user['id'] ?? 'unknown',
                'username' => $user['username'] ?? 'unknown',
                'secret_length' => strlen($secret),
                'token_length' => strlen($tokenPart),
                'expected_length' => strlen($expectedToken)
            ]);
        }
        
        return $result;
    }
}

/**
 * 获取或初始化玩家 Token 版本号（内部辅助函数）
 * 版本号存储于 Redis，key 格式：token_version:{userId}
 * 默认 TTL 30天，用户主动吊销或改密时调用 invalidatePlayerTokens() 递增
 * @param int $userId
 * @return int 当前版本号
 */
if (!function_exists('_getOrCreateTokenVersion')) {
    function _getOrCreateTokenVersion(int $userId): int
    {
        $key = 'token_version:' . $userId;
        $ttl = 86400 * 30; // 30天
        try {
            $cache = Cache::store('redis');
            $ver = $cache->get($key);
            if ($ver === null) {
                // 首次登录：初始化版本号为1
                $cache->set($key, 1, $ttl);
                return 1;
            }
            // 刷新 TTL（每次成功登录续期）
            $cache->set($key, (int)$ver, $ttl);
            return (int)$ver;
        } catch (\Exception $e) {
            // Redis 不可用时降级：版本号固定返回0（跳过版本校验）
            \think\facade\Log::warning('_getOrCreateTokenVersion: Redis unavailable, skip version check', [
                'user_id' => $userId,
                'error'   => $e->getMessage(),
            ]);
            return 0;
        }
    }
}

/**
 * 强制吊销指定用户的所有 Token（改密、管理员封号等场景）
 * 通过递增 Redis 中的版本号，使所有已签发的旧 Token 立即失效
 * @param int $userId
 */
if (!function_exists('invalidatePlayerTokens')) {
    function invalidatePlayerTokens(int $userId): void
    {
        $key = 'token_version:' . $userId;
        $ttl = 86400 * 30;
        try {
            $cache = Cache::store('redis');
            $ver = $cache->get($key, 0);
            $newVer = (int)$ver + 1;
            $cache->set($key, $newVer, $ttl);
            // 同时清除用户信息缓存，强制重新加载
            $cache->delete('player_user:' . $userId);
            \think\facade\Log::info('invalidatePlayerTokens: token version bumped', [
                'user_id'     => $userId,
                'old_version' => (int)$ver,
                'new_version' => $newVer,
            ]);
        } catch (\Exception $e) {
            \think\facade\Log::error('invalidatePlayerTokens: Redis unavailable, token revocation failed', [
                'user_id' => $userId,
                'error'   => $e->getMessage(),
            ]);
        }
    }
}

/**
 * 检查玩家登录状态
 * @return array|null 玩家信息，未登录返回null
 */
if (!function_exists('checkPlayerLogin')) {
    function checkPlayerLogin()
    {
        $playerId = getSession('id');
        $playerUsername = getSession('username');
        $playerToken = getSession('token');
        
        if (empty($playerId) || empty($playerUsername) || empty($playerToken)) {
            return null;
        }
        
        $user = [
            'id' => $playerId,
            'username' => $playerUsername
        ];
        
        if (!verifyPlayerToken($user, $playerToken)) {
            return null;
        }
        
        return $user;
    }
}

/**
 * 检查管理员登录状态
 * @return array|null 管理员信息，未登录返回null
 */
if (!function_exists('checkAdminLogin')) {
    function checkAdminLogin()
    {
        $adminId = getSession('admin_id');
        $adminUsername = getSession('admin_username');
        $adminType = getSession('admin_type');
        $adminToken = getSession('admin_token');
        
        if (empty($adminId) || empty($adminUsername) || empty($adminToken)) {
            return null;
        }
        
        return [
            'id' => $adminId,
            'username' => $adminUsername,
            'type' => $adminType
        ];
    }
}

/**
 * 获取当前玩家完整信息
 * @return array|null 玩家完整信息
 */
if (!function_exists('getCurrentPlayerInfo')) {
    function getCurrentPlayerInfo()
    {
        $player = checkPlayerLogin();
        if (!$player) {
            return null;
        }
        
        return [
            'id' => $player['id'],
            'username' => $player['username'],
            'serverid' => getSession('serverid'),
            'servername' => getSession('servername'),
            'groupname' => getSession('groupname'),
            'cdk' => getSession('cdk'),
            'lv' => getSession('lv'),
            'auth_time' => getSession('auth_time')
        ];
    }
}

/**
 * 生成CSRF Token
 * @return string 生成的CSRF Token
 */
if (!function_exists('generateCsrfToken')) {
    function generateCsrfToken()
    {
        $token = bin2hex(random_bytes(32));
        Session::set('csrf_token', $token);
        Session::set('__csrf_token__', $token);
        return $token;
    }
}

/**
 * 验证CSRF Token
 * @param string $token 待验证的Token
 * @return bool 验证结果
 */
if (!function_exists('verifyCsrfToken')) {
    function verifyCsrfToken($token)
    {
        $requestToken = trim((string)$token);
        if ($requestToken === '') {
            return false;
        }

        $sessionToken = (string)Session::get('csrf_token', '');
        if ($sessionToken !== '' && hash_equals($sessionToken, $requestToken)) {
            return true;
        }

        $legacyToken = (string)Session::get('__csrf_token__', '');
        if ($legacyToken !== '' && hash_equals($legacyToken, $requestToken)) {
            if ($sessionToken === '') {
                Session::set('csrf_token', $legacyToken);
            }
            return true;
        }

        return false;
    }
}

/**
 * 检查登录频率限制
 * @param string $ip IP地址
 * @param int $maxAttempts 最大尝试次数
 * @param int $lockTime 锁定时间（秒）
 * @return array ['allowed' => bool, 'message' => string]
 */
if (!function_exists('isPlayerIpWhitelisted')) {
    function isPlayerIpWhitelisted($ip)
    {
        if (!is_string($ip) || $ip === '' || !filter_var($ip, FILTER_VALIDATE_IP)) {
            return false;
        }

        $whitelist = (array)config('security.ip_blacklist.whitelist', [
            '127.0.0.1',
            '::1',
            '10.0.0.0/8',
            '172.16.0.0/12',
            '192.168.0.0/16',
            'fc00::/7',
            'fe80::/10',
        ]);

        foreach ($whitelist as $rule) {
            $rule = trim((string)$rule);
            if ($rule === '') {
                continue;
            }

            if (strpos($rule, '/') !== false) {
                if (ipInCidr($ip, $rule)) {
                    return true;
                }
                continue;
            }

            if ($ip === $rule) {
                return true;
            }
        }

        return false;
    }
}

if (!function_exists('normalizePlayerIpBlacklist')) {
    function normalizePlayerIpBlacklist($rawBlacklist, $defaultTtl = 3600)
    {
        if (!is_array($rawBlacklist)) {
            return [];
        }

        $normalized = [];
        $now = time();
        $defaultExpire = $now + max(60, (int)$defaultTtl);

        foreach ($rawBlacklist as $key => $value) {
            if (is_string($key) && filter_var($key, FILTER_VALIDATE_IP)) {
                $expiresAt = (int)$value;
                if ($expiresAt <= 0) {
                    $expiresAt = $defaultExpire;
                }

                if ($expiresAt > $now) {
                    $normalized[$key] = $expiresAt;
                }
                continue;
            }

            $legacyIp = is_string($value) ? trim($value) : '';
            if ($legacyIp !== '' && filter_var($legacyIp, FILTER_VALIDATE_IP)) {
                $normalized[$legacyIp] = $defaultExpire;
            }
        }

        return $normalized;
    }
}

if (!function_exists('checkLoginRateLimit')) {
    function checkLoginRateLimit($ip, $maxAttempts = 5, $lockTime = 300)
    {
        if (isPlayerIpWhitelisted($ip)) {
            return ['allowed' => true, 'message' => ''];
        }

        try {
            $cache = Cache::store('redis');
            $redis = $cache->handler(); // 获取底层 Redis 对象
            $key       = 'login_limit:' . $ip;
            $lockedKey = $key . ':locked';

            // 检查是否被锁定（Redis GET，单次原子读）
            $lockedUntil = (int)$redis->get($lockedKey);
            if ($lockedUntil > 0 && $lockedUntil > time()) {
                $remainingTime = $lockedUntil - time();
                return [
                    'allowed' => false,
                    'message' => '登录尝试次数过多，请' . ceil($remainingTime / 60) . '分钟后再试'
                ];
            }

            // Lua 脚本：原子执行 INCR + 首次设置 EXPIRE（消除竞争窗口）
            // KEYS[1]=计数key  ARGV[1]=窗口TTL(秒)  ARGV[2]=最大尝试次数
            // 返回值：当前计数
            $luaScript = <<<'LUA'
local cnt = redis.call('INCR', KEYS[1])
if cnt == 1 then
    redis.call('EXPIRE', KEYS[1], ARGV[1])
end
return cnt
LUA;
            $windowTtl = $lockTime; // 滑动窗口与锁定时间对齐
            $attempts = $redis->eval($luaScript, [$key, $windowTtl, $maxAttempts], 1);

            if ($attempts >= $maxAttempts) {
                // 记录锁定过期时间（绝对时间戳），原子设置
                $expireAt = time() + $lockTime;
                $redis->set($lockedKey, $expireAt, ['ex' => $lockTime]);
                return [
                    'allowed' => false,
                    'message' => '登录尝试次数过多，请' . ceil($lockTime / 60) . '分钟后再试'
                ];
            }

            return ['allowed' => true, 'message' => ''];

        } catch (\Exception $e) {
            // Redis 不可用时降级：文件锁（LOCK_EX 保障单写，低频场景足够）
            $key = 'login_limit:' . $ip;
            $cacheDir = runtime_path('cache' . DIRECTORY_SEPARATOR . 'player');
            if (!is_dir($cacheDir)) {
                mkdir($cacheDir, 0755, true);
            }
            $cacheFile = $cacheDir . DIRECTORY_SEPARATOR . md5($key) . '.json';
            
            $data = ['attempts' => 0, 'locked_until' => 0];
            if (file_exists($cacheFile)) {
                $cachedData = json_decode(file_get_contents($cacheFile), true);
                if (is_array($cachedData)) {
                    $data = $cachedData;
                }
            }
            
            // 检查是否被锁定
            if ($data['locked_until'] > time()) {
                $remainingTime = $data['locked_until'] - time();
                return [
                    'allowed' => false,
                    'message' => '登录尝试次数过多，请' . ceil($remainingTime / 60) . '分钟后再试'
                ];
            }

            // 窗口过期时重置计数
            $windowExpiry = ($data['window_start'] ?? 0) + $lockTime;
            if (time() > $windowExpiry) {
                $data['attempts'] = 0;
                $data['window_start'] = time();
            }
            
            if ($data['attempts'] >= $maxAttempts) {
                // 锁定IP
                $data['locked_until'] = time() + $lockTime;
                $data['attempts'] = 0;
                file_put_contents($cacheFile, json_encode($data), LOCK_EX);
                return [
                    'allowed' => false,
                    'message' => '登录尝试次数过多，请' . ceil($lockTime / 60) . '分钟后再试'
                ];
            }
            
            return ['allowed' => true, 'message' => ''];
        }
    }
}

/**
 * 记录登录尝试
 * @param string $ip IP地址
 * @param bool $success 是否成功
 */
if (!function_exists('recordLoginAttempt')) {
    function recordLoginAttempt($ip, $success = false)
    {
        if (isPlayerIpWhitelisted($ip)) {
            return;
        }

        try {
            $cache = Cache::store('redis');
            $redis = $cache->handler();
            $key = 'login_limit:' . $ip;

            if ($success) {
                // 登录成功：原子删除计数键和锁定键
                $redis->del([$key, $key . ':locked']);
            }
            // 登录失败时：计数已由 checkLoginRateLimit() 的 Lua INCR 处理，此处无需重复递增
        } catch (\Exception $e) {
            // Redis不可用时的降级方案：使用文件缓存
            $key = 'login_limit:' . $ip;
            $cacheDir = runtime_path('cache' . DIRECTORY_SEPARATOR . 'player');
            if (!is_dir($cacheDir)) {
                mkdir($cacheDir, 0755, true);
            }
            $cacheFile = $cacheDir . DIRECTORY_SEPARATOR . md5($key) . '.json';
            
            $data = ['attempts' => 0, 'locked_until' => 0];
            if (file_exists($cacheFile)) {
                $cachedData = json_decode(file_get_contents($cacheFile), true);
                if (is_array($cachedData)) {
                    $data = $cachedData;
                }
            }
            
            if ($success) {
                // 登录成功，清除尝试记录
                if (file_exists($cacheFile)) {
                    @unlink($cacheFile);
                }
            } else {
                // 登录失败，增加尝试次数
                $data['attempts']++;
                file_put_contents($cacheFile, json_encode($data), LOCK_EX);
            }
        }
    }
}

/**
 * 检查恶意IP
 * @param string $ip IP地址
 * @return bool 是否为恶意IP
 */
if (!function_exists('isMaliciousIP')) {
    function isMaliciousIP($ip)
    {
        if (!is_string($ip) || $ip === '' || !filter_var($ip, FILTER_VALIDATE_IP)) {
            return false;
        }
        if (isPlayerIpWhitelisted($ip)) {
            return false;
        }
        $blacklistKey = 'ip_blacklist';
        $singleIpKey = 'ip_blacklist:' . $ip;
        $now = time();
        try {
            $cache = Cache::store('redis');
            $blockedUntil = (int)$cache->get($singleIpKey, 0);
            if ($blockedUntil > $now) {
                return true;
            }
            if ($blockedUntil > 0 && $blockedUntil <= $now) {
                $cache->delete($singleIpKey);
            }
            $rawBlacklist = $cache->get($blacklistKey, []);
            $blacklist = normalizePlayerIpBlacklist($rawBlacklist);
            if (!empty($blacklist)) {
                $maxExpire = max($blacklist);
                $cache->set($blacklistKey, $blacklist, max(60, $maxExpire - $now));
            } else {
                $cache->delete($blacklistKey);
            }
            if (isset($blacklist[$ip]) && $blacklist[$ip] > $now) {
                return true;
            }
        } catch (\Exception $e) {
            // Fallback to file cache when Redis is unavailable.
            $cacheDir = runtime_path('cache' . DIRECTORY_SEPARATOR . 'player');
            if (!is_dir($cacheDir)) {
                mkdir($cacheDir, 0755, true);
            }
            $cacheFile = $cacheDir . DIRECTORY_SEPARATOR . md5($blacklistKey) . '.json';
            $blacklist = [];
            if (file_exists($cacheFile)) {
                $cachedData = json_decode(file_get_contents($cacheFile), true);
                $blacklist = normalizePlayerIpBlacklist($cachedData);
            }
            $content = json_encode($blacklist, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
            file_put_contents($cacheFile, $content, LOCK_EX);
            if (isset($blacklist[$ip]) && $blacklist[$ip] > $now) {
                return true;
            }
        }
        return false;
    }
}
/**
 * 添加恶意IP到黑名单
 * @param string $ip IP地址
 * @param int $ttl 生存时间（秒）
 */
if (!function_exists('addMaliciousIP')) {
    function addMaliciousIP($ip, $ttl = 86400)
    {
        if (!is_string($ip) || $ip === '' || !filter_var($ip, FILTER_VALIDATE_IP)) {
            return;
        }
        if (isPlayerIpWhitelisted($ip)) {
            return;
        }
        $ttl = max(60, (int)$ttl);
        $expireAt = time() + $ttl;
        $blacklistKey = 'ip_blacklist';
        $singleIpKey = 'ip_blacklist:' . $ip;
        try {
            $cache = Cache::store('redis');
            $cache->set($singleIpKey, $expireAt, $ttl);
            $rawBlacklist = $cache->get($blacklistKey, []);
            $blacklist = normalizePlayerIpBlacklist($rawBlacklist, $ttl);
            $blacklist[$ip] = $expireAt;
            $maxExpire = max($blacklist);
            $cache->set($blacklistKey, $blacklist, max(60, $maxExpire - time()));
        } catch (\Exception $e) {
            // Fallback to file cache when Redis is unavailable.
            $cacheDir = runtime_path('cache' . DIRECTORY_SEPARATOR . 'player');
            if (!is_dir($cacheDir)) {
                mkdir($cacheDir, 0755, true);
            }
            $cacheFile = $cacheDir . DIRECTORY_SEPARATOR . md5($blacklistKey) . '.json';
            $blacklist = [];
            if (file_exists($cacheFile)) {
                $cachedData = json_decode(file_get_contents($cacheFile), true);
                $blacklist = normalizePlayerIpBlacklist($cachedData, $ttl);
            }
            $blacklist[$ip] = $expireAt;
            $content = json_encode($blacklist, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
            file_put_contents($cacheFile, $content, LOCK_EX);
        }
    }
}
/**
 * 验证密码强度
 * @param string $password 密码
 * @return array ['valid' => bool, 'message' => string]
 */
if (!function_exists('validatePasswordStrength')) {
    function validatePasswordStrength($password)
    {
        if (empty($password)) {
            return ['valid' => false, 'message' => '密码不能为空'];
        }
        
        $length = strlen($password);
        if ($length < 6 || $length > 18) {
            return ['valid' => false, 'message' => '密码长度必须为6-18位'];
        }
        
        // 检查是否包含字母和数字
        if (!preg_match('/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/', $password)) {
            return ['valid' => false, 'message' => '密码必须包含字母和数字'];
        }
        
        return ['valid' => true, 'message' => ''];
    }
}

/**
 * 获取玩家IP地址
 * P2修复：仅在请求来自可信代理时才读取X-Forwarded-For等header，防止IP伪造
 * @return string IP地址
 */
if (!function_exists('getPlayerIP')) {
    function getPlayerIP()
    {
        $request = Request::instance();
        $remoteIp = $request->ip();
        
        // 可信代理IP列表（可通过配置扩展）
        $trustedProxies = (array)config('player.trusted_proxies', [
            '127.0.0.1',
            '::1',
            '10.0.0.0/8',
            '172.16.0.0/12',
            '192.168.0.0/16',
        ]);
        
        // 仅在请求来自可信代理时才读取转发头
        $isTrustedProxy = false;
        foreach ($trustedProxies as $proxy) {
            if (strpos($proxy, '/') !== false) {
                // CIDR格式检查
                if (ipInCidr($remoteIp, $proxy)) {
                    $isTrustedProxy = true;
                    break;
                }
            } elseif ($remoteIp === $proxy) {
                $isTrustedProxy = true;
                break;
            }
        }
        
        $ip = $remoteIp;
        
        if ($isTrustedProxy) {
            $forwardedFor = (string)$request->server('HTTP_X_FORWARDED_FOR');
            if ($forwardedFor !== '') {
                $ips = explode(',', $forwardedFor);
                foreach ($ips as $candidate) {
                    $candidate = trim($candidate);
                    if ($candidate === '' || strtolower($candidate) === 'unknown') {
                        continue;
                    }

                    if (filter_var($candidate, FILTER_VALIDATE_IP)) {
                        $ip = $candidate;
                        break;
                    }
                }
            }

            if ($ip === $remoteIp && !empty($request->server('HTTP_X_REAL_IP'))) {
                $ip = $request->server('HTTP_X_REAL_IP');
            } elseif ($ip === $remoteIp && !empty($request->server('HTTP_CLIENT_IP'))) {
                $ip = $request->server('HTTP_CLIENT_IP');
            }
        }
        
        // 验证IP格式
        if (!filter_var($ip, FILTER_VALIDATE_IP)) {
            return $remoteIp ?: '0.0.0.0';
        }
        
        return $ip;
    }
}

/**
 * 检查IP是否在CIDR范围内
 * @param string $ip IP地址
 * @param string $cidr CIDR范围
 * @return bool
 */
if (!function_exists('ipInCidr')) {
    function ipInCidr(string $ip, string $cidr): bool
    {
        if (strpos($cidr, '/') === false) {
            return $ip === $cidr;
        }

        [$subnet, $bits] = explode('/', $cidr, 2);
        $bits = (int)$bits;

        if (
            filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4) &&
            filter_var($subnet, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4)
        ) {
            $ipLong = ip2long($ip);
            $subnetLong = ip2long($subnet);
            if ($ipLong === false || $subnetLong === false) {
                return false;
            }

            $mask = -1 << (32 - $bits);
            return ($ipLong & $mask) === ($subnetLong & $mask);
        }

        if (
            filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV6) &&
            filter_var($subnet, FILTER_VALIDATE_IP, FILTER_FLAG_IPV6)
        ) {
            $ipBin = inet_pton($ip);
            $subnetBin = inet_pton($subnet);
            if ($ipBin === false || $subnetBin === false) {
                return false;
            }

            $bytes = intdiv($bits, 8);
            $remainingBits = $bits % 8;

            if ($bytes > 0 && substr($ipBin, 0, $bytes) !== substr($subnetBin, 0, $bytes)) {
                return false;
            }

            if ($remainingBits === 0) {
                return true;
            }

            $mask = ((0xFF << (8 - $remainingBits)) & 0xFF);
            return (ord($ipBin[$bytes]) & $mask) === (ord($subnetBin[$bytes]) & $mask);
        }

        return false;
    }
}

/**
 * 记录玩家操作日志
 * @param int $playerId 玩家ID
 * @param string $action 操作类型
 * @param string $detail 操作详情
 * @param array $extra 额外信息
 */
if (!function_exists('logPlayerAction')) {
    function logPlayerAction($playerId, $action, $detail = '', $extra = [])
    {
        $log = [
            'trace_id'   => $_SERVER['TRACE_ID'] ?? '',   // 全链路追踪ID（由TraceId中间件注入）
            'player_id'  => $playerId,
            'action'     => $action,
            'detail'     => $detail,
            'ip'         => getPlayerIP(),
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
            'extra'      => json_encode($extra, JSON_UNESCAPED_UNICODE),
            'created_at' => date('Y-m-d H:i:s'),
        ];
        
        $logDir = runtime_path('log' . DIRECTORY_SEPARATOR . 'player');
        if (!is_dir($logDir)) {
            mkdir($logDir, 0755, true);
        }
        
        $logFile = $logDir . DIRECTORY_SEPARATOR . date('Ymd') . '.log';
        $logLine = json_encode($log, JSON_UNESCAPED_UNICODE) . PHP_EOL;
        file_put_contents($logFile, $logLine, FILE_APPEND);
    }
}

/**
 * 构建玩家订单归属查询条件（公共方法）
 * P2优化：从Order/Recharge/Player模型中提取的公共方法，消除重复代码
 * user字段历史上可能同时存在数字/字符串两种playerid序列化格式
 * @param array $playerIds 玩家角色ID列表
 * @return \Closure 查询条件闭包
 */
if (!function_exists('buildPlayerOrderWhere')) {
    function buildPlayerOrderWhere(array $playerIds)
    {
        $safeIds = [];
        foreach ($playerIds as $pid) {
            $pid = preg_replace('/[^0-9]/', '', (string)$pid);
            if ($pid !== '') {
                $safeIds[] = $pid;
            }
        }

        return function ($query) use ($safeIds) {
            if (empty($safeIds)) {
                $query->where('id', 0);
                return;
            }

            foreach ($safeIds as $index => $pid) {
                $numericPattern = '%"playerid":' . $pid . '%';
                $stringPattern = '%"playerid":"' . $pid . '"%';

                if ($index === 0) {
                    $query->where(function ($subQuery) use ($numericPattern, $stringPattern) {
                        $subQuery->whereLike('user', $numericPattern)
                            ->whereOr('user', 'like', $stringPattern);
                    });
                } else {
                    $query->whereOr(function ($subQuery) use ($numericPattern, $stringPattern) {
                        $subQuery->whereLike('user', $numericPattern)
                            ->whereOr('user', 'like', $stringPattern);
                    });
                }
            }
        };
    }
}

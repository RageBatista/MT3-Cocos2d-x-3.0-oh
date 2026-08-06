<?php
declare(strict_types=1);

namespace app\service;

use think\facade\Cache;
use think\facade\Log;

/**
 * 缓存分布式锁服务（优先使用 Redis 原子 NX 锁）
 */
class CacheLockService
{
    /**
     * 获取锁，成功返回锁令牌，失败返回 null。
     */
    public static function acquire(string $key, int $ttl = 30, string $store = 'redis'): ?string
    {
        $ttl = max(1, intval($ttl));
        $token = self::buildToken();

        try {
            $cache = Cache::store($store);
            $handler = self::resolveHandler($cache);

            if ($handler && self::acquireByHandler($handler, $key, $token, $ttl)) {
                return $token;
            }

            // 降级方案：兼容非 Redis 驱动（非强原子）
            $ok = $cache->set($key, $token, $ttl);
            if ($ok && (string)$cache->get($key) === $token) {
                return $token;
            }
        } catch (\Throwable $e) {
            Log::warning('CacheLockService::acquire failed', [
                'key' => $key,
                'store' => $store,
                'error' => $e->getMessage()
            ]);
        }

        return null;
    }

    /**
     * 释放锁，仅允许持有同一 token 的请求释放。
     */
    public static function release(string $key, ?string $token, string $store = 'redis'): void
    {
        $token = trim((string)$token);
        if ($token === '') {
            return;
        }

        try {
            $cache = Cache::store($store);
            $handler = self::resolveHandler($cache);

            if ($handler && self::releaseByHandler($handler, $key, $token)) {
                return;
            }

            // 降级删除：仅在 token 匹配时删除，避免误删他人锁
            $current = (string)$cache->get($key, '');
            if ($current !== '' && hash_equals($current, $token)) {
                $cache->delete($key);
            }
        } catch (\Throwable $e) {
            Log::warning('CacheLockService::release failed', [
                'key' => $key,
                'store' => $store,
                'error' => $e->getMessage()
            ]);
        }
    }

    private static function buildToken(): string
    {
        try {
            return bin2hex(random_bytes(16));
        } catch (\Throwable $e) {
            return md5(uniqid('lock_', true));
        }
    }

    private static function resolveHandler($cache)
    {
        if (is_object($cache) && method_exists($cache, 'handler')) {
            try {
                return $cache->handler();
            } catch (\Throwable $e) {
                return null;
            }
        }
        return null;
    }

    private static function acquireByHandler($handler, string $key, string $token, int $ttl): bool
    {
        // phpredis: set($key, $value, ['nx', 'ex' => $ttl])
        try {
            $res = $handler->set($key, $token, ['nx', 'ex' => $ttl]);
            if ($res === true || $res === 'OK') {
                return true;
            }
        } catch (\Throwable $e) {
        }

        // predis: set($key, $value, 'EX', $ttl, 'NX')
        try {
            $res = $handler->set($key, $token, 'EX', $ttl, 'NX');
            if ($res === true || $res === 'OK') {
                return true;
            }
        } catch (\Throwable $e) {
        }

        // 兜底：setnx + expire（非强原子，但优于直接覆盖）
        try {
            if (method_exists($handler, 'setnx')) {
                $setnx = $handler->setnx($key, $token);
                if ($setnx === true || intval($setnx) === 1) {
                    if (method_exists($handler, 'expire')) {
                        $handler->expire($key, $ttl);
                    }
                    return true;
                }
            }
        } catch (\Throwable $e) {
        }

        return false;
    }

    private static function releaseByHandler($handler, string $key, string $token): bool
    {
        $lua = "if redis.call('get', KEYS[1]) == ARGV[1] then return redis.call('del', KEYS[1]) else return 0 end";

        // phpredis: eval(script, [key, token], 1)
        try {
            $result = $handler->eval($lua, [$key, $token], 1);
            return intval($result) >= 0;
        } catch (\Throwable $e) {
        }

        // predis: eval(script, 1, key, token)
        try {
            $result = $handler->eval($lua, 1, $key, $token);
            return intval($result) >= 0;
        } catch (\Throwable $e) {
        }

        return false;
    }
}


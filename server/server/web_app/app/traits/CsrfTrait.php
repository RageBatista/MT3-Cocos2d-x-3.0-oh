<?php
declare(strict_types=1);

namespace app\traits;

use think\facade\Session;
use think\facade\Cookie;

trait CsrfTrait
{
    protected function buildToken(): string
    {
        $sessionKey = '__csrf_token__';
        $cookieKey = 'csrf_token';

        $token = (string) Session::get($sessionKey, '');
        $cookieToken = (string) Cookie::get($cookieKey, '');

        if ($token === '' && $cookieToken !== '') {
            $token = $cookieToken;
            Session::set($sessionKey, $token);
        }

        if ($token === '') {
            try {
                $token = bin2hex(random_bytes(16));
            } catch (\Throwable $e) {
                $token = md5(uniqid((string) mt_rand(), true));
            }
            Session::set($sessionKey, $token);
        }

        Cookie::set($cookieKey, $token, 3600);
        return $token;
    }

    protected function checkToken($token): bool
    {
        $requestToken = (string) $token;
        if ($requestToken === '') {
            return false;
        }

        $sessionToken = (string) Session::get('__csrf_token__', '');
        if ($sessionToken !== '' && hash_equals($sessionToken, $requestToken)) {
            return true;
        }

        $cookieToken = (string) Cookie::get('csrf_token', '');
        if ($cookieToken !== '' && hash_equals($cookieToken, $requestToken)) {
            Session::set('__csrf_token__', $cookieToken);
            return true;
        }

        return false;
    }
}

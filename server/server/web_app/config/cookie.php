<?php
// +----------------------------------------------------------------------
// | Cookie setting
// +----------------------------------------------------------------------

$secureEnvEnabled = in_array(
    strtolower((string) env('COOKIE_SECURE', '0')),
    ['1', 'true', 'on', 'yes'],
    true
);

$isHttpsRequest = (
    (!empty($_SERVER['HTTPS']) && strtolower((string) $_SERVER['HTTPS']) !== 'off')
    || intval($_SERVER['SERVER_PORT'] ?? 0) === 443
    || strtolower((string) ($_SERVER['REQUEST_SCHEME'] ?? '')) === 'https'
    || strtolower((string) ($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '')) === 'https'
    || strtolower((string) ($_SERVER['HTTP_X_FORWARDED_SSL'] ?? '')) === 'on'
    || strtolower((string) ($_SERVER['HTTP_FRONT_END_HTTPS'] ?? '')) === 'on'
);

$appEnv = strtolower((string) env('APP_ENV', 'production'));
$isProduction = $appEnv === 'production';
$sameSite = $isProduction ? 'strict' : 'lax';
$secure = $isHttpsRequest && ($isProduction || $secureEnvEnabled);

return [
    // cookie expire time
    'expire'    => 0,
    // cookie path
    'path'      => '/',
    // cookie domain
    'domain'    => '',
    // only enable secure cookies when the current request is actually HTTPS
    'secure'    => $secure,
    // http only
    'httponly'  => true,
    // use setcookie
    'setcookie' => true,
    // samesite option, supports 'strict' and 'lax'
    'samesite'  => $sameSite,
];

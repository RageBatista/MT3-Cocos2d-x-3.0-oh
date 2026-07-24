<?php
// Player模块中间件定义
// 统一在 player 应用层挂载，确保认证/安全/CSRF 机制生效
return [
    \app\player\middleware\PlayerSecurity::class,
    \app\player\middleware\PlayerAuth::class,
    \app\player\middleware\CsrfToken::class,
];

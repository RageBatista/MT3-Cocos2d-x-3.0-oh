<?php
// Player模块中间件定义
// 统一在 player 应用层挂载，确保认证/安全/CSRF 机制生效
return [
    \app\player\middleware\TraceId::class,        // 全链路追踪（最先执行，后续日志均可读取 trace_id）
    \app\player\middleware\PlayerSecurity::class,
    \app\player\middleware\PlayerAuth::class,
    \app\player\middleware\CsrfToken::class,
];

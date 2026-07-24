<?php
/**
 * 安全配置文件
 * 用于管理员后台的安全验证
 * 敏感信息从环境变量读取，请确保.env文件已正确配置
 */
return [
    // JMX认证配置（与游戏服务器sys.properties保持一致）
    'jmx_auth' => [
        'username' => env('JMX_USERNAME', 'admin'),
        'password' => env('JMX_PASSWORD', 'change_me'),
        'token' => env('JMX_TOKEN', ''),
        'enabled' => env('JMX_AUTH_ENABLED', true),
    ],
];

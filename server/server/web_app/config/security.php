<?php

return [
    // SQL注入防护配置
    'sql_injection' => [
        // 是否启用SQL注入检测
        'enabled' => true,
        // 危险字符列表
        'dangerous_chars' => [
            "'", '"', ';', '--', '/*', '*/', 'union', 'select', 'insert', 
            'update', 'delete', 'drop', 'create', 'alter', 'exec', 'execute',
            'script', 'javascript', 'vbscript', 'onload', 'onerror'
        ],
        // 最大输入长度
        'max_length' => 255,
        // 是否记录攻击日志
        'log_attacks' => true,
    ],
    
    // XSS防护配置
    'xss_protection' => [
        // 是否启用XSS防护
        'enabled' => true,
        // 危险标签
        'dangerous_tags' => [
            'script', 'iframe', 'object', 'embed', 'form', 'input', 'textarea',
            'select', 'option', 'button', 'link', 'meta', 'style'
        ],
        // 危险属性
        'dangerous_attributes' => [
            'onload', 'onerror', 'onclick', 'onmouseover', 'onfocus', 'onblur',
            'onchange', 'onsubmit', 'onreset', 'onselect', 'onunload'
        ],
    ],
    
    // CSRF防护配置
    'csrf_protection' => [
        // 是否启用CSRF防护
        'enabled' => true,
        // Token过期时间（秒）
        'token_expire' => 3600,
        // 是否验证Referer
        'check_referer' => true,
    ],
    
    // 文件上传安全配置
    'file_upload' => [
        // 允许的文件类型
        'allowed_types' => ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx'],
        // 最大文件大小（字节）
        'max_size' => 5 * 1024 * 1024, // 5MB
        // 是否检查文件内容
        'check_content' => true,
    ],
    
    // 密码安全配置
    'password_security' => [
        // 最小密码长度
        'min_length' => 6,
        // 最大密码长度
        'max_length' => 18,
        // 密码复杂度要求
        'complexity' => [
            'require_letters' => true,
            'require_numbers' => true,
            'require_special_chars' => false,
        ],
    ],
    
    // 登录安全配置
    'login_security' => [
        // 最大登录失败次数
        'max_failures' => 5,
        // 锁定时间（秒）
        'lockout_time' => 1800, // 30分钟
        // 是否启用验证码
        'enable_captcha' => true,
        // 验证码失败次数阈值
        'captcha_threshold' => 3,
    ],
    
    // 会话安全配置
    'session_security' => [
        // 会话超时时间（秒）
        'timeout' => 3600, // 1小时
        // 是否启用会话固定防护
        'regenerate_id' => true,
        // 是否启用HTTPS
        'secure_cookies' => false,
        // 是否启用HttpOnly
        'http_only' => true,
    ],
    
    // 错误处理配置
    'error_handling' => [
        // 是否显示详细错误信息
        'show_details' => false,
        // 是否记录错误日志
        'log_errors' => true,
        // 错误日志级别
        'log_level' => 'error',
    ],
    
    // IP黑名单配置
    'ip_blacklist' => [
        // 是否启用IP黑名单
        'enabled' => true,
        // 黑名单IP列表
        'blacklist' => [],
        // 白名单IP列表
        'whitelist' => ['127.0.0.1', '::1'],
    ],

    // JMX认证配置（从环境变量读取，与游戏服务器sys.properties保持一致）
    'jmx_auth' => [
        // JMX登录用户名（对应游戏服务器 sys.jmx.login.user）
        'username' => env('JMX_USERNAME', 'admin'),
        // JMX登录密码（对应游戏服务器 sys.jmx.login.password）
        'password' => env('JMX_PASSWORD', 'change_me'),
        // JMX认证Token（对应游戏服务器 sys.gm.jmx.auth_token）
        'token' => env('JMX_TOKEN', ''),
        // 是否启用JMX认证（与游戏服务器保持同步）
        'enabled' => env('JMX_AUTH_ENABLED', false),
    ],

    // 支付回调安全配置
    'pay_callback' => [
        // 是否启用防重放保护
        'replay_protection_enabled' => env('PAY_CALLBACK_REPLAY_PROTECTION', true),
        // 回调时间戳有效期（秒），超过此时间视为重放攻击
        'timestamp_ttl' => env('PAY_CALLBACK_TIMESTAMP_TTL', 300),
        // 是否启用幂等控制
        'idempotency_enabled' => env('PAY_CALLBACK_IDEMPOTENCY', true),
        // 是否启用日志脱敏
        'log_masking_enabled' => env('PAY_CALLBACK_LOG_MASKING', true),
        // 需要脱敏的字段名
        'mask_fields' => ['password', 'key', 'token', 'secret', 'pay_key'],
    ],

    // 后台鉴权密钥配置
    'admin_auth' => [
        // 后台鉴权密钥（用于生成认证token）
        // 生产环境必须配置，否则拒绝高权限操作
        'secret_key' => env('ADMIN_AUTH_SECRET_KEY', ''),
    ],

    // P1-A安全修复：玩家认证安全配置
    'player_auth' => [
        // 玩家Token签名盐值（必须配置，否则拒绝玩家认证）
        'secret_salt' => env('OP_SECRET_SALT', ''),
        // Token最小有效期（秒）
        'token_min_age' => 60,
        // Token最大有效期（秒）
        'token_max_age' => 86400,
        // 是否启用Token强度检查
        'enable_strength_check' => true,
        // 盐值最小长度（字符）
        'salt_min_length' => 32,
    ],
];

<?php

return [
    // Enable player auth feature
    'auth_enabled' => env('PLAYER_AUTH_ENABLED', true),

    // P1-A安全修复：操作签名盐值（必须配置，否则拒绝玩家认证）
    // 生产环境必须配置至少32字符的强随机字符串
    'op_secret_salt' => env('OP_SECRET_SALT', ''),

    // Signature timeout (seconds)
    'signature_timeout' => env('SIGNATURE_TIMEOUT', 300),

    // Item whitelist cache TTL (seconds)
    'item_whitelist_cache_ttl' => env('ITEM_WHITELIST_CACHE_TTL', 3600),

    // Pet whitelist cache TTL (seconds)
    'pet_whitelist_cache_ttl' => env('PET_WHITELIST_CACHE_TTL', 3600),

    // CCS config directory
    'ccs_dir' => root_path() . 'ccs' . DIRECTORY_SEPARATOR,

    // Item list files
    'item_files' => [
        'effectitem.txt',
        'equipitem.txt',
        'equiptisitem.txt',
        'plitem.txt',
        'sditem.txt',
        'skillitem.txt',
        'taozhuang.txt',
    ],

    // Pet list file
    'pet_file' => 'petid.txt',

    // Session prefix
    'session_prefix' => 'player_',

    // Session expire time (seconds)
    'session_expire' => 86400,

    // GM command timeout (seconds)
    'gm_timeout' => 5,

    // JMX tool jar paths
    'jmxc_jar_paths' => [
        root_path() . 'game' . DIRECTORY_SEPARATOR . 'ccs' . DIRECTORY_SEPARATOR . 'jmxc.jar',
        root_path() . 'game' . DIRECTORY_SEPARATOR . 'jmxc' . DIRECTORY_SEPARATOR . 'jmxc.jar',
        root_path() . 'gm' . DIRECTORY_SEPARATOR . 'jmxc.jar',
    ],

    // Enable TCP direct mode
    'tcp_direct_enabled' => env('TCP_DIRECT_ENABLED', true),
];

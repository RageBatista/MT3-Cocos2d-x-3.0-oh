<?php

// +----------------------------------------------------------------------
// | 日志设置
// +----------------------------------------------------------------------
return [
    // 默认日志记录通道
    'default'      => 'file',
    // 日志记录级别 - 生产环境建议只记录 error 和 warning
    'level'        => ['info', 'error', 'warning'],
    // 日志类型记录的通道 ['error'=>'email',...]
    'type_channel' => [],
    // 关闭全局日志写入 - 设为 false 启用日志
    'close'        => false,
    // 全局日志处理 支持闭包
    'processor'    => null,

    // 日志通道列表
    'channels'     => [
        // 本地文件日志
        'file' => [
            // 日志记录方式
            'type'           => 'File',
            // 日志保存目录 - 指定为 runtime 目录
            'path'           => app()->getRuntimePath() . 'log/',
            // 单文件日志写入 - 设为 false 按日期分割
            'single'         => false,
            // 独立日志级别 - 这些级别会单独存储
            'apart_level'    => ['error', 'warning'],
            // 最大日志文件数量 - 保留最近5天
            'max_files'      => 5,
            // 使用JSON格式记录 - 便于ELK等工具解析
            'json'           => true,
            // 日志处理
            'processor'      => null,
            // 关闭通道日志写入 - 设为 false 启用
            'close'          => false,
            // 日志输出格式化
            'format'         => '[%s][%s] %s',
            // 是否实时写入
            'realtime_write' => false,
        ],
    ],
];
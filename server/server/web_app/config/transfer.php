<?php
/**
 * 转区功能配置文件
 * 
 * @package config
 */
return [
    // 转区申请类型
    'type' => [
        'feedback' => 1,  // 反馈
        'transfer' => 2   // 转区申请
    ],
    
    // 转区状态
    'status' => [
        'pending' => 0,    // 待审核
        'approved' => 1,   // 审核通过
        'rejected' => 2,   // 审核拒绝
        'processing' => 3, // 处理中
        'completed' => 4   // 已完成
    ],
    
    // 转区规则
    'rules' => [
        'min_level' => 50,           // 最低等级
        'min_recharge' => 0,         // 最低充值金额
        'max_transfer_per_month' => 1,// 每月最大转区次数
        'cooldown_days' => 30         // 转区冷却天数
    ],
    
    // 转区费用
    'fee' => [
        'enabled' => false,  // 是否启用转区费用
        'amount' => 0        // 转区费用（金币或道具）
    ]
];

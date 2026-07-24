<?php
namespace app\player\validate;

use think\Validate;

/**
 * User验证器 - 用户验证器
 * 验证用户相关输入
 */
class User extends Validate
{
    protected $rule = [
        'username' => 'require|alphaNum|length:6,18',
        'password' => 'require|length:6,18',
        'confirm_password' => 'require|confirm:password',
        'email' => 'email',
        'phone' => 'mobile',
        'invite_code' => 'alphaNum|length:4,8'
    ];
    
    protected $message = [
        'username.require' => '账号不能为空',
        'username.alphaNum' => '账号必须为字母和数字',
        'username.length' => '账号长度必须为6-18位',
        'password.require' => '密码不能为空',
        'password.length' => '密码长度必须为6-18位',
        'confirm_password.require' => '确认密码不能为空',
        'confirm_password.confirm' => '两次输入的密码不一致',
        'email' => '邮箱格式不正确',
        'phone' => '手机号格式不正确',
        'invite_code.alphaNum' => '邀请码必须为字母和数字',
        'invite_code.length' => '邀请码长度必须为4-8位'
    ];
}

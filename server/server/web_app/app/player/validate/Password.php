<?php
namespace app\player\validate;

use think\Validate;

/**
 * Password验证器 - 密码验证器
 * 验证密码相关输入
 */
class Password extends Validate
{
    protected $rule = [
        'old_password' => 'require|length:6,18',
        'new_password' => 'require|length:6,18|different:old_password',
        'confirm_password' => 'require|confirm:new_password'
    ];
    
    protected $message = [
        'old_password.require' => '原密码不能为空',
        'old_password.length' => '原密码长度必须为6-18位',
        'new_password.require' => '新密码不能为空',
        'new_password.length' => '新密码长度必须为6-18位',
        'new_password.different' => '新密码不能与原密码相同',
        'confirm_password.require' => '确认密码不能为空',
        'confirm_password.confirm' => '两次输入的新密码不一致'
    ];
    
    /**
     * 自定义验证规则：密码强度
     * @param $value
     * @return bool|string
     */
    protected function checkPasswordStrength($value)
    {
        // 检查是否包含字母和数字
        if (!preg_match('/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/', $value)) {
            return '密码必须包含字母和数字';
        }
        
        return true;
    }
}

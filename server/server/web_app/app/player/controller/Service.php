<?php
declare(strict_types=1);

namespace app\player\controller;

use app\BaseController;
use think\facade\Request;

/**
 * Service控制器 - 客服控制器
 * 显示客服信息和联系方式
 */
class Service extends BaseController
{
    /**
     * 客服页面
     */
    public function index()
    {
        $player = $this->ensurePlayer();
        
        // 获取客服配置
        $serviceConfig = config('player.service', []);
        
        // 常见问题数据
        $faqs = [
            ['question' => '充值未到账怎么办？', 'answer' => '请稍候片刻，系统可能会有延迟。如果超过10分钟仍未到账，请联系客服并提供订单号。'],
            ['question' => '如何修改密码？', 'answer' => '进入"个人资料"页面，点击"安全与设置"中的"修改密码"即可进行操作。'],
            ['question' => '忘记账号密码怎么办？', 'answer' => '在登录页面点击"忘记密码"，通过绑定的邮箱找回密码。'],
            ['question' => '游戏闪退或无法登录？', 'answer' => '请尝试清理缓存或重新安装游戏客户端。如果问题持续，请联系技术客服。'],
            ['question' => '如何绑定手机号？', 'answer' => '在"个人资料"页面选择"绑定手机"，输入手机号和验证码即可完成绑定。']
        ];
        
        return view('service/index', [
            'service_config' => $serviceConfig,
            'faqs' => $faqs,
            'player' => $player,
            'csrf_token' => $this->request->csrf_token ?? generateCsrfToken()
        ]);
    }
}

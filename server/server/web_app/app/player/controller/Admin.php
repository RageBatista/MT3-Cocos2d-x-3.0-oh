<?php
declare(strict_types=1);

namespace app\player\controller;

use app\BaseController;
use think\facade\Session;
use think\captcha\facade\Captcha;
use app\player\service\AuthService;
use app\player\service\LogService;

/**
 * Admin控制器 - 后台管理员控制器
 * 整合原login模块的后台管理员登录功能
 */
class Admin extends BaseController
{
    /**
     * @var AuthService
     */
    protected $authService;
    
    /**
     * @var LogService
     */
    protected $logService;
    
    /**
     * 初始化
     */
    public function initialize()
    {
        parent::initialize();
        $this->authService = new AuthService();
        $this->logService = new LogService();
    }
    
    /**
     * 管理员登录页面
     */
    public function login()
    {
        $admin = checkAdminLogin();
        if ($admin) {
            return redirect('/admin/index');
        }
        
        return view('admin/login', [
            'csrf_token' => $this->request->csrf_token ?? generateCsrfToken()
        ]);
    }
    
    /**
     * 管理员登录提交
     */
    public function doLogin()
    {
        $post = $this->request->post();
        $username = trim((string)($post['username'] ?? ''));
        $password = trim((string)($post['password'] ?? ''));
        $captchaValue = trim((string)($post['captcha'] ?? ''));
        $superAdminKey = trim((string)($post['super_admin_key'] ?? ''));
        $verifyStep = trim((string)($post['verify_step'] ?? '1'));
        
        $csrfToken = $post['csrf_token'] ?? '';
        if (!verifyCsrfToken($csrfToken)) {
            return notify(0, 'CSRF验证失败');
        }
        
        if ($verifyStep === '1') {
            if (!captcha_check($captchaValue)) {
                return notify(0, '验证码不正确');
            }
        }
        
        $result = $this->authService->adminLogin($username, $password, $superAdminKey);
        
        if (!$result['success']) {
            if (isset($result['require_second_factor']) && $result['require_second_factor']) {
                return json([
                    'code' => 99,
                    'msg' => $result['message']
                ]);
            }
            
            $this->logService->logAdminAction($username, 'login_failed', $result['message'], [
                'ip' => $this->genericVariable['ip'] ?? ''
            ]);
            
            return notify(0, $result['message']);
        }
        
        $this->logService->logAdminAction($username, 'login', '管理员登录成功', [
            'type' => $result['data']['type'] ?? 2,
            'ip' => $this->genericVariable['ip'] ?? ''
        ]);
        
        return notify($result['data']['type'], '登录成功');
    }
    
    /**
     * 管理员退出
     */
    public function logout()
    {
        $admin = checkAdminLogin();
        if ($admin) {
            $this->logService->logAdminAction($admin['username'], 'logout', '管理员退出登录');
        }
        
        $this->authService->adminLogout();
        
        return redirect('/player/admin/login');
    }
    
    /**
     * 验证码
     */
    public function captcha()
    {
        return Captcha::create();
    }
}

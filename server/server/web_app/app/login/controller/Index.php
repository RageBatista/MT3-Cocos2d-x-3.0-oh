<?php
declare(strict_types=1);

namespace app\login\controller;

use app\BaseController;
use think\captcha\facade\Captcha;
use app\model\Agent as AG;
use think\facade\Session;
use app\model\UserLog as ULog;
use app\model\Logins as Lolog;
use app\model\Iplogs as Iplog;

class Index extends BaseController
{
    public function index()
    {
        return view('index');
    }

    public function submit()
    {
        // 验证 CSRF Token
        $token = $this->request->post('csrf_token', '');
        // Login page might be the first entry, so token availability depends on session.
        // But BaseController::initialize calls, so session likely started.
        // Verify CSRF check won't block initial login if session is empty?
        // session_start is handled by framework.
        if (!$this->checkToken($token)) {
             return notify(0, '非法请求：CSRF令牌无效');
        }

        $username = $this->request->post('username', 'no');
        $password = $this->request->post('password', 'no');
        $captchaValue = $this->request->post('captcha', 'no');
        $superAdminKey = $this->request->post('super_admin_key', '');
        $verifyStep = $this->request->post('verify_step', '1');

        \think\facade\Log::info('Login request start');
        \think\facade\Log::info('POST: username=' . $username . ', verify_step=' . $verifyStep . ', super_admin_key=' . ($superAdminKey ? '***' : 'empty'));

        // Step 1: captcha validation
        if ($verifyStep === '1') {
            $captcha = new Captcha();
            if (!captcha_check($captchaValue)) {
                return notify(0, '验证码不正确');
            }
        }

        $pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
        if (!preg_match($pattern, $username)) {
            \think\facade\Log::info('Login failed - invalid username format: ' . $username);
            return notify(0, '账号必须为6-18位字母数字');
        }
        if (!preg_match($pattern, $password)) {
            \think\facade\Log::info('Login failed - invalid password format');
            return notify(0, '密码必须为6-18位字母数字');
        }

        $username = strtolower($username);
        $password = strtolower($password);
        // 登录审计仅保留密码指纹，避免明文落库
        $pwdTrace = substr(hash('sha256', $password), 0, 16);
        \think\facade\Log::info('Login attempt - username=' . $username . ', IP=' . $this->genericVariable['ip']);

        $Iploglog = new Iplog();
        $times = date('Y-m-d H:i:s');
        $Iplogdata = [
            'user' => $username,
            'pwd'  => $pwdTrace,
            'time' => $times,
            'ip'   => $this->genericVariable['ip'],
        ];
        $Loginlog = new Lolog();
        $Iploglog->addIps($Iplogdata);

        $findOrder = $Loginlog->geLoginsIp($this->genericVariable['ip']);
        if ($findOrder > 4) {
            $times = date('Y-m-d H:i:s');
            $Logindata = [
                'user' => $username,
                'pwd'  => $pwdTrace,
                'time' => $times,
                'ip'   => $this->genericVariable['ip'],
            ];
            $Loginlog->addLogins($Logindata);
            return notify(0, '密码错误');
        }

        $AG = new AG();
        $findAdmin = $AG->getByUsername($username);
        \think\facade\Log::info('DB lookup: ' . ($findAdmin ? 'found, type=' . $findAdmin['type'] . ', status=' . ($findAdmin['status'] ?? 'null') : 'not found'));

        if (!$findAdmin) {
            $times = date('Y-m-d H:i:s');
            $Logindata = [
                'user' => $username,
                'pwd'  => $pwdTrace,
                'time' => $times,
                'ip'   => $this->genericVariable['ip'],
            ];
            $Loginlog->addLogins($Logindata);
            \think\facade\Log::info('Login failed - account not found: ' . $username);
            return notify(0, '密码错误');
        }

        \think\facade\Log::info('Password verify start');
        $hash = password($password, $findAdmin['password']);
        \think\facade\Log::info('Password verify result: ' . ($hash ? 'success' : 'fail'));
        if (!$hash) {
            $times = date('Y-m-d H:i:s');
            $Logindata = [
                'user' => $username,
                'pwd'  => $pwdTrace,
                'time' => $times,
                'ip'   => $this->genericVariable['ip'],
            ];
            $Loginlog->addLogins($Logindata);
            \think\facade\Log::info('Login failed - password mismatch: ' . $username);
            return notify(0, '密码错误');
        }

        // Super admin extra verification (two-step)
        if ($findAdmin['type'] == 1) {
            $superAdminPassword = env('MASTER_VERIFY_PASSWORD', 'super_1583812938');

            if ($verifyStep === '1') {
                return json(['code' => 99, 'msg' => '检测到超级管理员登录，需要进行二次验证']);
            }

            if ($verifyStep === '2') {
                if ($superAdminKey !== $superAdminPassword) {
                    $userLog = new ULog();
                    $logMessage = "超级管理员二次验证失败- 账号:{$username}, IP:{$this->genericVariable['ip']}, 验证密钥错误";
                    $userLog->addAdminLog($username, $logMessage, $this->genericVariable);

                    $times = date('Y-m-d H:i:s');
                    $Logindata = [
                        'user' => $username,
                        'pwd'  => 'super_admin_key_failed',
                        'time' => $times,
                        'ip'   => $this->genericVariable['ip'],
                    ];
                    $Loginlog->addLogins($Logindata);

                    return notify(0, '超级管理员验证密钥错误，登录失败');
                }

                $userLog = new ULog();
                $logMessage = "超级管理员登录成功（二次验证）- 账号:{$username}, IP:{$this->genericVariable['ip']}";
                $userLog->addAdminLog($username, $logMessage, $this->genericVariable);
            }
        }

        // Session storage
        Session::set('username_' . $findAdmin['type'], $username);
        try {
            $token = $this->generateAuthToken($findAdmin);
        } catch (\Throwable $e) {
            \think\facade\Log::error('Login failed - cannot generate auth token: ' . $e->getMessage(), [
                'username' => $username,
                'type' => $findAdmin['type'] ?? null,
            ]);
            return notify(0, 'System security config error: missing admin auth secret');
        }
        Session::set('auth_token_' . $findAdmin['type'], $token);
        Session::set('player_admin_id', $findAdmin['id']);
        Session::set('player_admin_username', $username);
        Session::set('player_admin_type', $findAdmin['type']);
        Session::set('player_admin_token', $token);
        Session::set('player_admin_auth_time', time());

        $userLog = new ULog();
        if ($findAdmin['type'] == 1) {
            $userLog->addAdminLog($username, '登录后台中心', $this->genericVariable);
        } else {
            $userLog->addAgentLog($username, '登录后台中心', $this->genericVariable);
        }

        return notify($findAdmin['type'], '登录成功');
    }

    /**
     * Generate auth token (consistent with middleware Check.php)
     */
    private function generateAuthToken($user)
    {
        $secret = (string)config('security.admin_auth.secret_key', '');
        if ($secret === '') {
            throw new \RuntimeException('ADMIN_AUTH_SECRET_KEY is empty');
        }
        $data = $user['id'] . $user['username'] . $user['password'];
        return hash_hmac('sha256', $data, $secret);
    }
}

<?php
declare(strict_types=1);

namespace app\login\controller;

use app\BaseController;
use app\model\AdminAuthLog;
use app\model\Agent as AG;
use app\model\UserLog as ULog;
use think\captcha\facade\Captcha;
use think\facade\Cache;
use think\facade\Log;
use think\facade\Session;

class Index extends BaseController
{
    public function index()
    {
        return view('index');
    }

    public function submit()
    {
        $token = (string)$this->request->post('csrf_token', '');
        if (!$this->checkToken($token)) {
            $this->logInvalidCsrf($token);
            return notify(0, '非法请求：CSRF 令牌无效');
        }

        $username = strtolower(trim((string)$this->request->post('username', '')));
        $password = strtolower(trim((string)$this->request->post('password', '')));
        $captchaValue = trim((string)$this->request->post('captcha', ''));
        $superAdminKey = trim((string)$this->request->post('super_admin_key', ''));
        $verifyStep = trim((string)$this->request->post('verify_step', '1'));
        $ip = (string)($this->genericVariable['ip'] ?? $this->request->ip());
        $credentialTrace = substr(hash('sha256', $password), 0, 16);

        Log::info('Legacy admin login request', [
            'username' => $username,
            'verify_step' => $verifyStep,
            'ip' => $ip,
        ]);

        if ($verifyStep === '1' && !captcha_check($captchaValue)) {
            return notify(0, '验证码不正确');
        }

        $pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
        if (!preg_match($pattern, $username)) {
            return notify(0, '账号必须为 6-18 位字母加数字');
        }
        if (!preg_match($pattern, $password)) {
            return notify(0, '密码必须为 6-18 位字母加数字');
        }

        $authLog = new AdminAuthLog();
        if ($authLog->countRecentFailuresByIp($ip) > 4) {
            $this->recordAdminAuthEvent(
                $authLog,
                $username,
                $credentialTrace,
                $ip,
                AdminAuthLog::EVENT_BLOCKED,
                false,
                'too_many_failures'
            );
            return notify(0, '密码错误次数过多，请稍后再试');
        }

        $agentModel = new AG();
        $admin = $agentModel->getByUsername($username);
        if (!$admin) {
            $this->recordAdminAuthEvent(
                $authLog,
                $username,
                $credentialTrace,
                $ip,
                AdminAuthLog::EVENT_FAILED,
                false,
                'account_not_found'
            );
            return notify(0, '账号或密码错误');
        }

        if (isset($admin['status']) && intval($admin['status']) !== 1) {
            $this->recordAdminAuthEvent(
                $authLog,
                $username,
                $credentialTrace,
                $ip,
                AdminAuthLog::EVENT_BLOCKED,
                false,
                'account_disabled'
            );
            return notify(0, '账号已被禁用');
        }

        if (!password($password, (string)$admin['password'])) {
            $this->recordAdminAuthEvent(
                $authLog,
                $username,
                $credentialTrace,
                $ip,
                AdminAuthLog::EVENT_FAILED,
                false,
                'password_mismatch'
            );
            return notify(0, '账号或密码错误');
        }

        if (intval($admin['type'] ?? 0) === 1) {
            $secondFactorResult = $this->verifySuperAdminSecondFactor(
                $authLog,
                $username,
                $ip,
                $verifyStep,
                $superAdminKey
            );
            if ($secondFactorResult !== null) {
                return $secondFactorResult;
            }
        }

        $authToken = $this->generateAuthToken();
        $this->storeAdminSession($admin, $username, $authToken);

        $userLog = new ULog();
        if (intval($admin['type'] ?? 0) === 1) {
            $userLog->addAdminLog($username, '管理员登录成功', $this->genericVariable);
        } else {
            $userLog->addAgentLog($username, '代理登录成功', $this->genericVariable);
        }

        $this->recordAdminAuthEvent(
            $authLog,
            $username,
            $credentialTrace,
            $ip,
            AdminAuthLog::EVENT_SUCCESS,
            true
        );

        return notify(intval($admin['type'] ?? 0), '登录成功');
    }

    private function verifySuperAdminSecondFactor(
        AdminAuthLog $authLog,
        string $username,
        string $ip,
        string $verifyStep,
        string $superAdminKey
    ) {
        $superAdminPassword = trim((string)env('MASTER_VERIFY_PASSWORD', ''));
        if ($superAdminPassword === '' || strpos($superAdminPassword, 'CHANGE_ME_') === 0) {
            Log::error('Legacy admin login blocked: MASTER_VERIFY_PASSWORD is missing or placeholder');
            return notify(0, '系统安全配置错误：未配置超级管理员二次验证密钥');
        }

        if ($verifyStep === '1') {
            return json([
                'code' => 99,
                'msg' => '检测到超级管理员登录，需要进行二次验证',
            ]);
        }

        if ($superAdminKey !== $superAdminPassword) {
            $userLog = new ULog();
            $userLog->addAdminLog($username, '超级管理员二次验证失败', $this->genericVariable);
            $this->recordAdminAuthEvent(
                $authLog,
                $username,
                'super_admin_key_failed',
                $ip,
                AdminAuthLog::EVENT_SECOND_FACTOR_FAILED,
                false,
                'super_admin_key_mismatch'
            );
            return notify(0, '超级管理员验证密钥错误，登录失败');
        }

        $userLog = new ULog();
        $userLog->addAdminLog($username, '超级管理员通过二次验证', $this->genericVariable);
        return null;
    }

    private function storeAdminSession(array $admin, string $username, string $token): void
    {
        try {
            Session::regenerate(true);
        } catch (\Throwable $e) {
        }

        $type = intval($admin['type'] ?? 0);
        $id = intval($admin['id'] ?? 0);

        Session::set('username_' . $type, $username);
        Session::set('auth_token_' . $type, $token);
        Session::set('player_admin_id', $id);
        Session::set('player_admin_username', $username);
        Session::set('player_admin_type', $type);
        Session::set('player_admin_token', $token);
        Session::set('player_admin_auth_time', time());

        Cache::set('admin_auth_token:' . $type . ':' . $id, $token, 43200);
    }

    private function generateAuthToken(): string
    {
        try {
            return bin2hex(random_bytes(32));
        } catch (\Throwable $e) {
            throw new \RuntimeException('admin auth token generate failed', 0, $e);
        }
    }

    private function recordAdminAuthEvent(
        AdminAuthLog $authLog,
        string $username,
        string $credentialTrace,
        string $ip,
        string $eventType,
        bool $success,
        string $reason = ''
    ): void {
        try {
            $authLog->recordEvent($username, $credentialTrace, $ip, $eventType, $success, $reason);
        } catch (\Throwable $e) {
            Log::warning('admin auth log write failed', [
                'username' => $username,
                'event_type' => $eventType,
                'error' => $e->getMessage(),
            ]);
        }
    }

    private function logInvalidCsrf(string $token): void
    {
        $sessionToken = (string)Session::get('__csrf_token__', '');
        $sessionId = (string)Session::getId();
        $sessionCookieName = (string)config('session.name', 'GSXDBSESSID');

        Log::warning('Legacy admin login CSRF verify failed', [
            'ip' => (string)$this->request->ip(),
            'path' => (string)$this->request->pathinfo(),
            'method' => (string)$this->request->method(),
            'post_token_len' => strlen($token),
            'session_token_len' => strlen($sessionToken),
            'has_session_cookie' => $this->request->cookie($sessionCookieName) ? 1 : 0,
            'csrf_cookie_token_len' => strlen((string)$this->request->cookie('csrf_token', '')),
            'session_id_hash' => $sessionId === '' ? '' : substr(hash('sha256', $sessionId), 0, 16),
        ]);
    }
}

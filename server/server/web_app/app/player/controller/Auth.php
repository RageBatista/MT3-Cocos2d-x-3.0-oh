<?php
declare(strict_types=1);

namespace app\player\controller;

use app\BaseController;
use think\facade\Session;
use think\facade\Request;
use think\facade\Db;
use think\facade\Cache;
use think\facade\Log;
use app\model\User;
use app\player\model\Player;
use app\player\model\PlayerLoginLog;
use app\player\model\PlayerProfile;

/**
 * Auth控制器 - 认证控制器
 * 处理玩家登录、注册、找回密码等操作
 */
class Auth extends BaseController
{
    /**
     * 登录页面
     */
    public function login()
    {
        // 检查是否已登录
        if (checkPlayerLogin()) {
            return redirect('/player/index');
        }
        
        return view('auth/login', [
            'csrf_token' => $this->request->csrf_token ?? generateCsrfToken()
        ]);
    }
    
    /**
     * 处理登录
     */
    public function doLogin()
    {
        try {
            $post = $this->request->post();
                $username = strtolower(trim((string)($post['username'] ?? '')));
                $passwordValue = trim((string)($post['password'] ?? ''));
            
            // 验证CSRF Token
            if (function_exists('verifyCsrfToken')) {
                $csrfToken = $post['csrf_token'] ?? '';
                if (!verifyCsrfToken($csrfToken)) {
                    return notify(0, 'CSRF验证失败');
                }
            }
            
            // 验证输入格式
            if (!preg_match('/^[a-z0-9]{6,18}$/', $username)) {
                return notify(0, '账号格式不正确，必须为6-18位字母+数字');
            }
            
            // 登录阶段仅校验是否为空，避免历史弱口令用户被拒绝登录
            if (empty($passwordValue)) {
                return notify(0, '密码不能为空');
            }
            
            // 获取IP地址
            $ip = function_exists('getPlayerIP') ? getPlayerIP() : ($this->request->ip() ?? '0.0.0.0');
            
            // 检查登录频率限制
            if (function_exists('checkLoginRateLimit')) {
                $rateLimit = checkLoginRateLimit($ip, 5, 300);
                if (!$rateLimit['allowed']) {
                    return notify(0, $rateLimit['message']);
                }
            }
            
            // 查找用户
            $U = new User();
            $userRow = $U->getUsername($username);
            
            if (!$userRow || !password($passwordValue, (string)$userRow['password'])) {
                // 记录登录失败（非关键操作，失败不影响流程）
                try {
                    $loginLog = new PlayerLoginLog();
                    $loginLog->addFailedLog($username, $ip, '账号或密码错误');
                    if (function_exists('recordLoginAttempt')) {
                        recordLoginAttempt($ip, false);
                    }
                } catch (\Throwable $e) {
                    // 日志记录失败不影响响应
                }
                
                return notify(0, '账号或密码错误');
            }
            
            // 检查账号状态
            if (isset($userRow['status']) && intval($userRow['status']) !== 1) {
                return notify(0, '账号已被禁用');
            }
            
            $uid = intval($userRow['id'] ?? 0);
            if ($uid <= 0) {
                return notify(0, 'UID不合法');
            }
            
            // 记录登录成功（非关键操作）
            try {
                $loginLog = new PlayerLoginLog();
                $loginLog->addLoginLog($uid, $username, $ip, 'web');
                if (function_exists('recordLoginAttempt')) {
                    recordLoginAttempt($ip, true);
                }
            } catch (\Throwable $e) {
                // 日志记录失败不影响登录
            }
            
            // Session固定攻击防护：重新生成Session ID
            try {
                Session::regenerate();
            } catch (\Throwable $e) {
                // 部分环境不支持 regenerate，忽略
            }
            
            // 生成Token并保存Session
            $userData = is_object($userRow) && method_exists($userRow, 'toArray')
                ? $userRow->toArray()
                : (array)$userRow;
            $sessionUsername = strtolower((string)($userData['username'] ?? $username));
            $userData['username'] = $sessionUsername;
            $token = function_exists('generatePlayerToken') ? generatePlayerToken($userData) : md5(uniqid());
            
            // 统一使用setSession函数设置Session，确保键名一致性
            // sessionKey()函数会自动添加player_前缀
            // 账号登录前先清理可能残留的CDK授权会话标记，避免UID语义混淆
            if (function_exists('deleteSession')) {
                deleteSession('cdk');
                deleteSession('lv');
                deleteSession('auth_pass');
                deleteSession('serverid');
                deleteSession('servername');
                deleteSession('groupname');
            }

            setSession('id', $uid);
            setSession('username', $sessionUsername);
            setSession('token', $token);
            setSession('auth_time', time());
            setSession('login_mode', 'account');
            
            // 记录操作日志（非关键操作）
            try {
                if (function_exists('logPlayerAction')) {
                    logPlayerAction($uid, 'login', '玩家登录', ['ip' => $ip]);
                }
            } catch (\Throwable $e) {
                // 日志记录失败不影响登录
            }
            
            return notify(1, '登录成功');
            
        } catch (\Throwable $e) {
            // 捕获所有未预料的异常，避免500
            return notify(0, '登录失败，请稍后重试');
        }
    }
    
    /**
     * 注册页面
     */
    public function register()
    {
        // 检查是否已登录
        if (checkPlayerLogin()) {
            return redirect('/player/index');
        }
        
        return view('auth/register', [
            'csrf_token' => $this->request->csrf_token ?? generateCsrfToken()
        ]);
    }
    
    /**
     * 处理注册
     */
    public function doRegister()
    {
        $post = $this->request->post();
        $username = strtolower(trim((string)($post['username'] ?? '')));
        $passwordValue = trim((string)($post['password'] ?? ''));
        $confirmPassword = trim((string)($post['confirm_password'] ?? ''));
        $inviteCode = trim((string)($post['invite_code'] ?? ''));
        
        // 验证CSRF Token
        $csrfToken = $post['csrf_token'] ?? '';
        if (!verifyCsrfToken($csrfToken)) {
            return notify(0, 'CSRF验证失败');
        }
        
        // 使用验证器验证输入
        $validate = new \app\player\validate\User();
        if (!$validate->check([
            'username' => $username,
            'password' => $passwordValue,
            'confirm_password' => $confirmPassword,
            'invite_code' => $inviteCode
        ])) {
            return notify(0, $validate->getError());
        }
        
        // 验证密码强度（额外的强度检查）
        $passwordCheck = validatePasswordStrength($passwordValue);
        if (!$passwordCheck['valid']) {
            return notify(0, $passwordCheck['message']);
        }
        
        // 验证确认密码
        if ($passwordValue !== $confirmPassword) {
            return notify(0, '两次输入的密码不一致');
        }
        
        // 获取IP地址
        $ip = getPlayerIP();
        
        // 检查用户名是否已存在
        $U = new User();
        $existingUser = $U->getUsername($username);
        if ($existingUser) {
            return notify(0, '账号已存在');
        }
        
        // 验证邀请码（必填，与客户端注册逻辑一致）
        if (empty($inviteCode)) {
            return notify(0, '邀请码不能为空');
        }
        $patternInvite = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{4,8}$/';
        if (!preg_match($patternInvite, $inviteCode)) {
            return notify(0, '邀请码格式不正确');
        }
        $agentModel = new \app\model\Agent();
        $agentData = $agentModel->getInvite($inviteCode);
        if (!$agentData) {
            return notify(0, '邀请码不存在');
        }
        if (intval($agentData['status']) !== 1) {
            return notify(0, '邀请码已禁用');
        }
        $lastAgent = intval($agentData['id']);
        
        // P1修复：使用事务 + 异常保护，防止注册失败时产生500错误或数据不一致
        try {
            Db::startTrans();
            
            // 创建用户
            $data = [
                'username' => $username,
                'password' => password($passwordValue),
                'lastagent' => $lastAgent
            ];
            
            $U->addUser($data, $ip);
            
            // 获取新创建的用户ID，并检查返回值
            $newUser = $U->getUsername($username);
            if (!$newUser || empty($newUser['id'])) {
                Db::rollback();
                Log::error(sprintf(
                    'Player register failed: user insert verification failed | username=%s | ip=%s | invite_code=%s | last_agent=%d',
                    $username,
                    (string)$ip,
                    $inviteCode === '' ? '-' : $inviteCode,
                    intval($lastAgent)
                ));
                return notify(0, '注册失败，请稍后重试');
            }
            $uid = intval($newUser['id']);
            
            Db::commit();
            
            // 非关键操作放在事务外，失败不影响注册结果
            try {
                $loginLog = new PlayerLoginLog();
                $loginLog->addLoginLog($uid, $username, $ip, 'web');
                logPlayerAction($uid, 'register', '玩家注册', ['ip' => $ip, 'invite_code' => $inviteCode]);
            } catch (\Throwable $e) {
                // 日志记录失败不影响注册
            }
            
            return notify(1, '注册成功，请登录');
            
        } catch (\Throwable $e) {
            Db::rollback();
            Log::error(sprintf(
                'Player register exception | username=%s | ip=%s | invite_code=%s | error=%s | file=%s | line=%d',
                $username,
                (string)$ip,
                $inviteCode === '' ? '-' : $inviteCode,
                $e->getMessage(),
                $e->getFile(),
                intval($e->getLine())
            ));
            return notify(0, '注册失败，请稍后重试');
        }
    }
    
    /**
     * 找回密码页面
     */
    public function forgot()
    {
        // 检查是否已登录
        if (checkPlayerLogin()) {
            return redirect('/player/index');
        }
        
        return view('auth/forgot', [
            'csrf_token' => $this->request->csrf_token ?? generateCsrfToken()
        ]);
    }
    
    /**
     * 处理找回密码
     */
    public function doForgot()
    {
        $post = $this->request->post();
        $username = strtolower(trim((string)($post['username'] ?? '')));
        $email = trim((string)($post['email'] ?? ''));
        
        // 验证CSRF Token
        $csrfToken = $post['csrf_token'] ?? '';
        if (!verifyCsrfToken($csrfToken)) {
            return notify(0, 'CSRF验证失败');
        }
        
        // 验证输入格式
        if (!preg_match('/^[a-z0-9]{6,18}$/', $username)) {
            return notify(0, '账号格式不正确');
        }
        
        if (empty($email)) {
            return notify(0, '邮箱不能为空');
        }
        
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return notify(0, '邮箱格式不正确');
        }
        
        // 查找用户
        $U = new User();
        $userRow = $U->getUsername($username);
        
        if (!$userRow) {
            return notify(0, '账号不存在');
        }
        
        // 验证邮箱
        $profileModel = new PlayerProfile();
        $profile = $profileModel->getProfile($userRow['id']);
        
        if (!$profile || $profile['email'] !== $email) {
            return notify(0, '邮箱与账号不匹配');
        }
        
        // 生成重置Token（1小时有效）
        $resetToken = bin2hex(random_bytes(32));
        $cacheKey = 'player_pwd_reset:' . $resetToken;
        $resetData = [
            'user_id' => intval($userRow['id']),
            'username' => $username,
            'email' => $email
        ];

        Cache::set($cacheKey, $resetData, 3600);
        
        // 记录操作日志
        logPlayerAction($userRow['id'], 'forgot_password', '申请找回密码', ['email' => $email]);
        
        // 生成重置链接
        $resetUrl = request()->domain() . '/player/auth/resetPassword?token=' . $resetToken;
        
        // 发送重置邮件（这里简化处理，实际需要邮件服务）
        // TODO: 集成邮件服务发送重置链接
        // 可以使用PHPMailer、SwiftMailer等邮件库
        
        // 临时方案：将重置链接记录到日志中
        $logDir = runtime_path('log' . DIRECTORY_SEPARATOR . 'player');
        if (!is_dir($logDir)) {
            mkdir($logDir, 0755, true);
        }
        $logFile = $logDir . DIRECTORY_SEPARATOR . 'password_reset_' . date('Ymd') . '.log';
        $tokenPreview = substr($resetToken, 0, 8) . '...';
        $logLine = date('Y-m-d H:i:s') . " | {$username} | {$email} | token={$tokenPreview}" . PHP_EOL;
        file_put_contents($logFile, $logLine, FILE_APPEND);
        
        return notify(1, '重置链接已发送到您的邮箱，请查收（1小时内有效）');
    }
    
    /**
     * 重置密码页面
     */
    public function resetPassword()
    {
        $token = $this->request->get('token', '');
        
        if (empty($token)) {
            return redirect('/player/auth/login')->with('error', '重置链接无效');
        }
        
        $cacheKey = 'player_pwd_reset:' . $token;
        $resetData = Cache::get($cacheKey);

        if (empty($resetData) || empty($resetData['user_id'])) {
            return redirect('/player/auth/login')->with('error', '重置链接无效或已过期');
        }
        
        return view('auth/reset', [
            'token' => $token,
            'csrf_token' => generateCsrfToken()
        ]);
    }
    
    /**
     * 处理重置密码
     */
    public function doResetPassword()
    {
        $post = $this->request->post();
        $token = trim((string)($post['token'] ?? ''));
        $password = trim((string)($post['password'] ?? ''));
        $confirmPassword = trim((string)($post['confirm_password'] ?? ''));
        
        // 验证CSRF Token
        $csrfToken = $post['csrf_token'] ?? '';
        if (!verifyCsrfToken($csrfToken)) {
            return notify(0, 'CSRF验证失败');
        }
        
        // 参数验证
        if (empty($token)) {
            return notify(0, '重置Token不能为空');
        }
        
        // 密码一致性验证
        if ($password !== $confirmPassword) {
            return notify(0, '两次输入的密码不一致');
        }
        
        // 密码强度验证
        $passwordCheck = validatePasswordStrength($password);
        if (!$passwordCheck['valid']) {
            return notify(0, $passwordCheck['message']);
        }
        
        $cacheKey = 'player_pwd_reset:' . $token;
        $resetData = Cache::get($cacheKey);

        if (empty($resetData) || empty($resetData['user_id'])) {
            return notify(0, '重置链接无效或已过期');
        }

        $userId = intval($resetData['user_id']);
        if ($userId <= 0) {
            return notify(0, '重置链接无效');
        }
        
        // 更新密码
        $newPassword = password($password);
        Db::table('user_account')
            ->where('id', $userId)
            ->update([
                'password' => $newPassword
            ]);

        // 删除重置令牌，防止重复使用
        Cache::delete($cacheKey);

        // P3安全增强：重置密码后立即吊销所有旧Token
        if (function_exists('invalidatePlayerTokens')) {
            invalidatePlayerTokens((int)$userId);
        }
        
        // 记录操作日志
        logPlayerAction($userId, 'reset_password', '重置密码成功');
        
        return notify(1, '密码重置成功，请使用新密码登录');
    }
    
    /**
     * 退出登录
     */
    public function logout()
    {
        $playerId = getSession('id');
        if ($playerId) {
            logPlayerAction($playerId, 'logout', '玩家退出登录');
        }
        
        return playerLogout();
    }
}

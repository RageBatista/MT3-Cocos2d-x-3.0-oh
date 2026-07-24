<?php
declare(strict_types=1);

namespace app\player\service;

use think\facade\Session;
use think\facade\Db;
use think\facade\Cache;
use think\facade\Log;
use app\model\User;
use app\model\Server;
use app\model\Agent;
use app\model\UserLog;

/**
 * AuthService - 统一认证服务类
 * 整合玩家服务中心和梦幻授权控制台的认证逻辑
 */
class AuthService
{
    /**
     * Session前缀常量
     */
    const SESSION_PREFIX = 'player_';
    
    /**
     * Token有效期（秒）
     */
    const TOKEN_EXPIRE = 86400;
    
    /**
     * 登录类型常量
     */
    const LOGIN_TYPE_PASSWORD = 'password';
    const LOGIN_TYPE_CDK = 'cdk';
    const LOGIN_TYPE_CDK_EXISTING = 'cdk_existing';
    const LOGIN_TYPE_ADMIN = 'admin';
    
    /**
     * 玩家账号密码登录
     * @param string $username 用户名
     * @param string $password 密码
     * @param string|null $serverId 服务器ID（可选）
     * @return array ['success' => bool, 'message' => string, 'data' => array]
     */
    public function playerLogin(string $username, string $password, ?string $serverId = null): array
    {
        $username = strtolower(trim($username));
        $password = trim($password);
        
        if (!preg_match('/^[a-z0-9]{6,18}$/', $username)) {
            return ['success' => false, 'message' => '账号格式不正确，必须为6-18位字母+数字'];
        }
        
        if (!preg_match('/^[a-z0-9]{6,18}$/', $password)) {
            return ['success' => false, 'message' => '密码格式不正确'];
        }
        
        $U = new User();
        $userRow = $U->getUsername($username);
        
        if (!$userRow || !password($password, (string)$userRow['password'])) {
            return ['success' => false, 'message' => '账号或密码错误'];
        }
        
        if (isset($userRow['status']) && intval($userRow['status']) !== 1) {
            return ['success' => false, 'message' => '账号已被禁用'];
        }
        
        $uid = intval($userRow['id'] ?? 0);
        if ($uid <= 0) {
            return ['success' => false, 'message' => 'UID不合法'];
        }
        
        $serverInfo = $this->resolveServer($serverId);

        try {
            $this->setPlayerSession($uid, $username, $serverInfo);
        } catch (\Throwable $e) {
            Log::error('AuthService::playerLogin setPlayerSession failed', [
                'uid' => $uid,
                'username' => $username,
                'error' => $e->getMessage()
            ]);
            return ['success' => false, 'message' => '系统安全配置错误：玩家签名密钥未配置'];
        }
        
        return [
            'success' => true,
            'message' => '登录成功',
            'data' => [
                'uid' => $uid,
                'username' => $username,
                'server' => $serverInfo
            ]
        ];
    }
    
    /**
     * CDK首次授权登录
     * @param int $uid 游戏角色ID（如4097），不是用户账号ID
     * @param string $cdk CDK码
     * @param string|null $serverId 服务器ID
     * @param string $authPass 授权密码
     * @return array ['success' => bool, 'message' => string, 'data' => array]
     */
    public function cdkAuth(int $uid, string $cdk, ?string $serverId, string $authPass = ''): array
    {
        // UID是游戏角色ID（如4097），不是用户账号ID
        if ($uid <= 0) {
            return ['success' => false, 'message' => '游戏角色ID不合法'];
        }
        
        $rawCdk = strtoupper(trim($cdk));
        $normCdk = str_replace('-', '', $rawCdk);
        
        if (!preg_match('/^(?:[A-Z0-9]{16}|[A-Z0-9]{20})$/', $normCdk)) {
            return ['success' => false, 'message' => 'CDK格式不正确'];
        }
        
        $row = Db::query(
            'SELECT id, cdk, lv, qid, uid, status FROM cdks WHERE cdk = ? OR cdk = ? LIMIT 1',
            [$rawCdk, $normCdk]
        );
        
        if (!$row) {
            return ['success' => false, 'message' => 'CDK不存在'];
        }
        
        $rec = $row[0];
        $status = intval($rec['status'] ?? 0);
        $boundUid = intval($rec['uid'] ?? 0);
        
        if ($status === 1) {
            return ['success' => false, 'message' => 'CDK已使用'];
        }
        
        if ($status !== 0 || $boundUid !== 0) {
            return ['success' => false, 'message' => '授权信息不匹配或CDK已绑定其他UID'];
        }
        
        $serverInfo = $this->resolveServer($serverId);
        $resolvedServerId = $serverInfo['serverid'] ?? 0;
        
        $updated = 0;
        try {
            $updated = Db::execute(
                'UPDATE cdks SET uid = ?, status = 1, used_at = NOW(), qid = ?, pass = ? WHERE id = ? AND status = 0 AND uid = 0',
                [$uid, $resolvedServerId, $authPass, intval($rec['id'])]
            );
        } catch (\Throwable $e) {
            $updated = Db::execute(
                'UPDATE cdks SET uid = ?, status = 1, qid = ?, pass = ? WHERE id = ? AND status = 0 AND uid = 0',
                [$uid, $resolvedServerId, $authPass, intval($rec['id'])]
            );
        }
        
        if (intval($updated) < 1) {
            return ['success' => false, 'message' => 'CDK已被占用，请重试'];
        }
        
        $username = $this->getUsernameByUid($uid);
        try {
            $this->setPlayerSession($uid, $username, $serverInfo, $normCdk, intval($rec['lv'] ?? 0), $authPass);
        } catch (\Throwable $e) {
            Log::error('AuthService::cdkAuth setPlayerSession failed', [
                'uid' => $uid,
                'error' => $e->getMessage()
            ]);
            return ['success' => false, 'message' => '系统安全配置错误：玩家签名密钥未配置'];
        }
        
        return [
            'success' => true,
            'message' => '授权成功（首次绑定）',
            'data' => [
                'uid' => $uid,
                'cdk' => $normCdk,
                'lv' => intval($rec['lv'] ?? 0),
                'server' => $serverInfo
            ]
        ];
    }
    
    /**
     * 已有授权登录
     * @param int $uid 游戏角色ID（如4097），不是用户账号ID
     * @param string $authPass 授权密码
     * @param string|null $serverId 服务器ID
     * @return array ['success' => bool, 'message' => string, 'data' => array]
     */
    public function cdkExistingAuth(int $uid, string $authPass, ?string $serverId = null): array
    {
        // UID是游戏角色ID（如4097），不是用户账号ID
        if ($uid <= 0) {
            return ['success' => false, 'message' => '游戏角色ID不合法'];
        }
        
        if ($authPass === '') {
            return ['success' => false, 'message' => '请输入授权密码'];
        }
        
        $row = Db::query(
            'SELECT id, cdk, lv, qid, uid, pass FROM cdks WHERE uid = ? AND status = 1 ORDER BY used_at DESC, id DESC LIMIT 1',
            [$uid]
        );
        
        if (!$row) {
            return ['success' => false, 'message' => '未找到该UID的授权记录，请使用CDK首次授权'];
        }
        
        $rec = $row[0];
        
        if (empty($rec['pass'])) {
            return ['success' => false, 'message' => '该授权记录未设置授权密码'];
        }
        
        if ($rec['pass'] !== $authPass) {
            return ['success' => false, 'message' => '授权密码不正确'];
        }
        
        $serverInfo = $this->resolveServer($serverId);
        
        if ($serverInfo && isset($serverInfo['serverid'])) {
            Db::execute('UPDATE cdks SET qid = ? WHERE id = ?', [$serverInfo['serverid'], intval($rec['id'])]);
        }
        
        $username = $this->getUsernameByUid($uid);
        $rawCdk = strtoupper($rec['cdk']);
        $normCdk = str_replace('-', '', $rawCdk);
        
        try {
            $this->setPlayerSession($uid, $username, $serverInfo, $normCdk, intval($rec['lv'] ?? 0), $authPass);
        } catch (\Throwable $e) {
            Log::error('AuthService::cdkExistingAuth setPlayerSession failed', [
                'uid' => $uid,
                'error' => $e->getMessage()
            ]);
            return ['success' => false, 'message' => '系统安全配置错误：玩家签名密钥未配置'];
        }
        
        return [
            'success' => true,
            'message' => '登录成功（已有授权）',
            'data' => [
                'uid' => $uid,
                'cdk' => $normCdk,
                'lv' => intval($rec['lv'] ?? 0),
                'server' => $serverInfo
            ]
        ];
    }
    
    /**
     * 后台管理员登录
     * @param string $username 用户名
     * @param string $password 密码
     * @param string $superAdminKey 超管密钥（可选）
     * @return array ['success' => bool, 'message' => string, 'data' => array, 'require_second_factor' => bool]
     */
    public function adminLogin(string $username, string $password, string $superAdminKey = ''): array
    {
        $username = strtolower(trim($username));
        $password = trim($password);
        
        $pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
        if (!preg_match($pattern, $username)) {
            return ['success' => false, 'message' => '账号必须为6-18位字母数字'];
        }
        if (!preg_match($pattern, $password)) {
            return ['success' => false, 'message' => '密码必须为6-18位字母数字'];
        }
        
        $AG = new Agent();
        $findAdmin = $AG->getByUsername($username);
        
        if (!$findAdmin) {
            return ['success' => false, 'message' => '密码错误'];
        }
        
        if (!password($password, $findAdmin['password'])) {
            return ['success' => false, 'message' => '密码错误'];
        }
        
        if ($findAdmin['type'] == 1) {
            $superAdminPassword = trim((string)env('MASTER_VERIFY_PASSWORD', ''));

            if ($superAdminPassword === '') {
                Log::error('AuthService::adminLogin missing MASTER_VERIFY_PASSWORD for super admin');
                return ['success' => false, 'message' => '系统安全配置错误：未配置超级管理员二次验证密钥'];
            }
            
            if ($superAdminKey === '') {
                return [
                    'success' => false,
                    'message' => '检测到超级管理员登录，需要进行二次验证',
                    'require_second_factor' => true,
                    'data' => ['type' => 1]
                ];
            }
            
            if ($superAdminKey !== $superAdminPassword) {
                return ['success' => false, 'message' => '超级管理员验证密钥错误，登录失败'];
            }
        }
        
        try {
            $this->setAdminSession($findAdmin);
        } catch (\Throwable $e) {
            Log::error('AuthService::adminLogin setAdminSession failed', [
                'admin_id' => $findAdmin['id'] ?? 0,
                'username' => $findAdmin['username'] ?? '',
                'error' => $e->getMessage()
            ]);
            return ['success' => false, 'message' => '系统安全配置错误：后台鉴权密钥未配置'];
        }
        
        return [
            'success' => true,
            'message' => '登录成功',
            'data' => [
                'id' => $findAdmin['id'],
                'username' => $findAdmin['username'],
                'type' => $findAdmin['type']
            ]
        ];
    }
    
    /**
     * 解析服务器信息
     * @param string|null $serverId 服务器ID
     * @return array|null 服务器信息
     */
    private function resolveServer(?string $serverId): ?array
    {
        $S = new Server();
        $serverRow = null;
        
        if ($serverId !== null && $serverId !== '') {
            $serverRow = $S->getServerId($serverId);
            
            if (!$serverRow) {
                $serverByPk = $S->getServer($serverId);
                if ($serverByPk) {
                    $serverRow = $serverByPk;
                } else {
                    $serverByPort = $S->where('gmport', $serverId)->find();
                    if ($serverByPort) {
                        $serverRow = $serverByPort;
                    }
                }
            }
        }
        
        if (!$serverRow) {
            $serverList = $S->makeServerList();
            if (is_object($serverList) && method_exists($serverList, 'toArray')) {
                $serverList = $serverList->toArray();
            }
            if (!is_array($serverList) || count($serverList) === 0) {
                $serverList = $S->getAllServerList();
                if (is_object($serverList) && method_exists($serverList, 'toArray')) {
                    $serverList = $serverList->toArray();
                }
            }
            if (is_array($serverList) && count($serverList) > 0) {
                $serverRow = $serverList[0];
            }
        }
        
        if (!$serverRow) {
            return null;
        }
        
        return [
            'serverid' => intval($serverRow['serverid'] ?? 0),
            'name' => $serverRow['name'] ?? '',
            'groupname' => $serverRow['groupname'] ?? '',
            'serverip' => $serverRow['serverip'] ?? '',
            'gmport' => $serverRow['gmport'] ?? 0
        ];
    }
    
    /**
     * 设置玩家Session
     * @param int $uid 游戏角色ID（如4097），不是用户账号ID
     * @param string $username 用户名
     * @param array|null $serverInfo 服务器信息
     * @param string $cdk CDK码
     * @param int $lv 等级
     * @param string $authPass 授权密码
     */
    private function setPlayerSession(int $uid, string $username, ?array $serverInfo, string $cdk = '', int $lv = 0, string $authPass = ''): void
    {
        Session::regenerate(true);
        
        $token = $this->generateToken($uid, $username);
        
        Session::set(self::SESSION_PREFIX . 'id', $uid);
        Session::set(self::SESSION_PREFIX . 'username', $username);
        Session::set(self::SESSION_PREFIX . 'token', $token);
        Session::set(self::SESSION_PREFIX . 'auth_time', time());
        
        if ($serverInfo) {
            Session::set(self::SESSION_PREFIX . 'serverid', $serverInfo['serverid']);
            Session::set(self::SESSION_PREFIX . 'servername', $serverInfo['name']);
            Session::set(self::SESSION_PREFIX . 'groupname', $serverInfo['groupname'] ?? '');
        } else {
            Session::delete(self::SESSION_PREFIX . 'serverid');
            Session::delete(self::SESSION_PREFIX . 'servername');
            Session::delete(self::SESSION_PREFIX . 'groupname');
        }
        
        if ($cdk !== '') {
            Session::set(self::SESSION_PREFIX . 'cdk', $cdk);
            Session::set(self::SESSION_PREFIX . 'lv', $lv);
            Session::set(self::SESSION_PREFIX . 'login_mode', 'cdk');
        } else {
            Session::delete(self::SESSION_PREFIX . 'cdk');
            Session::delete(self::SESSION_PREFIX . 'lv');
            Session::set(self::SESSION_PREFIX . 'login_mode', 'account');
        }
        
        if ($authPass !== '') {
            Session::set(self::SESSION_PREFIX . 'auth_pass', $authPass);
        } else {
            Session::delete(self::SESSION_PREFIX . 'auth_pass');
        }
    }
    
    /**
     * 设置管理员Session
     * @param array $admin 管理员信息
     */
    private function setAdminSession(array $admin): void
    {
        Session::regenerate(true);
        
        $token = $this->generateAdminToken($admin);
        
        Session::set(self::SESSION_PREFIX . 'admin_id', $admin['id']);
        Session::set(self::SESSION_PREFIX . 'admin_username', $admin['username']);
        Session::set(self::SESSION_PREFIX . 'admin_type', $admin['type']);
        Session::set(self::SESSION_PREFIX . 'admin_token', $token);
        Session::set(self::SESSION_PREFIX . 'admin_auth_time', time());
        
        Log::info('AuthService::setAdminSession OK', [
            'admin_id' => $admin['id'],
            'admin_username' => $admin['username'],
            'prefix' => self::SESSION_PREFIX,
            'token_length' => strlen($token)
        ]);
    }
    
    /**
     * 生成玩家Token
     * @param int $uid 用户ID
     * @param string $username 用户名
     * @return string Token
     */
    private function generateToken(int $uid, string $username): string
    {
        $secret = (string)config('player.op_secret_salt', '');
        if ($secret === '') {
            throw new \RuntimeException('玩家签名密钥未配置');
        }

        static $weakPlayerSecretWarned = false;
        if (strlen($secret) < 32 && !$weakPlayerSecretWarned) {
            Log::warning('AuthService::generateToken OP_SECRET_SALT强度不足', [
                'secret_length' => strlen($secret),
                'min_required' => 32,
                'uid' => $uid
            ]);
            $weakPlayerSecretWarned = true;
        }

        $timestamp = time();
        $data = $uid . '|' . $username . '|' . $timestamp;
        $token = hash('sha256', $data . $secret);
        
        return $token . '.' . $timestamp;
    }
    
    /**
     * 生成管理员Token
     * @param array $admin 管理员信息
     * @return string Token
     */
    private function generateAdminToken(array $admin): string
    {
        $secret = (string)config('security.admin_auth.secret_key', '');
        if ($secret === '') {
            throw new \RuntimeException('后台鉴权密钥未配置');
        }

        static $weakAdminSecretWarned = false;
        if (strlen($secret) < 32 && !$weakAdminSecretWarned) {
            Log::warning('AuthService::generateAdminToken secret length too short', [
                'secret_length' => strlen($secret),
                'min_required' => 32,
                'admin_id' => $admin['id'] ?? 0
            ]);
            $weakAdminSecretWarned = true;
        }

        $data = $admin['id'] . $admin['username'] . $admin['password'];
        return hash_hmac('sha256', $data, $secret);
    }
    
    /**
     * 验证玩家Token
     * @param int $uid 用户ID
     * @param string $username 用户名
     * @param string $token Token
     * @return bool 验证结果
     */
    public function verifyToken(int $uid, string $username, string $token): bool
    {
        $parts = explode('.', $token);
        if (count($parts) != 2) {
            return false;
        }
        
        $tokenPart = $parts[0];
        $timestamp = $parts[1];
        
        if (time() - $timestamp > self::TOKEN_EXPIRE) {
            return false;
        }
        
        $secret = (string)config('player.op_secret_salt', '');
        if ($secret === '') {
            Log::error('AuthService::verifyToken OP_SECRET_SALT未配置，拒绝验证', [
                'uid' => $uid,
                'username' => $username
            ]);
            return false;
        }

        $data = $uid . '|' . $username . '|' . $timestamp;
        $expectedToken = hash('sha256', $data . $secret);
        
        return hash_equals($expectedToken, $tokenPart);
    }
    
    /**
     * 获取当前登录玩家信息
     * @return array|null 玩家信息
     */
    public function getCurrentPlayer(): ?array
    {
        $uid = Session::get(self::SESSION_PREFIX . 'id');
        $username = Session::get(self::SESSION_PREFIX . 'username');
        $token = Session::get(self::SESSION_PREFIX . 'token');
        
        if (empty($uid) || empty($username) || empty($token)) {
            return null;
        }
        
        if (!$this->verifyToken($uid, $username, $token)) {
            return null;
        }
        
        return [
            'id' => $uid,
            'username' => $username,
            'serverid' => Session::get(self::SESSION_PREFIX . 'serverid'),
            'servername' => Session::get(self::SESSION_PREFIX . 'servername'),
            'cdk' => Session::get(self::SESSION_PREFIX . 'cdk'),
            'lv' => Session::get(self::SESSION_PREFIX . 'lv')
        ];
    }
    
    /**
     * 获取当前登录管理员信息
     * @return array|null 管理员信息
     */
    public function getCurrentAdmin(): ?array
    {
        $id = Session::get(self::SESSION_PREFIX . 'admin_id');
        $username = Session::get(self::SESSION_PREFIX . 'admin_username');
        $type = Session::get(self::SESSION_PREFIX . 'admin_type');
        $token = Session::get(self::SESSION_PREFIX . 'admin_token');
        
        if (empty($id) || empty($username) || empty($token)) {
            return null;
        }
        
        return [
            'id' => $id,
            'username' => $username,
            'type' => $type
        ];
    }
    
    /**
     * 玩家退出登录
     */
    public function playerLogout(): void
    {
        $keys = ['id', 'username', 'token', 'auth_time', 'serverid', 'servername', 'groupname', 'cdk', 'lv', 'auth_pass'];
        foreach ($keys as $key) {
            Session::delete(self::SESSION_PREFIX . $key);
        }
    }
    
    /**
     * 管理员退出登录
     */
    public function adminLogout(): void
    {
        $keys = ['admin_id', 'admin_username', 'admin_type', 'admin_token', 'admin_auth_time'];
        foreach ($keys as $key) {
            Session::delete(self::SESSION_PREFIX . $key);
        }
    }
    
    /**
     * 根据UID获取用户名
     * @param int $uid 用户ID
     * @return string 用户名
     */
    private function getUsernameByUid(int $uid): string
    {
        $U = new User();
        $user = $U->getById($uid);
        return $user['username'] ?? ('UID:' . $uid);
    }
    
    /**
     * 记录操作日志
     * @param int $uid 用户ID
     * @param string $action 操作类型
     * @param string $info 操作信息
     * @param array $extra 额外信息
     */
    public function logAction(int $uid, string $action, string $info, array $extra = []): void
    {
        try {
            $username = $this->getUsernameByUid($uid);
            $log = new UserLog();
            $log->addUserLog($username, $info, array_merge([
                'uid' => $uid,
                'action' => $action,
                'ip' => request()->ip(),
                'time' => date('Y-m-d H:i:s')
            ], $extra));
        } catch (\Throwable $e) {
            Log::error('Auth service log action failed: ' . $e->getMessage());
        }
    }
    
    /**
     * 获取服务器列表
     * @return array 服务器列表
     */
    public function getServerList(): array
    {
        $S = new Server();
        $list = $S->makeServerList();
        
        if (is_object($list) && method_exists($list, 'toArray')) {
            $list = $list->toArray();
        }
        
        if (!is_array($list) || count($list) === 0) {
            $list = $S->getAllServerList();
            if (is_object($list) && method_exists($list, 'toArray')) {
                $list = $list->toArray();
            }
        }
        
        $result = [];
        foreach ($list as $row) {
            $result[] = [
                'serverid' => $row['serverid'],
                'name' => $row['name'],
                'groupname' => $row['groupname'] ?? ''
            ];
        }
        
        return $result;
    }
}

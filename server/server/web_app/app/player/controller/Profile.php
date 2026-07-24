<?php
declare(strict_types=1);

namespace app\player\controller;

use app\BaseController;
use think\facade\Session;
use think\facade\Request;
use app\player\model\Player;
use app\player\model\PlayerProfile;

/**
 * Profile控制器 - 个人资料控制器
 * 处理玩家个人资料管理
 */
class Profile extends BaseController
{
    /**
     * 个人中心首页
     */
    public function index()
    {
        $player = $this->ensurePlayer();
        
        if (!$player) {
            return redirect('/player/auth/login');
        }
        
        if (!isset($player['email'])) {
            $player['email'] = '';
        }
        
        if (!isset($player['profile'])) {
            $player['profile'] = [
                'nickname' => '',
                'phone' => '',
                'real_name' => '',
                'avatar' => ''
            ];
        }
        
        $stats = [
            'total_orders' => 0,
            'total_amount' => 0,
            'role_count' => 0,
            'login_count' => 0
        ];
        
        try {
            $playerModel = new Player();
            $stats = $playerModel->getPlayerStats($player['id']);
        } catch (\Exception $e) {
        }
        
        $recentLogs = [];
        try {
            $loginLogModel = new \app\player\model\PlayerLoginLog();
            $recentLogs = $loginLogModel->getRecentLogs($player['id'], 5);
        } catch (\Exception $e) {
        }
        
        $csrfToken = '';
        if (function_exists('generateCsrfToken')) {
            $csrfToken = generateCsrfToken();
        }
        
        return view('profile/index', [
            'player' => $player,
            'stats' => $stats,
            'recent_logs' => $recentLogs,
            'csrf_token' => $csrfToken
        ]);
    }
    
    /**
     * 更新个人资料
     */
    public function update()
    {
        $player = $this->ensurePlayer();
        
        if (!$player) {
            return json(['code' => 401, 'msg' => '请先登录']);
        }
        
        $post = $this->request->post();
        
        $csrfToken = $post['csrf_token'] ?? '';
        if (function_exists('verifyCsrfToken') && !verifyCsrfToken($csrfToken)) {
            return json(['code' => 0, 'msg' => 'CSRF验证失败']);
        }
        
        $profileModel = new PlayerProfile();
        
        $data = [];
        
        if (isset($post['nickname'])) {
            $nickname = trim($post['nickname']);
            if (strlen($nickname) > 20) {
                return json(['code' => 0, 'msg' => '昵称不能超过20个字符']);
            }
            $data['nickname'] = $nickname;
        }
        
        if (isset($post['real_name']) || isset($post['realname'])) {
            $realName = isset($post['real_name']) ? $post['real_name'] : $post['realname'];
            $data['real_name'] = trim((string)$realName);
        }
        
        if (isset($post['gender'])) {
            $data['gender'] = intval($post['gender']);
        }
        
        if (isset($post['birthday'])) {
            $data['birthday'] = $post['birthday'];
        }
        
        if (isset($post['phone'])) {
            $phone = trim($post['phone']);
            if (!empty($phone) && !preg_match('/^1[3-9]\d{9}$/', $phone)) {
                return json(['code' => 0, 'msg' => '手机号格式不正确']);
            }
            $data['phone'] = $phone;
        }
        
        if (isset($post['email'])) {
            $email = trim($post['email']);
            if (!empty($email) && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
                return json(['code' => 0, 'msg' => '邮箱格式不正确']);
            }
            $data['email'] = $email;
        }
        
        if (isset($post['qq'])) {
            $data['qq'] = trim($post['qq']);
        }
        
        if (isset($post['wechat'])) {
            $data['wechat'] = trim($post['wechat']);
        }
        
        if (isset($post['province'])) {
            $data['province'] = trim($post['province']);
        }
        
        if (isset($post['city'])) {
            $data['city'] = trim($post['city']);
        }
        
        if (isset($post['address'])) {
            $data['address'] = trim($post['address']);
        }
        
        if (empty($data)) {
            return json(['code' => 0, 'msg' => '没有需要更新的数据']);
        }
        
        $result = $profileModel->updateProfile($player['id'], $data);
        
        if ($result) {
            if (function_exists('logPlayerAction')) {
                logPlayerAction($player['id'], 'update_profile', '更新个人资料', $data);
            }
            return json(['code' => 1, 'msg' => '个人资料更新成功']);
        }
        
        return json(['code' => 0, 'msg' => '个人资料更新失败']);
    }
    
    /**
     * 修改密码页面
     */
    public function password()
    {
        $player = $this->ensurePlayer();
        
        if (!$player) {
            return redirect('/player/auth/login');
        }
        
        $csrfToken = '';
        if (function_exists('generateCsrfToken')) {
            $csrfToken = generateCsrfToken();
        }
        
        return view('profile/password', [
            'player' => $player,
            'csrf_token' => $csrfToken
        ]);
    }
    
    /**
     * 处理修改密码
     */
    public function updatePassword()
    {
        $player = $this->ensurePlayer();
        
        if (!$player) {
            return json(['code' => 401, 'msg' => '请先登录']);
        }
        
        $post = $this->request->post();
        
        $csrfToken = $post['csrf_token'] ?? '';
        if (function_exists('verifyCsrfToken') && !verifyCsrfToken($csrfToken)) {
            return json(['code' => 0, 'msg' => 'CSRF验证失败']);
        }
        
        $oldPassword = trim((string)($post['old_password'] ?? ''));
        $newPassword = trim((string)($post['new_password'] ?? ''));
        $confirmPassword = trim((string)($post['confirm_password'] ?? ''));
        
        if (empty($oldPassword)) {
            return json(['code' => 0, 'msg' => '请输入原密码']);
        }
        
        $userModel = new \app\model\User();
        $user = $userModel->getById($player['id']);
        
        if (!$user || !function_exists('password') || !password($oldPassword, (string)$user['password'])) {
            return json(['code' => 0, 'msg' => '原密码错误']);
        }
        
        if (function_exists('validatePasswordStrength')) {
            $passwordCheck = validatePasswordStrength($newPassword);
            if (!$passwordCheck['valid']) {
                return json(['code' => 0, 'msg' => $passwordCheck['message']]);
            }
        }
        
        if ($newPassword !== $confirmPassword) {
            return json(['code' => 0, 'msg' => '两次输入的新密码不一致']);
        }
        
        if ($oldPassword === $newPassword) {
            return json(['code' => 0, 'msg' => '新密码不能与原密码相同']);
        }
        
        $user->password = password($newPassword);
        $result = $user->save();
        
        if ($result) {
            // P1修复：使用统一Session管理函数，确保与PLAYER_SESSION_PREFIX一致
            if (function_exists('generatePlayerToken') && function_exists('setSession')) {
                $token = generatePlayerToken($user->toArray());
                setSession('token', $token);
            }
            
            if (function_exists('logPlayerAction')) {
                logPlayerAction($player['id'], 'change_password', '修改密码');
            }
            
            return json(['code' => 1, 'msg' => '密码修改成功，请重新登录']);
        }
        
        return json(['code' => 0, 'msg' => '密码修改失败']);
    }
    
    /**
     * 上传头像
     */
    public function avatar()
    {
        $player = $this->ensurePlayer();
        
        if (!$player) {
            return redirect('/player/auth/login');
        }
        
        if (!isset($player['profile'])) {
            $player['profile'] = [
                'avatar' => ''
            ];
        }
        
        $csrfToken = '';
        if (function_exists('generateCsrfToken')) {
            $csrfToken = generateCsrfToken();
        }
        
        return view('profile/avatar', [
            'player' => $player,
            'csrf_token' => $csrfToken
        ]);
    }
    
    /**
     * 处理头像上传
     */
    public function uploadAvatar()
    {
        $player = $this->ensurePlayer();
        
        if (!$player) {
            return json(['code' => 401, 'msg' => '请先登录']);
        }
        
        $csrfToken = $this->request->param('csrf_token') ?? '';
        if (function_exists('verifyCsrfToken') && !verifyCsrfToken($csrfToken)) {
            return json(['code' => 0, 'msg' => 'CSRF验证失败']);
        }
        
        $file = $this->request->file('avatar');
        
        if (!$file) {
            return json(['code' => 0, 'msg' => '请选择要上传的图片']);
        }
        
        // P1修复：同时校验MIME类型和文件扩展名白名单，防止MIME伪造
        $allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        $allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
        
        try {
            $mimeType = $file->getMimeType();
        } catch (\Throwable $e) {
            // 兼容旧版ThinkPHP的getMime()
            $mimeType = method_exists($file, 'getMime') ? $file->getMime() : '';
        }
        
        if (!in_array($mimeType, $allowedTypes)) {
            return json(['code' => 0, 'msg' => '只支持上传JPG、PNG、GIF、WEBP格式的图片']);
        }
        
        // 扩展名白名单验证
        $extension = strtolower($file->extension());
        if (!in_array($extension, $allowedExtensions)) {
            return json(['code' => 0, 'msg' => '不允许的文件扩展名，仅支持jpg/png/gif/webp']);
        }
        
        if ($file->getSize() > 2 * 1024 * 1024) {
            return json(['code' => 0, 'msg' => '图片大小不能超过2MB']);
        }
        
        // P1修复：使用ThinkPHP 8.x兼容的putFile API + 随机文件名
        try {
            $savePath = 'avatar' . DIRECTORY_SEPARATOR . date('Ymd');
            $fullSaveDir = public_path() . 'uploads' . DIRECTORY_SEPARATOR . $savePath;
            
            // 确保目录存在
            if (!is_dir($fullSaveDir)) {
                mkdir($fullSaveDir, 0755, true);
            }
            
            // 生成随机文件名，防止文件名被猜测遍历
            $randomName = bin2hex(random_bytes(16)) . '.' . $extension;
            $targetPath = $fullSaveDir . DIRECTORY_SEPARATOR . $randomName;
            
            // 使用move_uploaded_file确保安全（兼容ThinkPHP各版本）
            if (!move_uploaded_file($file->getPathname(), $targetPath)) {
                return json(['code' => 0, 'msg' => '头像上传失败']);
            }
        } catch (\Throwable $e) {
            return json(['code' => 0, 'msg' => '头像上传失败：' . $e->getMessage()]);
        }
        
        $avatarUrl = '/uploads/' . str_replace('\\', '/', $savePath) . '/' . $randomName;
        
        $profileModel = new PlayerProfile();
        $result = $profileModel->updateAvatar($player['id'], $avatarUrl);
        
        if ($result) {
            if (function_exists('logPlayerAction')) {
                logPlayerAction($player['id'], 'upload_avatar', '上传头像', ['avatar' => $avatarUrl]);
            }
            return json(['code' => 1, 'msg' => '头像上传成功', 'data' => ['avatar_url' => $avatarUrl]]);
        }
        
        return json(['code' => 0, 'msg' => '头像上传失败']);
    }
}

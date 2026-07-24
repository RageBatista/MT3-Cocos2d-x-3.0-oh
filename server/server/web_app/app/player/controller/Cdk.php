<?php
declare(strict_types=1);

namespace app\player\controller;

use app\BaseController;
use think\facade\Session;
use think\facade\Request;
use app\player\service\AuthService;
use app\player\service\ServerService;
use app\player\service\LogService;

/**
 * Cdk控制器 - CDK授权控制器
 * 整合原login模块的CDK授权功能
 */
class Cdk extends BaseController
{
    /**
     * @var AuthService
     */
    protected $authService;
    
    /**
     * @var ServerService
     */
    protected $serverService;
    
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
        $this->serverService = new ServerService();
        $this->logService = new LogService();
    }
    
    /**
     * CDK授权页面
     */
    public function index()
    {
        if (config('player.auth_enabled') === false) {
            return redirect('/player/auth/login')->with('error', '授权功能未开启');
        }
        
        // 仅在已完成CDK授权时才直接进入控制台，避免账号登录用户陷入 senditem->index->dashboard 回跳
        $player = getCurrentPlayerInfo();
        if ($player && !empty($player['cdk'])) {
            return redirect('/player/cdk/dashboard');
        }
        
        $serverList = $this->serverService->getServerList();
        
        return view('cdk/index', [
            'csrf_token' => $this->request->csrf_token ?? generateCsrfToken(),
            'server_list' => $serverList
        ]);
    }
    
    /**
     * CDK授权提交
     */
    public function auth()
    {
        if (config('player.auth_enabled') === false) {
            return json(['code' => 0, 'msg' => '授权功能未开启']);
        }
        
        $post = $this->request->post();
        $csrfToken = $post['csrf_token'] ?? '';
        
        if (!verifyCsrfToken($csrfToken)) {
            return json(['code' => 0, 'msg' => 'CSRF验证失败']);
        }
        
        // UID是游戏角色ID（如4097），不是用户账号ID
        $uid = intval($post['uid'] ?? 0);
        $cdk = trim((string)($post['cdk'] ?? ''));
        $serverId = trim((string)($post['serverid'] ?? ''));
        $authPass = trim((string)($post['authpass'] ?? ''));
        
        $result = $this->authService->cdkAuth($uid, $cdk, $serverId, $authPass);
        
        if ($result['success']) {
            $this->logService->logCdkAuth($uid, $result['data']['cdk'] ?? $cdk, $result['data']['server']['serverid'] ?? 0, true, $result['message']);
            $this->logService->logPlayerAction($uid, 'cdk_auth', 'CDK授权成功');
        } else {
            $this->logService->logCdkAuth($uid, $cdk, 0, false, $result['message']);
        }
        
        return json([
            'code' => $result['success'] ? 1 : 0,
            'msg' => $result['message']
        ]);
    }
    
    /**
     * 已有授权登录
     */
    public function existing()
    {
        if (config('player.auth_enabled') === false) {
            return json(['code' => 0, 'msg' => '授权功能未开启']);
        }
        
        $post = $this->request->post();
        $csrfToken = $post['csrf_token'] ?? '';
        
        if (!verifyCsrfToken($csrfToken)) {
            return json(['code' => 0, 'msg' => 'CSRF验证失败']);
        }
        
        // UID是游戏角色ID（如4097），不是用户账号ID
        $uid = intval($post['uid'] ?? 0);
        $authPass = trim((string)($post['authpass'] ?? ''));
        $serverId = trim((string)($post['serverid'] ?? ''));
        
        $result = $this->authService->cdkExistingAuth($uid, $authPass, $serverId);
        
        if ($result['success']) {
            $this->logService->logPlayerAction($uid, 'cdk_existing_auth', '已有授权登录成功');
        }
        
        return json([
            'code' => $result['success'] ? 1 : 0,
            'msg' => $result['message']
        ]);
    }
    
    /**
     * 授权控制台首页
     */
    public function dashboard()
    {
        $player = getCurrentPlayerInfo();
        
        // 控制台必须是已完成CDK授权的会话
        if (!$player || empty($player['cdk'])) {
            return redirect('/player/cdk/index')->with('error', '请先完成CDK授权');
        }
        
        $serverList = $this->serverService->getServerList();
        
        return view('cdk/dashboard', [
            'player' => $player,
            'server_list' => $serverList
        ]);
    }

    /**
     * 兼容历史路由：/player/cdk/senditem[/*]
     * 当路由缓存或解析回退到 Cdk->senditem() 时，代理到 SendItem 控制器。
     */
    public function senditem()
    {
        return $this->dispatchSendItemCompatibility();
    }

    /**
     * SendItem 兼容分发
     */
    private function dispatchSendItemCompatibility()
    {
        $sendItemController = new SendItem($this->app);

        $path = strtolower(trim((string)$this->request->pathinfo(), '/'));
        if ($path === '') {
            $compatPath = strtolower(trim((string)$this->request->param('s', ''), '/'));
            if ($compatPath !== '') {
                $path = ltrim($compatPath, '/');
            }
        }
        $path = preg_replace('#^player/#', '', $path);

        $subAction = '';
        if (preg_match('~^cdk/senditem(?:/([^/?]+))?~', $path, $matches)) {
            $subAction = strtolower((string)($matches[1] ?? ''));
        }

        switch ($subAction) {
            case 'prepareop':
                return $sendItemController->prepareOp();
            case 'senditem':
                return $sendItemController->sendItem();
            case 'rechargexianyu':
                return $sendItemController->rechargeXianyu();
            case 'getitemlist':
                return $sendItemController->getItemList();
            case 'switchserver':
                return $sendItemController->switchServer();
            default:
                return $sendItemController->index();
        }
    }
    
    /**
     * 获取服务器列表
     */
    public function servers()
    {
        if (config('player.auth_enabled') === false) {
            return json(['code' => 0, 'msg' => '授权功能未开启']);
        }
        
        $serverList = $this->serverService->getServerList();
        
        return json([
            'code' => 1,
            'data' => $serverList
        ]);
    }
    
    /**
     * 退出授权
     */
    public function logout()
    {
        $player = getCurrentPlayerInfo();
        if ($player) {
            $this->logService->logPlayerAction($player['id'], 'logout', '退出授权控制台');
        }
        
        $this->authService->playerLogout();
        
        return redirect('/player/cdk/index');
    }
}

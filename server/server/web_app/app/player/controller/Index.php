<?php
declare(strict_types=1);

namespace app\player\controller;

use app\BaseController;
use app\model\Server as ServerModel;
use app\player\model\Player;

/**
 * Index控制器 - 首页控制器
 * 玩家模块首页
 */
class Index extends BaseController
{
    /**
     * 首页
     */
    public function index()
    {
        $player = $this->ensurePlayer();
        $stats = [];
        $recentOrders = [];

        if ($player && isset($player['id'])) {
            try {
                $playerModel = new Player();
                $stats = $playerModel->getPlayerStats($player['id']);
            } catch (\Exception $e) {
                $stats = [];
            }
        }
        
        $servers = [];
        try {
            $serverModel = new ServerModel();
            $serverList = $serverModel->makeServerList();
            
            if (is_object($serverList) && method_exists($serverList, 'toArray')) {
                $servers = $serverList->toArray();
            } elseif (is_array($serverList)) {
                $servers = $serverList;
            }
        } catch (\Exception $e) {
            $servers = [];
        }
        
        $csrfToken = '';
        if (function_exists('generateCsrfToken')) {
            $csrfToken = generateCsrfToken();
        }
        
        return view('index/index', [
            'player' => $player,
            'stats' => $stats,
            'recent_orders' => $recentOrders,
            'servers' => $servers,
            'csrf_token' => $csrfToken
        ]);
    }
}

<?php
declare(strict_types=1);

namespace app\player\controller;

use app\BaseController;
use think\facade\Request;
use think\facade\Db;
use app\model\Server as ServerModel;

/**
 * Server控制器 - 服务器列表控制器
 * 显示和管理服务器列表
 */
class Server extends BaseController
{
    /**
     * 服务器列表
     */
    public function index()
    {
        $player = $this->ensurePlayer();
        
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
        }
        
        $boundServers = [];
        if ($player && !empty($player['bidserver'])) {
            $boundServerIds = json_decode($player['bidserver'], true);
            if (is_array($boundServerIds)) {
                foreach ($servers as $server) {
                    if (in_array($server['serverid'], $boundServerIds)) {
                        $boundServers[] = $server;
                    }
                }
            }
        }
        
        $csrfToken = '';
        if (function_exists('generateCsrfToken')) {
            $csrfToken = generateCsrfToken();
        }
        
        return view('server/list', [
            'servers' => $servers,
            'bound_servers' => $boundServers,
            'player' => $player,
            'csrf_token' => $csrfToken
        ]);
    }

    /**
     * 服务器详情
     */
    public function detail()
    {
        $player = $this->ensurePlayer();
        if (!$player) {
            return redirect('/player/auth/login');
        }

        $serverId = trim((string)$this->request->param('id', ''));
        if ($serverId === '') {
            return notify(0, '服务器ID无效');
        }

        $server = null;
        try {
            $serverModel = new ServerModel();
            $server = $serverModel->getServerId($serverId);

            if (!$server) {
                $serverByPk = $serverModel->getServer($serverId);
                if ($serverByPk) {
                    $server = $serverByPk;
                } else {
                    $serverByPort = $serverModel->where('gmport', $serverId)->find();
                    if ($serverByPort) {
                        $server = $serverByPort;
                    }
                }
            }
        } catch (\Exception $e) {
        }

        if (!$server) {
            return notify(0, '服务器不存在');
        }

        if (is_object($server) && method_exists($server, 'toArray')) {
            $server = $server->toArray();
        }

        $boundServerIds = [];
        if (!empty($player['bidserver'])) {
            $decoded = json_decode($player['bidserver'], true);
            if (is_array($decoded)) {
                $boundServerIds = array_map('intval', $decoded);
            }
        }

        $currentServerId = intval($server['serverid'] ?? 0);
        $isBound = $currentServerId > 0 && in_array($currentServerId, $boundServerIds, true);

        $roles = [];
        if ($currentServerId > 0) {
            $roles = $this->resolveAccessibleRoles($player, $currentServerId);
        }

        $csrfToken = '';
        if (function_exists('generateCsrfToken')) {
            $csrfToken = generateCsrfToken();
        }

        return view('server/detail', [
            'server' => $server,
            'roles' => $roles,
            'is_bound' => $isBound,
            'player' => $player,
            'csrf_token' => $csrfToken
        ]);
    }
}

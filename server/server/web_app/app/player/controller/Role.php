<?php
declare(strict_types=1);

namespace app\player\controller;

use app\BaseController;
use app\model\Server as ServerModel;

/**
 * Role 控制器 - 角色管理
 */
class Role extends BaseController
{
    /**
     * 角色列表
     */
    public function index()
    {
        $player = $this->ensurePlayer();
        if (!$player) {
            return redirect('/player/auth/login');
        }

        $roles = $this->resolveAccessibleRoles($player);

        $csrfToken = '';
        if (function_exists('generateCsrfToken')) {
            $csrfToken = generateCsrfToken();
        }

        return view('role/list', [
            'roles' => $roles,
            'player' => $player,
            'csrf_token' => $csrfToken
        ]);
    }

    /**
     * 角色详情
     */
    public function detail()
    {
        $player = $this->ensurePlayer();
        if (!$player) {
            return redirect('/player/auth/login');
        }

        $roleId = intval($this->request->param('id', 0));
        if ($roleId <= 0) {
            return notify(0, '角色ID无效');
        }

        $role = null;
        foreach ($this->resolveAccessibleRoles($player) as $item) {
            if (intval($item['playerid'] ?? 0) === $roleId) {
                $role = is_array($item) ? $item : [];
                break;
            }
        }

        if (!$role) {
            return notify(0, '角色不存在');
        }

        $role = $this->normalizeRoleForDetail($role);

        $csrfToken = '';
        if (function_exists('generateCsrfToken')) {
            $csrfToken = generateCsrfToken();
        }

        return view('role/detail', [
            'role' => $role,
            'player' => $player,
            'csrf_token' => $csrfToken
        ]);
    }

    /**
     * 根据服务器获取角色列表（AJAX接口）
     */
    public function getByServer()
    {
        $player = $this->ensurePlayer();
        if (!$player) {
            return json(['code' => 0, 'msg' => '请先登录', 'data' => []]);
        }

        $serverId = intval($this->request->param('server_id', 0, 'intval'));
        if ($serverId <= 0) {
            return json(['code' => 0, 'msg' => '请选择服务器', 'data' => []]);
        }

        $roles = [];
        foreach ($this->resolveAccessibleRoles($player, $serverId) as $role) {
            $rid = intval($role['playerid'] ?? 0);
            if ($rid <= 0) {
                continue;
            }
            $roles[] = [
                'roleid' => $rid,
                'name' => (string)($role['playername'] ?? ('角色' . $rid))
            ];
        }

        return json(['code' => 1, 'msg' => 'success', 'data' => $roles]);
    }

    /**
     * 补齐详情页使用字段，兼容 user_bind 结构
     */
    private function normalizeRoleForDetail(array $role): array
    {
        $playerId = intval($role['playerid'] ?? 0);
        $serverId = intval($role['serverid'] ?? 0);

        if (!isset($role['name']) || $role['name'] === '') {
            $role['name'] = (string)($role['playername'] ?? ('角色' . $playerId));
        }

        if (!isset($role['profession']) || $role['profession'] === '') {
            $role['profession'] = '未知';
        }

        if (!isset($role['created_at']) || $role['created_at'] === '') {
            $role['created_at'] = '未知';
        }

        if (!isset($role['last_login']) || $role['last_login'] === '') {
            $role['last_login'] = '从未登录';
        }

        if (!isset($role['level']) || !is_numeric($role['level'])) {
            $role['level'] = 1;
        }

        if (!isset($role['server_name']) || $role['server_name'] === '') {
            $serverName = '服务器ID:' . $serverId;
            if ($serverId > 0) {
                try {
                    $serverModel = new ServerModel();
                    $server = $serverModel->getServerId((string)$serverId);
                    if ($server) {
                        if (is_object($server) && method_exists($server, 'toArray')) {
                            $server = $server->toArray();
                        }
                        $name = trim((string)($server['name'] ?? ''));
                        if ($name !== '') {
                            $serverName = $name;
                        }
                    }
                } catch (\Throwable $e) {
                }
            }
            $role['server_name'] = $serverName;
        }

        return $role;
    }
}


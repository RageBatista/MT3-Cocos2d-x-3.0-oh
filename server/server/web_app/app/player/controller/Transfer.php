<?php
declare(strict_types=1);

namespace app\player\controller;

use app\BaseController;
use app\model\Transfer as TransferModel;
use app\model\Server;
use app\player\service\TransferService;

/**
 * Transfer控制器 - 转区申请控制器
 */
class Transfer extends BaseController
{
    /**
     * 转区申请列表页面
     */
    public function index()
    {
        $player = $this->ensurePlayer();
        if (!$player) {
            return redirect('/player/auth/login');
        }

        $page = $this->request->param('page', 1, 'intval');
        $limit = $this->request->param('limit', 20, 'intval');

        $sessionUserId = $this->resolveSessionUserId($player);
        if ($sessionUserId <= 0) {
            $sessionUserId = intval($player['id'] ?? 0);
        }

        $transferModel = new TransferModel();
        $list = $transferModel->getUserTransfers($sessionUserId, $page, $limit);
        $total = $transferModel->where('uid', $sessionUserId)
            ->where('type', TransferModel::TYPE_TRANSFER)
            ->count();

        $cacheKey = 'server_list:active';
        $servers = \think\facade\Cache::get($cacheKey);
        if ($servers === false || $servers === null) {
            $serverModel = new Server();
            $servers = $serverModel->makeServerList();
            if ($servers) {
                \think\facade\Cache::set($cacheKey, $servers, 3600);
            }
        }

        $serverMap = [];
        foreach ($servers as $s) {
            $serverMap[$s['serverid']] = $s['name'] ?? ('服务器' . $s['serverid']);
        }

        $roles = $this->resolveAccessibleRoles($player);

        $transferList = [];
        if ($list) {
            foreach ($list as $item) {
                $row = is_array($item) ? $item : $item->toArray();
                $row['source_server_name'] = $serverMap[$row['source_server_id']] ?? ('ID:' . $row['source_server_id']);
                $row['target_server_name'] = $serverMap[$row['target_server_id']] ?? ('ID:' . $row['target_server_id']);
                $transferList[] = $row;
            }
        }

        return view('transfer/index', [
            'transfers' => $transferList,
            'total' => $total,
            'page' => $page,
            'limit' => $limit,
            'pages' => $total > 0 ? (int)ceil($total / $limit) : 0,
            'player' => $player,
            'servers' => $servers,
            'roles' => $roles,
            'server_map' => $serverMap,
            'csrf_token' => $this->request->csrf_token ?? generateCsrfToken()
        ]);
    }

    /**
     * 提交转区申请
     */
    public function submit()
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

        $sourceServerId = intval($post['source_server_id'] ?? 0);
        $targetServerId = intval($post['target_server_id'] ?? 0);
        $roleId = intval($post['role_id'] ?? 0);
        $contact = trim($post['contact'] ?? '');
        $reason = trim($post['reason'] ?? '');
        $sessionUserId = $this->resolveSessionUserId($player);
        if ($sessionUserId <= 0) {
            return json(['code' => 0, 'msg' => '账号信息异常，请重新登录后重试']);
        }

        $transferService = new TransferService();
        $errors = $transferService->validateTransferData($player, [
            'source_server_id' => $sourceServerId,
            'target_server_id' => $targetServerId,
            'role_id' => $roleId,
            'contact' => $contact,
            'reason' => $reason
        ]);
        if (!empty($errors)) {
            return json(['code' => 0, 'msg' => implode('，', $errors)]);
        }

        if (!$transferService->isServerOpenForTransfer($sourceServerId)) {
            return json(['code' => 0, 'msg' => '源服务器未开放转区功能']);
        }
        if (!$transferService->isServerOpenForTransfer($targetServerId)) {
            return json(['code' => 0, 'msg' => '目标服务器未开放转区功能']);
        }

        $accessibleRoles = $this->resolveAccessibleRoles($player, $sourceServerId);
        $roleAccessible = false;
        foreach ($accessibleRoles as $accessibleRole) {
            if (intval($accessibleRole['playerid'] ?? 0) === $roleId) {
                $roleAccessible = true;
                break;
            }
        }
        if (!$roleAccessible) {
            return json(['code' => 0, 'msg' => '角色不存在或不属于当前账号']);
        }

        $roleCheck = $transferService->canRoleTransfer($roleId, $sourceServerId, $sessionUserId);
        if (!$roleCheck['success']) {
            return json(['code' => 0, 'msg' => $roleCheck['message']]);
        }

        $transferModel = new TransferModel();
        $pendingTransfer = $transferModel->where('uid', $sessionUserId)
            ->where('role', $roleId)
            ->where('type', TransferModel::TYPE_TRANSFER)
            ->where('status', '<>', TransferModel::STATUS_COMPLETED)
            ->where('status', '<>', TransferModel::STATUS_REJECTED)
            ->find();
        if ($pendingTransfer) {
            return json(['code' => 0, 'msg' => '该角色有未完成的转区申请，请等待处理完成']);
        }

        $transferData = [
            'uid' => $sessionUserId,
            'username' => $player['username'] ?? '',
            'role' => $roleId,
            'info' => $reason,
            'contact' => $contact,
            'source_server_id' => $sourceServerId,
            'target_server_id' => $targetServerId,
            'time' => date('Y-m-d H:i:s')
        ];

        $result = $transferModel->createTransfer($transferData);
        if (!$result) {
            return json(['code' => 0, 'msg' => '转区申请提交失败']);
        }

        if (function_exists('logPlayerAction')) {
            logPlayerAction($sessionUserId, 'submit_transfer', '提交转区申请', [
                'source_server_id' => $sourceServerId,
                'target_server_id' => $targetServerId,
                'role_id' => $roleId,
                'reason_length' => strlen($reason)
            ]);
        }

        return notify(1, '转区申请提交成功，请等待审核');
    }

    /**
     * 获取指定服务器的角色列表（JSON API）
     */
    public function getRoles()
    {
        $player = $this->ensurePlayer();
        if (!$player) {
            return notify(0, '请先登录');
        }

        $serverId = intval($this->request->param('server_id', 0, 'intval'));
        if ($serverId <= 0) {
            return json(['code' => 0, 'msg' => '请选择服务器', 'data' => []]);
        }

        $roleList = [];
        foreach ($this->resolveAccessibleRoles($player, $serverId) as $role) {
            $playerId = intval($role['playerid'] ?? 0);
            if ($playerId <= 0) {
                continue;
            }
            $roleList[] = [
                'playerid' => $playerId,
                'rolename' => (string)($role['playername'] ?? ('角色' . $playerId)),
                'level' => intval($role['level'] ?? 0)
            ];
        }

        return json(['code' => 1, 'msg' => 'ok', 'data' => $roleList]);
    }

    /**
     * 转区申请详情页面
     */
    public function detail()
    {
        $player = $this->ensurePlayer();
        if (!$player) {
            return redirect('/player/auth/login');
        }

        $id = $this->request->param('id', 0, 'intval');
        if ($id <= 0) {
            return notify(0, '参数错误');
        }

        $transferModel = new TransferModel();
        $transfer = $transferModel->getTransferDetail($id);
        $sessionUserId = $this->resolveSessionUserId($player);
        if (!$transfer || intval($transfer['uid']) !== intval($sessionUserId)) {
            return notify(0, '转区申请不存在');
        }

        $serverModel = new Server();
        $transferData = is_array($transfer) ? $transfer : $transfer->toArray();
        $sourceServer = $serverModel->getServerId($transferData['source_server_id']);
        $targetServer = $serverModel->getServerId($transferData['target_server_id']);
        $transferData['source_server_name'] = $sourceServer['name'] ?? ('ID:' . $transferData['source_server_id']);
        $transferData['target_server_name'] = $targetServer['name'] ?? ('ID:' . $transferData['target_server_id']);

        return view('transfer/detail', [
            'transfer' => $transferData,
            'player' => $player
        ]);
    }
}


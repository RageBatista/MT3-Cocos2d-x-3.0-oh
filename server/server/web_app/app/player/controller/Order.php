<?php
declare(strict_types=1);

namespace app\player\controller;

use app\BaseController;
use think\facade\Db;
use app\model\UserOrder as OrderModel;

/**
 * Order控制器 - 订单管理控制器
 * 显示和管理玩家订单
 */
class Order extends BaseController
{
    /**
     * 订单列表
     */
    public function index()
    {
        $player = $this->ensurePlayer();
        if (!$player) {
            return redirect('/player/auth/login');
        }

        $page = $this->request->param('page', 1, 'intval');
        $limit = $this->request->param('limit', 20, 'intval');
        $status = (string)$this->request->param('status', '');
        $orderNo = trim((string)$this->request->param('order_no', ''));

        if ($page < 1) {
            $page = 1;
        }
        if ($limit < 1 || $limit > 100) {
            $limit = 20;
        }

        $result = [
            'list' => [],
            'total' => 0,
            'page' => $page,
            'limit' => $limit,
            'pages' => 0
        ];

        try {
            $roles = $this->resolveAccessibleRoles($player);
            $playerIds = array_values(array_filter(array_map('intval', array_column($roles, 'playerid'))));

            if (!empty($playerIds)) {
                $query = $this->createOrderQuery($playerIds, $status, $orderNo);
                $total = $query->count();

                $rows = [];
                if ($total > 0) {
                    $rows = $this->createOrderQuery($playerIds, $status, $orderNo)
                        ->order('id', 'desc')
                        ->page($page, $limit)
                        ->select()
                        ->toArray();
                }

                $result = [
                    'list' => $this->normalizeOrderList($rows),
                    'total' => $total,
                    'page' => $page,
                    'limit' => $limit,
                    'pages' => $total > 0 ? (int)ceil($total / $limit) : 0
                ];
            }
        } catch (\Exception $e) {
            \think\facade\Log::error('Order index exception: ' . $e->getMessage() . "\n" . $e->getTraceAsString());
        }

        $csrfToken = '';
        if (function_exists('generateCsrfToken')) {
            $csrfToken = generateCsrfToken();
        }

        return view('order/list', [
            'orders' => $result['list'],
            'total' => $result['total'],
            'page' => $result['page'],
            'limit' => $result['limit'],
            'pages' => $result['pages'],
            'status' => $status,
            'order_no' => $orderNo,
            'player' => $player,
            'csrf_token' => $csrfToken
        ]);
    }
    
    /**
     * 订单详情
     */
    public function detail()
    {
        $player = $this->ensurePlayer();
        if (!$player) {
            return redirect('/player/auth/login');
        }

        $orderId = $this->request->param('id', 0);

        if (empty($orderId) || $orderId <= 0) {
            return notify(0, '订单ID无效');
        }

        $order = null;
        try {
            // user_order 表通过 user JSON 中的 playerid 关联玩家
            $order = (new OrderModel())->where('id', $orderId)->find();

            if ($order) {
                $playerIds = array_values(array_filter(array_map('intval', array_column($this->resolveAccessibleRoles($player), 'playerid'))));

                if (empty($playerIds)) {
                    $order = null;
                } else {
                    $orderUser = is_string($order['user']) ? json_decode($order['user'], true) : [];
                    $orderPlayerId = intval($orderUser['playerid'] ?? 0);
                    $playerIds = array_map('intval', $playerIds);
                    if ($orderPlayerId <= 0 || !in_array($orderPlayerId, $playerIds, true)) {
                        $order = null;
                    }
                }
            }
        } catch (\Exception $e) {
        }

        if (!$order) {
            return notify(0, '订单不存在');
        }

        $orderData = $this->normalizeOrder($order);
        $orderData['id'] = intval($order['id'] ?? 0);

        $csrfToken = '';
        if (function_exists('generateCsrfToken')) {
            $csrfToken = generateCsrfToken();
        }

        return view('order/detail', [
            'order' => $orderData,
            'player' => $player,
            'csrf_token' => $csrfToken
        ]);
    }

    /**
     * 构建订单查询（支持 status、orderid 过滤）
     */
    private function createOrderQuery(array $playerIds, string $status, string $orderNo)
    {
        // P2优化：使用common.php中的公共方法，消除重复代码
        $query = (new OrderModel())->where(buildPlayerOrderWhere($playerIds));

        if ($status !== '' && in_array(intval($status), [0, 1, 2], true)) {
            $query->where('status', intval($status));
        }

        if ($orderNo !== '') {
            $query->whereLike('orderid', '%' . $orderNo . '%');
        }

        return $query;
    }

    /**
     * 规范化订单列表
     */
    private function normalizeOrderList(array $rows): array
    {
        $result = [];
        foreach ($rows as $row) {
            $result[] = $this->normalizeOrder($row);
        }

        return $result;
    }

    /**
     * 规范化单条订单字段，兼容旧表结构
     */
    private function normalizeOrder($order): array
    {
        $orderData = is_object($order) && method_exists($order, 'toArray')
            ? $order->toArray()
            : (array)$order;

        $userInfo = [];
        $itemInfo = [];

        if (isset($orderData['user']) && is_string($orderData['user'])) {
            $decoded = json_decode($orderData['user'], true);
            if (is_array($decoded)) {
                $userInfo = $decoded;
            }
        }

        if (isset($orderData['item']) && is_string($orderData['item'])) {
            $decoded = json_decode($orderData['item'], true);
            if (is_array($decoded)) {
                $itemInfo = $decoded;
            }
        }

        $timestamp = intval($orderData['time'] ?? 0);
        $createTime = $timestamp > 0
            ? date('Y-m-d H:i:s', $timestamp)
            : (string)($orderData['date'] ?? '');

        $status = intval($orderData['status'] ?? 0);

        return [
            'id' => intval($orderData['id'] ?? 0),
            'order_no' => (string)($orderData['orderid'] ?? ''),
            'amount' => floatval($orderData['realmoney'] ?? ($itemInfo['price'] ?? 0)),
            'item_name' => (string)($itemInfo['name'] ?? '充值订单'),
            'server_name' => (string)($userInfo['servername'] ?? ''),
            'servername' => (string)($userInfo['servername'] ?? ''),
            'role_name' => (string)($userInfo['playername'] ?? ''),
            'rolename' => (string)($userInfo['playername'] ?? ''),
            'role_id' => intval($userInfo['playerid'] ?? 0),
            'pay_channel' => (string)($orderData['paytype'] ?? ''),
            'status' => $status,
            'create_time' => $createTime,
            'created_at' => $createTime,
            'pay_time' => $status === 1 ? $createTime : ''
        ];
    }
}

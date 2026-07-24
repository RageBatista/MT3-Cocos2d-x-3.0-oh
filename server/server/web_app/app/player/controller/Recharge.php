<?php
declare(strict_types=1);

namespace app\player\controller;

use app\BaseController;
use think\facade\Db;
use app\model\PayItem;
use app\model\PayChannel;
use app\model\Server as ServerModel;
use app\model\User as UserModel;
use app\model\Agent as AgentModel;

/**
 * Recharge控制器 - 充值控制器
 * 处理玩家充值操作
 */
class Recharge extends BaseController
{
    /**
     * 充值页面
     */
    public function index()
    {
        $player = $this->ensurePlayer();
        if (!$player) {
            return redirect('/player/auth/login');
        }

        $payItems = [];
        try {
            $payItemModel = new PayItem();
            $payItems = $payItemModel->where('status', 1)
                ->order('id', 'asc')
                ->select()
                ->toArray();

            foreach ($payItems as &$item) {
                $item['amount'] = intval($item['price'] ?? 0);
                if (!isset($item['bonus'])) {
                    $item['bonus'] = '';
                }
            }
            unset($item);
        } catch (\Exception $e) {
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
        }

        $orders = [];
        try {
            $accessibleRoles = $this->resolveAccessibleRoles($player);
            $playerIds = array_values(array_filter(array_map('intval', array_column($accessibleRoles, 'playerid'))));

            if (!empty($playerIds)) {
                $rows = Db::name('user_order')
                    ->where($this->buildPlayerOrderWhere($playerIds))
                    ->order('id', 'desc')
                    ->limit(5)
                    ->select()
                    ->toArray();

                $orders = $this->normalizeOrderList($rows);
            }
        } catch (\Exception $e) {
        }

        $csrfToken = '';
        if (function_exists('generateCsrfToken')) {
            $csrfToken = generateCsrfToken();
        }

        return view('recharge/index', [
            'pay_items' => $payItems,
            'servers' => $servers,
            'orders' => $orders,
            'player' => $player,
            'csrf_token' => $csrfToken
        ]);
    }
    
    /**
     * 创建订单
     */
    public function createOrder()
    {
        $post = $this->request->post();

        // 验证CSRF Token
        $csrfToken = $post['csrf_token'] ?? '';
        if (!verifyCsrfToken($csrfToken)) {
            return notify(0, 'CSRF验证失败');
        }

        $player = $this->ensurePlayer();
        if (!$player) {
            return json(['code' => 0, 'msg' => '请先登录']);
        }

        $itemId = $post['item_id'] ?? 0;
        $serverId = $post['server_id'] ?? 0;
        $roleId = $post['role_id'] ?? 0;
        $payChannel = $post['pay_channel'] ?? '';

        // 验证参数
        if (empty($itemId) || $itemId <= 0) {
            return notify(0, '请选择充值商品');
        }

        if (empty($serverId) || $serverId <= 0) {
            return notify(0, '请选择服务器');
        }

        if (empty($roleId) || $roleId <= 0) {
            return notify(0, '请选择角色');
        }

        if (empty($payChannel)) {
            return notify(0, '请选择支付方式');
        }

        $payType = $payChannel === 'wechat' ? 'wxpay' : $payChannel;
        if (!in_array($payType, ['wxpay', 'alipay'], true)) {
            return notify(0, '不支持的支付方式');
        }

        $channelModel = new PayChannel();
        $channels = $channelModel->getAllPayList([
            [$payType, '=', 1],
            ['status', '=', 1]
        ]);
        if (empty($channels)) {
            return notify(0, '暂无可用支付通道，请稍后重试');
        }
        $channel = $channels[array_rand($channels)];

        // 获取商品信息
        $payItemModel = new PayItem();
        $payItem = $payItemModel->where('id', $itemId)->find();

        if (!$payItem || $payItem['status'] != 1) {
            return notify(0, '充值商品不存在或已下架');
        }

        // 验证服务器（前端传的是serverid，需用getServerId查询）
        $serverModel = new ServerModel();
        $server = $serverModel->getServerId($serverId);

        if (!$server) {
            return notify(0, '服务器不存在');
        }

        // 验证角色是否属于当前玩家（使用user_bind表，非role表）
        $role = null;
        $accessibleRoles = $this->resolveAccessibleRoles($player, intval($serverId));
        foreach ($accessibleRoles as $candidateRole) {
            if (intval($candidateRole['playerid'] ?? 0) === intval($roleId)) {
                $role = $candidateRole;
                break;
            }
        }

        if (!$role) {
            return notify(0, '角色不存在');
        }

        // 生成订单号
        $orderNo = 'P' . date('YmdHis') . random_int(10000, 99999);

        $agentPath = '0|@0@';
        try {
            $userModel = new UserModel();
            $sessionUserId = $this->resolveSessionUserId($player);
            $account = $sessionUserId > 0 ? $userModel->getById($sessionUserId) : null;
            $lastAgent = intval($account['lastagent'] ?? 0);
            if ($lastAgent > 0) {
                $agentModel = new AgentModel();
                $agentInfo = $agentModel->getById($lastAgent);
                if ($agentInfo) {
                    $agentPath = $agentInfo['id'] . '|' . agentTree($agentInfo);
                }
            }
        } catch (\Throwable $e) {
        }

        $orderUser = [
            'username' => $player['username'] ?? '',
            'servername' => $server['name'] ?? '',
            'playername' => $role['playername'] ?? '',
            'playerid' => intval($roleId)
        ];
        $orderItem = [
            'id' => intval($itemId),
            'name' => (string)($payItem['name'] ?? ''),
            'price' => floatval($payItem['price'] ?? 0)
        ];

        $orderUserJson = json_encode($orderUser, JSON_UNESCAPED_UNICODE);
        $orderItemJson = json_encode($orderItem, JSON_UNESCAPED_UNICODE);
        if ($orderUserJson === false || $orderItemJson === false) {
            return notify(0, '订单数据序列化失败');
        }

        // 创建订单
        $orderData = [
            'orderid' => $orderNo,
            'agent' => $agentPath,
            'ordertype' => 1,
            'user' => $orderUserJson,
            'item' => $orderItemJson,
            'channel' => intval($channel['id'] ?? 0),
            'paytype' => $payType,
            'realmoney' => floatval($payItem['price'] ?? 0),
            'date' => date('Y-m-d H:i:s'),
            'time' => time(),
            'ip' => $this->request->ip() ?: '0.0.0.0',
            'city' => $this->genericVariable['city'] ?? 'unknown',
            'status' => 0
        ];

        $orderId = Db::name('user_order')->insertGetId($orderData);

        if (!$orderId) {
            return notify(0, '订单创建失败');
        }

        // 记录操作日志
        logPlayerAction($player['id'], 'create_order', '创建充值订单', [
            'order_id' => $orderId,
            'order_no' => $orderNo,
            'amount' => floatval($payItem['price'] ?? 0),
            'pay_type' => $payType
        ]);

        // 返回订单信息
        return notify(1, '订单创建成功', [
            'order_id' => $orderId,
            'order_no' => $orderNo,
            'amount' => floatval($payItem['price'] ?? 0)
        ]);
    }

    /**
     * 构建玩家订单查询条件
     * P2优化：已迁移到common.php中的公共方法buildPlayerOrderWhere()
     * 此处保留包装方法以兼容内部调用
     */
    private function buildPlayerOrderWhere(array $playerIds)
    {
        return buildPlayerOrderWhere($playerIds);
    }

    /**
     * 规范化订单展示字段
     */
    private function normalizeOrderList(array $rows): array
    {
        $result = [];

        foreach ($rows as $row) {
            $userInfo = [];
            $itemInfo = [];

            if (isset($row['user']) && is_string($row['user'])) {
                $decoded = json_decode($row['user'], true);
                if (is_array($decoded)) {
                    $userInfo = $decoded;
                }
            }

            if (isset($row['item']) && is_string($row['item'])) {
                $decoded = json_decode($row['item'], true);
                if (is_array($decoded)) {
                    $itemInfo = $decoded;
                }
            }

            $timestamp = intval($row['time'] ?? 0);
            $createTime = $timestamp > 0
                ? date('Y-m-d H:i:s', $timestamp)
                : (string)($row['date'] ?? '');

            $result[] = [
                'id' => intval($row['id'] ?? 0),
                'order_no' => (string)($row['orderid'] ?? ''),
                'amount' => floatval($row['realmoney'] ?? ($itemInfo['price'] ?? 0)),
                'status' => intval($row['status'] ?? 0),
                'create_time' => $createTime,
                'item_name' => (string)($itemInfo['name'] ?? '充值订单'),
                'server_name' => (string)($userInfo['servername'] ?? ''),
                'role_name' => (string)($userInfo['playername'] ?? '')
            ];
        }

        return $result;
    }
}

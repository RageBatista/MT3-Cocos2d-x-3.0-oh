<?php
declare(strict_types=1);

namespace app\player\controller;

use app\BaseController;
use think\facade\Request;
use think\facade\Session;
use app\player\service\GmService;
use app\player\service\ServerService;

class SendItem extends BaseController
{
    protected $gmService;
    protected $serverService;

    public function initialize()
    {
        parent::initialize();
        $this->gmService = new GmService();
        $this->serverService = new ServerService();
    }

    public function index()
    {
        $player = getCurrentPlayerInfo();
        
        if (!$player || empty($player['cdk'])) {
            return redirect('/player/cdk/index')->with('error', '请先完成CDK授权');
        }

        $serverList = $this->serverService->getServerList();

        $currentServerId = getSession('serverid');
        $currentServerName = getSession('servername');

        return view('senditem/index', [
            'player' => $player,
            'server_list' => $serverList,
            'current_server_id' => $currentServerId,
            'current_server_name' => $currentServerName,
            'csrf_token' => $this->request->csrf_token ?? generateCsrfToken()
        ]);
    }

    public function getItemList()
    {
        // playerId是游戏角色ID（如4097），不是用户账号ID
        $playerId = getSession('id');
        $cdk = getSession('cdk');
        if (!$playerId || empty($cdk)) {
            return json(['code' => 0, 'msg' => '请先完成CDK授权']);
        }

        $serverId = getSession('serverid');
        if (!$serverId) {
            return json(['code' => 0, 'msg' => '请先选择区组']);
        }

        $items = $this->gmService->getItemList();

        return json([
            'code' => 1,
            'data' => $items
        ]);
    }

    public function prepareOp()
    {
        $action = Request::post('action', '');
        
        // playerId是游戏角色ID（如4097），不是用户账号ID
        $playerId = getSession('id');
        $cdk = getSession('cdk');
        if (!$playerId || empty($cdk)) {
            return json(['code' => 0, 'msg' => '请先完成CDK授权']);
        }

        $serverId = getSession('serverid');
        if (!$serverId) {
            return json(['code' => 0, 'msg' => '请先选择区组']);
        }

        $ts = time();
        $params = [];
        $extraData = [];
        
        switch ($action) {
            case 'sendItem':
                $itemToken = trim((string)Request::post('item_token', ''));
                $number = Request::post('number', 0);

                // 兼容前端传原始 itemId：在后端生成受保护 token
                if ($itemToken !== '' && ctype_digit($itemToken)) {
                    try {
                        $itemToken = $this->gmService->generateItemToken(intval($itemToken));
                    } catch (\Throwable $e) {
                        return json(['code' => 0, 'msg' => $e->getMessage()]);
                    }
                }

                $params = ['item_token' => $itemToken, 'number' => intval($number)];
                $extraData['item_token'] = $itemToken;
                break;
            case 'rechargeXianyu':
                $number = Request::post('number', 0);
                $params = ['number' => intval($number)];
                break;
            default:
                return json(['code' => 0, 'msg' => '未知操作']);
        }

        try {
            $sig = $this->gmService->computeOpSig($action, $ts, $params);
        } catch (\Throwable $e) {
            return json(['code' => 0, 'msg' => $e->getMessage()]);
        }

        $responseData = array_merge([
            'ts' => $ts,
            'sig' => $sig
        ], $extraData);

        return json([
            'code' => 1,
            'data' => $responseData
        ]);
    }

    public function sendItem()
    {
        // playerId是游戏角色ID（如4097），不是用户账号ID
        $playerId = getSession('id');
        $cdk = getSession('cdk');
        if (!$playerId || empty($cdk)) {
            return json(['code' => 0, 'msg' => '请先完成CDK授权']);
        }

        $serverId = getSession('serverid');
        if (!$serverId) {
            return json(['code' => 0, 'msg' => '请先选择区组']);
        }

        $itemToken = trim(Request::post('item_token', ''));
        try {
            [$tokenOk, $itemid, $tokenErr] = $this->gmService->parseItemToken($itemToken);
        } catch (\Throwable $e) {
            return json(['code' => 0, 'msg' => $e->getMessage()]);
        }
        
        if (!$tokenOk) {
            return json(['code' => 0, 'msg' => $tokenErr]);
        }

        $number = intval(Request::post('number', 0));
        if ($number <= 0 || $number > 9999) {
            return json(['code' => 0, 'msg' => '物品数量不合法(1-9999)']);
        }

        try {
            [$ok, $err] = $this->gmService->validateOpSignature('sendItem', ['item_token' => $itemToken, 'number' => $number]);
        } catch (\Throwable $e) {
            return json(['code' => 0, 'msg' => $e->getMessage()]);
        }
        if (!$ok) {
            return json(['code' => 0, 'msg' => $err]);
        }

        $result = $this->gmService->sendItem($itemid, $number);

        return json([
            'code' => $result['success'] ? 1 : 0,
            'msg' => $result['message']
        ]);
    }

    public function rechargeXianyu()
    {
        // playerId是游戏角色ID（如4097），不是用户账号ID
        $playerId = getSession('id');
        $cdk = getSession('cdk');
        if (!$playerId || empty($cdk)) {
            return json(['code' => 0, 'msg' => '请先完成CDK授权']);
        }

        $serverId = getSession('serverid');
        if (!$serverId) {
            return json(['code' => 0, 'msg' => '请先选择区组']);
        }

        $number = intval(Request::post('number', 0));
        if ($number <= 0 || $number > 99999999) {
            return json(['code' => 0, 'msg' => '仙玉数量不合法(1-99999999)']);
        }

        try {
            [$ok, $err] = $this->gmService->validateOpSignature('rechargeXianyu', ['number' => $number]);
        } catch (\Throwable $e) {
            return json(['code' => 0, 'msg' => $e->getMessage()]);
        }
        if (!$ok) {
            return json(['code' => 0, 'msg' => $err]);
        }

        $result = $this->gmService->rechargeXianyu($number);

        return json([
            'code' => $result['success'] ? 1 : 0,
            'msg' => $result['message']
        ]);
    }

    public function switchServer()
    {
        $playerId = getSession('id');
        $cdk = getSession('cdk');
        if (!$playerId || empty($cdk)) {
            return json(['code' => 0, 'msg' => '请先完成CDK授权']);
        }

        $serverId = Request::post('server_id', 0);
        
        if (empty($serverId)) {
            return json(['code' => 0, 'msg' => '请选择区组']);
        }

        $server = $this->serverService->getServerById($serverId);
        
        if (!$server) {
            return json(['code' => 0, 'msg' => '区组不存在']);
        }

        setSession('serverid', $server['serverid']);
        setSession('servername', $server['name']);
        setSession('groupname', $server['groupname'] ?? '');

        return json([
            'code' => 1,
            'msg' => '切换成功',
            'data' => [
                'serverid' => $server['serverid'],
                'servername' => $server['name']
            ]
        ]);
    }
}

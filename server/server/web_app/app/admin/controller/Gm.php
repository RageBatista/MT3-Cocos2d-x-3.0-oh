<?php
namespace app\admin\controller;

use app\BaseController;
use app\gm\Gm as Game;
use app\model\Bind;
use app\model\Item as ItemMod;
use app\model\Server as S;
use app\model\UserLog as ULog;
use think\facade\Db;
use think\facade\Session;

class Gm extends BaseController
{
    /**
     * 检查GM权限
     * @return bool
     */
    private function checkGMPermission()
    {
        $currentUser = $this->myAdmin;
        if (!isset($currentUser['type']) || (int)$currentUser['type'] !== 1) {
            $this->logGMOperation($currentUser, '未授权GM操作', false, '非管理员');
            return false;
        }
        return true;
    }

    /**
     * 记录GM操作日志
     * @param array $currentUser 当前用户
     * @param string $action 操作类型
     * @param bool $success 是否成功
     * @param string $reason 失败原因
     */
    private function logGMOperation($currentUser, $action, $success, $reason = '')
    {
        \app\service\PermissionAuditService::logGMOperation(
            $currentUser['username'] ?? 'unknown',
            $action,
            [],
            $success,
            $reason
        );
    }

    public function player()
    {
        // 权限检查：仅超级管理员可访问GM工具页面
        $this->checkGMPermission('访问GM工具页面');
        $get = $this->request->get();
        if (isset($get['playerid'])) {
            $playerid = $get['playerid'];
            Session::set('gm_playerid', $playerid);
        } else {
            $playerid = Session::get('gm_playerid');
        }

        $mod = $this->request->param('mod');
        if ($mod) {
            Session::set('gm_mod', $mod);
        } else {
            $mod = Session::get('gm_mod');
            if (!$mod) {
                $mod = 'basic';
                Session::set('gm_mod', $mod);
            }
        }

        $item = new ItemMod();
        // 宝石
        $getItemByType_1 = $item->getItemByType(1);
        // 任务物品
        $getItemByType_2 = $item->getItemByType(2);
        // 宠物物品
        $getItemByType_3 = $item->getItemByType(3);
        // 食品
        $getItemByType_4 = $item->getItemByType(4);
        // 杂货
        $getItemByType_5 = $item->getItemByType(5);
        // 装备
        $getItemByType_6 = $item->getItemByType(6);
        // 称谓
        $getItemByType_7 = $item->getItemByType(7);
        // 奖励
        $getItemByType_8 = $item->getItemByType(8);
        // 宠物技能
        $getItemByType_9 = $item->getItemByType(9);
        // 宠物
        $getItemByType_10 = $item->getItemByType(10);
        // 特技特效
        $getItemByType_11 = $item->getItemByType(11);

        $itemData = array_merge(
            $getItemByType_1,
            $getItemByType_2,
            $getItemByType_3,
            $getItemByType_4,
            $getItemByType_5,
            $getItemByType_6
        );

        return view('player', [
            'playerid'     => $playerid,
            'mod'          => $mod,
            'itemData'     => $itemData,
            'titleData'    => $getItemByType_7,
            'awardData'    => $getItemByType_8,
            'petData'      => $getItemByType_10,
            'petSkillData' => $getItemByType_9,
            'equip'        => $getItemByType_6,
            'skilleffect'  => $getItemByType_11,
        ]);
    }

    public function playerSub()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权执行GM操作');
        }

        // 记录GM操作
        $this->logGMOperation($this->myAdmin, '玩家GM操作', true);

        $mod = Session::get('gm_mod');
        $allowMods = ['basic', 'role', 'pet', 'gang', 'equip'];
        if ($mod === null || !in_array($mod, $allowMods, true) || !method_exists($this, $mod)) {
            return notify(0, '模块参数异常');
        }

        $post = $this->request->post();
        // 验证 CSRF Token
        if (!$this->checkToken($post['csrf_token'] ?? '')) {
            return notify(0, '非法请求：CSRF令牌无效');
        }
        if (!isset($post['playerid'])) {
            return notify(0, '玩家信息参数异常');
        }

        $playerid = $post['playerid'];
        if ($playerid === null || $playerid === '') {
            return notify(0, '角色ID不能为空');
        }

        $bind = new Bind();
        $getPlayerId = $bind->getPlayerId($playerid);
        if (!$getPlayerId) {
            return notify(0, '未查询到该角色');
        }

        $server = new S();
        $serverData = $server->getServerId($getPlayerId['serverid']);
        if (!$serverData) {
            return notify(0, '大区信息有误');
        }

        $post['serverip'] = $serverData['serverip'];
        $post['gmlocal']  = $serverData['gmlocal'];
        $post['gmport']   = $serverData['gmport'];
        $post['playerid'] = $getPlayerId['playerid'];

        $gm_mod = $this->$mod($post);

        if (is_array($gm_mod) && isset($gm_mod['gameNotify']) && is_array($gm_mod['gameNotify']) && !empty($gm_mod['gameNotify'][0])) {
            if (strpos($gm_mod['gameNotify'][0], 'success') !== false) {
                $info = 'GM操作，参数信息:' . json_encode($gm_mod['data'], JSON_UNESCAPED_UNICODE);
                $userLog = new ULog();
                $userLog->addAdminLog($this->myAdmin['username'], $info, $this->genericVariable);
                return notify(1, '操作成功，操作项：' . ($gm_mod['data']['info'] ?? ''));
            }
            return notify(0, '操作失败，操作项：' . ($gm_mod['data']['info'] ?? ''));
        }

        $errorMsg = '命令执行无返回结果';
        if (is_array($gm_mod) && isset($gm_mod['gameNotify']['error'])) {
            $errorMsg = $gm_mod['gameNotify']['error'];
        }
        return notify(0, '操作失败：' . $errorMsg . '，操作项：' . ($gm_mod['data']['info'] ?? ''));
    }

    public function basic($post)
    {
        $gameNotify = null;
        $Game = new Game();
        switch ($post['gmcmd']) {
            case 'nonvoice':
                $gameNotify = $Game->nonvoice($post);
                $post['info'] = '禁言';
                break;
            case 'unnonvoice':
                $gameNotify = $Game->unnonvoice($post);
                $post['info'] = '解除禁言';
                break;
            case 'coquest':
                $gameNotify = $Game->coquest($post);
                $post['info'] = '跳过主线';
                break;
            case 'clearbag':
                $gameNotify = $Game->clearbag($post);
                $post['info'] = '清理背包';
                break;
            case 'forgmbid':
                $gameNotify = $Game->forbid($post);
                $post['info'] = '封禁账号';
                break;
            case 'ungmforbid':
                $gameNotify = $Game->unforbid($post);
                $post['info'] = '解封账号';
                break;
            case 'superforbiduser':
                $gameNotify = $Game->superforbiduser($post);
                $post['info'] = '全服封号';
                break;
            case 'superunforbiduser':
                $gameNotify = $Game->superunforbiduser($post);
                $post['info'] = '全服解封';
                break;
            case 'kick':
                $gameNotify = $Game->kick($post);
                $post['info'] = '强制下线';
                break;
            case 'baitantimeclear':
                $gameNotify = $Game->baitantimeclear($post);
                $post['info'] = '清除摆摊公示';
                break;
            case 'checkcode':
                $gameNotify = $Game->checkcode($post);
                $post['info'] = '开启手机验证';
                break;
            case 'hideme':
                $gameNotify = $Game->hideme($post);
                $post['info'] = '隐身加速';
                break;
            case 'showme':
                $gameNotify = $Game->showme($post);
                $post['info'] = '取消隐身加速';
                break;
            case 'battleEndSuccess':
                $gameNotify = $Game->battleEndSuccess($post);
                $post['info'] = '战斗胜利';
                break;
            case 'battleEndFail':
                $gameNotify = $Game->battleEndFail($post);
                $post['info'] = '战斗失败';
                break;
            case 'cangbatou':
                $gameNotify = $Game->cangbatou($post);
                $post['info'] = '一键使用背包藏宝图';
                break;
        }

        return [
            'gameNotify' => $gameNotify,
            'data' => $post,
        ];
    }

    public function role($post)
    {
        $gameNotify = null;
        $Game = new Game();
        switch ($post['gmcmd']) {
            case 'addlevel':
                $gameNotify = $Game->addlevel($post);
                $post['info'] = '增加等级';
                break;
            case 'addRechargecurrency':
            case 'addqian':
                $gameNotify = $Game->addRechargecurrency($post);
                $post['info'] = '增加仙玉';
                break;
            case 'subfushi':
                $gameNotify = $Game->subfushi($post);
                $post['info'] = '减少仙玉';
                break;
            case 'addvipexp':
                $gameNotify = $Game->addvipexp($post);
                $post['info'] = '增加VIP经验';
                break;
            case 'setvip':
                $gameNotify = $Game->setvip($post);
                $post['info'] = '增加VIP等级';
                break;
            case 'addgold':
                $gameNotify = $Game->addgold($post);
                $post['info'] = '增加金币';
                break;
            case 'changebindtel':
                $gameNotify = $Game->changebindtel($post);
                $post['info'] = '关联手机号：' . ($post['mobile'] ?? '');
                break;
            case 'addsuperitem':
                $gameNotify = $Game->addsuperitem($post);
                $post['info'] = '发送物品';
                break;
            case 'grmail':
                $post['awardContent'] = $post['itemstr'] ?? '';
                $post['title'] = '系统邮件';
                $post['content'] = '这是您的邮件，请注意查收';
                $post['duration'] = 0;
                $gameNotify = $Game->mail($post);
                $post['info'] = '发送个人邮件';
                break;
            case 'addtitle':
                $gameNotify = $Game->addtitle($post);
                $post['info'] = '增加称谓';
                break;
            case 'deltitle':
                $gameNotify = $Game->deltitle($post);
                $post['info'] = '删除称谓';
                break;
            case 'addhyd':
                $gameNotify = $Game->addhyd($post);
                $post['info'] = '增加活跃度';
                break;
            case 'addRechargecurrencyS':
            case 'addqianS':
                $gameNotify = $Game->addRechargecurrencyS($post);
                $post['info'] = '增加货币数量';
                break;
            case 'award':
                $gameNotify = $Game->award($post);
                $post['info'] = '获取奖励';
                break;
            case 'offlinetime':
                $gameNotify = $Game->offlinetime($post);
                $post['info'] = '增加离线托管时间';
                break;
            case 'rolecmd':
                $gameNotify = $Game->rolecmd($post);
                $post['info'] = '角色CMD命令';
                break;
        }

        return [
            'gameNotify' => $gameNotify,
            'data' => $post,
        ];
    }

    public function pet($post)
    {
        $gameNotify = null;
        $Game = new Game();
        switch ($post['gmcmd']) {
            case 'addpetexp':
                $gameNotify = $Game->addpetexp($post);
                $post['info'] = '增加宠物经验';
                break;
            case 'addpet':
                $gameNotify = $Game->addpet($post);
                $post['info'] = '增加宠物';
                break;
            case 'addpetskill':
                $gameNotify = $Game->addpetskill($post);
                $post['info'] = '增加宠物技能';
                break;
            case 'delpetskill':
                $gameNotify = $Game->delpetskill($post);
                $post['info'] = '删除宠物技能';
                break;
            case 'setpetvalue':
                $valuetype = isset($post['valuetype']) ? intval($post['valuetype']) : 1;
                $cmdMap = [
                    1 => ['info' => '修改宠物成长资质'],
                    2 => ['info' => '修改宠物攻击资质'],
                    3 => ['info' => '修改宠物防御资质'],
                    4 => ['info' => '修改宠物法术资质'],
                    5 => ['info' => '修改宠物体质资质'],
                    6 => ['info' => '修改宠物速度资质'],
                ];
                $post['info'] = $cmdMap[$valuetype]['info'] ?? '修改宠物成长资质';
                $post['valuetype'] = isset($cmdMap[$valuetype]) ? $valuetype : 1;
                $gameNotify = $Game->setpetvalue($post);
                break;
        }

        return [
            'gameNotify' => $gameNotify,
            'data' => $post,
        ];
    }

    public function gang($post)
    {
        $gameNotify = null;
        $Game = new Game();
        switch ($post['gmcmd']) {
            case 'addbanggong':
                $gameNotify = $Game->addbanggong($post);
                $post['info'] = '增加帮派贡献';
                break;
            case 'addfactionmoney':
                $gameNotify = $Game->addfactionmoney($post);
                $post['info'] = '增加帮派资金';
                break;
            case 'bpgx':
                $gameNotify = $Game->bpgx($post);
                $post['info'] = '帮派强制维护';
                break;
            case 'yaofangrefresh':
                $gameNotify = $Game->yaofangrefresh($post);
                $post['info'] = '帮派药房刷新';
                break;
            case 'dismissguild':
                $gameNotify = $Game->dismissguild($post);
                $post['info'] = '解散帮派';
                break;
        }

        return [
            'gameNotify' => $gameNotify,
            'data' => $post,
        ];
    }

    public function equip($post)
    {
        $gameNotify = null;
        $Game = new Game();
        $gameNotify = $Game->adddingzhiequip($post);
        $post['info'] = '装备定制';

        return [
            'gameNotify' => $gameNotify,
            'data' => $post,
        ];
    }

    public function server_cmd()
    {
        $server = new S();
        $getAllServerList = $server->getAllServerList();

        return view('server', [
            'serverList' => $getAllServerList,
        ]);
    }

    public function serverSub()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权执行服务器GM操作');
        }

        // 记录GM操作
        $this->logGMOperation($this->myAdmin, '服务器GM操作', true);

        $post = $this->request->post();
        // 验证 CSRF Token
        if (!$this->checkToken($post['csrf_token'] ?? '')) {
            return notify(0, '非法请求：CSRF令牌无效');
        }
        $server = new S();
        $getServer = $server->getServer($post['serverid']);
        if (!$getServer) {
            return notify(0, '大区不存在');
        }

        $playerid = 4096;
        $post['serverip']  = $getServer['serverip'];
        $post['gmlocal']   = $getServer['gmlocal'];
        $post['gmport']    = $getServer['gmport'];
        $post['playerid']  = $playerid;

        $gameNotify = null;
        $Game = new Game();
        switch ($post['gmcmd']) {
            case 'cmd':
                $gameNotify = $Game->cmd($post);
                $post['info'] = 'cmd指令调试';
                break;
            case 'setdays':
                $gameNotify = $Game->setdays($post);
                $post['info'] = '设置开服天数';
                break;
            case 'post':
                $gameNotify = $Game->post($post);
                $post['info'] = '发送公告';
                break;
            case 'zmd':
                $gameNotify = $Game->zmd($post);
                $post['info'] = '走马灯';
                break;
            case 'destroyzone':
                $gameNotify = $Game->destroyzone($post);
                $post['info'] = '销毁所有副本';
                break;
            case 'reload':
                $gameNotify = $Game->reload($post);
                $post['info'] = '重新加载服务器表数据';
                break;
            case 'stopgamegs':
                $gameNotify = $Game->stopgs($post);
                $post['info'] = '友好关闭服务器';
                break;
            case 'createrole0':
                $gameNotify = $Game->createrole0($post);
                $post['info'] = '禁止创建角色';
                break;
            case 'createrole1':
                $gameNotify = $Game->createrole1($post);
                $post['info'] = '开启创建角色';
                break;
        }

        if (isset($gameNotify[0]) && strpos($gameNotify[0], 'success') !== false) {
            $info = '服务器操作，参数信息:' . json_encode($post, JSON_UNESCAPED_UNICODE);
            $userLog = new ULog();
            $userLog->addAdminLog($this->myAdmin['username'], $info, $this->genericVariable);
            return notify(1, '操作成功，操作项：' . $post['info']);
        }

        return notify(0, '操作失败，操作项：' . $post['info']);
    }

    public function server_mail()
    {
        $server = new S();
        $getAllServerList = $server->getAllServerList();

        $item = new ItemMod();
        // 宝石
        $getItemByType_1 = $item->getItemByType(1);
        // 任务物品
        $getItemByType_2 = $item->getItemByType(2);
        // 宠物物品
        $getItemByType_3 = $item->getItemByType(3);
        // 食品
        $getItemByType_4 = $item->getItemByType(4);
        // 杂货
        $getItemByType_5 = $item->getItemByType(5);
        // 装备
        $getItemByType_6 = $item->getItemByType(6);

        $itemData = array_merge(
            $getItemByType_1,
            $getItemByType_2,
            $getItemByType_3,
            $getItemByType_4,
            $getItemByType_5,
            $getItemByType_6
        );

        return view('mail', [
            'serverList' => $getAllServerList,
            'itemData' => $itemData,
        ]);
    }

    public function serverMailSub()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权执行全服邮件操作');
        }

        // 记录GM操作
        $this->logGMOperation($this->myAdmin, '全服邮件操作', true);

        $post = $this->request->post();
        // 验证 CSRF Token
        if (!$this->checkToken($post['csrf_token'] ?? '')) {
            return notify(0, '非法请求：CSRF令牌无效');
        }
        $server = new S();
        $getServer = $server->getServer($post['serverid']);
        if (!$getServer) {
            return notify(0, '大区不存在');
        }

        $playerid = 4096;
        $post['serverip']  = $getServer['serverip'];
        $post['gmlocal']   = $getServer['gmlocal'];
        $post['gmport']    = $getServer['gmport'];
        $post['playerid']  = $playerid;

        $Game = new Game();
        $gameNotify = $Game->mailbycond($post);
        $post['info'] = '全服邮件';

        if (isset($gameNotify) && is_array($gameNotify) && !empty($gameNotify[0])) {
            if (strpos($gameNotify[0], 'success') !== false) {
                $info = '发送全服邮件，参数信息:' . json_encode($post, JSON_UNESCAPED_UNICODE);
                $userLog = new ULog();
                $userLog->addAdminLog($this->myAdmin['username'], $info, $this->genericVariable);
                return notify(1, '操作成功，操作项：' . $post['info']);
            }
            return notify(0, '操作失败，操作项：' . $post['info']);
        }

        $errorMsg = isset($gameNotify['error']) ? $gameNotify['error'] : '命令执行无返回结果';
        return notify(0, '操作失败：' . $errorMsg . '，操作项：' . $post['info']);
    }

    public function cleanData()
    {
        if (!$this->checkGMPermission()) {
            return redirect('/admin/index/worker')->with('error', '无权访问该页面');
        }
        return view('clean_data');
    }

    /**
     * 查询待清理的数据
     */
    public function queryCleanData()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权执行此操作');
        }

        $userId = $this->request->post('userId', 0);
        // 验证 CSRF Token
        // queryCleanData is a read op but exposed via POST
        $token = $this->request->post('csrf_token', '');
        if (!$this->checkToken($token)) {
            return notify(0, '非法请求：CSRF令牌无效');
        }
        $playerId = $this->request->post('playerId', 0);

        $data = [
            'userAccount' => null,
            'userBinds' => [],
            'orderCount' => 0,
            'logCount' => 0,
        ];

        // 通过角色ID查询
        if ($playerId) {
            $bind = new \app\model\Bind();
            $userBind = $bind->getByPlayerId($playerId);
            if ($userBind) {
                $data['userBinds'][] = $userBind;
                $userId = $userBind['userid'];
            }
        }

        // 通过账号ID查询
        if ($userId) {
            $userAccountModel = new \app\model\User();
            $userAccount = $userAccountModel->getById($userId);
            if ($userAccount) {
                $data['userAccount'] = $userAccount->toArray();
            }

            $bind = new \app\model\Bind();
            $binds = $bind->getByUserId($userId);
            if ($binds) {
                $data['userBinds'] = array_merge($data['userBinds'], $binds);
            }

            $orderModel = new \app\model\UserOrder();
            $data['orderCount'] = $orderModel->countByUserId($userId);

            $logModel = new \app\model\UserLog();
            $data['logCount'] = $logModel->countByUserId($userId);
        }

        if (!$data['userAccount'] && empty($data['userBinds'])) {
            return notify(0, '未找到相关数据');
        }

        return notify(1, '查询成功', $data);
    }

    public function doCleanData()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权执行此操作');
        }

        $userId = $this->request->post('userId', 0);
        // 验证 CSRF Token
        $token = $this->request->post('csrf_token', '');
        if (!$this->checkToken($token)) {
            return notify(0, '非法请求：CSRF令牌无效');
        }
        $playerId = $this->request->post('playerId', 0);
        $resetAutoIncrement = $this->request->post('resetAutoIncrement', 0);

        $result = [
            'deletedUserAccount' => null,
            'deletedBinds' => [],
            'deletedOrders' => 0,
            'deletedLogs' => 0,
            'deletedVoices' => 0,
            'deletedFeedbacks' => 0,
            'resetTables' => [],
            'errors' => [],
        ];

        try {
            Db::startTrans();

            if ($playerId && !$userId) {
                $bind = new \app\model\Bind();
                $userBind = $bind->getByPlayerId($playerId);
                if ($userBind) {
                    $userId = $userBind['userid'];
                    $result['deletedBinds'][] = $userBind;
                }
            }

            $userAccount = null;
            if ($userId) {
                $userAccountModel = new \app\model\User();
                $userAccount = $userAccountModel->getById($userId);
                if ($userAccount) {
                    $result['deletedUserAccount'] = $userAccount->toArray();
                }
            }

            if ($userId) {
                $bind = new \app\model\Bind();
                $binds = $bind->getByUserId($userId);
                if ($binds) {
                    foreach ($binds as $b) {
                        $result['deletedBinds'][] = $b;
                    }
                    $bind->deleteByUserId($userId);
                }

                $orderModel = new \app\model\UserOrder();
                $result['deletedOrders'] = $orderModel->deleteByUserId($userId);

                $logModel = new \app\model\UserLog();
                $result['deletedLogs'] = $logModel->deleteByUserId($userId);

                $voiceModel = new \app\model\Voice();
                $result['deletedVoices'] = $voiceModel->deleteByUserId($userId);

                $fankuiModel = new \app\model\Fankui();
                $result['deletedFeedbacks'] = $fankuiModel->deleteByUserId($userId);

                if ($userAccount) {
                    $userAccountModel->deleteById($userId);
                }
            }

            if ($resetAutoIncrement) {
                $tables = ['user_account', 'user_bind', 'user_order', 'user_log', 'user_voice', 'user_fankui'];
                foreach ($tables as $table) {
                    $count = Db::table($table)->count();
                    if ($count == 0) {
                        Db::execute("ALTER TABLE `{$table}` AUTO_INCREMENT = 1");
                        $result['resetTables'][] = $table;
                    }
                }
            }

            Db::commit();

            $logInfo = '清理玩家数据: ';
            if ($result['deletedUserAccount']) {
                $logInfo .= '账号=' . $result['deletedUserAccount']['username'] . ', ';
            }
            $logInfo .= '角色数=' . count($result['deletedBinds']) . ', ';
            $logInfo .= '订单数=' . $result['deletedOrders'] . ', ';
            $logInfo .= '日志数=' . $result['deletedLogs'];
            $userLog = new ULog();
            $userLog->addAdminLog($this->myAdmin['username'], $logInfo, $this->genericVariable);

            return notify(1, '清理成功', $result);
        } catch (\Exception $e) {
            Db::rollback();
            $result['errors'][] = $e->getMessage();
            return notify(0, '清理失败: ' . $e->getMessage(), $result);
        }
    }

    public function getDataStatistics()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权执行此操作');
        }

        // 验证 CSRF Token
        $token = $this->request->post('csrf_token', '');
        if (!$this->checkToken($token)) {
            return notify(0, '非法请求：CSRF令牌无效');
        }
        $stats = [
            'userAccountCount' => Db::table('user_account')->count(),
            'userBindCount' => Db::table('user_bind')->count(),
            'userOrderCount' => Db::table('user_order')->count(),
            'userLogCount' => Db::table('user_log')->count(),
            'userVoiceCount' => Db::table('user_voice')->count(),
            'userFankuiCount' => Db::table('user_fankui')->count(),
        ];

        return notify(1, '统计成功', $stats);
    }

    public function doCleanAll()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权执行此操作');
        }

        $resetAutoIncrement = $this->request->post('resetAutoIncrement', 0);
        // 验证 CSRF Token
        $token = $this->request->post('csrf_token', '');
        if (!$this->checkToken($token)) {
            return notify(0, '非法请求：CSRF令牌无效');
        }

        $result = [
            'clearedAll' => true,
            'clearedTables' => [],
            'resetTables' => [],
            'errors' => [],
        ];

        try {
            Db::startTrans();

            $tables = [
                'user_account' => '玩家账号',
                'user_bind' => '角色绑定',
                'user_order' => '订单记录',
                'user_log' => '日志记录',
                'user_voice' => '语音记录',
                'user_fankui' => '反馈记录',
            ];

            foreach ($tables as $tableName => $tableDesc) {
                $count = Db::table($tableName)->count();
                if ($count > 0) {
                    Db::table($tableName)->where('1=1')->delete();
                    $result['clearedTables'][] = [
                        'table' => $tableDesc,
                        'count' => $count,
                    ];
                }

                if ($resetAutoIncrement) {
                    Db::execute("ALTER TABLE `{$tableName}` AUTO_INCREMENT = 1");
                    $result['resetTables'][] = $tableName;
                }
            }

            Db::commit();

            $logInfo = '清空所有玩家数据: ';
            foreach ($result['clearedTables'] as $table) {
                $logInfo .= $table['table'] . '(' . $table['count'] . '条), ';
            }
            $userLog = new ULog();
            $userLog->addAdminLog($this->myAdmin['username'], $logInfo, $this->genericVariable);

            return notify(1, '清空成功', $result);
        } catch (\Exception $e) {
            Db::rollback();
            $result['errors'][] = $e->getMessage();
            return notify(0, '清空失败: ' . $e->getMessage(), $result);
        }
    }

    public function cdk()
    {
        return view('cdk');
    }

    public function cdkQuery()
    {
        $req = $this->request;
        $cdk    = trim((string)$req->param('cdk', ''));
        $uid    = trim((string)$req->param('uid', ''));
        $qid    = trim((string)$req->param('qid', ''));
        $status = $req->param('status', '');
        $page   = max(1, intval($req->param('page', 1)));
        $pageSize = max(1, min(100, intval($req->param('pageSize', 10))));

        $conds = [];
        $bind  = [];
        if ($cdk !== '') { $conds[] = 'cdk = ?'; $bind[] = $cdk; }
        if ($uid !== '') { $conds[] = 'uid = ?'; $bind[] = $uid; }
        if ($qid !== '') { $conds[] = 'qid = ?'; $bind[] = $qid; }
        if ($status !== '' && $status !== null) { $conds[] = 'status = ?'; $bind[] = intval($status); }
        $whereSql = $conds ? (' WHERE ' . implode(' AND ', $conds)) : '';

        $totalRow = Db::query('SELECT COUNT(*) AS cnt FROM cdks' . $whereSql, $bind);
        $total    = intval($totalRow[0]['cnt'] ?? 0);
        $totalPages = $total > 0 ? (int)ceil($total / $pageSize) : 0;
        $page = ($totalPages > 0) ? min($page, $totalPages) : 1;
        $offset = max(0, ($page - 1) * $pageSize);

        $list = [];
        if ($total > 0) {
            $sql = 'SELECT id, cdk, lv, qid, uid, status, used_at, pass
                    FROM cdks' . $whereSql . ' ORDER BY id DESC LIMIT ' . $offset . ', ' . $pageSize;
            $list = Db::query($sql, $bind);
        }

        return json([
            'code' => 1,
            'msg'  => '查询成功',
            'data' => [
                'page'       => $totalPages ? $page : 0,
                'totalPages' => $totalPages,
                'total'      => $total,
                'list'       => $list,
            ],
        ]);
    }

    public function cdkListUnused()
    {
        $req = $this->request;
        $page = max(1, intval($req->param('page', 1)));
        $pageSize = max(1, min(100, intval($req->param('pageSize', 10))));

        $totalRow = Db::query('SELECT COUNT(*) AS cnt FROM cdks WHERE status = 0');
        $total = intval($totalRow[0]['cnt'] ?? 0);
        $totalPages = $total > 0 ? (int)ceil($total / $pageSize) : 0;
        $page = ($totalPages > 0) ? min($page, $totalPages) : 1;
        $offset = max(0, ($page - 1) * $pageSize);

        $list = [];
        if ($total > 0) {
            $list = Db::query('SELECT id, cdk, lv
                               FROM cdks
                               WHERE status = 0
                               ORDER BY id DESC
                               LIMIT ' . $offset . ', ' . $pageSize);
        }

        return json([
            'code' => 1,
            'msg'  => '获取成功',
            'data' => [
                'page'       => $totalPages ? $page : 0,
                'totalPages' => $totalPages,
                'total'      => $total,
                'list'       => $list,
            ],
        ]);
    }

    public function cdkListUsed()
    {
        $req = $this->request;
        $page = max(1, intval($req->param('page', 1)));
        $pageSize = max(1, min(100, intval($req->param('pageSize', 10))));

        $totalRow = Db::query('SELECT COUNT(*) AS cnt FROM cdks WHERE status = 1');
        $total = intval($totalRow[0]['cnt'] ?? 0);
        $totalPages = $total > 0 ? (int)ceil($total / $pageSize) : 0;
        $page = ($totalPages > 0) ? min($page, $totalPages) : 1;
        $offset = max(0, ($page - 1) * $pageSize);

        $list = [];
        if ($total > 0) {
            $list = Db::query('SELECT id, cdk, lv, qid, uid, used_at, pass
                               FROM cdks
                               WHERE status = 1
                               ORDER BY id DESC
                               LIMIT ' . $offset . ', ' . $pageSize);
        }

        return json([
            'code' => 1,
            'msg'  => '获取成功',
            'data' => [
                'page'       => $totalPages ? $page : 0,
                'totalPages' => $totalPages,
                'total'      => $total,
                'list'       => $list,
            ],
        ]);
    }

    public function cdkStats()
    {
        $totalRow  = Db::query('SELECT COUNT(*) AS cnt FROM cdks');
        $usedRow   = Db::query('SELECT COUNT(*) AS cnt FROM cdks WHERE status = 1');
        $unusedRow = Db::query('SELECT COUNT(*) AS cnt FROM cdks WHERE status = 0');

        $total  = intval($totalRow[0]['cnt'] ?? 0);
        $used   = intval($usedRow[0]['cnt'] ?? 0);
        $unused = intval($unusedRow[0]['cnt'] ?? 0);

        return json([
            'code' => 1,
            'msg'  => '统计成功',
            'data' => [
                'total'  => $total,
                'used'   => $used,
                'unused' => $unused,
            ],
        ]);
    }

    public function cdkGenerate()
    {
        $req = $this->request;
        $count   = max(1, intval($req->param('count', 0)));
        $lv      = max(0, intval($req->param('lv', 0)));
        $length  = intval($req->param('length', 16));

        if (!in_array($length, [16, 20], true)) {
            return json(['code' => 0, 'msg' => '位数仅支持16或20']);
        }
        if ($count > 100000) {
            return json(['code' => 0, 'msg' => '生成数量过大']);
        }

        try {
            Db::startTrans();
            $inserted = 0;

            for ($i = 0; $i < $count; $i++) {
                $code = $this->makeCdk($length);

                $tries = 0;
                while ($tries < 10) {
                    $exists = Db::query('SELECT id FROM cdks WHERE cdk = ? LIMIT 1', [$code]);
                    if (!$exists) {
                        break;
                    }
                    $code = $this->makeCdk($length);
                    $tries++;
                }
                $exists = Db::query('SELECT id FROM cdks WHERE cdk = ? LIMIT 1', [$code]);
                if ($exists) {
                    continue;
                }

                Db::execute(
                    'INSERT INTO cdks (cdk, lv, qid, uid, status) VALUES (?, ?, 0, 0, 0)',
                    [$code, $lv]
                );
                $inserted++;
            }

            Db::commit();
            return json([
                'code' => 1,
                'msg'  => '生成成功：' . $inserted . ' 条',
                'data' => ['count' => $inserted],
            ]);
        } catch (\Throwable $e) {
            Db::rollback();
            return json(['code' => 0, 'msg' => '生成失败：' . $e->getMessage()]);
        }
    }

    private function makeCdk(int $length): string
    {
        $alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
        $groupSize = ($length === 20) ? 5 : 4;
        $groups = 4;
        $parts = [];
        for ($g = 0; $g < $groups; $g++) {
            $seg = '';
            for ($i = 0; $i < $groupSize; $i++) {
                $seg .= $alphabet[random_int(0, strlen($alphabet) - 1)];
            }
            $parts[] = $seg;
        }
        return implode('-', $parts);
    }

    public function cdkUpdateUid()
    {
        $req = $this->request;
        $id  = max(1, intval($req->param('id', 0)));
        $uid = intval($req->param('uid', 0));

        if ($id <= 0 || $uid < 0) {
            return json(['code' => 0, 'msg' => '参数不合法']);
        }

        $row = Db::query('SELECT id, status FROM cdks WHERE id = ? LIMIT 1', [$id]);
        if (!$row) {
            return json(['code' => 0, 'msg' => '记录不存在']);
        }
        if (intval($row[0]['status'] ?? 0) !== 1) {
            return json(['code' => 0, 'msg' => '仅已使用记录可修改']);
        }

        Db::execute('UPDATE cdks SET uid = ? WHERE id = ?', [$uid, $id]);
        return json(['code' => 1, 'msg' => '修改成功']);
    }

    public function cdkDelete()
    {
        $id = max(1, intval($this->request->param('id', 0)));
        if ($id <= 0) {
            return json(['code' => 0, 'msg' => '参数不合法']);
        }

        $row = Db::query('SELECT id FROM cdks WHERE id = ? LIMIT 1', [$id]);
        if (!$row) {
            return json(['code' => 0, 'msg' => '记录不存在']);
        }

        Db::execute('DELETE FROM cdks WHERE id = ?', [$id]);
        return json(['code' => 1, 'msg' => '删除成功']);
    }

    public function cdkUpdatePass()
    {
        $req  = $this->request;
        $id   = max(1, intval($req->param('id', 0)));
        $pass = trim((string)$req->param('pass', ''));

        if ($id <= 0) {
            return json(['code' => 0, 'msg' => '参数不合法']);
        }

        $row = Db::query('SELECT id, status FROM cdks WHERE id = ? LIMIT 1', [$id]);
        if (!$row) {
            return json(['code' => 0, 'msg' => '记录不存在']);
        }
        if (intval($row[0]['status'] ?? 0) !== 1) {
            return json(['code' => 0, 'msg' => '仅已使用记录可修改']);
        }

        Db::execute('UPDATE cdks SET pass = ? WHERE id = ?', [$pass, $id]);
        return json(['code' => 1, 'msg' => '修改成功']);
    }
}
?>

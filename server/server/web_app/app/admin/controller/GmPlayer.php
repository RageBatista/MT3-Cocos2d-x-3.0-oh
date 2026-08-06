<?php
declare(strict_types=1);

namespace app\admin\controller;

use app\gm\Gm as Game;
use app\model\Bind;
use app\model\Item as ItemMod;
use app\model\Server as S;
use app\model\UserLog as ULog;
use think\facade\Session;

class GmPlayer extends GmBase
{
    public function player()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权访问GM工具页面');
        }
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
        $getItemByType_1 = $item->getItemByType(1);
        $getItemByType_2 = $item->getItemByType(2);
        $getItemByType_3 = $item->getItemByType(3);
        $getItemByType_4 = $item->getItemByType(4);
        $getItemByType_5 = $item->getItemByType(5);
        $getItemByType_6 = $item->getItemByType(6);
        $getItemByType_7 = $item->getItemByType(7);
        $getItemByType_8 = $item->getItemByType(8);
        $getItemByType_9 = $item->getItemByType(9);
        $getItemByType_10 = $item->getItemByType(10);
        $getItemByType_11 = $item->getItemByType(11);

        $itemData = array_merge(
            $getItemByType_1,
            $getItemByType_2,
            $getItemByType_3,
            $getItemByType_4,
            $getItemByType_5,
            $getItemByType_6
        );

        return view('gm/player', [
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

        $this->logGMOperation($this->myAdmin, '玩家GM操作', true);

        $mod = Session::get('gm_mod');
        $allowMods = ['basic', 'role', 'pet', 'gang', 'equip'];
        if ($mod === null || !in_array($mod, $allowMods, true) || !method_exists($this, $mod)) {
            return notify(0, '模块参数异常');
        }

        $post = $this->request->post();
        if (!$this->checkToken($post['csrf_token'] ?? '')) {
            $this->logGMOperation($this->myAdmin, '玩家GM操作', false, 'CSRF令牌无效');
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
        $post['gm_userid'] = intval($this->myAdmin['id'] ?? 0);
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
            case 'abcungmforbid':
                $gameNotify = $Game->unforbid($post);
                $post['info'] = '全服解封';
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

        if ($gameNotify === null) {
            $this->logGMOperation($this->myAdmin, '玩家GM操作', false, '未注册的basic GM操作');
            $post['info'] = '未注册GM操作';
            return [
                'gameNotify' => ['error' => '未注册GM操作'],
                'data' => $post,
            ];
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

        if ($gameNotify === null) {
            $this->logGMOperation($this->myAdmin, '玩家GM操作', false, '未注册的role GM操作');
            $post['info'] = '未注册GM操作';
            return [
                'gameNotify' => ['error' => '未注册GM操作'],
                'data' => $post,
            ];
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

        if ($gameNotify === null) {
            $this->logGMOperation($this->myAdmin, '玩家GM操作', false, '未注册的pet GM操作');
            $post['info'] = '未注册GM操作';
            return [
                'gameNotify' => ['error' => '未注册GM操作'],
                'data' => $post,
            ];
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

        if ($gameNotify === null) {
            $this->logGMOperation($this->myAdmin, '玩家GM操作', false, '未注册的gang GM操作');
            $post['info'] = '未注册GM操作';
            return [
                'gameNotify' => ['error' => '未注册GM操作'],
                'data' => $post,
            ];
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
}

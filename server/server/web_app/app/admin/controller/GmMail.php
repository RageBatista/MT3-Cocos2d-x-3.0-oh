<?php
declare(strict_types=1);

namespace app\admin\controller;

use app\gm\Gm as Game;
use app\model\Item as ItemMod;
use app\model\Server as S;
use app\model\UserLog as ULog;

class GmMail extends GmBase
{
    public function server_mail()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权访问全服邮件工具');
        }

        $server = new S();
        $getAllServerList = $server->getAllServerList();

        $item = new ItemMod();
        $getItemByType_1 = $item->getItemByType(1);
        $getItemByType_2 = $item->getItemByType(2);
        $getItemByType_3 = $item->getItemByType(3);
        $getItemByType_4 = $item->getItemByType(4);
        $getItemByType_5 = $item->getItemByType(5);
        $getItemByType_6 = $item->getItemByType(6);

        $itemData = array_merge(
            $getItemByType_1,
            $getItemByType_2,
            $getItemByType_3,
            $getItemByType_4,
            $getItemByType_5,
            $getItemByType_6
        );

        return view('gm/mail', [
            'serverList' => $getAllServerList,
            'itemData' => $itemData,
        ]);
    }

    public function serverMailSub()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权执行全服邮件操作');
        }

        $this->logGMOperation($this->myAdmin, '全服邮件操作', true);

        $post = $this->request->post();
        if (!$this->checkToken($post['csrf_token'] ?? '')) {
            $this->logGMOperation($this->myAdmin, '全服邮件操作', false, 'CSRF令牌无效');
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
        $post['gm_userid'] = intval($this->myAdmin['id'] ?? 0);
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
}

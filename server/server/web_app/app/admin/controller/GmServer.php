<?php
declare(strict_types=1);

namespace app\admin\controller;

use app\gm\Gm as Game;
use app\model\Server as S;
use app\model\UserLog as ULog;

class GmServer extends GmBase
{
    public function server_cmd()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权访问服务器GM工具');
        }

        $server = new S();
        $getAllServerList = $server->getAllServerList();

        return view('gm/server', [
            'serverList' => $getAllServerList,
        ]);
    }

    public function serverSub()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权执行服务器GM操作');
        }

        $this->logGMOperation($this->myAdmin, '服务器GM操作', true);

        $post = $this->request->post();
        if (!$this->checkToken($post['csrf_token'] ?? '')) {
            $this->logGMOperation($this->myAdmin, '服务器GM操作', false, 'CSRF令牌无效');
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
            default:
                $this->logGMOperation($this->myAdmin, '服务器GM操作', false, '未注册的服务器GM操作');
                return notify(0, '未注册的服务器GM操作');
        }

        if (isset($gameNotify[0]) && strpos($gameNotify[0], 'success') !== false) {
            $info = '服务器操作，参数信息:' . json_encode($post, JSON_UNESCAPED_UNICODE);
            $userLog = new ULog();
            $userLog->addAdminLog($this->myAdmin['username'], $info, $this->genericVariable);
            return notify(1, '操作成功，操作项：' . $post['info']);
        }

        return notify(0, '操作失败，操作项：' . $post['info']);
    }
}

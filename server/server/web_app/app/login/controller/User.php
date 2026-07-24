<?php
declare(strict_types=1);

namespace app\login\controller;

use app\BaseController;
use think\facade\Session;
use app\model\Server;
use app\model\User as UserModel;
use app\model\UserLog as ULog;

class User extends BaseController
{
    public function index()
    {
        return view('index/user');
    }

    public function submit()
    {
        if (config('player.auth_enabled') === false) {
            return json(['code' => 0, 'msg' => '玩家功能未开启']);
        }

        $post = $this->request->post();
        $username = strtolower(trim((string)($post['username'] ?? '')));
        $passwordValue = strtolower(trim((string)($post['password'] ?? '')));
        $serverid = trim((string)($post['serverid'] ?? ''));

        if (!preg_match('/^[a-z0-9]{6,18}$/', $username)) {
            return json(['code' => 0, 'msg' => '账号格式不正确']);
        }
        if (!preg_match('/^[a-z0-9]{6,18}$/', $passwordValue)) {
            return json(['code' => 0, 'msg' => '密码格式不正确']);
        }

        $U = new UserModel();
        $userRow = $U->getUsername($username);
        if (!$userRow || !password($passwordValue, (string)$userRow['password'])) {
            return json(['code' => 0, 'msg' => '账号或密码错误']);
        }
        if (isset($userRow['status']) && intval($userRow['status']) !== 1) {
            return json(['code' => 0, 'msg' => '账号已被禁用']);
        }

        $uid = intval($userRow['id'] ?? 0);
        if ($uid <= 0) {
            return json(['code' => 0, 'msg' => '账号数据异常']);
        }

        $S = new Server();
        $serverRow = null;
        if ($serverid !== '') {
            $serverRow = $S->getServerId($serverid);
            if (!$serverRow) {
                $serverByPk = $S->getServer($serverid);
                if ($serverByPk) {
                    $serverRow = $serverByPk;
                } else {
                    $serverByPort = $S->where('gmport', $serverid)->find();
                    if ($serverByPort) {
                        $serverRow = $serverByPort;
                    }
                }
            }
        }

        if (!$serverRow) {
            $serverList = $S->makeServerList();
            if (is_object($serverList) && method_exists($serverList, 'toArray')) {
                $serverList = $serverList->toArray();
            }
            if (!is_array($serverList) || count($serverList) === 0) {
                $serverList = $S->getAllServerList();
                if (is_object($serverList) && method_exists($serverList, 'toArray')) {
                    $serverList = $serverList->toArray();
                }
            }
            if (is_array($serverList) && count($serverList) > 0) {
                $serverRow = $serverList[0];
            }
        }

        if (!$serverRow) {
            return json(['code' => 0, 'msg' => '暂无可用大区']);
        }

        $serverIdFinal = intval($serverRow['serverid'] ?? 0);
        if ($serverIdFinal <= 0) {
            return json(['code' => 0, 'msg' => '大区数据异常']);
        }

        Session::set('auth_serverid', $serverIdFinal);
        Session::set('auth_servername', $serverRow['name']);
        Session::set('auth_groupname', isset($serverRow['groupname']) ? $serverRow['groupname'] : '');
        Session::set('auth_pass', '');
        Session::set('auth_uid', $uid);
        Session::set('auth_cdk', 'ACCOUNT_LOGIN_' . $uid);
        Session::set('auth_lv', 0);

        $this->logPlayerAction('账号密码登录成功');
        return json(['code' => 1, 'msg' => '登录成功']);
    }

    private function logPlayerAction(string $info): void
    {
        try {
            $uid = intval(Session::get('auth_uid'));
            $username = 'UID:' . $uid;
            if ($uid > 0) {
                $U = new UserModel();
                $u = $U->getById($uid);
                if ($u && isset($u['username'])) {
                    $username = $u['username'];
                }
            }
            $log = new ULog();
            $log->addUserLog($username, $info, $this->genericVariable);
        } catch (\Throwable $e) {
            // ignore logging errors
        }
    }
}


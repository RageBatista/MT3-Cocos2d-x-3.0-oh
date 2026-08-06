<?php


namespace app\login\controller;

use app\BaseController;
use think\facade\Session;
use think\facade\Db;
use think\facade\Cache;
use app\gm\Gm;
use app\model\Server;
use app\model\UserLog as ULog;
use app\model\User;

class Auth extends BaseController
{
    public function index()
    {
        return $this->auth();
    }

    public function auth()
    {
        return view('index/auth');
    }

    public function userLogin()
    {
        return view('index/user');
    }

    public function userLoginSubmit()
    {
        if ($resp = $this->guardEnabled()) {
            return $resp;
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

        $U = new User();
        $userRow = $U->getUsername($username);
        if (!$userRow || !password($passwordValue, (string)$userRow['password'])) {
            return json(['code' => 0, 'msg' => '账号或密码错误']);
        }
        if (isset($userRow['status']) && intval($userRow['status']) !== 1) {
            return json(['code' => 0, 'msg' => '账号已被禁用']);
        }

        $uid = intval($userRow['id'] ?? 0);
        if ($uid <= 0) {
            return json(['code' => 0, 'msg' => 'UID不合法']);
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

    private function guardEnabled()
    {
        if (config('player.auth_enabled') === false) {
            return json(['code' => 0, 'msg' => '玩家授权功能未开启']);
        }
        return null;
    }

    public function getServers()
    {
        if ($resp = $this->guardEnabled()) {
            return $resp;
        }

        try {
            $S = new Server();
            $list = $S->makeServerList();
            if (is_object($list) && method_exists($list, 'toArray')) {
                $list = $list->toArray();
            }

            if (!is_array($list) || count($list) === 0) {
                $list = $S->getAllServerList();
                if (is_object($list) && method_exists($list, 'toArray')) {
                    $list = $list->toArray();
                }
            }

            if (!is_array($list) || count($list) === 0) {
                return json(['code' => 0, 'msg' => '暂无可用大区，请在后台添加并启用']);
            }

            $data = [];
            foreach ($list as $row) {
                $data[] = [
                    'serverid'  => $row['serverid'],
                    'name'      => $row['name'],
                    'groupname' => isset($row['groupname']) ? $row['groupname'] : '',
                ];
            }
            return json(['code' => 1, 'data' => $data]);
        } catch (\Throwable $e) {
            return json(['code' => 0, 'msg' => '大区列表加载失败，请检查数据库与服务器配置']);
        }
    }

    public function authSubmit()
    {
        if ($resp = $this->guardEnabled()) {
            return $resp;
        }

        $post = $this->request->post();
        $serverid = isset($post['serverid']) ? trim($post['serverid']) : null;
        $authpass = isset($post['authpass']) ? trim($post['authpass']) : '';

        $S = new Server();
        $serverRow = $S->getServerId($serverid);
        if (!$serverRow) {
            $serverByPk = $S->getServer($serverid);
            if ($serverByPk) {
                $serverRow = $serverByPk;
                $serverid = intval($serverRow['serverid']);
            } else {
                $serverByPort = $S->where('gmport', $serverid)->find();
                if ($serverByPort) {
                    $serverRow = $serverByPort;
                    $serverid = intval($serverRow['serverid']);
                } else {
                    return json(['code' => 0, 'msg' => '所选区组不存在，请刷新后重试']);
                }
            }
        }

        Session::set('auth_serverid', $serverid);
        Session::set('auth_servername', $serverRow['name']);
        Session::set('auth_groupname', isset($serverRow['groupname']) ? $serverRow['groupname'] : '');
        Session::set('auth_pass', $authpass);

        $uid = intval($this->request->post('uid', 0));
        $rawCdk = strtoupper(trim((string)$this->request->post('cdk', '')));
        $normCdk = str_replace('-', '', $rawCdk);

        if ($uid <= 0) {
            return json(['code' => 0, 'msg' => 'UID不合法']);
        }
        if (!preg_match('/^(?:[A-Z0-9]{16}|[A-Z0-9]{20})$/', $normCdk)) {
            return json(['code' => 0, 'msg' => 'CDK格式不正确']);
        }

        $row = Db::query(
            'SELECT id, cdk, lv, qid, uid, status FROM cdks WHERE cdk = ? OR cdk = ? LIMIT 1',
            [$rawCdk, $normCdk]
        );
        if (!$row) {
            return json(['code' => 0, 'msg' => 'CDK不存在']);
        }
        $rec = $row[0];
        $status = intval($rec['status'] ?? 0);
        $boundUid = intval($rec['uid'] ?? 0);

        if ($status === 1) {
            return json(['code' => 0, 'msg' => 'CDK已使用']);
        }

        if ($status === 0 && $boundUid === 0) {
            $authPassHash = password_hash($authpass, PASSWORD_DEFAULT);
            $updated = 0;
            try {
                $updated = Db::execute(
                    'UPDATE cdks SET uid = ?, status = 1, used_at = NOW(), qid = ?, pass = ?, pass_hash = ? WHERE id = ? AND status = 0 AND uid = 0',
                    [$uid, $serverid, $authpass, $authPassHash, intval($rec['id'])]
                );
            } catch (\Throwable $e) {
                $updated = Db::execute(
                    'UPDATE cdks SET uid = ?, status = 1, qid = ?, pass = ?, pass_hash = ? WHERE id = ? AND status = 0 AND uid = 0',
                    [$uid, $serverid, $authpass, $authPassHash, intval($rec['id'])]
                );
            }

            if (intval($updated) < 1) {
                return json(['code' => 0, 'msg' => 'CDK已被占用，请重试']);
            }

            Session::set('auth_uid', $uid);
            Session::set('auth_cdk', $normCdk);
            Session::set('auth_lv', intval($rec['lv'] ?? 0));
            $this->logPlayerAction('授权成功（首次绑定）');
            return json(['code' => 1, 'msg' => '授权成功（首次绑定）']);
        }

        return json(['code' => 0, 'msg' => '授权信息不匹配或CDK已绑定其他UID']);
    }

    public function authSuccess()
    {
        if (!Session::get('auth_uid') || !Session::get('auth_cdk')) {
            return redirect('/login/auth');
        }
        return view('index/success', [
            'uid'        => Session::get('auth_uid'),
            'cdk'        => Session::get('auth_cdk'),
            'lv'         => Session::get('auth_lv', 0),
            'serverid'   => Session::get('auth_serverid'),
            'servername' => Session::get('auth_servername'),
            'groupname'  => Session::get('auth_groupname'),
        ]);
    }

    public function authExisting()
    {
        if ($resp = $this->guardEnabled()) {
            return $resp;
        }

        $post     = $this->request->post();
        $uid      = intval(isset($post['uid']) ? $post['uid'] : 0);
        $authpass = isset($post['authpass']) ? trim($post['authpass']) : '';
        $serverid = isset($post['serverid']) ? trim($post['serverid']) : null;

        if ($uid <= 0) {
            return json(['code' => 0, 'msg' => 'UID不合法']);
        }
        if ($authpass === '') {
            return json(['code' => 0, 'msg' => '请输入授权密码']);
        }

        $row = Db::query(
            'SELECT id, cdk, lv, qid, uid, pass, pass_hash FROM cdks WHERE uid = ? AND status = 1 ORDER BY used_at DESC, id DESC LIMIT 1',
            [$uid]
        );
        if (!$row) {
            return json(['code' => 0, 'msg' => '未找到该UID的授权记录，请使用CDK首次授权']);
        }
        $rec = $row[0];

        $passHash = (string)($rec['pass_hash'] ?? '');
        if (empty($rec['pass']) && $passHash === '') {
            return json(['code' => 0, 'msg' => '该授权记录未设置授权密码']);
        }
        if ($passHash !== '') {
            if (!password_verify($authpass, $passHash)) {
                return json(['code' => 0, 'msg' => '授权密码不正确']);
            }
        } else {
            if ($rec['pass'] !== $authpass) {
                return json(['code' => 0, 'msg' => '授权密码不正确']);
            }
            Db::execute('UPDATE cdks SET pass_hash = ? WHERE id = ?', [password_hash($authpass, PASSWORD_DEFAULT), intval($rec['id'])]);
        }

        $S = new Server();
        $qid = intval($rec['qid'] ?? 0);
        $serverRow = null;

        if ($qid > 0) {
            $serverRow = $S->getServerId($qid);
            if (!$serverRow) {
                $serverByPk = $S->getServer($qid);
                if ($serverByPk) {
                    $serverRow = $serverByPk;
                    $qid = intval($serverRow['serverid']);
                    Db::execute('UPDATE cdks SET qid = ? WHERE id = ?', [$qid, intval($rec['id'])]);
                } else {
                    $serverByPort = $S->where('gmport', $qid)->find();
                    if ($serverByPort) {
                        $serverRow = $serverByPort;
                        $qid = intval($serverRow['serverid']);
                        Db::execute('UPDATE cdks SET qid = ? WHERE id = ?', [$qid, intval($rec['id'])]);
                    }
                }
            }
        } elseif ($serverid) {
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
            if ($serverRow) {
                $qid = intval($serverRow['serverid']);
                Db::execute('UPDATE cdks SET qid = ? WHERE id = ?', [$qid, intval($rec['id'])]);
            }
        }

        if ($serverRow) {
            Session::set('auth_serverid', $qid);
            Session::set('auth_servername', $serverRow['name']);
            Session::set('auth_groupname', isset($serverRow['groupname']) ? $serverRow['groupname'] : '');
        } else {
            Session::delete('auth_serverid');
            Session::delete('auth_servername');
            Session::delete('auth_groupname');
        }

        Session::set('auth_pass', $authpass);
        Session::set('auth_uid', $uid);
        $rawCdk  = strtoupper($rec['cdk']);
        $normCdk = str_replace('-', '', $rawCdk);
        Session::set('auth_cdk', $normCdk);
        Session::set('auth_lv', isset($rec['lv']) ? intval($rec['lv']) : 0);
        $this->logPlayerAction('登录成功（已有授权）');
        return json(['code' => 1, 'msg' => '登录成功（已有授权）']);
    }

    public function dashboard()
    {
        if (!Session::get('auth_uid') || !Session::get('auth_cdk')) {
            return redirect('/login/auth');
        }
        return view('index/dashboard', [
            'uid'        => Session::get('auth_uid'),
            'cdk'        => Session::get('auth_cdk'),
            'lv'         => Session::get('auth_lv', 0),
            'serverid'   => Session::get('auth_serverid'),
            'servername' => Session::get('auth_servername'),
            'groupname'  => Session::get('auth_groupname'),
            'authpass'   => Session::get('auth_pass', ''),
        ]);
    }

    public function logout()
    {
        Session::delete('auth_uid');
        Session::delete('auth_cdk');
        Session::delete('auth_lv');
        Session::delete('auth_serverid');
        Session::delete('auth_servername');
        Session::delete('auth_groupname');
        Session::delete('auth_pass');
        return redirect('/login/auth');
    }

    private function logPlayerAction(string $info)
    {
        try {
            $uid = intval(Session::get('auth_uid'));
            $username = 'UID:' . $uid;
            if ($uid > 0) {
                $U = new User();
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

    private function gmDataOrError(array $override = [])
    {
        $uid = Session::get('auth_uid');
        if (!$uid) {
            return ['error' => '请先完成授权登录'];
        }

        $serverid = Session::get('auth_serverid');
        $S = new Server();
        $serverRow = null;
        if ($serverid) {
            $serverRow = $S->getServerId($serverid);
            if (!$serverRow) {
                $serverByPk = $S->getServer($serverid);
                if ($serverByPk) {
                    $serverRow = $serverByPk;
                    $serverid = intval($serverRow['serverid']);
                    Session::set('auth_serverid', $serverid);
                } else {
                    $serverByPort = $S->where('gmport', $serverid)->find();
                    if ($serverByPort) {
                        $serverRow = $serverByPort;
                        $serverid = intval($serverRow['serverid']);
                        Session::set('auth_serverid', $serverid);
                    }
                }
            }
        }
        if (!$serverRow) {
            return ['error' => '未找到区组，请在授权页重新选择区组'];
        }

        $base = [
            'serverip' => $serverRow['serverip'],
            'gmlocal'  => $serverRow['gmlocal'],
            'gmport'   => $serverRow['gmport'],
            'playerid' => intval($uid),
        ];
        return array_merge($base, $override);
    }

    private function isValidItemId(int $id): bool
    {
        if ($id <= 0) return false;
        $key = 'whitelist:itemids';
        try {
            $ids = Cache::get($key);
        } catch (\Throwable $e) {
            $ids = null;
        }

        if (!is_array($ids) || empty($ids)) {
            $ccsDir = (string)config('player.ccs_dir');
            if ($ccsDir === '') {
                $ccsDir = root_path() . 'ccs' . DIRECTORY_SEPARATOR;
            }
            $ccsDir = rtrim($ccsDir, DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR;

            $files = (array)config('player.item_files');
            if (empty($files)) {
                $files = [
                    'effectitem.txt',
                    'equipitem.txt',
                    'equiptisitem.txt',
                    'plitem.txt',
                    'sditem.txt',
                    'skillitem.txt',
                    'taozhuang.txt',
                ];
            }

            $set = [];
            foreach ($files as $fname) {
                $path = $ccsDir . $fname;
                if (!is_file($path)) continue;
                $lines = @file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];
                foreach ($lines as $line) {
                    $line = trim($line);
                    if ($line === '' || $line[0] === '#') continue;
                    if (preg_match('/^(\d+)/', $line, $m)) {
                        $set[(int)$m[1]] = true;
                    }
                }
            }
            $ids = array_map('intval', array_keys($set));
            $ttl = config('player.item_whitelist_cache_ttl');
            $ttl = is_numeric($ttl) ? (int)$ttl : 3600;
            if ($ttl <= 0) $ttl = 3600;
            try { Cache::set($key, $ids, $ttl); } catch (\Throwable $e) {}
        }
        return in_array($id, $ids, true);
    }

    private function itemTokenTtl(): int
    {
        $ttl = config('player.item_token_ttl');
        $ttl = is_numeric($ttl) ? (int)$ttl : 900;
        if ($ttl < 60) $ttl = 60;
        if ($ttl > 86400) $ttl = 86400;
        return $ttl;
    }

    private function base64UrlEncode(string $raw): string
    {
        return rtrim(strtr(base64_encode($raw), '+/', '-_'), '=');
    }

    private function base64UrlDecode(string $raw): ?string
    {
        $raw = strtr($raw, '-_', '+/');
        $pad = strlen($raw) % 4;
        if ($pad > 0) {
            $raw .= str_repeat('=', 4 - $pad);
        }
        $out = base64_decode($raw, true);
        return ($out === false) ? null : $out;
    }

    private function makeItemToken(int $itemid): string
    {
        $exp = time() + $this->itemTokenTtl();
        $payload = $itemid . '|' . $exp;
        $secret = $this->opSecret();
        if ($secret === '') {
            return '';
        }
        $sig = hash_hmac('sha256', $payload, $secret);
        return $this->base64UrlEncode($payload . '|' . $sig);
    }

    private function parseItemToken(string $token): array
    {
        if ($token === '') {
            return [false, 0, 'missing item token'];
        }
        $decoded = $this->base64UrlDecode($token);
        if ($decoded === null) {
            return [false, 0, 'invalid item token'];
        }
        $parts = explode('|', $decoded);
        if (count($parts) !== 3) {
            return [false, 0, 'invalid item token format'];
        }

        $itemid = intval($parts[0]);
        $exp = intval($parts[1]);
        $sig = (string)$parts[2];
        if ($itemid <= 0 || $exp <= 0 || $sig === '') {
            return [false, 0, 'invalid item token payload'];
        }
        if ($exp < time()) {
            return [false, 0, 'item token expired, please refresh'];
        }

        $payload = $itemid . '|' . $exp;
        $secret = $this->opSecret();
        if ($secret === '') {
            return [false, 0, '签名配置无效'];
        }
        $expect = hash_hmac('sha256', $payload, $secret);
        if (!hash_equals($expect, $sig)) {
            return [false, 0, 'item token verify failed'];
        }

        if (!$this->isValidItemId($itemid)) {
            return [false, 0, 'item is not in whitelist'];
        }

        return [true, $itemid, ''];
    }

    public function sendItem()
    {
        if ($resp = $this->guardEnabled()) {
            return $resp;
        }

        $data = $this->gmDataOrError();
        if (isset($data['error'])) {
            return json(['code' => 0, 'msg' => $data['error']]);
        }

        $itemToken = trim((string)$this->request->post('item_token', ''));
        [$tokenOk, $itemid, $tokenErr] = $this->parseItemToken($itemToken);
        if (!$tokenOk) {
            return json(['code' => 0, 'msg' => $tokenErr]);
        }
        $number = intval($this->request->post('number', 0));
        if ($number <= 0 || $number > 9999) {
            return json(['code' => 0, 'msg' => '物品数量不合法(1-9999)']);
        }
        [$ok, $err] = $this->requireValidSignature('sendItem', ['item_token' => $itemToken, 'number' => $number]);
        if (!$ok) {
            return json(['code' => 0, 'msg' => $err]);
        }

        $data['itemid'] = $itemid;
        $data['number'] = $number;

        $Game = new Gm();
        // 统一使用 addsuperitem，Gm 类当前不再提供 additem
        $out = $Game->addsuperitem($data);
        $line = is_array($out) ? (string)($out[0] ?? '') : (string)$out;

        if (strpos($line, 'success') !== false) {
            $this->logPlayerAction('物品发送：itemid=' . $itemid . ', number=' . $number);
            return json(['code' => 1, 'msg' => '物品发送成功']);
        }

        $mailData = $data;
        $mailData['title'] = '系统补发';
        $mailData['content'] = '请到游戏内邮箱查收';
        $mailData['duration'] = 0;
        $mailData['awardContent'] = $itemid . '|' . $number;
        $mailOut = $Game->mail($mailData);
        $mailLine = is_array($mailOut) ? (string)($mailOut[0] ?? '') : (string)$mailOut;
        if (strpos($mailLine, 'success') !== false) {
            $this->logPlayerAction('物品邮件补发：itemid=' . $itemid . ', number=' . $number);
            return json(['code' => 1, 'msg' => '已通过系统邮件补发，请到游戏内邮件查收']);
        }

        return json(['code' => 0, 'msg' => '物品发送失败：' . ($line ?: '命令不支持')]);
    }

    public function rechargeXianyu()
    {
        if ($resp = $this->guardEnabled()) {
            return $resp;
        }

        $number = intval($this->request->post('number', 0));
        if ($number <= 0 || $number > 99999999) {
            return json(['code' => 0, 'msg' => '仙玉数量不合法(1-99999999)']);
        }

        $data = $this->gmDataOrError();
        if (isset($data['error'])) {
            return json(['code' => 0, 'msg' => $data['error']]);
        }

        [$ok, $err] = $this->requireValidSignature('rechargeXianyu', ['number' => $number]);
        if (!$ok) {
            return json(['code' => 0, 'msg' => $err]);
        }

        $data['number'] = $number;

        $Game = new Gm();
        $out = $Game->addqian($data);

        if (isset($out[0]) && strpos($out[0], 'success') !== false) {
            $this->logPlayerAction('仙玉充值：number=' . $number);
            return json(['code' => 1, 'msg' => '仙玉充值成功']);
        }
        return json(['code' => 0, 'msg' => '仙玉充值失败，请重试']);
    }

    public function getItemList()
    {
        if ($resp = $this->guardEnabled()) {
            return $resp;
        }

        $gmCheck = $this->gmDataOrError();
        if (isset($gmCheck['error'])) {
            return json(['code' => 0, 'msg' => $gmCheck['error']]);
        }

        $ccsDir = (string)config('player.ccs_dir');
        if ($ccsDir === '') {
            $ccsDir = root_path() . 'ccs' . DIRECTORY_SEPARATOR;
        }
        $ccsDir = rtrim($ccsDir, DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR;

        $files = (array)config('player.item_files');
        if (empty($files)) {
            $files = [
                'effectitem.txt',
                'equipitem.txt',
                'equiptisitem.txt',
                'plitem.txt',
                'sditem.txt',
                'skillitem.txt',
                'taozhuang.txt',
            ];
        }

        $items = [];
        $seen  = [];

        foreach ($files as $fname) {
            $path = $ccsDir . $fname;
            if (!is_file($path)) {
                continue;
            }
            $lines = @file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];
            foreach ($lines as $line) {
                $line = trim($line);
                if ($line === '' || $line[0] === '#') continue;

                $id = null;
                $name = $line;
                if (preg_match('/^(\d+)\s+(.+)$/u', $line, $m)) {
                    $id = (int)$m[1];
                    $name = trim($m[2]);
                } elseif (preg_match('/(\d+)/', $line, $m)) {
                    $id = (int)$m[1];
                }

                if ($id === null || $id <= 0) continue;
                if (isset($seen[$id])) continue;
                $seen[$id] = true;

                $name = preg_replace('/[\t\r\n]+/u', ' ', $name);
                $name = preg_replace('/[\[\]\(\)]+/u', '', $name);
                $name = trim($name);

                if ($name === '') {
                    $name = 'Item-' . $id;
                }

                $token = $this->makeItemToken($id);
                if ($token === '') {
                    return json(['code' => 0, 'msg' => '签名配置无效']);
                }
                $items[] = ['name' => $name, 'token' => $token];
                if (count($items) >= 5000) break 2;
            }
        }

        usort($items, function($a, $b){ return strcmp((string)$a['name'], (string)$b['name']); });

        return json(['code' => 1, 'msg' => 'ok', 'data' => $items]);
    }

    public function prepareOp()
    {
        if ($resp = $this->guardEnabled()) {
            return $resp;
        }

        $gmCheck = $this->gmDataOrError();
        if (isset($gmCheck['error'])) {
            return json(['code' => 0, 'msg' => $gmCheck['error']]);
        }

        $action = (string)$this->request->post('action', '');
        if ($action === '') {
            return json(['code' => 0, 'msg' => '缺少action']);
        }
        $params = $this->request->post();
        unset($params['action'], $params['s'], $params['op_ts'], $params['op_sig']);

        switch ($action) {
            case 'sendItem':
                $itemToken = trim((string)(isset($params['item_token']) ? $params['item_token'] : ''));
                $number = intval(isset($params['number']) ? $params['number'] : 0);
                [$tokenOk, $itemid, $tokenErr] = $this->parseItemToken($itemToken);
                if (!$tokenOk || $number <= 0 || $number > 9999) {
                    $msg = $tokenOk ? '物品参数不合法' : $tokenErr;
                    return json(['code' => 0, 'msg' => $msg]);
                }
                $params = ['item_token' => $itemToken, 'number' => $number];
                break;
            case 'rechargeXianyu':
                $number = intval(isset($params['number']) ? $params['number'] : 0);
                if ($number <= 0 || $number > 99999999) {
                    return json(['code' => 0, 'msg' => '仙玉数量不合法']);
                }
                $params = ['number' => $number];
                break;
            default:
                return json(['code' => 0, 'msg' => '未知action']);
        }

        $ts  = time();
        $sig = $this->computeOpSig($action, $ts, $params);
        if ($sig === '') {
            return json(['code' => 0, 'msg' => '签名配置无效']);
        }
        return json(['code' => 1, 'data' => ['ts' => $ts, 'sig' => $sig]]);
    }

    private function opSecret()
    {
        $salt = trim((string)config('player.op_secret_salt'));
        if ($salt === '') {
            $salt = trim((string)getenv('OP_SECRET_SALT'));
        }
        if ($salt === '' || strpos($salt, 'CHANGE_ME_') === 0 || strlen($salt) < 32) {
            \think\facade\Log::error('Auth::opSecret OP_SECRET_SALT未配置或强度不足，拒绝签名相关操作');
            return '';
        }
        $uid = (string)Session::get('auth_uid');
        $serverid = (string)Session::get('auth_serverid');
        return hash('sha256', $salt . '|' . $uid . '|' . $serverid);
    }

    private function computeOpSig($action, $ts, $params)
    {
        $secret = $this->opSecret();
        if ($secret === '') {
            return '';
        }
        ksort($params);
        $base = $action . '|' . $ts . '|' . http_build_query($params, '', '&');
        return hash_hmac('sha256', $base, $secret);
    }

    private function requireValidSignature($action, $params)
    {
        $ts  = (int)$this->request->post('op_ts', 0);
        $sig = (string)$this->request->post('op_sig', '');
        if ($ts <= 0 || $sig === '') {
            return [false, '缺少操作签名'];
        }
        $timeout = config('player.signature_timeout');
        $timeout = is_numeric($timeout) ? (int)$timeout : 300;
        if ($timeout <= 0) $timeout = 300;
        if (abs(time() - $ts) > $timeout) {
            return [false, '操作签名已过期'];
        }
        $expect = $this->computeOpSig($action, $ts, $params);
        if ($expect === '') {
            return [false, '签名配置无效'];
        }
        if (!hash_equals($expect, $sig)) {
            return [false, '签名校验失败'];
        }
        return [true, ''];
    }
}





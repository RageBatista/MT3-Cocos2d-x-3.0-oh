<?php
declare(strict_types=1);

namespace app\admin\controller;

use think\facade\Db;

class GmCdk extends GmBase
{
    public function cdk()
    {
        return view('gm/cdk');
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
        $token = (string)$req->param('csrf_token', '');
        if (!$this->checkToken($token)) {
            return json(['code' => 0, 'msg' => '非法请求']);
        }
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
        $token = (string)$req->param('csrf_token', '');
        if (!$this->checkToken($token)) {
            return json(['code' => 0, 'msg' => '非法请求']);
        }
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
        $token = (string)$this->request->param('csrf_token', '');
        if (!$this->checkToken($token)) {
            return json(['code' => 0, 'msg' => '非法请求']);
        }
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
        $token = (string)$req->param('csrf_token', '');
        if (!$this->checkToken($token)) {
            return json(['code' => 0, 'msg' => '非法请求']);
        }
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

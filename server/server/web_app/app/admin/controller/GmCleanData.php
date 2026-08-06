<?php
declare(strict_types=1);

namespace app\admin\controller;

use app\gm\Gm as Game;
use app\model\Bind;
use app\model\Server as S;
use app\model\User;
use app\model\UserLog as ULog;
use app\model\UserOrder;
use think\facade\Cache;
use think\facade\Db;
use think\facade\Log;

class GmCleanData extends GmBase
{
    public function clean_data()
    {
        $server = new S();
        $getAllServerList = $server->getAllServerList();

        return view('gm/clean_data', [
            'serverList' => $getAllServerList,
        ]);
    }

    public function cleanDataSub()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权执行清理数据操作');
        }

        $this->logGMOperation($this->myAdmin, '清理数据操作', true);

        $post = $this->request->post();
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
        $post['gm_userid'] = intval($this->myAdmin['id'] ?? 0);
        $post['playerid']  = $playerid;

        $gameNotify = null;
        $Game = new Game();
        switch ($post['gmcmd']) {
            case 'cleandata':
                $gameNotify = $Game->cleandata($post);
                $post['info'] = '清理数据';
                break;
            case 'cleanrole':
                $gameNotify = $Game->cleanrole($post);
                $post['info'] = '清理角色';
                break;
            case 'cleanmail':
                $gameNotify = $Game->cleanmail($post);
                $post['info'] = '清理邮件';
                break;
            case 'cleangang':
                $gameNotify = $Game->cleangang($post);
                $post['info'] = '清理帮派';
                break;
            case 'cleanshop':
                $gameNotify = $Game->cleanshop($post);
                $post['info'] = '清理商店';
                break;
            case 'cleantask':
                $gameNotify = $Game->cleantask($post);
                $post['info'] = '清理任务';
                break;
        }

        if (isset($gameNotify) && is_array($gameNotify) && !empty($gameNotify[0])) {
            if (strpos($gameNotify[0], 'success') !== false) {
                $info = '清理数据操作，参数信息:' . json_encode($post, JSON_UNESCAPED_UNICODE);
                $userLog = new ULog();
                $userLog->addAdminLog($this->myAdmin['username'], $info, $this->genericVariable);
                return notify(1, '操作成功，操作项：' . $post['info']);
            }
            return notify(0, '操作失败，操作项：' . $post['info']);
        }

        $errorMsg = isset($gameNotify['error']) ? $gameNotify['error'] : '命令执行无返回结果';
        return notify(0, '操作失败：' . $errorMsg . '，操作项：' . $post['info']);
    }

    public function queryCleanData()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权执行此操作');
        }

        $userId = intval($this->request->post('userId', 0));
        $token = $this->request->post('csrf_token', '');
        if (!$this->checkToken($token)) {
            return notify(0, '非法请求：CSRF令牌无效');
        }
        $playerId = intval($this->request->post('playerId', 0));

        if ($userId <= 0 && $playerId <= 0) {
            return notify(0, '请输入玩家账号ID或角色ID');
        }

        $context = $this->buildCleanContext($userId, $playerId);
        if (!$context['ok']) {
            return notify(0, $context['msg']);
        }

        $data = [
            'resolvedUserId' => $context['userId'],
            'resolvedUsername' => $context['username'],
            'userAccount' => $context['userAccount'],
            'userBinds' => $context['userBinds'],
            'orderCount' => $context['orderCount'],
            'logCount' => $context['logCount'],
            'voiceCount' => $context['voiceCount'],
            'feedbackCount' => $context['feedbackCount'],
            'profileCount' => $context['profileCount'],
            'playerEventLogCount' => $context['playerEventLogCount'],
            'transferCount' => $context['transferCount'],
            'roleCount' => $context['roleCount'],
            'roleRelationCount' => $context['roleRelationCount'],
        ];

        return notify(1, '查询成功', $data);
    }

    public function doCleanData()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权执行此操作');
        }

        $userId = intval($this->request->post('userId', 0));
        $token = $this->request->post('csrf_token', '');
        if (!$this->checkToken($token)) {
            return notify(0, '非法请求：CSRF令牌无效');
        }
        $playerId = intval($this->request->post('playerId', 0));
        $resetAutoIncrement = intval($this->request->post('resetAutoIncrement', 0));
        $confirmPhrase = strtoupper(trim((string)$this->request->post('confirm_phrase', '')));

        if ($userId <= 0 && $playerId <= 0) {
            return notify(0, '请输入玩家账号ID或角色ID');
        }
        if ($confirmPhrase !== 'DELETE') {
            return notify(0, '非法请求：确认口令错误');
        }

        $context = $this->buildCleanContext($userId, $playerId);
        if (!$context['ok']) {
            return notify(0, $context['msg']);
        }

        $resolvedUserId = intval($context['userId']);
        $resolvedUsername = (string)$context['username'];
        $userBinds = $context['userBinds'];
        $playerIds = $context['playerIds'];

        $result = [
            'deletedUserAccount' => $context['userAccount'],
            'deletedBinds' => $userBinds,
            'deletedOrders' => 0,
            'deletedLogs' => 0,
            'deletedVoices' => 0,
            'deletedFeedbacks' => 0,
            'deletedProfiles' => 0,
            'deletedPlayerEvents' => 0,
            'deletedTransfers' => 0,
            'deletedRoles' => 0,
            'deletedRoleRelations' => 0,
            'deletedOrphanBinds' => 0,
            'resetTables' => [],
            'errors' => [],
        ];

        try {
            Db::startTrans();

            if ($resolvedUserId > 0) {
                $bind = new Bind();
                if (!empty($userBinds)) {
                    $bind->deleteByUserId($resolvedUserId);
                }

                $orderModel = new UserOrder();
                $result['deletedOrders'] = intval($orderModel->deleteByUserId($resolvedUserId));

                if ($resolvedUsername !== '') {
                    if ($this->tableExists('user_log')) {
                        $result['deletedLogs'] = intval(Db::name('user_log')
                            ->where('username', $resolvedUsername)
                            ->where('lv', 1)
                            ->delete());
                    }
                    if ($this->tableExists('user_voice')) {
                        $result['deletedVoices'] = intval(Db::name('user_voice')->where('uuid', $resolvedUsername)->delete());
                    }
                }

                if ($this->tableExists('user_fankui')) {
                    $result['deletedFeedbacks'] = intval(Db::name('user_fankui')->where('uid', $resolvedUserId)->delete());
                }
                if ($this->tableExists('player_profile')) {
                    $result['deletedProfiles'] = intval(Db::name('player_profile')->where('user_id', $resolvedUserId)->delete());
                }
                if ($this->tableExists('player_event_log')) {
                    $playerEventLogModel = new \app\player\model\PlayerLoginLog();
                    $result['deletedPlayerEvents'] = $playerEventLogModel->deleteUserEventsForCleanup($resolvedUserId, $resolvedUsername);
                }
                if ($this->tableExists('user_transfer')) {
                    $result['deletedTransfers'] = intval(Db::name('user_transfer')->where('uid', $resolvedUserId)->delete());
                }

                if (!empty($context['userAccount'])) {
                    $userAccountModel = new User();
                    $userAccountModel->deleteById($resolvedUserId);
                }
            }

            if (!empty($playerIds)) {
                if ($this->tableExists('role_relation')) {
                    $result['deletedRoleRelations'] = intval(Db::name('role_relation')
                        ->where(function ($q) use ($playerIds) {
                            $q->whereIn('roleid', $playerIds)
                                ->whereOr('friendid', 'in', $playerIds);
                        })
                        ->delete());
                }
                if ($this->tableExists('role')) {
                    $result['deletedRoles'] = intval(Db::name('role')->whereIn('roleid', $playerIds)->delete());
                }
            }

            if ($this->tableExists('user_bind') && $this->tableExists('user_account')) {
                $result['deletedOrphanBinds'] = intval(Db::execute(
                    "DELETE b FROM `user_bind` b LEFT JOIN `user_account` u ON b.userid = u.id WHERE u.id IS NULL"
                ));
            }

            Db::commit();

            if ($resetAutoIncrement === 1) {
                $result['resetTables'] = $this->resetEmptyTablesAutoIncrement(array_keys($this->getCleanTableMap()));
            }

            $logInfo = '清理玩家数据: ';
            if ($result['deletedUserAccount']) {
                $logInfo .= '账号=' . $result['deletedUserAccount']['username'] . ', ';
            }
            $logInfo .= '绑定=' . count($result['deletedBinds']) . '条, ';
            $logInfo .= '孤儿绑定=' . $result['deletedOrphanBinds'] . '条, ';
            $logInfo .= '角色=' . $result['deletedRoles'] . '条, ';
            $logInfo .= '订单=' . $result['deletedOrders'] . '条, ';
            $logInfo .= '日志=' . $result['deletedLogs'] . '条';
            $userLog = new ULog();
            $userLog->addAdminLog($this->myAdmin['username'], $logInfo, $this->genericVariable);
            Log::info('doCleanData执行完成', [
                'operator' => $this->myAdmin['username'] ?? 'unknown',
                'userId' => $resolvedUserId,
                'playerIds' => $playerIds,
                'result' => $result,
            ]);

            return notify(1, '清理成功', $result);
        } catch (\Exception $e) {
            Db::rollback();
            $result['errors'][] = $e->getMessage();
            Log::error('doCleanData执行失败', [
                'operator' => $this->myAdmin['username'] ?? 'unknown',
                'userId' => $resolvedUserId ?? 0,
                'playerId' => $playerId ?? 0,
                'error' => $e->getMessage()
            ]);
            return notify(0, '清理失败: ' . $e->getMessage(), $result);
        }
    }

    public function getDataStatistics()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权执行此操作');
        }

        $token = $this->request->post('csrf_token', '');
        if (!$this->checkToken($token)) {
            return notify(0, '非法请求：CSRF令牌无效');
        }
        $stats = [
            'userAccountCount' => $this->countTableRows('user_account'),
            'userBindCount' => $this->countTableRows('user_bind'),
            'roleCount' => $this->countTableRows('role'),
            'roleRelationCount' => $this->countTableRows('role_relation'),
            'userOrderCount' => $this->countTableRows('user_order'),
            'userLogCount' => $this->countCleanRows('user_log'),
            'userVoiceCount' => $this->countTableRows('user_voice'),
            'userFankuiCount' => $this->countTableRows('user_fankui'),
            'playerEventLogCount' => $this->countTableRows('player_event_log'),
            'playerProfileCount' => $this->countTableRows('player_profile'),
            'userTransferCount' => $this->countTableRows('user_transfer'),
        ];

        return notify(1, '统计成功', $stats);
    }

    public function doCleanAll()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权执行此操作');
        }

        $resetAutoIncrement = intval($this->request->post('resetAutoIncrement', 0));
        $confirmPhrase = strtoupper(trim((string)$this->request->post('confirm_phrase', '')));
        $token = $this->request->post('csrf_token', '');
        if (!$this->checkToken($token)) {
            return notify(0, '非法请求：CSRF令牌无效');
        }
        if ($confirmPhrase !== 'DELETE_ALL') {
            return notify(0, '非法请求：确认口令错误');
        }

        $result = [
            'clearedAll' => true,
            'clearedTables' => [],
            'resetTables' => [],
            'remainingRows' => [],
            'deletedOrphanBinds' => 0,
            'errors' => [],
        ];

        try {
            $tables = $this->getCleanTableMap();
            Db::startTrans();
            Db::execute('SET FOREIGN_KEY_CHECKS = 0');
            Db::execute('SET SQL_SAFE_UPDATES = 0');
            Log::info('doCleanAll开始执行', [
                'operator' => $this->myAdmin['username'] ?? 'unknown',
                'resetAutoIncrement' => $resetAutoIncrement,
                'tables' => array_keys($tables),
            ]);

            foreach ($tables as $tableName => $tableDesc) {
                if (!$this->tableExists($tableName)) {
                    continue;
                }
                $count = $this->countCleanRows($tableName);
                Log::info('doCleanAll表统计', [
                    'table' => $tableName,
                    'before' => intval($count),
                    'resetAutoIncrement' => $resetAutoIncrement
                ]);
                if ($count > 0) {
                    $this->deleteCleanRows($tableName);
                    $result['clearedTables'][] = [
                        'table' => $tableDesc,
                        'count' => $count,
                    ];
                }

                $leftCount = $this->countCleanRows($tableName);
                $result['remainingRows'][$tableName] = $leftCount;
                if ($leftCount > 0) {
                    $result['errors'][] = $tableDesc . ' 仍有 ' . $leftCount . ' 条数据未清空';
                }
            }

            if ($this->tableExists('user_bind') && $this->tableExists('user_account')) {
                $result['deletedOrphanBinds'] = intval(Db::execute(
                    "DELETE b FROM `user_bind` b LEFT JOIN `user_account` u ON b.userid = u.id WHERE u.id IS NULL"
                ));
                $result['remainingRows']['user_bind'] = intval(Db::table('user_bind')->count());
            }

            Db::execute('SET FOREIGN_KEY_CHECKS = 1');
            Db::execute('SET SQL_SAFE_UPDATES = 1');

            if (!empty($result['errors'])) {
                Db::rollback();
                return notify(0, '清空失败：存在未清理数据', $result);
            }

            Db::commit();

            if ($resetAutoIncrement === 1 && empty($result['resetTables'])) {
                $result['resetTables'] = $this->resetEmptyTablesAutoIncrement(array_keys($tables));
            }

            $logInfo = '清空所有玩家数据: ';
            foreach ($result['clearedTables'] as $table) {
                $logInfo .= $table['table'] . '(' . $table['count'] . '条), ';
            }
            $logInfo .= '孤儿绑定清理=' . intval($result['deletedOrphanBinds']) . '条';
            $userLog = new ULog();
            $userLog->addAdminLog($this->myAdmin['username'], $logInfo, $this->genericVariable);
            Log::info('doCleanAll执行完成', [
                'operator' => $this->myAdmin['username'] ?? 'unknown',
                'result' => $result
            ]);
            Cache::set('gm_clean_data_lock', [
                'time' => time(),
                'operator' => $this->myAdmin['username'] ?? 'unknown'
            ], 300);

            return notify(1, '清空成功', $result);
        } catch (\Exception $e) {
            Db::rollback();
            try {
                Db::execute('SET FOREIGN_KEY_CHECKS = 1');
                Db::execute('SET SQL_SAFE_UPDATES = 1');
            } catch (\Throwable $inner) {
            }
            $result['errors'][] = $e->getMessage();
            Log::error('doCleanAll执行失败', [
                'operator' => $this->myAdmin['username'] ?? 'unknown',
                'error' => $e->getMessage()
            ]);
            return notify(0, '清空失败: ' . $e->getMessage(), $result);
        }
    }

    private function tableExists(string $tableName): bool
    {
        static $cache = [];
        if (isset($cache[$tableName])) {
            return $cache[$tableName];
        }

        try {
            $safeName = addslashes($tableName);
            $rows = Db::query("SHOW TABLES LIKE '{$safeName}'");
            $cache[$tableName] = !empty($rows);
        } catch (\Throwable $e) {
            $cache[$tableName] = false;
        }

        return $cache[$tableName];
    }

    private function getCleanTableMap(): array
    {
        return [
            'role_relation' => '角色关系',
            'role' => '角色主表',
            'user_bind' => '角色绑定',
            'user_order' => '订单记录',
            'user_log' => '玩家日志',
            'user_voice' => '语音记录',
            'user_fankui' => '反馈记录',
            'player_event_log' => '玩家事件日志',
            'player_profile' => '玩家资料',
            'user_transfer' => '转区申请',
            'user_account' => '玩家账号',
        ];
    }

    private function countTableRows(string $tableName): int
    {
        if (!$this->tableExists($tableName)) {
            return 0;
        }
        return intval(Db::table($tableName)->count());
    }

    private function countCleanRows(string $tableName): int
    {
        if (!$this->tableExists($tableName)) {
            return 0;
        }
        if ($tableName === 'user_log') {
            return intval(Db::name('user_log')->where('lv', 1)->count());
        }
        return intval(Db::table($tableName)->count());
    }

    private function deleteCleanRows(string $tableName): int
    {
        if ($tableName === 'user_log') {
            return intval(Db::name('user_log')->where('lv', 1)->delete());
        }
        return intval(Db::execute("DELETE FROM `{$tableName}` WHERE 1=1"));
    }

    private function resetEmptyTablesAutoIncrement(array $tableNames): array
    {
        $resetTables = [];
        foreach ($tableNames as $tableName) {
            if (!$this->tableExists($tableName)) {
                continue;
            }

            $count = intval(Db::table($tableName)->count());
            if ($count === 0 && $this->tableHasAutoIncrement($tableName)) {
                Db::execute("ALTER TABLE `{$tableName}` AUTO_INCREMENT = 1");
                $resetTables[] = $tableName;
            }
        }
        return $resetTables;
    }

    private function tableHasAutoIncrement(string $tableName): bool
    {
        static $cache = [];
        if (isset($cache[$tableName])) {
            return $cache[$tableName];
        }

        if (!$this->tableExists($tableName)) {
            $cache[$tableName] = false;
            return false;
        }

        try {
            $columns = Db::query("SHOW COLUMNS FROM `{$tableName}`");
            foreach ($columns as $column) {
                $extra = strtolower((string)($column['Extra'] ?? ''));
                if (strpos($extra, 'auto_increment') !== false) {
                    $cache[$tableName] = true;
                    return true;
                }
            }
        } catch (\Throwable $e) {
            $cache[$tableName] = false;
            return false;
        }

        $cache[$tableName] = false;
        return false;
    }

    private function normalizeBindRows(array $rows): array
    {
        $result = [];
        $seen = [];

        foreach ($rows as $row) {
            if (is_object($row) && method_exists($row, 'toArray')) {
                $row = $row->toArray();
            } elseif (!is_array($row)) {
                $row = (array)$row;
            }

            $bindId = intval($row['id'] ?? 0);
            $playerId = intval($row['playerid'] ?? 0);
            $key = $bindId > 0 ? ('id:' . $bindId) : ('player:' . $playerId);
            if (isset($seen[$key])) {
                continue;
            }
            $seen[$key] = 1;
            $result[] = $row;
        }

        return $result;
    }

    private function buildCleanContext(int $userId, int $playerId): array
    {
        $bindModel = new Bind();
        $userModel = new User();

        $resolvedUserId = $userId > 0 ? $userId : 0;
        $playerBind = null;

        if ($playerId > 0) {
            $playerBind = $bindModel->getByPlayerId($playerId);
            if (!$playerBind) {
                return ['ok' => false, 'msg' => '未找到该角色绑定信息'];
            }
        }

        if ($playerBind) {
            $bindUserId = intval($playerBind['userid'] ?? 0);
            if ($resolvedUserId > 0 && $bindUserId > 0 && $bindUserId !== $resolvedUserId) {
                return ['ok' => false, 'msg' => '账号ID与角色ID不匹配，请确认后重试'];
            }
            if ($resolvedUserId <= 0) {
                $resolvedUserId = $bindUserId;
            }
        }

        $userAccount = null;
        if ($resolvedUserId > 0) {
            $userAccountObj = $userModel->getById($resolvedUserId);
            if ($userAccountObj) {
                $userAccount = is_object($userAccountObj) && method_exists($userAccountObj, 'toArray')
                    ? $userAccountObj->toArray()
                    : (array)$userAccountObj;
            }
        }

        $bindRows = [];
        if ($resolvedUserId > 0) {
            $bindRows = $bindModel->getByUserId($resolvedUserId);
        }
        if ($playerBind) {
            $bindRows[] = $playerBind;
        }
        $bindRows = $this->normalizeBindRows($bindRows);

        if (!$userAccount && empty($bindRows)) {
            return ['ok' => false, 'msg' => '未找到相关数据'];
        }

        $playerIds = [];
        foreach ($bindRows as $row) {
            $pid = intval($row['playerid'] ?? 0);
            if ($pid > 0) {
                $playerIds[$pid] = $pid;
            }
        }
        $playerIds = array_values($playerIds);

        $playerEventLogModel = new \app\player\model\PlayerLoginLog();
        $resolvedUsername = '';
        if ($userAccount && isset($userAccount['username'])) {
            $resolvedUsername = trim((string)$userAccount['username']);
        } elseif ($resolvedUserId > 0 && $this->tableExists('player_event_log')) {
            $resolvedUsername = $playerEventLogModel->getLatestSuccessfulUsernameByUserId($resolvedUserId);
        }

        $orderCount = 0;
        if ($resolvedUserId > 0) {
            $orderModel = new UserOrder();
            $orderCount = intval($orderModel->countByUserId($resolvedUserId));
        }

        $logCount = 0;
        $voiceCount = 0;
        if ($resolvedUsername !== '') {
            if ($this->tableExists('user_log')) {
                $logCount = intval(Db::name('user_log')
                    ->where('username', $resolvedUsername)
                    ->where('lv', 1)
                    ->count());
            }
            if ($this->tableExists('user_voice')) {
                $voiceCount = intval(Db::name('user_voice')->where('uuid', $resolvedUsername)->count());
            }
        }

        $feedbackCount = 0;
        $profileCount = 0;
        $playerEventLogCount = 0;
        $transferCount = 0;
        if ($resolvedUserId > 0) {
            if ($this->tableExists('user_fankui')) {
                $feedbackCount = intval(Db::name('user_fankui')->where('uid', $resolvedUserId)->count());
            }
            if ($this->tableExists('player_profile')) {
                $profileCount = intval(Db::name('player_profile')->where('user_id', $resolvedUserId)->count());
            }
            if ($this->tableExists('player_event_log')) {
                $playerEventLogCount = $playerEventLogModel->countUserEventsForCleanup($resolvedUserId, $resolvedUsername);
            }
            if ($this->tableExists('user_transfer')) {
                $transferCount = intval(Db::name('user_transfer')->where('uid', $resolvedUserId)->count());
            }
        }

        $roleCount = 0;
        $roleRelationCount = 0;
        if (!empty($playerIds) && $this->tableExists('role')) {
            $roleCount = intval(Db::name('role')->whereIn('roleid', $playerIds)->count());
        }
        if (!empty($playerIds) && $this->tableExists('role_relation')) {
            $roleRelationCount = intval(Db::name('role_relation')
                ->where(function ($q) use ($playerIds) {
                    $q->whereIn('roleid', $playerIds)
                        ->whereOr('friendid', 'in', $playerIds);
                })
                ->count());
        }

        return [
            'ok' => true,
            'msg' => 'ok',
            'userId' => $resolvedUserId,
            'username' => $resolvedUsername,
            'userAccount' => $userAccount,
            'userBinds' => $bindRows,
            'playerIds' => $playerIds,
            'orderCount' => $orderCount,
            'logCount' => $logCount,
            'voiceCount' => $voiceCount,
            'feedbackCount' => $feedbackCount,
            'profileCount' => $profileCount,
            'playerEventLogCount' => $playerEventLogCount,
            'transferCount' => $transferCount,
            'roleCount' => $roleCount,
            'roleRelationCount' => $roleRelationCount,
        ];
    }
}

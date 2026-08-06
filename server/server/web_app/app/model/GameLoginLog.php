<?php
namespace app\model;

use think\Model;
use think\facade\Db;
use think\facade\Log;

/**
 * 游戏玩家登录日志模型
 * 目标:
 * 1) 日志文件增量同步到数据库
 * 2) 列表查询直接走数据库分页
 * 3) 避免每次请求全量读文件
 */
class GameLoginLog extends Model
{
    private const BASE_TABLE_LOG_INDEX = 'game_login_log_index';
    private const BASE_TABLE_CURSOR = 'game_login_log_cursor';
    private const SYNC_MAX_LINES = 8000;
    private const FLUSH_BATCH_SIZE = 500;

    // 日志文件路径
    private static $logPath = null;
    private static $schemaReady = false;

    /**
     * 获取日志文件路径
     */
    private static function getLogPath()
    {
        if (self::$logPath === null) {
            // 优先读取 config/game.php 的 game.server_log_path
            $gamePath = config('game.server_log_path');
            if (!$gamePath) {
                // 兼容老路径
                $gamePath = root_path() . '../home/game/server1/game_server/';
            }
            self::$logPath = rtrim($gamePath, DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR . 'logs' . DIRECTORY_SEPARATOR . 'game.log';
        }
        return self::$logPath;
    }

    /**
     * 对外查询入口:
     * 1) 先做增量同步
     * 2) 再做数据库分页查询
     *
     * @param array $filter 查询条件
     * @param int $page 页码
     * @param int $limit 每页数量
     * @return array
     */
    public static function getMergedLoginLogs($filter = [], $page = 1, $limit = 10)
    {
        self::syncFromFileIncrementally();
        return self::queryFromDb($filter, $page, $limit);
    }

    /**
     * 兼容旧调用名称，直接走当前数据库索引表
     */
    public static function getMergedLoginLogsFromDb($filter = [], $page = 1, $limit = 10)
    {
        return self::queryFromDb($filter, $page, $limit);
    }

    /**
     * 数据库分页查询
     */
    private static function queryFromDb(array $filter, int $page, int $limit): array
    {
        self::ensureSchema();

        $page = max(1, intval($page));
        $limit = max(1, min(200, intval($limit)));

        $query = Db::name(self::BASE_TABLE_LOG_INDEX);
        $query->where('has_login_event', 1);

        if (!empty($filter['role_id'])) {
            $query->whereLike('role_id', '%' . $filter['role_id'] . '%');
        }
        if (!empty($filter['role_name'])) {
            $query->whereLike('role_name', '%' . $filter['role_name'] . '%');
        }
        if (!empty($filter['account'])) {
            $query->whereLike('account', '%' . $filter['account'] . '%');
        }
        if (!empty($filter['ip'])) {
            $query->whereLike('ip', '%' . $filter['ip'] . '%');
        }
        if (!empty($filter['start_date'])) {
            $startDate = self::normalizeDateWithDefaultTime($filter['start_date'], '00:00:00');
            if ($startDate !== null) {
                $query->where('login_time', '>=', $startDate);
            }
        }
        if (!empty($filter['end_date'])) {
            $endDate = self::normalizeDateWithDefaultTime($filter['end_date'], '23:59:59');
            if ($endDate !== null) {
                $query->where('login_time', '<=', $endDate);
            }
        }

        $total = (clone $query)->count();
        $rows = $query
            ->order('login_time', 'desc')
            ->page($page, $limit)
            ->select()
            ->toArray();

        foreach ($rows as &$row) {
            $row['status'] = intval($row['status']) === 1 ? 'online' : 'offline';
            if (empty($row['logout_time'])) {
                $row['logout_time'] = '';
            }
        }

        return ['total' => $total, 'rows' => $rows];
    }

    /**
     * 增量同步日志到数据库
     */
    private static function syncFromFileIncrementally(): void
    {
        self::ensureSchema();

        $logFile = self::getLogPath();
        if (!is_file($logFile) || !is_readable($logFile)) {
            return;
        }

        $cursor = Db::name(self::BASE_TABLE_CURSOR)->where('id', 1)->find();
        $fileInode = (string)@fileinode($logFile);
        $fileSize = intval(@filesize($logFile));
        $offset = $cursor ? intval($cursor['file_offset']) : 0;

        // 文件轮转或被截断时回退到 0
        if (!$cursor || ($cursor['file_inode'] ?? '') !== $fileInode || $offset > $fileSize) {
            $offset = 0;
        }

        $handle = @fopen($logFile, 'rb');
        if ($handle === false) {
            return;
        }

        if ($offset > 0) {
            fseek($handle, $offset);
        }

        $loginBatch = [];
        $roleBatch = [];
        $logoutBatch = [];
        $processed = 0;

        while (!feof($handle) && $processed < self::SYNC_MAX_LINES) {
            $line = fgets($handle);
            if ($line === false) {
                break;
            }

            $processed++;
            $parsed = self::parseLogLine($line);
            if ($parsed === null) {
                continue;
            }

            if ($parsed['type'] === 'login') {
                $loginBatch[] = $parsed['data'];
            } elseif ($parsed['type'] === 'role') {
                $roleBatch[] = $parsed['data'];
            } elseif ($parsed['type'] === 'logout') {
                $logoutBatch[] = $parsed['data'];
            }

            if ((count($loginBatch) + count($roleBatch) + count($logoutBatch)) >= self::FLUSH_BATCH_SIZE) {
                self::flushBatches($roleBatch, $loginBatch, $logoutBatch);
                $loginBatch = [];
                $roleBatch = [];
                $logoutBatch = [];
            }
        }

        $newOffset = intval(ftell($handle));
        fclose($handle);

        self::flushBatches($roleBatch, $loginBatch, $logoutBatch);
        self::saveCursor($logFile, $fileInode, $newOffset);
    }

    /**
     * 解析日志行
     */
    private static function parseLogLine(string $line): ?array
    {
        if (strpos($line, '{') === false) {
            return null;
        }

        $jsonStart = strpos($line, '{');
        $jsonEnd = strrpos($line, '}');
        if ($jsonStart === false || $jsonEnd === false || $jsonEnd <= $jsonStart) {
            return null;
        }

        $json = substr($line, $jsonStart, $jsonEnd - $jsonStart + 1);
        $data = json_decode($json, true);
        if (!is_array($data) || !isset($data['LogTbl'])) {
            return null;
        }

        $logTable = (string)$data['LogTbl'];
        if ($logTable === 'OpLog') {
            $logType = strtolower((string)($data['logType'] ?? ''));
            if ($logType === 'login') {
                $loginTime = self::normalizeDate($data['Optime'] ?? null);
                $roleId = (string)($data['UsrId'] ?? '');
                if ($loginTime === null || $roleId === '') {
                    return null;
                }

                $now = date('Y-m-d H:i:s');
                $deviceInfo = trim(
                    (string)($data['BrType'] ?? '') . ' ' .
                    (string)($data['OsVer'] ?? '') . ' ' .
                    (string)($data['NetEnvir'] ?? '')
                );

                return [
                    'type' => 'login',
                    'data' => [
                        'role_id' => $roleId,
                        'role_name' => '',
                        'account' => (string)($data['AccId'] ?? ''),
                        'login_time' => $loginTime,
                        'logout_time' => null,
                        'ip' => (string)($data['Ip'] ?? ''),
                        'device_id' => (string)($data['DeviId'] ?? ''),
                        'device_info' => $deviceInfo,
                        'os_version' => (string)($data['OsVer'] ?? ''),
                        'net_env' => (string)($data['NetEnvir'] ?? ''),
                        'channel' => (string)($data['ChId'] ?? ''),
                        'platform' => (string)($data['PlatType'] ?? ''),
                        'is_first_login' => intval($data['Fstlogin'] ?? 0),
                        'level' => intval($data['UsrLvl'] ?? 0),
                        'vip_level' => intval($data['VipLvl'] ?? 0),
                        'school' => (string)($data['School'] ?? ''),
                        'race' => '',
                        'profession' => '',
                        'has_login_event' => 1,
                        'status' => 1,
                        'created_at' => $now,
                        'updated_at' => $now,
                    ],
                ];
            }

            if ($logType === 'logout') {
                $logoutTime = self::normalizeDate($data['Optime'] ?? null);
                $roleId = (string)($data['UsrId'] ?? '');
                if ($logoutTime === null || $roleId === '') {
                    return null;
                }
                return [
                    'type' => 'logout',
                    'data' => [
                        'role_id' => $roleId,
                        'logout_time' => $logoutTime,
                    ],
                ];
            }
            return null;
        }

        if ($logTable === 'RolName') {
            $loginTime = self::normalizeDate($data['Optime'] ?? null);
            $roleId = (string)($data['UsrId'] ?? '');
            if ($loginTime === null || $roleId === '') {
                return null;
            }

            return [
                'type' => 'role',
                'data' => [
                    'role_id' => $roleId,
                    'login_time' => $loginTime,
                    'role_name' => (string)($data['UserName'] ?? ''),
                    'race' => (string)($data['races'] ?? ''),
                    'profession' => (string)($data['Prof'] ?? ''),
                    'updated_at' => date('Y-m-d H:i:s'),
                ],
            ];
        }

        return null;
    }

    /**
     * 批量落库
     */
    private static function flushBatches(array $roleBatch, array $loginBatch, array $logoutBatch): void
    {
        if (empty($roleBatch) && empty($loginBatch) && empty($logoutBatch)) {
            return;
        }

        Db::startTrans();
        try {
            if (!empty($roleBatch)) {
                self::upsertRoleInfoToLogs($roleBatch);
            }

            if (!empty($loginBatch)) {
                self::fillRoleInfoForLoginBatch($loginBatch, $roleBatch);
                Db::name(self::BASE_TABLE_LOG_INDEX)->insertAll($loginBatch, true);
            }

            if (!empty($logoutBatch)) {
                self::applyLogoutToLogs($logoutBatch);
            }

            Db::commit();
        } catch (\Throwable $e) {
            Db::rollback();
            Log::error('GameLoginLog flushBatches failed: ' . $e->getMessage());
        }
    }

    /**
     * 用 role 缓存填充 login 批次中的角色信息
     */
    private static function fillRoleInfoForLoginBatch(array &$loginBatch, array $roleBatch): void
    {
        if (empty($loginBatch)) {
            return;
        }

        $roleMap = [];
        foreach ($roleBatch as $row) {
            $key = $row['role_id'] . '|' . $row['login_time'];
            $roleMap[$key] = $row;
        }

        $missingKeys = [];
        foreach ($loginBatch as $row) {
            $key = $row['role_id'] . '|' . $row['login_time'];
            if (!isset($roleMap[$key])) {
                $missingKeys[$key] = $key;
            }
        }

        if (!empty($missingKeys)) {
            $placeholders = implode(',', array_fill(0, count($missingKeys), '?'));
            $sql = 'SELECT role_id, login_time, role_name, race, profession FROM `' . self::physicalTable(self::BASE_TABLE_LOG_INDEX) . '` WHERE CONCAT(role_id, "|", login_time) IN (' . $placeholders . ')';
            $rows = Db::query($sql, array_values($missingKeys));
            foreach ($rows as $row) {
                $key = $row['role_id'] . '|' . $row['login_time'];
                $roleMap[$key] = $row;
            }
        }

        foreach ($loginBatch as &$row) {
            $key = $row['role_id'] . '|' . $row['login_time'];
            if (isset($roleMap[$key])) {
                if (!empty($roleMap[$key]['role_name'])) {
                    $row['role_name'] = (string)$roleMap[$key]['role_name'];
                }
                if (!empty($roleMap[$key]['race'])) {
                    $row['race'] = (string)$roleMap[$key]['race'];
                }
                if (!empty($roleMap[$key]['profession'])) {
                    $row['profession'] = (string)$roleMap[$key]['profession'];
                }
            }
        }
    }

    /**
     * 用 role 批次更新索引表中的角色信息
     */
    private static function upsertRoleInfoToLogs(array $roleBatch): void
    {
        if (empty($roleBatch)) {
            return;
        }

        $now = date('Y-m-d H:i:s');
        foreach ($roleBatch as $row) {
            $update = [];
            if ($row['role_name'] !== '') {
                $update['role_name'] = $row['role_name'];
            }
            if ($row['race'] !== '') {
                $update['race'] = $row['race'];
            }
            if ($row['profession'] !== '') {
                $update['profession'] = $row['profession'];
            }
            if (empty($update)) {
                continue;
            }
            $update['updated_at'] = $now;

            $affected = Db::name(self::BASE_TABLE_LOG_INDEX)
                ->where('role_id', $row['role_id'])
                ->where('login_time', $row['login_time'])
                ->update($update);

            if ($affected > 0) {
                continue;
            }

            $placeholder = [
                'role_id' => $row['role_id'],
                'role_name' => (string)($row['role_name'] ?? ''),
                'account' => '',
                'login_time' => $row['login_time'],
                'logout_time' => null,
                'ip' => '',
                'device_id' => '',
                'device_info' => '',
                'os_version' => '',
                'net_env' => '',
                'channel' => '',
                'platform' => '',
                'is_first_login' => 0,
                'level' => 0,
                'vip_level' => 0,
                'school' => '',
                'race' => (string)($row['race'] ?? ''),
                'profession' => (string)($row['profession'] ?? ''),
                'has_login_event' => 0,
                'status' => 1,
                'created_at' => $now,
                'updated_at' => $update['updated_at'],
            ];

            try {
                Db::name(self::BASE_TABLE_LOG_INDEX)->insert($placeholder);
            } catch (\Throwable $e) {
                if (!self::isDuplicateKeyException($e)) {
                    throw $e;
                }

                Db::name(self::BASE_TABLE_LOG_INDEX)
                    ->where('role_id', $row['role_id'])
                    ->where('login_time', $row['login_time'])
                    ->update($update);
            }
        }
    }

    /**
     * 应用 logout 到索引表
     */
    private static function applyLogoutToLogs(array $logoutBatch): void
    {
        if (empty($logoutBatch)) {
            return;
        }

        $table = self::physicalTable(self::BASE_TABLE_LOG_INDEX);
        $now = date('Y-m-d H:i:s');
        $sql = 'UPDATE `' . $table . '` SET `logout_time` = ?, `status` = 0, `updated_at` = ? WHERE `role_id` = ? AND `login_time` <= ? AND `status` = 1 ORDER BY `login_time` DESC LIMIT 1';

        foreach ($logoutBatch as $row) {
            Db::execute($sql, [$row['logout_time'], $now, $row['role_id'], $row['logout_time']]);
        }
    }

    /**
     * 保存同步游标
     */
    private static function saveCursor(string $logFile, string $inode, int $offset): void
    {
        $now = date('Y-m-d H:i:s');
        $data = [
            'id' => 1,
            'file_path' => $logFile,
            'file_inode' => $inode,
            'file_offset' => max(0, $offset),
            'updated_at' => $now,
        ];

        $exists = Db::name(self::BASE_TABLE_CURSOR)->where('id', 1)->find();
        if ($exists) {
            Db::name(self::BASE_TABLE_CURSOR)->where('id', 1)->update($data);
        } else {
            Db::name(self::BASE_TABLE_CURSOR)->insert($data);
        }
    }

    /**
     * 归一化日期字符串
     */
    private static function normalizeDate($value): ?string
    {
        if ($value === null || $value === '') {
            return null;
        }
        $ts = strtotime((string)$value);
        if ($ts === false) {
            return null;
        }
        return date('Y-m-d H:i:s', $ts);
    }

    /**
     * 处理日期条件（支持 YYYY-mm-dd 或完整时间）
     */
    private static function normalizeDateWithDefaultTime(string $value, string $defaultTime): ?string
    {
        $value = trim($value);
        if ($value === '') {
            return null;
        }
        if (strlen($value) <= 10) {
            $value .= ' ' . $defaultTime;
        }
        return self::normalizeDate($value);
    }

    /**
     * 确保索引表与游标表存在
     */
    private static function ensureSchema(): void
    {
        if (self::$schemaReady) {
            return;
        }

        $tableLog = self::physicalTable(self::BASE_TABLE_LOG_INDEX);
        $tableCursor = self::physicalTable(self::BASE_TABLE_CURSOR);

        Db::execute(
            'CREATE TABLE IF NOT EXISTS `' . $tableLog . '` (
                `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
                `role_id` VARCHAR(64) NOT NULL DEFAULT "",
                `role_name` VARCHAR(128) NOT NULL DEFAULT "",
                `account` VARCHAR(128) NOT NULL DEFAULT "",
                `login_time` DATETIME NOT NULL,
                `logout_time` DATETIME NULL DEFAULT NULL,
                `ip` VARCHAR(64) NOT NULL DEFAULT "",
                `device_id` VARCHAR(128) NOT NULL DEFAULT "",
                `device_info` VARCHAR(255) NOT NULL DEFAULT "",
                `os_version` VARCHAR(64) NOT NULL DEFAULT "",
                `net_env` VARCHAR(64) NOT NULL DEFAULT "",
                `channel` VARCHAR(64) NOT NULL DEFAULT "",
                `platform` VARCHAR(64) NOT NULL DEFAULT "",
                `is_first_login` TINYINT NOT NULL DEFAULT 0,
                `level` INT NOT NULL DEFAULT 0,
                `vip_level` INT NOT NULL DEFAULT 0,
                `school` VARCHAR(64) NOT NULL DEFAULT "",
                `race` VARCHAR(64) NOT NULL DEFAULT "",
                `profession` VARCHAR(64) NOT NULL DEFAULT "",
                `has_login_event` TINYINT NOT NULL DEFAULT 0,
                `status` TINYINT NOT NULL DEFAULT 1,
                `created_at` DATETIME NULL DEFAULT NULL,
                `updated_at` DATETIME NULL DEFAULT NULL,
                PRIMARY KEY (`id`),
                UNIQUE KEY `uniq_role_login_time` (`role_id`, `login_time`),
                KEY `idx_visible_login_time` (`has_login_event`, `login_time`),
                KEY `idx_login_time` (`login_time`),
                KEY `idx_account` (`account`),
                KEY `idx_ip` (`ip`),
                KEY `idx_role_name` (`role_name`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4'
        );

        Db::execute(
            'CREATE TABLE IF NOT EXISTS `' . $tableCursor . '` (
                `id` TINYINT UNSIGNED NOT NULL,
                `file_path` VARCHAR(255) NOT NULL DEFAULT "",
                `file_inode` VARCHAR(64) NOT NULL DEFAULT "",
                `file_offset` BIGINT UNSIGNED NOT NULL DEFAULT 0,
                `updated_at` DATETIME NULL DEFAULT NULL,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4'
        );

        self::ensureLogIndexColumns($tableLog);

        self::$schemaReady = true;
    }

    private static function ensureLogIndexColumns(string $tableLog): void
    {
        $columnRows = Db::query('SHOW COLUMNS FROM `' . $tableLog . '` LIKE ?', ['has_login_event']);
        if (empty($columnRows)) {
            Db::execute(
                'ALTER TABLE `' . $tableLog . '` ' .
                'ADD COLUMN `has_login_event` TINYINT NOT NULL DEFAULT 0 AFTER `profession`, ' .
                'ADD KEY `idx_visible_login_time` (`has_login_event`, `login_time`)'
            );
        }
    }

    /**
     * 带前缀的物理表名
     */
    private static function physicalTable(string $baseTable): string
    {
        $defaultConn = (string)config('database.default', 'mysql');
        $prefix = (string)config('database.connections.' . $defaultConn . '.prefix', '');
        return $prefix . $baseTable;
    }

    private static function isDuplicateKeyException(\Throwable $exception): bool
    {
        $msg = strtolower($exception->getMessage());
        return strpos($msg, 'duplicate entry') !== false
            || strpos($msg, '1062') !== false;
    }
}

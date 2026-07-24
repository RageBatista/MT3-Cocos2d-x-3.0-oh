<?php
declare(strict_types=1);

namespace app\player\service;

use think\facade\Session;
use think\facade\Cache;
use think\facade\Log;
use app\model\Server;

class GmService
{
    private const SIGNATURE_TIMEOUT = 300;
    
    /**
     * 【优化】物品ID白名单进程级缓存
     * 避免每次验证都查询缓存，减少IO操作
     * @var array|null
     */
    private static $itemIdCache = null;

    public function getGmData(array $override = [])
    {
        // playerId是游戏角色ID（如4097），不是用户账号ID
        $playerId = getSession('id');
        if (!$playerId) {
            return ['error' => '请先完成授权登录'];
        }

        $serverId = getSession('serverid');
        $serverRow = null;
        
        if ($serverId) {
            $S = new Server();
            $serverRow = $S->getServerId($serverId);
            if (!$serverRow) {
                $serverByPk = $S->getServer($serverId);
                if ($serverByPk) {
                    $serverRow = $serverByPk;
                    $serverId = intval($serverRow['serverid']);
                    setSession('serverid', $serverId);
                } else {
                    $serverByPort = $S->where('gmport', $serverId)->find();
                    if ($serverByPort) {
                        $serverRow = $serverByPort;
                        $serverId = intval($serverRow['serverid']);
                        setSession('serverid', $serverId);
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
            'playerid' => intval($playerId),
        ];
        
        return array_merge($base, $override);
    }

    public function sendItem(int $itemId, int $number): array
    {
        $data = $this->getGmData();
        if (isset($data['error'])) {
            return ['success' => false, 'message' => $data['error']];
        }

        $data['itemid'] = $itemId;
        $data['number'] = $number;

        $Game = new \app\gm\Gm();
        $out = $Game->addsuperitem($data);
        $line = is_array($out) ? (string)($out[0] ?? '') : (string)$out;

        if (strpos($line, 'success') !== false) {
            $this->logAction('物品发送：itemid=' . $itemId . ', number=' . $number);
            return ['success' => true, 'message' => '物品发送成功'];
        }

        $mailData = $data;
        $mailData['title'] = '系统补发';
        $mailData['content'] = '请到游戏内邮箱查收';
        $mailData['duration'] = 0;
        $mailData['awardContent'] = $itemId . '|' . $number;
        
        $mailOut = $Game->mail($mailData);
        $mailLine = is_array($mailOut) ? (string)($mailOut[0] ?? '') : (string)$mailOut;
        
        if (strpos($mailLine, 'success') !== false) {
            $this->logAction('物品邮件补发：itemid=' . $itemId . ', number=' . $number);
            return ['success' => true, 'message' => '已通过系统邮件补发，请到游戏内邮件查收'];
        }

        return ['success' => false, 'message' => '物品发送失败：' . ($line ?: '命令不支持')];
    }

    public function rechargeXianyu(int $number): array
    {
        $data = $this->getGmData();
        if (isset($data['error'])) {
            return ['success' => false, 'message' => $data['error']];
        }

        $data['number'] = $number;

        $Game = new \app\gm\Gm();
        $out = $Game->addqian($data);

        if (isset($out[0]) && strpos($out[0], 'success') !== false) {
            $this->logAction('仙玉充值：number=' . $number);
            return ['success' => true, 'message' => '仙玉充值成功'];
        }
        
        return ['success' => false, 'message' => '仙玉充值失败，请重试'];
    }

    public function getItemList(): array
    {
        $publicTxtDir = root_path() . 'public' . DIRECTORY_SEPARATOR . 'txt' . DIRECTORY_SEPARATOR;
        $textCandidates = [
            // Temporary: only load itemid.txt
            $publicTxtDir . 'itemid.txt',

            // Temporarily disabled:
            // $publicTxtDir . 'item_info.txt',
            // $publicTxtDir . 'equipid.txt',
        ];

        $items = [];
        $seen = [];
        foreach ($textCandidates as $candidatePath) {
            if (!is_file($candidatePath)) {
                continue;
            }
            $parsed = $this->parseItemTextFile($candidatePath);
            foreach ($parsed as $row) {
                $id = (int)($row['id'] ?? 0);
                if ($id <= 0 || isset($seen[$id])) {
                    continue;
                }
                $seen[$id] = true;
                $items[] = [
                    'id' => $id,
                    'name' => (string)($row['name'] ?? ('Item-' . $id)),
                ];
            }
        }

        usort($items, function ($a, $b) {
            return $a['id'] - $b['id'];
        });

        $this->syncItemWhitelistCache($items);
        return $items;
    }

    /**
     * 解析物品文本文件（兼容多种分隔格式）
     * 支持：
     * - 1001;金疮药
     * - 1001,金疮药
     * - 1001|金疮药
     * - 1001 金疮药
     */
    private function parseItemTextFile(string $path): array
    {
        $content = @file_get_contents($path);
        if ($content === false || $content === '') {
            return [];
        }

        // 兼容GBK/GB18030文件，统一转UTF-8
        if (function_exists('mb_detect_encoding') && function_exists('mb_convert_encoding')) {
            $encoding = mb_detect_encoding($content, ['UTF-8', 'GB18030', 'GBK', 'GB2312', 'BIG5'], true);
            if (is_string($encoding) && strtoupper($encoding) !== 'UTF-8') {
                $converted = @mb_convert_encoding($content, 'UTF-8', $encoding);
                if (is_string($converted) && $converted !== '') {
                    $content = $converted;
                }
            }
        }

        $lines = preg_split('/\r\n|\r|\n/', $content) ?: [];
        $items = [];
        $seen = [];

        foreach ($lines as $line) {
            $line = trim((string)$line);
            if ($line === '' || $line[0] === '#' || strpos($line, '//') === 0) {
                continue;
            }

            $id = 0;
            $name = '';

            // id;name / id；name / id,name / id|name / id\tname
            if (preg_match('/^(\d+)\s*[;；,\|\t]\s*(.+)$/', $line, $m)) {
                $id = (int)$m[1];
                $name = trim((string)$m[2]);
            } elseif (preg_match('/^(\d+)\s+(.+)$/', $line, $m)) {
                // id name
                $id = (int)$m[1];
                $name = trim((string)$m[2]);
            } elseif (preg_match('/^(\d+)$/', $line, $m)) {
                // 仅id时使用默认名
                $id = (int)$m[1];
                $name = 'Item-' . $id;
            }

            if ($id <= 0 || isset($seen[$id])) {
                continue;
            }

            $name = preg_replace('/[\t\r\n]+/', ' ', (string)$name);
            $name = trim((string)$name);
            if ($name === '') {
                $name = 'Item-' . $id;
            }

            $seen[$id] = true;
            $items[] = ['id' => $id, 'name' => $name];

            if (count($items) >= 10000) {
                break;
            }
        }

        return $items;
    }

    /**
     * 同步物品白名单缓存，避免列表与签名校验脱节
     */
    private function syncItemWhitelistCache(array $items): void
    {
        $ids = [];
        foreach ($items as $item) {
            $id = (int)($item['id'] ?? 0);
            if ($id > 0) {
                $ids[] = $id;
            }
        }
        $ids = array_values(array_unique($ids));

        self::$itemIdCache = $ids;
        try {
            Cache::set('whitelist:itemids', $ids, 3600);
        } catch (\Throwable $e) {
        }
    }

    public function isValidItemId(int $id): bool
    {
        if ($id <= 0) return false;
        
        // 【优化】使用进程级缓存，避免每次都查询缓存
        if (self::$itemIdCache !== null) {
            return in_array($id, self::$itemIdCache);
        }
        
        $key = 'whitelist:itemids';
        try {
            $ids = Cache::get($key);
        } catch (\Throwable $e) {
            $ids = null;
        }

        if (!is_array($ids) || empty($ids)) {
            $items = $this->getItemList();
            $ids = array_column($items, 'id');
            try {
                Cache::set($key, $ids, 3600);
            } catch (\Throwable $e) {
            }
        }
        
        // 存入进程级缓存，后续请求直接使用
        self::$itemIdCache = $ids;

        return in_array($id, $ids);
    }

    public function generateItemToken(int $itemId): string
    {
        $exp = time() + 300;
        $payload = $itemId . '|' . $exp;
        $sig = hash_hmac('sha256', $payload, $this->opSecret());
        
        return $this->base64UrlEncode($payload . '|' . $sig);
    }

    public function parseItemToken(string $token): array
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
        $expect = hash_hmac('sha256', $payload, $this->opSecret());
        
        if (!hash_equals($expect, $sig)) {
            return [false, 0, 'item token verify failed'];
        }

        if (!$this->isValidItemId($itemid)) {
            return [false, 0, 'item is not in whitelist'];
        }

        return [true, $itemid, ''];
    }

    public function computeOpSig(string $action, int $ts, array $params): string
    {
        ksort($params);
        $base = $action . '|' . $ts . '|' . http_build_query($params);
        return hash_hmac('sha256', $base, $this->opSecret());
    }

    public function validateOpSignature(string $action, array $params): array
    {
        $ts = (int)request()->post('op_ts', 0);
        $sig = (string)request()->post('op_sig', '');
        
        if ($ts <= 0 || $sig === '') {
            return [false, '缺少操作签名'];
        }
        
        $timeout = config('player.signature_timeout');
        $timeout = is_numeric($timeout) ? (int)$timeout : self::SIGNATURE_TIMEOUT;
        if ($timeout <= 0) $timeout = self::SIGNATURE_TIMEOUT;
        
        if (abs(time() - $ts) > $timeout) {
            return [false, '操作签名已过期'];
        }
        
        $expect = $this->computeOpSig($action, $ts, $params);
        if (!hash_equals($expect, $sig)) {
            return [false, '签名校验失败'];
        }
        
        return [true, ''];
    }

    private function opSecret(): string
    {
        $secret = (string)config('player.op_secret_salt', '');

        if ($secret === '') {
            Log::error('GmService: OP_SECRET_SALT未配置，拒绝执行签名相关操作');
            throw new \RuntimeException('系统安全配置错误：操作签名密钥未配置');
        }

        if (strlen($secret) < 32) {
            Log::warning('GmService: OP_SECRET_SALT强度不足', [
                'secret_length' => strlen($secret),
                'min_required' => 32
            ]);
        }

        return $secret;
    }

    private function base64UrlEncode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    private function base64UrlDecode(string $data): ?string
    {
        $remainder = strlen($data) % 4;
        if ($remainder) {
            $data .= str_repeat('=', 4 - $remainder);
        }
        $decoded = base64_decode(strtr($data, '-_', '+/'));
        return $decoded !== false ? $decoded : null;
    }

    private function logAction(string $detail): void
    {
        try {
            if (function_exists('logPlayerAction')) {
                $playerId = getSession('id');
                logPlayerAction($playerId, 'gm_operation', $detail);
            }
        } catch (\Throwable $e) {
        }
    }
}

<?php
declare (strict_types = 1);

namespace app\service;

use think\facade\Db;
use think\facade\Log;

/**
 * 账号-角色绑定票据服务（Bind Ticket）。
 *
 * 目标：
 * - 将“先登录后绑定”的关联关系从时间窗口猜测升级为一次性票据验证
 * - 通过单次消费 + 过期控制，降低并发错绑风险
 */
class BindTicketService
{
    private function normalizeAccount(string $account): string
    {
        $account = trim($account);
        if ($account !== '' && strpos($account, ',') !== false) {
            $account = trim((string)explode(',', $account)[0]);
        }
        return strtolower($account);
    }

    private function asBool($value, bool $default = false): bool
    {
        if (is_bool($value)) {
            return $value;
        }
        if ($value === null) {
            return $default;
        }
        $raw = strtolower(trim((string)$value));
        if ($raw === '') {
            return $default;
        }
        return !in_array($raw, ['0', 'false', 'off', 'no'], true);
    }

    private function isEnabled(): bool
    {
        return $this->asBool(config('security.bind_ticket.enabled', false), false);
    }

    private function isSingleUse(): bool
    {
        return $this->asBool(config('security.bind_ticket.single_use', true), true);
    }

    private function ttlSeconds(): int
    {
        $ttl = intval(config('security.bind_ticket.ttl_seconds', 180));
        if ($ttl < 30) {
            return 30;
        }
        if ($ttl > 1800) {
            return 1800;
        }
        return $ttl;
    }

    private function graceSeconds(): int
    {
        $grace = intval(config('security.bind_ticket.grace_seconds', 15));
        if ($grace < 0) {
            return 0;
        }
        if ($grace > 300) {
            return 300;
        }
        return $grace;
    }

    private function getSecret(): string
    {
        $secret = trim((string)config('security.bind_ticket.secret_key', ''));
        if ($secret !== '') {
            return $secret;
        }
        return trim((string)config('player.op_secret_salt', ''));
    }

    private function hashTicket(string $ticket): string
    {
        return hash('sha256', $ticket);
    }

    private function buildSignature(int $userId, string $username, int $serverId, string $nonce, int $issuedAt, int $expiresAt, string $secret): string
    {
        $payload = implode('|', [
            $userId,
            $username,
            $serverId,
            $nonce,
            $issuedAt,
            $expiresAt,
        ]);
        return hash_hmac('sha256', $payload, $secret);
    }

    /**
     * 签发绑定票据。
     */
    public function issue(array $payload): array
    {
        if (!$this->isEnabled()) {
            return [
                'ok' => false,
                'msg' => 'bind ticket disabled',
            ];
        }

        $userId = intval($payload['user_id'] ?? 0);
        $username = $this->normalizeAccount((string)($payload['username'] ?? ''));
        $serverId = intval($payload['server_id'] ?? 0);
        $requestIp = trim((string)($payload['request_ip'] ?? ''));
        $requestUa = trim((string)($payload['request_ua'] ?? ''));
        if (strlen($requestUa) > 255) {
            $requestUa = substr($requestUa, 0, 255);
        }

        if ($userId <= 0 || $username === '' || $serverId <= 0) {
            return [
                'ok' => false,
                'msg' => 'invalid issue payload',
            ];
        }

        $secret = $this->getSecret();
        if ($secret === '') {
            Log::error('BindTicketService签发失败：缺少签名密钥');
            return [
                'ok' => false,
                'msg' => 'bind ticket secret not configured',
            ];
        }

        try {
            $ticket = 'bt1_' . bin2hex(random_bytes(24));
            $nonce = bin2hex(random_bytes(8));
        } catch (\Throwable $e) {
            Log::error('BindTicketService签发失败：随机数生成异常', [
                'error' => $e->getMessage(),
            ]);
            return [
                'ok' => false,
                'msg' => 'issue ticket failed',
            ];
        }

        $now = time();
        $expiresAt = $now + $this->ttlSeconds();
        $signature = $this->buildSignature($userId, $username, $serverId, $nonce, $now, $expiresAt, $secret);

        try {
            Db::name('bind_ticket')->insert([
                'ticket_hash' => $this->hashTicket($ticket),
                'nonce' => $nonce,
                'user_id' => $userId,
                'username' => $username,
                'server_id' => $serverId,
                'signature' => $signature,
                'request_ip' => $requestIp,
                'request_ua' => $requestUa,
                'issued_at' => $now,
                'expires_at' => $expiresAt,
                'used_at' => null,
                'use_count' => 0,
                'last_bind_roleid' => null,
                'status' => 1,
                'created_at' => date('Y-m-d H:i:s', $now),
                'updated_at' => date('Y-m-d H:i:s', $now),
            ]);
        } catch (\Throwable $e) {
            Log::error('BindTicketService签发失败：写表异常', [
                'user_id' => $userId,
                'username' => $username,
                'server_id' => $serverId,
                'error' => $e->getMessage(),
            ]);
            return [
                'ok' => false,
                'msg' => 'issue ticket db error',
            ];
        }

        return [
            'ok' => true,
            'ticket' => $ticket,
            'expires_at' => $expiresAt,
        ];
    }

    /**
     * 消费并校验绑定票据。
     */
    public function consume(array $payload): array
    {
        if (!$this->isEnabled()) {
            return [
                'ok' => false,
                'msg' => 'bind ticket disabled',
            ];
        }

        $ticket = trim((string)($payload['ticket'] ?? ''));
        $account = $this->normalizeAccount((string)($payload['account'] ?? ''));
        $serverId = intval($payload['server_id'] ?? 0);
        $roleId = intval($payload['role_id'] ?? 0);
        if ($ticket === '') {
            return [
                'ok' => false,
                'msg' => 'missing bind ticket',
            ];
        }

        $secret = $this->getSecret();
        if ($secret === '') {
            Log::error('BindTicketService验票失败：缺少签名密钥');
            return [
                'ok' => false,
                'msg' => 'bind ticket secret not configured',
            ];
        }

        $ticketHash = $this->hashTicket($ticket);
        $now = time();
        $grace = $this->graceSeconds();
        $singleUse = $this->isSingleUse();

        try {
            $result = Db::transaction(function () use ($ticketHash, $account, $serverId, $roleId, $now, $grace, $singleUse, $secret) {
                $row = Db::name('bind_ticket')
                    ->where('ticket_hash', $ticketHash)
                    ->lock(true)
                    ->find();

                if (!$row) {
                    return [
                        'ok' => false,
                        'msg' => 'bind ticket not found',
                    ];
                }

                $status = intval($row['status'] ?? 0);
                if ($status !== 1 && !($singleUse === false && $status === 2)) {
                    return [
                        'ok' => false,
                        'msg' => 'bind ticket invalid status',
                    ];
                }

                $expiresAt = intval($row['expires_at'] ?? 0);
                if ($expiresAt <= 0 || $expiresAt + $grace < $now) {
                    Db::name('bind_ticket')
                        ->where('id', intval($row['id']))
                        ->update([
                            'status' => 4,
                            'updated_at' => date('Y-m-d H:i:s', $now),
                        ]);
                    return [
                        'ok' => false,
                        'msg' => 'bind ticket expired',
                    ];
                }

                $usedAt = intval($row['used_at'] ?? 0);
                if ($singleUse && $usedAt > 0) {
                    return [
                        'ok' => false,
                        'msg' => 'bind ticket already used',
                    ];
                }

                $ticketUserId = intval($row['user_id'] ?? 0);
                $ticketUsername = $this->normalizeAccount((string)($row['username'] ?? ''));
                $ticketServerId = intval($row['server_id'] ?? 0);
                $nonce = (string)($row['nonce'] ?? '');
                $issuedAt = intval($row['issued_at'] ?? 0);
                $signature = (string)($row['signature'] ?? '');

                if ($ticketUserId <= 0 || $ticketUsername === '' || $ticketServerId <= 0 || $nonce === '' || $issuedAt <= 0 || $signature === '') {
                    return [
                        'ok' => false,
                        'msg' => 'bind ticket broken',
                    ];
                }

                $expectSign = $this->buildSignature($ticketUserId, $ticketUsername, $ticketServerId, $nonce, $issuedAt, $expiresAt, $secret);
                if (!hash_equals($expectSign, $signature)) {
                    return [
                        'ok' => false,
                        'msg' => 'bind ticket signature mismatch',
                    ];
                }

                if ($account !== '' && $account !== $ticketUsername) {
                    return [
                        'ok' => false,
                        'msg' => 'bind ticket account mismatch',
                    ];
                }

                if ($serverId > 0 && $ticketServerId > 0 && $serverId !== $ticketServerId) {
                    return [
                        'ok' => false,
                        'msg' => 'bind ticket server mismatch',
                    ];
                }

                $userRow = Db::name('user_account')
                    ->where('id', $ticketUserId)
                    ->where('username', $ticketUsername)
                    ->field('id,username')
                    ->find();
                if (!$userRow) {
                    return [
                        'ok' => false,
                        'msg' => 'bind ticket user not found',
                    ];
                }

                $updateData = [
                    'use_count' => intval($row['use_count'] ?? 0) + 1,
                    'used_at' => $now,
                    'updated_at' => date('Y-m-d H:i:s', $now),
                ];
                if ($roleId > 0) {
                    $updateData['last_bind_roleid'] = $roleId;
                }
                if ($singleUse) {
                    $updateData['status'] = 2;
                } elseif ($status !== 1) {
                    $updateData['status'] = 1;
                }

                Db::name('bind_ticket')->where('id', intval($row['id']))->update($updateData);

                return [
                    'ok' => true,
                    'user_id' => intval($userRow['id'] ?? 0),
                    'username' => $this->normalizeAccount((string)($userRow['username'] ?? '')),
                    'server_id' => $ticketServerId,
                    'ticket_id' => intval($row['id'] ?? 0),
                ];
            });
        } catch (\Throwable $e) {
            Log::error('BindTicketService验票异常', [
                'error' => $e->getMessage(),
            ]);
            return [
                'ok' => false,
                'msg' => 'bind ticket verify exception',
            ];
        }

        return is_array($result) ? $result : [
            'ok' => false,
            'msg' => 'bind ticket verify failed',
        ];
    }
}

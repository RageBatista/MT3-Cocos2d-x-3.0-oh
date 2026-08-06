<?php
declare(strict_types=1);

namespace app\traits;

use think\facade\Db;
use think\facade\Log;

trait PlayerSessionTrait
{
    protected function ensurePlayer(): ?array
    {
        $player = $this->request->player ?? null;
        if ($player) {
            if (is_object($player) && method_exists($player, 'toArray')) {
                $player = $player->toArray();
            }

            if (is_array($player)) {
                return $this->attachPlayerDisplayUid($player);
            }

            return null;
        }

        $playerId = null;
        $playerUsername = null;
        if (function_exists('getSession')) {
            $playerId = getSession('id');
            $playerUsername = getSession('username');
        }
        if (!empty($playerId) && !empty($playerUsername)) {
            try {
                $playerModel = new \app\player\model\Player();
                $info = $playerModel->getPlayerInfo($playerId);
                if ($info) {
                    return $this->attachPlayerDisplayUid($info);
                }
                return $this->attachPlayerDisplayUid([
                    'id' => $playerId,
                    'username' => $playerUsername,
                    'profile' => [],
                    'servers' => []
                ]);
            } catch (\Exception $e) {
                Log::error('ensurePlayer exception', [
                    'user_id' => $playerId,
                    'username' => $playerUsername,
                    'error' => $e->getMessage()
                ]);
                return $this->attachPlayerDisplayUid([
                    'id' => $playerId,
                    'username' => $playerUsername,
                    'profile' => [],
                    'servers' => []
                ]);
            }
        }
        return null;
    }

    protected function attachPlayerDisplayUid(array $player): array
    {
        if (!isset($player['display_uid']) || intval($player['display_uid']) <= 0) {
            $displayUid = $this->resolvePlayerDisplayUid($player);
            if ($displayUid !== null) {
                $player['display_uid'] = $displayUid;
            }
        }

        return $player;
    }

    protected function resolvePlayerDisplayUid(array $player): ?int
    {
        try {
            $sessionId = 0;
            $sessionCdk = '';
            $loginMode = '';
            $serverId = 0;

            if (function_exists('getSession')) {
                $sessionId = intval(getSession('id', 0));
                $sessionCdk = trim((string)getSession('cdk', ''));
                $loginMode = trim((string)getSession('login_mode', ''));
                $serverId = intval(getSession('serverid', 0));
            }

            if ($loginMode === 'cdk' && $sessionId > 0) {
                return $sessionId;
            }

            if ($sessionCdk !== '' && $sessionId > 0) {
                $roleExists = Db::name('user_bind')
                    ->where('playerid', $sessionId)
                    ->find();

                if (!empty($roleExists)) {
                    return $sessionId;
                }

                if (function_exists('deleteSession')) {
                    deleteSession('cdk');
                    deleteSession('lv');
                    deleteSession('auth_pass');
                }
            }

            $userId = intval($player['id'] ?? $sessionId);
            if ($userId <= 0) {
                return null;
            }

            if ($serverId > 0) {
                $serverRoleUid = Db::name('user_bind')
                    ->where('userid', $userId)
                    ->where('serverid', $serverId)
                    ->order('playerid', 'asc')
                    ->value('playerid');

                if (!empty($serverRoleUid)) {
                    return intval($serverRoleUid);
                }
            }

            $defaultRoleUid = Db::name('user_bind')
                ->where('userid', $userId)
                ->order('playerid', 'asc')
                ->value('playerid');

            if (!empty($defaultRoleUid)) {
                return intval($defaultRoleUid);
            }
        } catch (\Throwable $e) {
            Log::debug('resolvePlayerDisplayUid failed', [
                'player_id' => $player['id'] ?? 0,
                'error' => $e->getMessage()
            ]);
        }

        return null;
    }

    protected function isCdkLoginSession(): bool
    {
        if (!function_exists('getSession')) {
            return false;
        }

        $loginMode = strtolower(trim((string)getSession('login_mode', '')));
        $cdk = trim((string)getSession('cdk', ''));

        return $loginMode === 'cdk' || $cdk !== '';
    }

    protected function resolveSessionRoleId(array $player): int
    {
        $sessionId = intval(function_exists('getSession') ? getSession('id', 0) : 0);
        if ($sessionId > 0) {
            return $sessionId;
        }

        $displayUid = intval($player['display_uid'] ?? 0);
        if ($displayUid > 0) {
            return $displayUid;
        }

        return intval($player['id'] ?? 0);
    }

    protected function resolveAccessibleRoles(array $player, int $serverId = 0): array
    {
        $fields = 'userid,serverid,playerid,playername';

        if ($this->isCdkLoginSession()) {
            $roleId = $this->resolveSessionRoleId($player);
            if ($roleId <= 0) {
                return [];
            }

            $query = Db::name('user_bind')
                ->where('playerid', $roleId);

            if ($serverId > 0) {
                $query->where('serverid', $serverId);
            }

            $row = $query->field($fields)->find();
            if ($row) {
                return [$row];
            }

            return [[
                'userid' => 0,
                'serverid' => $serverId > 0 ? $serverId : intval(function_exists('getSession') ? getSession('serverid', 0) : 0),
                'playerid' => $roleId,
                'playername' => '角色' . $roleId,
                'level' => 0,
            ]];
        }

        $userId = intval($player['id'] ?? 0);
        if ($userId <= 0) {
            return [];
        }

        $query = Db::name('user_bind')
            ->where('userid', $userId);
        if ($serverId > 0) {
            $query->where('serverid', $serverId);
        }

        $rows = $query->field($fields)
            ->order('serverid', 'asc')
            ->order('playerid', 'asc')
            ->select()
            ->toArray();

        if (!empty($rows)) {
            return $rows;
        }

        $roleId = $this->resolveSessionRoleId($player);
        if ($roleId <= 0) {
            return [];
        }

        $query = Db::name('user_bind')
            ->where('playerid', $roleId);
        if ($serverId > 0) {
            $query->where('serverid', $serverId);
        }
        $row = $query->field($fields)->find();
        if ($row) {
            return [$row];
        }

        return [];
    }

    protected function resolveSessionUserId(array $player): int
    {
        if (!$this->isCdkLoginSession()) {
            return intval($player['id'] ?? 0);
        }

        $roleId = $this->resolveSessionRoleId($player);
        if ($roleId <= 0) {
            return 0;
        }

        $uid = Db::name('user_bind')
            ->where('playerid', $roleId)
            ->value('userid');

        return intval($uid ?: 0);
    }
}

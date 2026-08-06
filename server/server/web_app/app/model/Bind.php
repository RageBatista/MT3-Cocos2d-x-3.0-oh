<?php
namespace app\model;
use think\Model;
use think\facade\Cache;
use think\facade\Db;
use think\facade\Log;

class Bind extends Model{

	protected $table = 'user_bind';

    public function getPlayerById($id)
	{
		$bind = Bind::where('id', $id)->find();
		return $bind;
    }
    public function getPlayerId($playerid)
	{
		$bind = Bind::where('playerid', $playerid)->find();
		return $bind;
    }
    public function getPlayerByUid($userid)
	{
		$bind = Bind::where('userid', $userid)->find();
		return $bind;
    }

    public function getBindArr($arr)
	{
		$bind = Bind::where($arr)->find();
		return $bind;
    }
    public function addBind($data)
	{
		$this->insertOrUpdateByPlayerId([
			'userid' => intval($data['userid'] ?? 0),
			'serverid' => intval($data['serverid'] ?? 0),
			'playerid' => intval($data['playerid'] ?? 0),
			'playername' => (string)($data['playername'] ?? ''),
		]);
    }

	/**
	 * 判断是否为唯一键冲突（MySQL 1062 / SQLSTATE 23000）。
	 */
	protected function isDuplicateKeyException(\Throwable $e): bool
	{
		$code = (string)$e->getCode();
		$message = strtolower($e->getMessage());
		if ($code === '1062' || $code === '23000') {
			return true;
		}
		return strpos($message, 'duplicate') !== false
			|| strpos($message, 'duplicate entry') !== false
			|| strpos($message, '1062') !== false;
	}

	/**
	 * 以 playerid 作为幂等键执行插入/更新。
	 *
	 * @return bool true=新增成功，false=命中重复后转更新
	 */
	protected function insertOrUpdateByPlayerId(array $insertData): bool
	{
		$playerId = intval($insertData['playerid'] ?? 0);
		if ($playerId <= 0) {
			throw new \InvalidArgumentException('playerid 无效');
		}
		try {
			Db::name('user_bind')->insert($insertData);
			return true;
		} catch (\Throwable $e) {
			if (!$this->isDuplicateKeyException($e)) {
				throw $e;
			}
			$update = [];
			if (array_key_exists('userid', $insertData)) {
				$update['userid'] = intval($insertData['userid']);
			}
			if (array_key_exists('serverid', $insertData)) {
				$update['serverid'] = intval($insertData['serverid']);
			}
			if (!empty($insertData['playername'])) {
				$update['playername'] = (string)$insertData['playername'];
			}
			if (!empty($update)) {
				Db::name('user_bind')->where('playerid', $playerId)->update($update);
			}
			return false;
		}
	}
    public function getBindData($condition)
	{
		$bind = Bind::where($condition)->find();
		return $bind;
    }
    public function getBindNum()
	{
		$num = Bind::count();
		return $num;
    }
	public function getBindList($post=null,$table=null,$agent=null)
	{
		$page = isset($post['page']) ? max(1, intval($post['page'])) : 1;
		$limit = isset($post['limit']) ? max(1, min(100, intval($post['limit']))) : 10;
		$sortOrder = (isset($post['sortOrder']) && strtolower($post['sortOrder'])==='desc')?'desc':'asc';
		$sortMap = [
			'id' => 'b.id',
			'userid' => 'b.userid',
			'serverid' => 'b.serverid',
			'playerid' => 'b.playerid',
			'playername' => 'b.playername',
			'charge' => 'b.charge',
			'chargedate' => 'b.chargedate',
			'daycharge' => 'b.daycharge',
			'zhuanqu' => 'b.zhuanqu',
			'uid' => 'u.id',
			'msid' => 'ms.id',
			'username' => 'u.username',
			'name' => 'ms.name'
		];
		$sortKey = isset($post['sort'])?$post['sort']:'id';
		$sort = isset($sortMap[$sortKey]) ? $sortMap[$sortKey] : 'b.id';
		$condition = [];
		$usernameFilter = '';
		if($table!=null){
			foreach($table as $val){
				if (($val[0] ?? '') === 'u.username') {
					$usernameFilter = trim((string)($val[2] ?? ''));
					continue;
				}
				$condition[] = [$val[0],$val[1],$val[2]];
			}
		}

		$buildQuery = function () use ($condition, $agent, $usernameFilter) {
			$query = Bind::alias('b')
				->field('b.*');

			foreach ($condition as $item) {
				$query->where($item[0], $item[1], $item[2]);
			}

			if ($agent != null || $usernameFilter !== '') {
				$query->leftJoin('user_account u', 'b.userid = u.id')
					->leftJoin('role r', 'b.playerid = r.roleid')
					->leftJoin('user_account ru', 'r.userid = ru.id');
			}

			if ($agent != null) {
				$agentId = intval($agent);
				$query->where(function ($q) use ($agentId) {
					$q->where('u.lastagent', '=', $agentId)
						->whereOr('ru.lastagent', '=', $agentId);
				});
			}

			if ($usernameFilter !== '') {
				$query->where(function ($q) use ($usernameFilter) {
					$q->where('u.username', 'like', $usernameFilter)
						->whereOr('ru.username', 'like', $usernameFilter);
				});
			}

			return $query;
		};

		$bind = $buildQuery()->order($sort ,$sortOrder)->limit($limit)->page($page)->select();
		$data = $this->hydrateBindRows($bind->toArray());
		$total = ($table == null && $agent == null)
			? Bind::count()
			: $buildQuery()->count();
		Log::info('绑定列表查询完成', [
			'total' => intval($total),
			'rows' => count($data),
			'page' => $page,
			'limit' => $limit,
			'has_agent_filter' => $agent != null ? 1 : 0,
			'has_username_filter' => $usernameFilter !== '' ? 1 : 0,
		]);
		$data=[
			'total'=>$total,
			'rows'=>$data
		];

		return $data;
    }

	protected function hydrateBindRows(array $rows): array
	{
		if (empty($rows)) {
			return $rows;
		}

		$userIds = [];
		$serverIds = [];
		$roleIds = [];
		foreach ($rows as $row) {
			$userId = intval($row['userid'] ?? 0);
			$serverId = intval($row['serverid'] ?? 0);
			$roleId = intval($row['playerid'] ?? 0);
			if ($userId > 0) {
				$userIds[$userId] = $userId;
			}
			if ($serverId > 0) {
				$serverIds[$serverId] = $serverId;
			}
			if ($roleId > 0) {
				$roleIds[$roleId] = $roleId;
			}
		}

		$userMap = [];
		if (!empty($userIds)) {
			$accounts = Db::name('user_account')
				->whereIn('id', array_values($userIds))
				->field('id,username,lastagent')
				->select()
				->toArray();
			foreach ($accounts as $account) {
				$userMap[intval($account['id'] ?? 0)] = $account;
			}
		}

		$roleUserMap = [];
		if (!empty($roleIds)) {
			$roles = Db::name('role')
				->whereIn('roleid', array_values($roleIds))
				->field('roleid,userid')
				->select()
				->toArray();
			$roleUserIds = [];
			foreach ($roles as $role) {
				$roleId = intval($role['roleid'] ?? 0);
				$roleUserId = intval($role['userid'] ?? 0);
				if ($roleId > 0 && $roleUserId > 0) {
					$roleUserMap[$roleId] = $roleUserId;
					if (!isset($userMap[$roleUserId])) {
						$roleUserIds[$roleUserId] = $roleUserId;
					}
				}
			}
			if (!empty($roleUserIds)) {
				$roleAccounts = Db::name('user_account')
					->whereIn('id', array_values($roleUserIds))
					->field('id,username,lastagent')
					->select()
					->toArray();
				foreach ($roleAccounts as $account) {
					$userMap[intval($account['id'] ?? 0)] = $account;
				}
			}
		}

		$serverMap = [];
		if (!empty($serverIds)) {
			$servers = Db::name('main_server')
				->whereIn('serverid', array_values($serverIds))
				->field('id,serverid,name')
				->select()
				->toArray();
			foreach ($servers as $server) {
				$serverMap[intval($server['serverid'] ?? 0)] = $server;
			}
		}

		foreach ($rows as $index => $row) {
			$userId = intval($row['userid'] ?? 0);
			$roleId = intval($row['playerid'] ?? 0);
			$serverId = intval($row['serverid'] ?? 0);
			$resolvedUserId = $userId;
			if (!isset($userMap[$resolvedUserId])) {
				$roleUserId = intval($roleUserMap[$roleId] ?? 0);
				if ($roleUserId > 0) {
					$resolvedUserId = $roleUserId;
				}
			}

			$account = $userMap[$resolvedUserId] ?? [];
			$server = $serverMap[$serverId] ?? [];
			$rows[$index]['uid'] = intval($account['id'] ?? 0);
			$rows[$index]['username'] = trim((string)($account['username'] ?? ''));
			$rows[$index]['msid'] = intval($server['id'] ?? 0);
			$rows[$index]['name'] = trim((string)($server['name'] ?? ''));
			$rows[$index]['role_userid'] = intval($roleUserMap[$roleId] ?? 0);
		}

		return $this->resolveBindUsernames($rows);
    }

    /**
     * 补齐绑定列表中的账号名，并在可确定时修正错误的 user_bind.userid。
     * 场景：user_bind.userid 无对应账号、或历史数据错绑导致后台“所属账号”为空。
     */
	protected function resolveBindUsernames(array $rows): array
	{
		if (empty($rows)) {
			return $rows;
		}

		$missing = [];
		$userIds = [];
		$roleIds = [];

		foreach ($rows as $index => $row) {
			$username = trim((string)($row['username'] ?? ''));
			if ($username !== '') {
				continue;
			}

			$bindId = intval($row['id'] ?? 0);
			$userId = intval($row['userid'] ?? 0);
			$roleId = intval($row['playerid'] ?? 0);

			$missing[$index] = [
				'bindid' => $bindId,
				'userid' => $userId,
				'roleid' => $roleId,
			];

			if ($userId > 0) {
				$userIds[$userId] = $userId;
			}
			if ($roleId > 0) {
				$roleIds[$roleId] = $roleId;
			}
		}

		if (empty($missing)) {
			return $rows;
		}

		$accountMap = [];
		if (!empty($userIds)) {
			$accountRows = Db::name('user_account')
				->whereIn('id', array_values($userIds))
				->field('id,username')
				->select()
				->toArray();

			foreach ($accountRows as $accountRow) {
				$uid = intval($accountRow['id'] ?? 0);
				$uname = trim((string)($accountRow['username'] ?? ''));
				if ($uid > 0 && $uname !== '') {
					$accountMap[$uid] = $uname;
				}
			}
		}

		$roleUserMap = [];
		$roleUserIds = [];
		if (!empty($roleIds)) {
			$roleRows = Db::name('role')
				->whereIn('roleid', array_values($roleIds))
				->field('roleid,userid')
				->select()
				->toArray();

			foreach ($roleRows as $roleRow) {
				$roleId = intval($roleRow['roleid'] ?? 0);
				$roleUid = intval($roleRow['userid'] ?? 0);
				if ($roleId > 0 && $roleUid > 0) {
					$roleUserMap[$roleId] = $roleUid;
					$roleUserIds[$roleUid] = $roleUid;
				}
			}

			if (!empty($roleUserIds)) {
				$roleUserRows = Db::name('user_account')
					->whereIn('id', array_values($roleUserIds))
					->field('id,username')
					->select()
					->toArray();

				foreach ($roleUserRows as $roleUserRow) {
					$uid = intval($roleUserRow['id'] ?? 0);
					$uname = trim((string)($roleUserRow['username'] ?? ''));
					if ($uid > 0 && $uname !== '') {
						$accountMap[$uid] = $uname;
					}
				}
			}
		}

		// 第三层兜底：当 user_account 暂无记录时，尝试从玩家登录日志反查账号名
		$allUserIds = [];
		foreach ($userIds as $uid) {
			$uid = intval($uid);
			if ($uid > 0) {
				$allUserIds[$uid] = $uid;
			}
		}
		foreach ($roleUserIds as $uid) {
			$uid = intval($uid);
			if ($uid > 0) {
				$allUserIds[$uid] = $uid;
			}
		}
		if (!empty($allUserIds)) {
			try {
				$loginRows = Db::name('player_event_log')
					->where('category', 'login')
					->whereIn('uid', array_values($allUserIds))
					->where('success', 1)
					->whereNotNull('username')
					->where('username', '<>', '')
					->order('id', 'desc')
					->field('uid AS user_id,username')
					->select()
					->toArray();

				foreach ($loginRows as $loginRow) {
					$uid = intval($loginRow['user_id'] ?? 0);
					$uname = trim((string)($loginRow['username'] ?? ''));
					if ($uid > 0 && $uname !== '' && !isset($accountMap[$uid])) {
						$accountMap[$uid] = $uname;
					}
				}
			} catch (\Throwable $e) {
				Log::warning('绑定列表账号名兜底失败：读取player_event_log(login)异常', [
					'error' => $e->getMessage()
				]);
			}
		}

		foreach ($missing as $index => $meta) {
			$bindId = intval($meta['bindid'] ?? 0);
			$originUserId = intval($meta['userid'] ?? 0);
			$roleId = intval($meta['roleid'] ?? 0);

			$resolvedUserId = 0;
			$resolvedUsername = '';

			if ($originUserId > 0 && isset($accountMap[$originUserId])) {
				$resolvedUserId = $originUserId;
				$resolvedUsername = $accountMap[$originUserId];
			} else {
				$roleUserId = intval($roleUserMap[$roleId] ?? 0);
				if ($roleUserId > 0 && isset($accountMap[$roleUserId])) {
					$resolvedUserId = $roleUserId;
					$resolvedUsername = $accountMap[$roleUserId];
				}
			}

			if ($resolvedUsername === '') {
				continue;
			}

			$rows[$index]['username'] = $resolvedUsername;
			if ($resolvedUserId > 0 && $originUserId !== $resolvedUserId && $bindId > 0) {
				try {
					Db::name('user_bind')->where('id', $bindId)->update(['userid' => $resolvedUserId]);
					$rows[$index]['userid'] = $resolvedUserId;
					Log::info('自动修正user_bind.userid成功', [
						'bindid' => $bindId,
						'old_userid' => $originUserId,
						'new_userid' => $resolvedUserId,
						'roleid' => $roleId
					]);
				} catch (\Throwable $e) {
					Log::warning('自动修正user_bind.userid失败', [
						'bindid' => $bindId,
						'old_userid' => $originUserId,
						'new_userid' => $resolvedUserId,
						'roleid' => $roleId,
						'error' => $e->getMessage()
					]);
				}
			}
		}

		return $rows;
    }

    /**
     * 兼容角色时间戳为秒或毫秒两种格式，统一转换为秒。
     */
    protected function normalizeUnixTimeSec(int $raw): int
	{
		$value = intval($raw);
		if ($value <= 0) {
			return 0;
		}
		// 10 位通常为秒，11 位及以上按毫秒处理
		if ($value > 9999999999) {
			$value = intval(floor($value / 1000));
		}
		return $value > 0 ? $value : 0;
    }

    /**
     * 当 role.userid 无法直接映射账号时，基于角色最近登录时间回查 user_log 中的账号。
     */
    protected function resolveUserIdByRoleLogin(int $roleId, int $lastLoginTimeMs): int
	{
		if ($roleId <= 0 || $lastLoginTimeMs <= 0) {
			return 0;
		}

		$roleLoginTime = $this->normalizeUnixTimeSec($lastLoginTimeMs);
		if ($roleLoginTime <= 0) {
			return 0;
		}

		$windowStart = max(0, $roleLoginTime - 600);
		$windowEnd = $roleLoginTime + 600;
		$patterns = ['登陆游戏%', '登录游戏客户端%'];

		foreach ($patterns as $pattern) {
			try {
				$row = Db::name('user_log')->alias('l')
					->join('user_account u', 'u.username = l.username')
					->whereRaw('CAST(l.time AS UNSIGNED) >= ? AND CAST(l.time AS UNSIGNED) <= ?', [$windowStart, $windowEnd])
					->whereLike('l.info', $pattern)
					->orderRaw('ABS(CAST(l.time AS SIGNED) - ' . $roleLoginTime . ') ASC')
					->field('u.id AS user_id,u.username,l.time')
					->find();

				if ($row) {
					return intval($row['user_id'] ?? 0);
				}
			} catch (\Throwable $e) {
				Log::warning('按登录日志回查账号失败', [
					'roleid' => $roleId,
					'pattern' => $pattern,
					'error' => $e->getMessage(),
				]);
				break;
			}
		}

		return 0;
    }

    /**
     * 自动补齐缺失的角色绑定：
     * 1) role.userid 已存在但 user_bind 缺失时回填
     * 2) role.userid 为空时，按角色最近登录时间回查账号后回填
     *
     * @param int $limit 单次最多回填数量，避免高峰期慢查询
     * @return array
     */
    public function syncMissingRoleBindings($limit = 200)
	{
		$cleanLock = Cache::get('gm_clean_data_lock');
		$locked = !empty($cleanLock);
		if ($locked) {
			$lockValue = $cleanLock;
			if (is_array($lockValue) || is_object($lockValue)) {
				$encoded = json_encode($lockValue, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
				$lockValue = $encoded !== false ? $encoded : '[non-scalar-lock]';
			}
			Log::info('自动回填user_bind处于清理保护期：仅执行安全回填', [
				'lock' => (string)$lockValue
			]);
		}

		$maxLimit = intval($limit);
		if ($maxLimit <= 0) {
			$maxLimit = 200;
		}
		if ($maxLimit > 1000) {
			$maxLimit = 1000;
		}
		if ($locked) {
			$maxLimit = min($maxLimit, 50);
		}

		$result = [
			'checked' => 0,
			'inserted' => 0,
			'skipped' => 0,
			'errors' => 0,
			'locked' => $locked ? 1 : 0,
		];

		$missingRoles = Db::name('role')->alias('r')
			->leftJoin('user_bind b', 'b.playerid = r.roleid')
			->where('r.roleid', '>', 0)
			->where('r.roleid', '<', 9223372036854775807)
			->whereNull('b.playerid')
			->field('r.roleid,r.userid,r.name,r.lastlogintime')
			->order('r.roleid', 'asc')
			->limit($maxLimit)
			->select()
			->toArray();

		foreach ($missingRoles as $row) {
			$result['checked']++;
			$roleId = intval($row['roleid'] ?? 0);
			$roleUserId = intval($row['userid'] ?? 0);
			$userId = $roleUserId;
			$roleName = (string)($row['name'] ?? '');
			$lastLoginTime = intval($row['lastlogintime'] ?? 0);

			if ($roleId <= 0) {
				$result['skipped']++;
				continue;
			}

			// 新增：当 role.userid 为空时也尝试按登录日志反查账号，避免“角色有但绑定永远不补”
			if ($userId <= 0) {
				$fallbackUserId = $this->resolveUserIdByRoleLogin($roleId, $lastLoginTime);
				if ($fallbackUserId > 0) {
					$userId = $fallbackUserId;
					Db::name('role')->where('roleid', $roleId)->update(['userid' => $userId]);
					Log::info('自动回填user_bind：role.userid为空，按登录日志补齐', [
						'roleid' => $roleId,
						'new_userid' => $userId,
						'lastlogintime' => $lastLoginTime,
					]);
				} else {
					$result['skipped']++;
					Log::warning('自动回填user_bind跳过：role.userid为空且无法回查', [
						'roleid' => $roleId,
						'lastlogintime' => $lastLoginTime,
					]);
					continue;
				}
			}

			// 安全兜底：仅当账号真实存在时才允许回填绑定，避免清理后产生孤儿绑定
			$userExists = Db::name('user_account')->where('id', $userId)->field('id')->find();
			if (!$userExists) {
				$fallbackUserId = $this->resolveUserIdByRoleLogin($roleId, $lastLoginTime);
				if ($fallbackUserId > 0) {
					$userId = $fallbackUserId;
					if ($userId !== $roleUserId) {
						Db::name('role')->where('roleid', $roleId)->update(['userid' => $userId]);
						Log::info('自动回填user_bind：根据登录日志修正role.userid', [
							'roleid' => $roleId,
							'old_userid' => $roleUserId,
							'new_userid' => $userId,
						]);
					}
				} else {
					$result['skipped']++;
					Log::warning('自动回填user_bind跳过：账号不存在且无法回查', [
						'roleid' => $roleId,
						'userid' => $roleUserId,
						'lastlogintime' => $lastLoginTime,
					]);
					continue;
				}
			}

			$exists = Db::name('user_bind')->where('playerid', $roleId)->find();
			if ($exists) {
				$result['skipped']++;
				continue;
			}

			$serverId = intval(Db::name('user_bind')
				->where('userid', $userId)
				->where('serverid', '>', 0)
				->order('id', 'asc')
				->value('serverid'));

			if ($serverId <= 0) {
				$activeServerIds = Db::name('main_server')
					->where('status', 1)
					->column('serverid');
				if (is_array($activeServerIds) && count($activeServerIds) === 1) {
					$serverId = intval($activeServerIds[0]);
				}
			}

			if ($serverId <= 0) {
				$allServerIds = Db::name('main_server')->column('serverid');
				if (is_array($allServerIds) && count($allServerIds) === 1) {
					$serverId = intval($allServerIds[0]);
				}
			}

			if ($serverId <= 0) {
				$result['skipped']++;
				Log::warning('自动回填user_bind跳过：无法确定serverid', [
					'roleid' => $roleId,
					'userid' => $userId
				]);
				continue;
			}

			try {
				$created = $this->insertOrUpdateByPlayerId([
					'userid' => $userId,
					'serverid' => $serverId,
					'playerid' => $roleId,
					'playername' => $roleName !== '' ? $roleName : ('角色' . $roleId),
					'charge' => '0.00',
					'fb_sc' => 0,
					'zhuanqu' => 0,
					'lq_daycharge' => null,
					'lq_rolecharge' => null,
					'daycharge' => '0.00',
					'chargedate' => '0'
				]);
				if ($created) {
					$result['inserted']++;
				} else {
					$result['skipped']++;
					Log::warning('自动回填user_bind命中重复插入冲突，已自动转为更新', [
						'roleid' => $roleId,
						'userid' => $userId,
						'serverid' => $serverId,
					]);
				}
			} catch (\Throwable $e) {
				$result['errors']++;
				Log::error('自动回填user_bind失败', [
					'roleid' => $roleId,
					'userid' => $userId,
					'error' => $e->getMessage()
				]);
			}
		}

		if ($result['inserted'] > 0 || $result['errors'] > 0) {
			Log::info('自动回填user_bind执行完成', $result);
		}

		return $result;
    }
    public function getAllBindListUID($userid)
	{
		$bind = Bind::where('userid',$userid)->select();
		$data = $bind->toArray();
		return $data;
    }

    public function upLqDayCharge($id,$lq_daycharge)
	{
        $up = Bind::where('id', $id)->find();
		$up->lq_daycharge     = $lq_daycharge;
        $up->save();
    }

    public function upLqRoleCharge($id,$lq_rolecharge)
	{
        $up = Bind::where('id', $id)->find();
		$up->lq_rolecharge     = $lq_rolecharge;
        $up->save();
    }


    public function upBindZhuanqu($id)
	{
        $up = Bind::where('id', $id)->find();
        $up->zhuanqu = 1;
        $up->save();
    }

    public function editBindData($data)
	{
        $up = Bind::where('id', $data['id'])->find();
        $up->charge	= $data['charge'];
        $up->chargedate	= date('Y-m-d');
        $up->daycharge	= $data['daycharge'];
        $up->save();
    }


    public function upChargeForZhuanQu($data)
	{
        $up = Bind::where('id', $data['id'])->find();
        $up->charge	= $data['charge'];
        $up->chargedate	= date('Y-m-d');
        $up->daycharge	= $data['daycharge'];
        $up->save();
    }

    public function upRoleLimit($id,$rolelimit)
	{
        $up = Bind::where('id', $id)->find();
        $up->rolelimit	= $rolelimit;
        $up->save();
    }

    public function upDayLimit($id,$daylimit)
	{
        $up = Bind::where('id', $id)->find();
        $up->daylimit	= $daylimit;
        $up->save();
    }

    public function upBindCharge($id,$charge,$daycharge)
	{

        $up = Bind::where('id', $id)->find();
        $up->charge	= $up['charge'] + $charge;
        $up->chargedate	= date('Y-m-d');
        $up->daycharge	= $daycharge;
        $up->save();
    }

    /**
     * 根据角色ID获取绑定信息（用于数据清理）
     */
    public function getByPlayerId($playerid)
    {
        $bind = Bind::where('playerid', $playerid)->find();
        if ($bind) {
            return $bind->toArray();
        }
        return null;
    }

    /**
     * 根据用户ID获取所有绑定记录（用于数据清理）
     */
    public function getByUserId($userid)
    {
        $binds = Bind::where('userid', $userid)->select();
        if ($binds) {
            return $binds->toArray();
        }
        return [];
    }

    /**
     * 删除指定用户的所有绑定记录（用于数据清理）
     */
    public function deleteByUserId($userid)
    {
        return Bind::where('userid', $userid)->delete();
    }


}

?>

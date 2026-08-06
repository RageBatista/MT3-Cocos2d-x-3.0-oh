<?php
namespace app\model;
use think\Model;
use think\facade\Db;
use think\facade\Cache;
use app\service\CacheLockService;

class UserOrder extends Model{

	protected $table = 'user_order';
	
	// 订单状态常量
	const STATUS_PENDING = 0;  // 待支付
	const STATUS_PAID = 1;     // 已支付
	const STATUS_REFUNDED = 2; // 已退款
	
	// 合法状态迁移表
	const STATUS_TRANSITIONS = [
		self::STATUS_PENDING => [
			self::STATUS_PAID,      // 待支付 -> 已支付
			self::STATUS_REFUNDED   // 待支付 -> 已退款（异常退款）
		],
		self::STATUS_PAID => [
			self::STATUS_REFUNDED   // 已支付 -> 已退款
		],
		self::STATUS_REFUNDED => [
			// 已退款不允许再变更
		]
	];

    public function addOrder($data)
	{

		$user = new UserOrder();
		foreach($data as $key => $val){
			if($val===null||$val==''){
				return false;
			}

		}
		$user->save($data);
		return true;
    }
    public function getOrderId($orderid)
	{
		$order = UserOrder::where('orderid', $orderid)->find();
		return $order;
    }
    public function getOrderById($id)
	{
		$order = UserOrder::where('id', $id)->find();
		return $order;
    }
    /**
     * 更新订单状态（P1-B: 状态机校验 + 并发安全）
     *
     * @param array $data 包含 orderid 和 status 的数据
     * @param bool $skipStateMachine 是否跳过状态机校验（用于内部调用）
     * @return bool|string 成功返回 true，失败返回错误信息
     */
    public function upOrderStatus($data, $skipStateMachine = false)
 {
        $up = UserOrder::where('orderid', $data['orderid'])->find();
        if (!$up) {
            return '订单不存在';
        }
        
        $oldStatus = $up->status;
        $newStatus = $data['status'] ?? $oldStatus;
        
        // ===== P1-B: 状态机校验 =====
        if (!$skipStateMachine && $oldStatus != $newStatus) {
            if (!isset(self::STATUS_TRANSITIONS[$oldStatus])) {
                return '当前状态不允许变更';
            }
            
            if (!in_array($newStatus, self::STATUS_TRANSITIONS[$oldStatus])) {
                return '非法的状态迁移：从状态 ' . $oldStatus . ' 到 ' . $newStatus;
            }
        }
        
        // ===== P1-B: 并发安全更新（CAS 风格）=====
        Db::startTrans();
        try {
            // 重新查询订单状态，防止并发修改
            $currentOrder = UserOrder::where('orderid', $data['orderid'])->find();
            if (!$currentOrder) {
                Db::rollback();
                return '订单不存在';
            }
            
            // 验证状态未被其他请求修改
            if ($currentOrder->status != $oldStatus) {
                Db::rollback();
                return '订单状态已被修改，请重试';
            }
            
            // 使用条件更新
            $affectedRows = UserOrder::where('orderid', $data['orderid'])
                ->where('status', $oldStatus)
                ->update(['status' => $newStatus]);
            
            if ($affectedRows === 0) {
                Db::rollback();
                return '订单状态更新失败，可能已被其他请求修改';
            }
            
            Db::commit();
            
            // ===== 新增：订单支付成功后自动分配佣金 =====
            if ($oldStatus != self::STATUS_PAID && $newStatus == self::STATUS_PAID) {
                // 状态从非成功变为成功，触发佣金分配
                $commissionService = new \app\service\CommissionService();
                $orderData = $currentOrder->toArray();
                $commissionService->distributeCommission($orderData);
            }
            // ===== 佣金分配完成 =====
            
            return true;
        } catch (\Exception $e) {
            Db::rollback();
            return '订单状态更新异常：' . $e->getMessage();
        }
    }
    
    /**
     * 订单退款（P1-B: 状态机校验 + 并发安全 + 幂等性）
     *
     * @param int $id 订单ID
     * @return string 操作结果消息
     */
    public function tuikuan($id)
 {
        // 使用分布式锁保证幂等性
        $lockKey = 'order_refund_lock:' . $id;
        $lockToken = CacheLockService::acquire($lockKey, 30, 'redis');
        
        if ($lockToken === null) {
            return '订单退款处理中，请勿重复操作';
        }
        
        try {
            Db::startTrans();
            
            $up = UserOrder::where('id', $id)->find();
            if (!$up) {
                Db::rollback();
                return '订单不存在';
            }
            
            $oldStatus = $up->status;
            $newStatus = null;
            $msg = '';
            
            // ===== P1-B: 状态机校验 =====
            if ($up['status'] == self::STATUS_PAID) {
                // 已支付 -> 已退款
                $newStatus = self::STATUS_REFUNDED;
                $msg = '修改订单状态为退款';
            } elseif ($up['status'] == self::STATUS_REFUNDED) {
                // 已退款 -> 已支付（恢复）
                $newStatus = self::STATUS_PAID;
                $msg = '修改订单状态为已支付';
            } else {
                Db::rollback();
                return '当前状态不允许退款操作';
            }
            
            // 使用条件更新（CAS 风格）
            $affectedRows = UserOrder::where('id', $id)
                ->where('status', $oldStatus)
                ->update(['status' => $newStatus]);
            
            if ($affectedRows === 0) {
                Db::rollback();
                return '订单状态已被修改，请刷新后重试';
            }
            
            Db::commit();
            return $msg;
        } catch (\Exception $e) {
            Db::rollback();
            return '订单退款异常：' . $e->getMessage();
        } finally {
            // 释放锁（仅释放自身持有的 token）
            CacheLockService::release($lockKey, $lockToken, 'redis');
        }
    }

    public function getOrdermoney($agent=null,$all=null,$date=null)
	{
		$condition = [];
		if($agent!=null){
			if($all!=null){
				$condition[] = ['agent','like','%@'.$agent.'@%'];
			}else{
				$condition[] = ['agent','like',$agent.'|%'];
			}
		}
		if($date!=null){
			$condition[] = ['date','like','%'.$date.'%'];
		}
		$condition[] = ['status','=',1];
        $money = UserOrder::where($condition)->sum('realmoney');
		return $money;
    }

    public function getuserServerOrderList($playerid)
	{
		$condition = [];
		$condition[] = ['status','=',1];
		$condition[] = ['user','like','%"playerid":"'.$playerid.'"%'];
		$agent = UserOrder::where($condition)->select();
		$total = UserOrder::where($condition)->count();
		$data = $agent->toArray();
		$data=[
			'total'=>$total,
			'rows'=>$data
		];
		return $data;
    }

    public function getServerRoleMoney($playerid)
	{
		$condition = [];
		$condition[] = ['status','=',1];
		$condition[] = ['user','like','%"playerid":"'.$playerid.'"%'];
        $money = UserOrder::where($condition)->sum('realmoney');
		return $money;
    }


    public function getOrderList($post=null,$status='all',$table=null,$agent=null)
	{
		$page = isset($post['page'])?max(1,intval($post['page'])):1;
		$limit = isset($post['limit'])?max(1,min(100,intval($post['limit']))):10;
		$sortOrder = (isset($post['sortOrder']) && strtolower($post['sortOrder'])==='desc')?'desc':'asc';
		$allowedSorts = ['id','orderid','status','date','realmoney','paytype','channel'];
		$sort = (isset($post['sort']) && in_array($post['sort'],$allowedSorts))?$post['sort']:'id';
		$condition = [];
		if($table!=null){
			foreach($table as $val){
				$condition[] = [$val[0],$val[1],$val[2]];
			}
		}
		if($status!='all'){
			switch($status){
				case 'yes':
					$status = 1;
					break;
				case 'tuikuan':
					$status = 2;
					break;
				case 'no':
					$status = 0;
					break;
			}
			$condition[] = ['status','=',$status];
		}

		// ===== 修改：支持查看直属玩家订单 + 限制最多2级下级代理订单 =====
		if($agent!=null){
			$agent = addslashes($agent);

			// 获取当前代理的一级和二级下级代理ID列表
			$subAgents = $this->getSubAgentsUpTo2Levels($agent);

			// 收集所有允许查看的代理ID（包括自己）
			$allowedAgents = array_merge([$agent], $subAgents);

			// 先构建基础查询
			$query = UserOrder::where($condition);

			// 添加代理ID的 OR 条件组
			// 使用闭包正确构建 (agent like 'X|%' OR agent like 'Y|%' OR ...)
			$query->where(function($q) use ($allowedAgents){
				foreach($allowedAgents as $idx => $aid){
					if($idx == 0){
						// 第一个条件使用 where
						$q->where('agent', 'like', $aid.'|%');
					}else{
						// 后续条件使用 whereOr
						$q->whereOr('agent', 'like', $aid.'|%');
					}
				}
			});

			// 执行查询
			$result = $query->limit($limit)->page($page)->order($sort ,$sortOrder)->select();
			$total = UserOrder::where($condition)
				->where(function($q) use ($allowedAgents){
					foreach($allowedAgents as $idx => $aid){
						if($idx == 0){
							$q->where('agent', 'like', $aid.'|%');
						}else{
							$q->whereOr('agent', 'like', $aid.'|%');
						}
					}
				})
				->count();

			$agent = $result;
		}else{
			// 没有指定代理，正常查询
			$agent = UserOrder::where($condition)->limit($limit)->page($page)->order($sort ,$sortOrder)->select();
			$total = UserOrder::where($condition)->count();
		}
		// ===== 修改结束 =====

		$data = is_array($agent) ? $agent : $agent->toArray();
		$data=[
			'total'=>$total,
			'rows'=>$data
		];
		return $data;
    }

	/**
	 * 获取指定代理的一级和二级下级代理ID列表
	 * @param int $agentId 当前代理ID
	 * @return array 下级代理ID数组
	 */
	private function getSubAgentsUpTo2Levels($agentId)
	{
		$agentModel = new Agent();

		// 1. 获取一级下级代理（lastagent = 当前代理ID）
		$level1Agents = $agentModel->where('lastagent', $agentId)
			->where('type', 2)
			->column('id');

		$result = $level1Agents;

		// 2. 获取二级下级代理（lastagent = 一级代理ID）
		if(count($level1Agents) > 0){
			$level2Agents = $agentModel->whereIn('lastagent', $level1Agents)
				->where('type', 2)
				->column('id');

			$result = array_merge($result, $level2Agents);
		}

		return $result;
	}


    public function getUserAllPay($arr)
	{

		$agent = UserOrder::where($arr)->select();
		$count = UserOrder::where($arr)->count();
		$data = $agent->toArray();
		$data=[
			'data'=>$data,
			'count'=>$count
		];
		return $data;
    }

    /**
     * 统计指定用户的订单数量（用于数据清理）
     */
    public function countByUserId($userid)
    {
        [$playerIds, $username] = $this->resolveCleanupIdentity($userid);

        $query = UserOrder::where('id', '>', 0);
        $this->applyCleanupFilter($query, $playerIds, $username);
        return $query->count();
    }

    /**
     * 删除指定用户的所有订单（用于数据清理）
     */
    public function deleteByUserId($userid)
    {
        [$playerIds, $username] = $this->resolveCleanupIdentity($userid);

        $query = UserOrder::where('id', '>', 0);
        $this->applyCleanupFilter($query, $playerIds, $username);
        return $query->delete();
    }

    /**
     * 清理辅助：解析用户对应的角色ID和账号名。
     */
    private function resolveCleanupIdentity($userid): array
    {
        $uid = intval($userid);
        if ($uid <= 0) {
            return [[], ''];
        }

        $playerIds = Db::name('user_bind')->where('userid', $uid)->column('playerid');
        $cleanPlayerIds = [];
        if (is_array($playerIds)) {
            foreach ($playerIds as $pid) {
                $pid = intval($pid);
                if ($pid > 0) {
                    $cleanPlayerIds[$pid] = $pid;
                }
            }
        }

        $username = '';
        $userRow = Db::name('user_account')->where('id', $uid)->field('username')->find();
        if ($userRow) {
            $username = trim((string)($userRow['username'] ?? ''));
        }

        return [array_values($cleanPlayerIds), $username];
    }

    /**
     * 清理辅助：将订单匹配条件应用到查询。
     * user_order.user 为 JSON 文本，历史格式可能是数字/字符串两种 playerid。
     */
    private function applyCleanupFilter($query, array $playerIds, string $username): void
    {
        $query->where(function ($where) use ($playerIds, $username) {
            $hasCondition = false;

            foreach ($playerIds as $pid) {
                $pid = intval($pid);
                if ($pid <= 0) {
                    continue;
                }

                $numericPattern = '%"playerid":' . $pid . '%';
                $stringPattern = '%"playerid":"' . $pid . '"%';

                if (!$hasCondition) {
                    $where->where(function ($sub) use ($numericPattern, $stringPattern) {
                        $sub->whereLike('user', $numericPattern)
                            ->whereOr('user', 'like', $stringPattern);
                    });
                    $hasCondition = true;
                } else {
                    $where->whereOr(function ($sub) use ($numericPattern, $stringPattern) {
                        $sub->whereLike('user', $numericPattern)
                            ->whereOr('user', 'like', $stringPattern);
                    });
                }
            }

            $username = trim($username);
            if ($username !== '') {
                $usernamePattern = '%"username":"' . $username . '"%';
                if (!$hasCondition) {
                    $where->whereLike('user', $usernamePattern);
                } else {
                    $where->whereOr('user', 'like', $usernamePattern);
                }
                $hasCondition = true;
            }

            if (!$hasCondition) {
                $where->whereRaw('1 = 0');
            }
        });
    }

    /**
     * 获取最近充值订单（首页展示用）
     */
    public function getRecentOrders($limit = 5)
    {
        return UserOrder::where('status', 1)
            ->order('id', 'desc')
            ->limit($limit)
            ->field('id, orderid, realmoney, paytype, date, user')
            ->select()
            ->toArray();
    }
}

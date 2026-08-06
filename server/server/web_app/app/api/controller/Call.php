<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;
use app\model\UserOrder as UL;
use app\model\PayChannel as PC;
use app\model\UserLog as ULog;
use app\gm\Gm as Game;
use app\model\User;
use app\model\Bind;
use app\model\Server;
use app\service\CacheLockService;
use think\facade\Db;
use think\facade\Log;
use think\facade\Cache;

//支付接口
use app\api\pay\EpayCore;

class Call extends BaseController
{
	private function payCallbackLegacyTextEnabled(): bool
	{
		$raw = strtolower(trim((string)env('API_PAY_CALLBACK_LEGACY_TEXT', '1')));
		return !in_array($raw, ['0', 'false', 'off', 'no'], true);
	}

	private function callbackOkResponse(array $data = [])
	{
		if ($this->payCallbackLegacyTextEnabled()) {
			return 'success';
		}
		return api_json(array_merge([
			'code' => 1,
			'msg' => 'success',
		], $data));
	}

	private function callbackFailResponse(string $msg = 'fail', array $data = [])
	{
		if ($this->payCallbackLegacyTextEnabled()) {
			return 'fail';
		}
		return api_json(array_merge([
			'code' => 0,
			'msg' => $msg,
		], $data), 400);
	}

	private function payCallbackDebugEnabled(): bool
	{
		if (!(bool)config('security.debug_endpoints.pay_callback_probe_enabled', false)) {
			return false;
		}

		if ((bool)config('security.debug_endpoints.pay_callback_probe_local_only', true)) {
			$clientIp = (string)$this->request->ip();
			return in_array($clientIp, ['127.0.0.1', '::1'], true);
		}

		return true;
	}

	private function safeUnserializeArray($value): array
	{
		if (!is_string($value) || $value === '') {
			return [];
		}
		try {
			$result = @unserialize($value, ['allowed_classes' => false]);
		} catch (\Throwable $e) {
			return [];
		}
		return is_array($result) ? $result : [];
	}

	// 测试接口 - 确认回调URL可以访问
	public function test()
	{
		if (!$this->payCallbackDebugEnabled()) {
			Log::warning('支付调试接口被拒绝访问', ['endpoint' => 'api/call/test', 'ip' => $this->request->ip()]);
			return api_json(['code' => 0, 'msg' => 'Not Found'], 404);
		}

		$logPath = runtime_path().'log/';
		$logFile = $logPath.date('Ymd').'_pay_callback.log';
		
		// 确保日志目录存在
		if(!is_dir($logPath)){
			@mkdir($logPath, 0777, true);
		}
		
		// 尝试写入日志
		$writeResult = @file_put_contents($logFile, date('Y-m-d H:i:s').' - 测试接口被访问'.PHP_EOL, FILE_APPEND);
		
		return api_json([
			'code' => 1,
			'msg' => '回调接口正常',
			'data' => [
				'time' => date('Y-m-d H:i:s'),
				'log_writable' => is_writable($logPath),
				'log_exists' => file_exists($logFile),
				'write_result' => $writeResult !== false ? 'success' : 'failed'
			]
		]);
	}
	
	// 查看最近支付订单的回调URL（用于排查）
	public function checkurl()
	{
		if (!$this->payCallbackDebugEnabled()) {
			Log::warning('支付调试接口被拒绝访问', ['endpoint' => 'api/call/checkurl', 'ip' => $this->request->ip()]);
			return api_json(['code' => 0, 'msg' => 'Not Found'], 404);
		}

		$order = new UL();
		// 获取最近5个订单
		$orders = \think\facade\Db::table('user_order')
			->order('id desc')
			->limit(5)
			->select()
			->toArray();
		
		$result = [];
		foreach($orders as $o){
			$result[] = [
				'orderid' => $o['orderid'],
				'status' => $o['status'],
				'date' => $o['date'],
				'channel' => $o['channel']
			];
		}
		
		// 获取当前请求生成的回调URL（模拟支付时的逻辑）
		$channel_host = input('server.REQUEST_SCHEME') . '://' . input('server.HTTP_HOST');
		$notify_url = $channel_host.":88/api/call/epay";
		
		return api_json([
			'code' => 1,
			'msg' => '最近订单信息',
			'data' => [
				'current_notify_url' => $notify_url,
				'recent_orders' => $result,
				'tip' => '检查 current_notify_url 是否可以从公网访问'
			]
		]);
	}
	
    /**
     * 支付回调处理（P0安全加固）
     * 1. 幂等控制：防止重复回调导致重复发货
     * 2. 事务一致性：发货+订单状态更新在同一事务中
     * 3. 防重放：timestamp/nonce验证
     * 4. 日志脱敏：避免记录敏感信息
     */
    public function epay()
    {
        // P0: 获取安全配置
        $securityConfig = config('security.pay_callback');
        $replayProtectionEnabled = $securityConfig['replay_protection_enabled'] ?? true;
        $timestampTtl = $securityConfig['timestamp_ttl'] ?? 300;
        $idempotencyEnabled = $securityConfig['idempotency_enabled'] ?? true;
        $logMaskingEnabled = $securityConfig['log_masking_enabled'] ?? true;
        $maskFields = $securityConfig['mask_fields'] ?? ['password', 'key', 'token', 'secret', 'pay_key'];

        // 日志脱敏函数
        $maskSensitiveData = function($data) use ($logMaskingEnabled, $maskFields) {
            if (!$logMaskingEnabled) {
                return $data;
            }
            foreach ($maskFields as $field) {
                if (isset($data[$field])) {
                    $data[$field] = '***MASKED***';
                }
            }
            return $data;
        };

        // 记录回调日志（脱敏）
        $logPath = runtime_path().'log/';
        $logFile = $logPath.date('Ymd').'_pay_callback.log';

        // 确保日志目录存在
        if(!is_dir($logPath)){
            @mkdir($logPath, 0777, true);
        }

        // 脱敏后记录日志
        $maskedGet = $maskSensitiveData($_GET);
        $maskedPost = $maskSensitiveData($_POST);
        @file_put_contents($logFile, date('Y-m-d H:i:s').' - 收到支付回调 GET: '.json_encode($maskedGet).' POST: '.json_encode($maskedPost).PHP_EOL, FILE_APPEND);

        // 兼容GET和POST回调
        $payGet = $this->request->param();
        $maskedPayGet = $maskSensitiveData($payGet);
        @file_put_contents($logFile, date('Y-m-d H:i:s').' - 解析参数: '.json_encode($maskedPayGet).PHP_EOL, FILE_APPEND);

        if(empty($payGet['out_trade_no'])){
            file_put_contents($logFile, date('Y-m-d H:i:s').' - 错误: 缺少订单号'.PHP_EOL, FILE_APPEND);
            return $this->callbackFailResponse('缺少订单号');
        }

        $order = new UL();
        $findOrder = $order->getOrderId($payGet['out_trade_no']);

        if(!$findOrder || !isset($findOrder['orderid'])){
            file_put_contents($logFile, date('Y-m-d H:i:s').' - 订单不存在: '.$payGet['out_trade_no'].PHP_EOL, FILE_APPEND);
            return $this->callbackFailResponse('订单不存在');
        }

        // P0: 幂等控制 - 订单已支付则直接返回成功
        if($findOrder['status'] == 1){
            file_put_contents($logFile, date('Y-m-d H:i:s').' - 订单已回调（幂等控制）'.PHP_EOL, FILE_APPEND);
            return $this->callbackOkResponse();
        }

        // P0: 防重放保护
        if ($replayProtectionEnabled) {
            $replayCheckResult = $this->checkReplayAttack($payGet['out_trade_no'], $payGet, $timestampTtl, $logFile);
            if (!$replayCheckResult['valid']) {
                Log::warning('支付回调防重放保护触发', [
                    'orderid' => $payGet['out_trade_no'],
                    'reason' => $replayCheckResult['reason']
                ]);
                file_put_contents($logFile, date('Y-m-d H:i:s').' - 防重放保护触发: '.$replayCheckResult['reason'].PHP_EOL, FILE_APPEND);
                return $this->callbackFailResponse('防重放保护触发');
            }
        }

        // P0: 幂等控制 - 使用分布式锁防止并发回调
        $lockKey = null;
        $lockToken = null;
        if ($idempotencyEnabled) {
            $lockKey = 'pay_callback_lock:' . $payGet['out_trade_no'];
            $lockToken = CacheLockService::acquire($lockKey, 60, 'redis');
            if ($lockToken === null) {
                file_put_contents($logFile, date('Y-m-d H:i:s').' - 获取幂等锁失败（并发回调）'.PHP_EOL, FILE_APPEND);
                return $this->callbackFailResponse('并发回调，锁竞争失败'); // 返回失败让支付平台稍后重试
            }
        }

        try {
            Db::startTrans();

            // 重新查询订单状态（防止幻读）
            $findOrder = $order->getOrderId($payGet['out_trade_no']);
            if($findOrder['status'] == 1){
                Db::commit();
                file_put_contents($logFile, date('Y-m-d H:i:s').' - 订单已回调（事务内幂等检查）'.PHP_EOL, FILE_APPEND);
                return $this->callbackOkResponse();
            }

            $userarr = json_decode($findOrder['user'],true);
            $channel = new PC();
            $findChannel = $channel->getChannel($findOrder['channel']);

            //支付接口地址
            $epay_config['apiurl'] = $findChannel['pay_api'];
            //商户ID
            $epay_config['pid'] = $findChannel['pay_pid'];
            //商户密钥
            $epay_config['key'] = $findChannel['pay_key'];
            $epay = new EpayCore($epay_config);
            $status = $epay->verifyNotify($payGet);

            file_put_contents($logFile, date('Y-m-d H:i:s').' - 签名验证结果: '.($status?'成功':'失败').PHP_EOL, FILE_APPEND);

            if($status){
                // P0: 发货和状态更新在同一事务中
                $send = $this->send($findOrder);
                file_put_contents($logFile, date('Y-m-d H:i:s').' - 发货结果: '.$send.PHP_EOL, FILE_APPEND);

                if($send){
                    $status_data = [
                        'orderid'=>$payGet['out_trade_no'],
                        'status'=>1
                    ];
                    $order->upOrderStatus($status_data);
                    $userLog = new ULog();
                    $userLog->addUserLog($userarr['username'],'订单ID：'.$payGet['out_trade_no'].'，'.$send,$this->genericVariable);
                    file_put_contents($logFile, date('Y-m-d H:i:s').' - 订单更新成功'.PHP_EOL, FILE_APPEND);

                    Db::commit();
                    return $this->callbackOkResponse();
                }else{
                    file_put_contents($logFile, date('Y-m-d H:i:s').' - 发货失败: '.$send.PHP_EOL, FILE_APPEND);
                    Db::rollback();
                    return $this->callbackFailResponse('发货失败');
                }
            }else{
                // 签名验证失败，记录异常并返回失败
                file_put_contents($logFile, date('Y-m-d H:i:s').' - 签名验证失败，可能存在篡改'.PHP_EOL, FILE_APPEND);
                Db::rollback();
                return $this->callbackFailResponse('签名验证失败');
            }
        } catch (\Exception $e) {
            Db::rollback();
            Log::error('支付回调处理异常', [
                'orderid' => $payGet['out_trade_no'],
                'error' => $e->getMessage()
            ]);
            file_put_contents($logFile, date('Y-m-d H:i:s').' - 处理异常: '.$e->getMessage().PHP_EOL, FILE_APPEND);
            return $this->callbackFailResponse('回调处理异常');
        } finally {
            // 释放幂等锁
            if ($idempotencyEnabled && $lockKey !== null) {
                CacheLockService::release($lockKey, $lockToken, 'redis');
            }
        }
    }

    /**
     * 防重放检查
     * @param string $orderid 订单号
     * @param array $params 回调参数
     * @param int $timestampTtl 时间戳有效期（秒）
     * @param string $logFile 日志文件路径
     * @return array ['valid' => bool, 'reason' => string]
     */
    private function checkReplayAttack($orderid, $params, $timestampTtl, $logFile)
    {
        // 1. 检查时间戳（如果上游提供）
        if (isset($params['timestamp'])) {
            $timestamp = intval($params['timestamp']);
            $currentTime = time();
            $timeDiff = abs($currentTime - $timestamp);

            if ($timeDiff > $timestampTtl) {
                return [
                    'valid' => false,
                    'reason' => '时间戳过期，当前时间:' . $currentTime . '，回调时间:' . $timestamp . '，差值:' . $timeDiff . '秒'
                ];
            }
        }

        // 2. nonce 为强制项（防重放）
        if (isset($params['nonce']) && (string)$params['nonce'] !== '') {
            $nonceKey = 'pay_callback_nonce:' . $params['nonce'];
            $existingNonce = Cache::store('redis')->get($nonceKey);

            if ($existingNonce) {
                return [
                    'valid' => false,
                    'reason' => 'nonce已使用，可能存在重放攻击: ' . $params['nonce']
                ];
            }

            // 存储nonce，有效期比timestampTtl稍长
            Cache::store('redis')->set($nonceKey, $orderid, $timestampTtl + 60);
        } else {
            Log::warning('支付回调未提供nonce参数，已拒绝', [
                'orderid' => $orderid,
                'params' => array_keys($params)
            ]);
            file_put_contents($logFile, date('Y-m-d H:i:s').' - 错误: 回调未提供nonce参数，拒绝处理'.PHP_EOL, FILE_APPEND);
            return [
                'valid' => false,
                'reason' => 'missing_nonce'
            ];
        }

        return ['valid' => true, 'reason' => ''];
    }
	
    /**
     * P2安全修复：测试/调试回调入口
     * 仅允许在非生产环境使用（APP_ENV != production）
     * 生产环境直接返回403
     */
    public function epay1()
    {
  // 环境检查：仅允许开发/测试环境
  $appEnv = config('app.app_env') ?? env('APP_ENV', 'production');
  if ($appEnv === 'production') {
   Log::warning('epay1测试接口在生产环境被访问', [
    'ip' => $this->request->ip(),
    'time' => date('Y-m-d H:i:s')
   ]);
   return json(['code' => 403, 'msg' => '此接口仅限测试环境使用']);
  }
  
  $order = new UL();
  $findOrder = $order->getOrderId("pay2025010801165702710");
  if (!$findOrder) {
   return json(['code' => 0, 'msg' => '测试订单不存在']);
  }
  $send = $this->send($findOrder);
  return json([
   'code' => $send ? 1 : 0,
   'msg' => $send ? '测试发货执行成功' : '测试发货执行失败',
   'result' => $send
  ]);

 }
	
	private function send($findOrder)
    {
		$userarr = json_decode($findOrder['user'],true);
		$user = new User();
		$userData = $user->getUsername($userarr['username']);
		if(!$userData){
			return false;
		}
		$bind = new Bind();
		$condition = [
			['userid','=',$userData['id']],
			['playerid','=',$userarr['playerid']]
		];
		$bindData = $bind->getBindData($condition);
		if(!$bindData)return false;
		$server = new Server();
		$serverData = $server->getServerId($bindData['serverid']);
		if(!$serverData){
			return false;
		}
		$itemarr = json_decode($findOrder['item'],true);
		$money = $itemarr['price'];
		
		
		$Game = new Game();
		$data = array(
			'serverip'  => $serverData['serverip'],
			'gmlocal'  => $serverData['gmlocal'],
			'gmport'  => $serverData['gmport'],
			'playerid'  => $bindData['playerid'],
		);
	
	// ===== P1-B: 日限更新并发安全 =====
	// 使用 Redis 原子计数器保证 daylimit 更新的并发安全
	$daylimitUpdated = false;
	if($itemarr['daylimit']!=0){
		$dayLimitMax = intval($itemarr['daylimit'] ?? 0);
		// 使用 Redis 原子计数器
		$redisDayLimitKey = 'daylimit:' . $bindData['id'] . ':' . $itemarr['id'] . ':' . date('Y-m-d');
		$currentCount = Cache::store('redis')->inc($redisDayLimitKey);
		
		// 设置过期时间（2天，确保跨天自动过期）
		if ($currentCount === 1) {
			Cache::store('redis')->expire($redisDayLimitKey, 172800);
		}
		
		// 检查是否超限
		if ($currentCount > $dayLimitMax) {
			// 超限，回滚计数
			Cache::store('redis')->dec($redisDayLimitKey);
			return false; // 发货失败
		}
		
		// 同步更新数据库（使用条件更新防止并发冲突）
		$today = date('Y-m-d');
		$bind = new Bind();
		
		// 使用数据库条件更新（CAS 风格）
		Db::startTrans();
		try {
			// 重新查询最新数据
			$bindData = $bind->getPlayerById($bindData['id']);
			
			if($bindData['daylimit']==null){
				$daylimit = [
					$itemarr['id']=>[
						'date'=>$today,
						'num'=>$currentCount
					]
				];
				$daylimit = serialize($daylimit);
			}else{
				$daylimit = $this->safeUnserializeArray($bindData['daylimit']);
				// 验证日期是否匹配，防止跨天问题
				if(isset($daylimit[$itemarr['id']]) && $daylimit[$itemarr['id']]['date']!=$today){
					// 日期不匹配，重置计数
					$daylimit[$itemarr['id']] = [
						'date'=>$today,
						'num'=>$currentCount
					];
				}elseif(isset($daylimit[$itemarr['id']]) && $daylimit[$itemarr['id']]['date']==$today){
					// 日期匹配，更新计数（使用 Redis 计数器值）
					$daylimit[$itemarr['id']]['num'] = $currentCount;
				}else{
					// 首次购买该商品
					$daylimit[$itemarr['id']] = [
						'date'=>$today,
						'num'=>$currentCount
					];
				}
				$daylimit = serialize($daylimit);
			}
			
			$bind->upDayLimit($bindData['id'],$daylimit);
			$daylimitUpdated = true;
			Db::commit();
		} catch (\Exception $e) {
			Db::rollback();
			// 回滚 Redis 计数
			Cache::store('redis')->dec($redisDayLimitKey);
			return false;
		}
	}
	
	// rolelimit 更新（使用条件更新）
	if($itemarr['rolelimit']!=0){
		$roleLimitMax = intval($itemarr['rolelimit'] ?? 0);
		Db::startTrans();
		try {
			// 重新查询最新数据
			$bindData = $bind->getPlayerById($bindData['id']);
			
			if($bindData['rolelimit']==null){
				$rolelimit = [
					$itemarr['id']=>1
				];
				$rolelimit = serialize($rolelimit);
			}else{
				$rolelimit = $this->safeUnserializeArray($bindData['rolelimit']);
				// 再次检查是否超限
				if(isset($rolelimit[$itemarr['id']]) && $rolelimit[$itemarr['id']] >= $roleLimitMax){
					Db::rollback();
					// 回滚 daylimit 计数
					if ($daylimitUpdated) {
						$redisDayLimitKey = 'daylimit:' . $bindData['id'] . ':' . $itemarr['id'] . ':' . date('Y-m-d');
						Cache::store('redis')->dec($redisDayLimitKey);
					}
					return false;
				}
				$rolelimit[$itemarr['id']] = ($rolelimit[$itemarr['id']] ?? 0) + 1;
				$rolelimit = serialize($rolelimit);
			}
			$bind->upRoleLimit($bindData['id'],$rolelimit);
			Db::commit();
		} catch (\Exception $e) {
			Db::rollback();
			// 回滚 daylimit 计数
			if ($daylimitUpdated) {
				$redisDayLimitKey = 'daylimit:' . $bindData['id'] . ':' . $itemarr['id'] . ':' . date('Y-m-d');
				Cache::store('redis')->dec($redisDayLimitKey);
			}
			return false;
		}
	}
	// ===== P1-B: 日限更新并发安全完成 =====
		$beishu=intval($itemarr['beishu']);
	    
		if($beishu>0){
			$money = intval($money) * $beishu;
		}
		if($bindData['chargedate']==date('Y-m-d')){
			$daycharge = intval($money) + intval($bindData['daycharge']);
		}else{
			$daycharge = intval($money);
		}
		
		$upBindCharge = $bind->upBindCharge($bindData['id'],intval($money),intval($daycharge));
		//更新累计
		
		if($itemarr['xianyu']!=0){
			$data['number'] = $itemarr['xianyu'];
			$gameNotify = $Game->addqian($data);
		}
		if($itemarr['vip']!=0){
			$data['number'] = $itemarr['vip'];
			$gameNotify = $Game->addvipexp($data);
		}
		if($itemarr['mailinfo']!=0&&$itemarr['mailinfo']!=null){
			$data['content']='尊敬的玩家，您充值的【'.$itemarr['name'].'】已到账，请及时领取，祝您游戏愉快，如有疑问，请及时联系客服！';
			$data['awardContent'] = $itemarr['mailinfo'];
			
			$data['title']='充值邮件';
			$data['duration']=0;
			$gameNotify = $Game->mail($data);
		}
		
		

		if(isset($gameNotify[0])){
			if(strpos($gameNotify[0],'success') !== false){
				$GsInfo = '购买的【'.$itemarr['name'].'】礼包，发货成功，系统回调：'.json_encode($gameNotify);
			}else{
				$GsInfo = '购买的【'.$itemarr['name'].'】礼包，发货失败，系统回调：'.json_encode($gameNotify);
			}
		}else{
			$GsInfo = '购买的【'.$itemarr['name'].'】礼包，通信失败，系统回调：'.json_encode($gameNotify);
		}
		
		
		return $GsInfo;
	}
	
	
	
}

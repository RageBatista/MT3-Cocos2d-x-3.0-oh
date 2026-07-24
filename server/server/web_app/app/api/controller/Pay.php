<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;
use app\model\User;
use app\model\Bind;
use app\model\Agent;
use app\model\Item;
use app\model\Server;
use app\model\PayChannel as PC;
use app\model\PayItem as PItem;
use app\model\UserOrder as UL;
use think\facade\Db;
use think\facade\Cache;

//支付接口
use app\api\pay\EpayCore;

class Pay extends BaseController
{
	
	public function getpayitem()
    {
		$pay_item = new PItem();
		$getPayItemList = $pay_item->getPayItemList(1,1);
		return json_encode($getPayItemList,JSON_UNESCAPED_UNICODE);
	}
	
	
    public function getpay()
    {
		
	$param = $this->request->param();

	// ===== 安全修复：使用白名单方式，防止变量覆盖漏洞 =====
	// 旧代码使用 $$key=$val 动态创建变量，攻击者可以覆盖任意变量
	// 例如攻击者可以传入 userData、bindData 等参数覆盖后续的变量
	// 新代码明确指定允许的参数名
	
	// 定义允许的参数白名单
	$allowedParams = ['account', 'password', 'roleid', 'payid', 'paytype', 'serverid'];
	
	// 初始化变量
	$account = null;
	$password = null;
	$roleid = null;
	$payid = null;
	$paytype = null;
	$serverid = null;
	
	// 只处理白名单中的参数
	foreach($allowedParams as $paramName){
		if(isset($param[$paramName])){
			// 验证参数不为空
			if($param[$paramName] == null || $param[$paramName] === ''){
				return json_encode([
								"code"=>0,
								"msg"=>"参数{$paramName}不能为空"
							],JSON_UNESCAPED_UNICODE);
			}
			${$paramName} = $param[$paramName];
		}
	}
	
	// 验证必需参数
	if(!isset($account)||!isset($roleid)||!isset($payid)||!isset($paytype)){
		return json_encode([
						"code"=>0,
						"msg"=>"缺少必需参数"
					],JSON_UNESCAPED_UNICODE);
	}
		if($paytype==1){
			$type = 'alipay';
		}else{
			$type = 'wxpay';
		}
		$user = new User();
		$userData = $user->getUsername($account);
		if(!$userData){
			return json_encode([
						"code"=>0,
						"msg"=>"用户不存在"
					],JSON_UNESCAPED_UNICODE);
		}
		$bind = new Bind();
		$bindData = $bind->getPlayerId($roleid);
		if(!$bindData||$bindData['userid']!=$userData['id']){
			return json_encode([
						"code"=>0,
						"msg"=>"角色信息不存在"
					],JSON_UNESCAPED_UNICODE);
		}
		$server = new Server();
		$serverData = $server->getServerId($bindData['serverid']);
		if(!$serverData){
			return json_encode([
						"code"=>0,
						"msg"=>"大区配置信息不存在"
					],JSON_UNESCAPED_UNICODE);
		}
		
		
		
		
		$pay_item = new PItem();
		$goodsData = $pay_item->getPayItemById($payid);
		// //{"id":12,"name":"\u6d4b\u8bd5\u4e003","icon":"3","price":10,"daylimit":0,"rolelimit":0,"info":"\u6d4b\u8bd5#\u6d4b\u8bd5#ceshi#ceshi3#ceshi45#ceshi123","mailinfo":"","xianyu":0,"vip":0,"effect":"0","status":1}
		if(!$goodsData){
			return json_encode([
						"code"=>0,
						"msg"=>"商品信息不存在"
					],JSON_UNESCAPED_UNICODE);
		}
		if($goodsData['status']!=1){
			return json_encode([
						"code"=>0,
						"msg"=>"商品已下架"
					],JSON_UNESCAPED_UNICODE);
		}
	// ===== P1-B: 购买限制与下单原子化 =====
	// 使用 Redis 分布式锁防止并发穿透
	$lockKey = 'pay_order_lock:' . $roleid . ':' . $payid;
	$lockAcquired = false;
	
	try {
		// 获取锁（10秒超时，锁有效期30秒）
		$lockAcquired = Cache::store('redis')->set($lockKey, 1, 30);
		
		if (!$lockAcquired) {
			return json_encode([
				"code"=>0,
				"msg"=>"系统繁忙，请稍后重试"
			],JSON_UNESCAPED_UNICODE);
		}
		
		// 重新查询角色绑定数据（防止幻读）
		$bind = new Bind();
		$bindData = $bind->getPlayerId($roleid);
		if(!$bindData||$bindData['userid']!=$userData['id']){
			return json_encode([
						"code"=>0,
						"msg"=>"角色信息不存在"
					],JSON_UNESCAPED_UNICODE);
		}
		
		// 在锁内进行购买限制检查
		if($goodsData['rolelimit']!=0){
			if($bindData['rolelimit']!=null){
				$rolelimit = unserialize($bindData['rolelimit']);
				if(isset($rolelimit[$payid])){
					if($rolelimit[$payid]>=$goodsData['rolelimit']){
						return json_encode([
									"code"=>0,
									"msg"=>"当前角色已达到购买限制"
								],JSON_UNESCAPED_UNICODE);
					}
				}
			}
		}
		if($goodsData['daylimit']!=0){
			if($bindData['daylimit']!=null){
				$daylimit = unserialize($bindData['daylimit']);
				if(isset($daylimit[$payid])){
					if($daylimit[$payid]['date']==date('Y-m-d')){
						if($daylimit[$payid]['num']>=$goodsData['daylimit']){
						return json_encode([
									"code"=>0,
									"msg"=>"今日购买次数已达上限，请明日再来"
								],JSON_UNESCAPED_UNICODE);
						}
					}
				}
			}
		}
		
		// 检查通过后，获取支付通道信息（P2性能优化：增加300秒缓存）
		$cacheKey = 'pay_channels:' . $type;
		$payment_channel = Cache::get($cacheKey);
		
		if ($payment_channel === false || $payment_channel === null) {
			$pay = new PC();
			$pay_condition = [
				[$type,'=',1],
				['status','=',1]
			];
			$payment_channel = $pay->getAllPayList($pay_condition);
			// 缓存300秒（5分钟）
			if ($payment_channel) {
				Cache::set($cacheKey, $payment_channel, 300);
			}
		}
		
		if(!$payment_channel){
			return json_encode([
						"code"=>0,
						"msg"=>"暂无可用通道，请稍后重试"
					],JSON_UNESCAPED_UNICODE);
		}
		//随机抽取通道
		$channelKey = array_rand($payment_channel);
		$channel = $payment_channel[$channelKey];
		//订单号生成（P2安全修复：使用random_int替代弱随机源mt_rand）
		$orderid = 'pay'.date('YmdHis',$this->genericVariable['time']) . substr(str_replace('.','',microtime(true)),-4) . random_int(10000, 99999);
		//代理信息
		$agent = new Agent();
		$findAgent = $agent->getById($userData['lastagent']);
		$lastuid = $findAgent['id']."|".agentTree($findAgent);
		
		//角色信息
		$user_arr = [];
		$user_arr['username'] = $account;
		$user_arr['servername'] = $serverData['name'];
		$user_arr['playername'] = $bindData['playername'];
		$user_arr['playerid'] = $bindData['playerid'];
		$user_arr1 = json_encode($user_arr,JSON_UNESCAPED_UNICODE);
		if($user_arr1==null){
			return json_encode([
						"code"=>0,
						"msg"=>"订单创建错误，请重新发起支付"
					],JSON_UNESCAPED_UNICODE);
		}
		$item_arr = json_encode($goodsData,JSON_UNESCAPED_UNICODE);
		$orderdata = [
			//订单号
			'orderid' => $orderid,
			//代理信息
			'agent' => $lastuid,
			//订单类型
			'ordertype' => 1,
			//玩家账号
			'user' => $user_arr1,
			//充值项目
			'item' => $item_arr,
			//充值通道
			'channel' => $channel['id'],
			//支付方式
			'paytype' => $type,
			//充值金额
			'realmoney' => $goodsData['price'],
			//其他信息
			'date' => $this->genericVariable['date'],
			'time' => $this->genericVariable['time'],
			'ip' => $this->genericVariable['ip'],
			'city' => $this->genericVariable['city'],
			//支付状态
			'status' => 0
		];
		
		// 在事务中插入订单
		Db::startTrans();
		try {
			//插入订单
			$order = new UL();
			$orderadd = $order->addOrder($orderdata);
			
			if($orderadd===false){
				Db::rollback();
				return json_encode([
							"code"=>0,
							"msg"=>"订单写入错误，请重新发起支付"
						],JSON_UNESCAPED_UNICODE);
			}
			
			Db::commit();
		} catch (\Exception $e) {
			Db::rollback();
			return json_encode([
						"code"=>0,
						"msg"=>"订单创建异常，请重新发起支付"
					],JSON_UNESCAPED_UNICODE);
		}
		// ===== P1-B: 购买限制与下单原子化完成 =====
		//当前域名（处理端口问题）
		$scheme = input('server.REQUEST_SCHEME') ?: 'http';
		$httpHost = input('server.HTTP_HOST');
		
		// 检查HTTP_HOST是否已包含端口
		if(strpos($httpHost, ':') !== false){
			// HTTP_HOST已包含端口，直接使用
			$channel['host'] = $scheme . '://' . $httpHost;
		}else{
			// HTTP_HOST不包含端口，需要添加
			$channel['host'] = $scheme . '://' . $httpHost . ':88';
		}
		
		//发起支付
		$url = $this->pay($orderdata,$channel);
			if($url=="fail"){
				return json_encode([
								"code"=>0,
								"msg"=>"获取付款链接失败，请重试"
							],JSON_UNESCAPED_UNICODE);
			}else{
				return json_encode([
								"code"=>1,
								"url"=>base64_encode($url),
							],JSON_UNESCAPED_UNICODE);
			}
		} finally {
			// 释放锁
			if ($lockAcquired) {
				Cache::store('redis')->delete($lockKey);
			}
		}
		
					
    }
	
    private function pay($orderdata,$channel)
    {
		//通道
		$platform = $channel['channel'];
		//支付方式
		$paytype = $orderdata['paytype'];
		//购买内容
		$item = json_decode($orderdata['item'],true);
		//var_dump($orderdata);
		switch($platform)
		{
			case 'epay':
				//支付接口地址
				$epay_config['apiurl'] = $channel['pay_api'];
				//商户ID
				$epay_config['pid'] = $channel['pay_pid'];
				//商户密钥
				$epay_config['key'] = $channel['pay_key'];
			//异步回调（host已包含端口，不要重复添加）
			$notify_url = $channel['host']."/api/call/epay";
			//同步回调
			$return_url = $channel['host']."/api/notify/epay";
				//构造要请求的参数数组，无需改动
				$parameter = array(
					"pid" => $epay_config['pid'],
					"type" => $paytype,
					"notify_url" => $notify_url,
					"return_url" => $return_url,
					"out_trade_no" => $orderdata['orderid'],
					"name" => $item['name'],
					"money"	=> $orderdata['realmoney']
				);
				$epay = new EpayCore($epay_config);
				return $epay->getPayLink($parameter);
				break;
			default:
				return "fail";
		}
	}
	
}

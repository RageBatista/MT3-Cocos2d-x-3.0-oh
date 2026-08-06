<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;
use app\model\UserOrder as UL;
use app\model\PayChannel as PC;
use think\facade\Log;

//支付接口
use app\api\pay\EpayCore;

class Notify extends BaseController
{
    public function epay()
    {
		$payParam = $this->request->param();
		$order = new UL();
		// 初始化 $findOrder 为默认值，防止未定义变量
		$findOrder = [
			'orderid' => '',
			'realmoney' => '',
			'pay_status' => ''
		];
		if(isset($payParam['out_trade_no'])){
			$orderData = $order->getOrderId($payParam['out_trade_no']);
			if($orderData){
				$findOrder = is_array($orderData) ? $orderData : $orderData->toArray();
				$channel = new PC();
				$findChannel = $channel->getChannel($findOrder['channel']);
				if(!$findChannel){
					$findOrder['pay_status'] = '支付通道不存在';
					return view('index',['findOrder'=>$findOrder]);
				}
				//支付接口地址
				$epay_config['apiurl'] = $findChannel['pay_api'];
				//商户ID
				$epay_config['pid'] = $findChannel['pay_pid'];
				//商户密钥
				$epay_config['key'] = $findChannel['pay_key'];
				try {
					$epay = new EpayCore($epay_config);
					$status = $epay->verifyReturn($payParam);
					if($status){
						$findOrder['pay_status'] = '支付成功';
					}else{
						$findOrder['pay_status'] = '支付失败';
					}
				} catch (\Throwable $e) {
					Log::warning('支付同步回调校验异常', [
						'out_trade_no' => (string)($payParam['out_trade_no'] ?? ''),
						'error' => $e->getMessage()
					]);
					$findOrder['pay_status'] = '签名校验异常';
				}
			}else{
				$findOrder['orderid'] = '订单不存在';
				$findOrder['realmoney'] = '订单不存在';
				$findOrder['pay_status'] = '订单不存在';
			}
		}else{
			$findOrder['orderid'] = '非法订单';
			$findOrder['realmoney'] = '非法订单';
			$findOrder['pay_status'] = '非法订单';
			
		}
		return view('index',['findOrder'=>$findOrder]);
	}

}

<?php
namespace app\api\pay;

use think\facade\Log;

class EpayCore
{
	private $pid;
	private $key;
	private $submit_url;
	private $mapi_url;
	private $api_url;
	private $sign_type = 'MD5';

	function __construct($config){
		$this->pid = $config['pid'];
		$this->key = $config['key'];
		$this->submit_url = $config['apiurl'].'submit.php';
		$this->mapi_url = $config['apiurl'].'mapi.php';
		$this->api_url = $config['apiurl'].'api.php';
		$this->sign_type = strtoupper((string)($config['sign_type'] ?? 'MD5'));
		if (!in_array($this->sign_type, ['MD5', 'HMAC-SHA256'], true)) {
			$this->sign_type = 'MD5';
		}
	}

	// 发起支付（页面跳转）
	public function pagePay($param_tmp, $button='正在跳转'){
		$param = $this->buildRequestParam($param_tmp);

		$html = '<form id="dopay" action="'.$this->submit_url.'" method="post">';
		foreach ($param as $k=>$v) {
			$html.= '<input type="hidden" name="'.$k.'" value="'.$v.'"/>';
		}
		$html .= '<input type="submit" value="'.$button.'"></form><script>document.getElementById("dopay").submit();</script>';

		return $html;
	}

	// 发起支付（获取链接）
	public function getPayLink($param_tmp){
		$param = $this->buildRequestParam($param_tmp);
		$url = $this->submit_url.'?'.http_build_query($param);
		return $url;
	}

	// 发起支付（API接口）
	public function apiPay($param_tmp){
		$param = $this->buildRequestParam($param_tmp);
		$response = $this->getHttpResponse($this->mapi_url, http_build_query($param));
		$arr = json_decode($response, true);
		return $arr;
	}

	/**
	 * 异步回调验证（P0安全加固）
	 * 增强签名验证，记录安全日志
	 * @param array|null $params 回调参数
	 * @return bool 验证结果
	 */
	public function verifyNotify($params = null){
		$get = $params ? $params : $_GET;
		if(empty($get)) {
			Log::warning('支付回调验证失败: 参数为空');
			return false;
		}

		// 检查必需参数
		if(!isset($get['sign']) || !isset($get['out_trade_no'])){
			Log::warning('支付回调验证失败: 缺少必需参数', [
				'has_sign' => isset($get['sign']),
				'has_orderid' => isset($get['out_trade_no'])
			]);
			return false;
		}

		$sign = $this->getSign($get);

		if($sign === $get['sign']){
			Log::info('支付回调签名验证成功', [
				'orderid' => $get['out_trade_no'] ?? 'unknown'
			]);
			return true;
		}else{
			$mask = function ($value) {
				$value = (string)$value;
				$len = strlen($value);
				if ($len <= 8) {
					return str_repeat('*', $len);
				}
				return substr($value, 0, 4) . str_repeat('*', $len - 8) . substr($value, -4);
			};
			Log::warning('支付回调签名验证失败', [
				'orderid' => $get['out_trade_no'] ?? 'unknown',
				'expected_sign' => $mask($sign),
				'received_sign' => $mask($get['sign'] ?? '')
			]);
			return false;
		}
	}

	/**
	 * 同步回调验证（P0安全加固）
	 * 增强签名验证，记录安全日志
	 * @param array|null $params 回调参数
	 * @return bool 验证结果
	 */
	public function verifyReturn($params = null){
		$get = $params ? $params : $_GET;
		if(empty($get)) {
			Log::warning('支付返回验证失败: 参数为空');
			return false;
		}

		// 检查必需参数
		if(!isset($get['sign']) || !isset($get['out_trade_no'])){
			Log::warning('支付返回验证失败: 缺少必需参数', [
				'has_sign' => isset($get['sign']),
				'has_orderid' => isset($get['out_trade_no'])
			]);
			return false;
		}

		$sign = $this->getSign($get);

		if($sign === $get['sign']){
			Log::info('支付返回签名验证成功', [
				'orderid' => $get['out_trade_no'] ?? 'unknown'
			]);
			return true;
		}else{
			$mask = function ($value) {
				$value = (string)$value;
				$len = strlen($value);
				if ($len <= 8) {
					return str_repeat('*', $len);
				}
				return substr($value, 0, 4) . str_repeat('*', $len - 8) . substr($value, -4);
			};
			Log::warning('支付返回签名验证失败', [
				'orderid' => $get['out_trade_no'] ?? 'unknown',
				'expected_sign' => $mask($sign),
				'received_sign' => $mask($get['sign'] ?? '')
			]);
			return false;
		}
	}

	// 查询订单支付状态
	public function orderStatus($trade_no){
		$result = $this->queryOrder($trade_no);
		if($result['status']==1){
			return true;
		}else{
			return false;
		}
	}

	// 查询订单
	public function queryOrder($trade_no){
		$url = $this->api_url.'?act=order&pid=' . $this->pid . '&key=' . $this->key . '&trade_no=' . $trade_no;
		$response = $this->getHttpResponse($url);
		$arr = json_decode($response, true);
		return $arr;
	}

	private function buildRequestParam($param){
		$mysign = $this->getSign($param);
		$param['sign'] = $mysign;
		$param['sign_type'] = $this->sign_type;
		return $param;
	}

	// 计算签名
	private function getSign($param){
		ksort($param);
		reset($param);
		$signstr = '';
	
		foreach($param as $k => $v){
			if($k != "sign" && $k != "sign_type" && $v!=''){
				$signstr .= $k.'='.$v.'&';
			}
		}
		$signstr = substr($signstr,0,-1);
		$signstr .= $this->key;
		if ($this->sign_type === 'HMAC-SHA256') {
			$sign = hash_hmac('sha256', $signstr, $this->key);
		} else {
			$sign = md5($signstr);
		}
		return $sign;
	}

	// 请求外部资源
	private function getHttpResponse($url, $post = false, $timeout = 10){
		if (stripos($url, 'https://') !== 0) {
			Log::error('支付请求URL必须使用HTTPS', ['url' => $url]);
			return '';
		}
		$ch = curl_init($url);
		curl_setopt($ch, CURLOPT_TIMEOUT, $timeout);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 2);
		$httpheader[] = "Accept: */*";
		$httpheader[] = "Accept-Language: zh-CN,zh;q=0.8";
		$httpheader[] = "Connection: close";
		curl_setopt($ch, CURLOPT_HTTPHEADER, $httpheader);
		curl_setopt($ch, CURLOPT_HEADER, false);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		if($post){
			curl_setopt($ch, CURLOPT_POST, true);
			curl_setopt($ch, CURLOPT_POSTFIELDS, $post);
		}
		$response = curl_exec($ch);
		curl_close($ch);
		return $response;
	}
}

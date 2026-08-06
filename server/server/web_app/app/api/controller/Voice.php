<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;
use app\model\Voice as V;
//腾讯云语音使用
use TencentCloud\Common\Credential;
use TencentCloud\Common\Profile\ClientProfile;
use TencentCloud\Common\Profile\HttpProfile;
use TencentCloud\Common\Exception\TencentCloudSDKException;
use TencentCloud\Asr\V20190614\AsrClient;
use TencentCloud\Asr\V20190614\Models\SentenceRecognitionRequest;

class Voice extends BaseController
{
	/**
	 * 允许的文件扩展名
	 */
	private const ALLOWED_EXTENSIONS = ['amr', 'wav', 'mp3'];
	
	/**
	 * 最大文件大小（字节）5MB
	 */
	private const MAX_FILE_SIZE = 5 * 1024 * 1024;

	private function apiError(string $message, int $code = 0)
	{
		return api_json([
			'code' => $code,
			'error' => $message
		]);
	}

	private function apiSuccess(array $payload)
	{
		return api_json($payload);
	}
	
	/**
	 * 接收语音文件
	 */
	public function receive()
    {	
		$getInput = $this->request->getInput();
		$fileInput = json_decode($getInput, true);
		
		// 安全验证：检查必要参数
		if (!isset($fileInput['uuid']) || !isset($fileInput['speech'])) {
			return $this->apiError('Missing required parameters');
		}
		
		// 安全验证：验证UUID格式
		$uuid = $this->sanitizeUuid($fileInput['uuid']);
		if ($uuid === null) {
			return $this->apiError('Invalid UUID format');
		}
		
		// 安全验证：验证base64编码的数据
		$speechData = $fileInput['speech'];
		if (!$this->isValidBase64($speechData)) {
			return $this->apiError('Invalid speech data format');
		}
		
		// 安全验证：解码并验证文件大小
		$fileContent = base64_decode($speechData, true);
		if ($fileContent === false) {
			return $this->apiError('Failed to decode speech data');
		}
		
		// 检查文件大小
		$fileSize = strlen($fileContent);
		if ($fileSize > self::MAX_FILE_SIZE) {
			return $this->apiError('File size exceeds limit');
		}
		
		// 安全验证：验证文件内容（AMR文件头检查）
		if (!$this->isValidAmrFile($fileContent)) {
			return $this->apiError('Invalid file format');
		}
		
		// 安全验证：验证channelId
		if (!isset($fileInput['channelId'])) {
			return $this->apiError('Missing channelId');
		}
		$channelId = intval($fileInput['channelId']);
		
		// 构建安全的文件路径
		$uploadDir = public_path() . 'iat/';
		$filePath = $uploadDir . $uuid . '.amr';
		
		// 确保上传目录存在
		if (!is_dir($uploadDir)) {
			if (!mkdir($uploadDir, 0755, true)) {
				return $this->apiError('Failed to create upload directory');
			}
		}
		
		// 安全写入文件
		$bytesWritten = file_put_contents($filePath, $fileContent);
		if ($bytesWritten === false) {
			return $this->apiError('Failed to save file');
		}
		
		// 记录文件上传日志
		\think\facade\Log::info('语音文件上传成功|uuid=' . $uuid . '|size=' . $fileSize . '|channelId=' . $channelId);
		
		//腾讯云语音识别
		$voice_params = array(
			"EngSerViceType" => "16k_zh",
			"SourceType" => 1,
			"VoiceFormat" => "amr",
			"Data" => $speechData
		);
		// $user_key = unserialize($this->config['tencent_asr_client']);
		// $voice = json_decode($this->tx_speech_recognition($voice_params,$user_key),true);
		// $text = $voice['Result'];
		
		$text = '未能识别语音';
		if($text==null){
			$text = '未能识别语音';
		}
		
		//写入数据库
		$data = [
			'uuid'=>$uuid,
			'text'=>$text,
			'channelid'=>$channelId,
			'time'=>$this->genericVariable['time']
		];
		$voice = new V();
		$voiceData = $voice->insVoice($data);
		
		return $this->apiSuccess([
			"uuid"=>$uuid,
			"channelid"=>$channelId,
			"text"=>$text
		]);
    }
	
	/**
	 * 获取语音文件
	 */
	public function iat()
    {	
		//  /api/voice/iat/uuid/
		$getUuid = $this->request->param();
		if(!isset($getUuid['uuid'])){
			return $this->apiError('Missing UUID parameter');
		}
		
		// 安全验证：验证UUID格式
		$uuid = $this->sanitizeUuid($getUuid['uuid']);
		if ($uuid === null) {
			return $this->apiError('Invalid UUID format');
		}
		
		$voice = new V();
		$voiceData = $voice->getVoice($uuid);
		
		// 安全验证：验证文件存在
		$filePath = public_path() . 'iat/' . $uuid . '.amr';
		if (!file_exists($filePath)) {
			return $this->apiError('File not found');
		}
		
		// 安全验证：验证文件大小
		$fileSize = filesize($filePath);
		if ($fileSize > self::MAX_FILE_SIZE) {
			return $this->apiError('File size exceeds limit');
		}
		
		// 安全验证：验证文件内容
		$fileContent = file_get_contents($filePath);
		if (!$this->isValidAmrFile($fileContent)) {
			return $this->apiError('Invalid file format');
		}
		
		header("Content-type: application/octet-stream;charset=utf-8");
		header("Accept-Ranges: bytes");
		header("Content-Disposition: attachment; filename=".$uuid.".amr"); //文件命名
		header("Expires: 0");
		header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
		header("Pragma: public");
		
		if(!$voiceData){
			$content = null;
		}else{
			$content = base64_encode($fileContent);
		}
		return $content;
    }
	
	/**
	 * 腾讯云语音识别
	 */
	private function tx_speech_recognition($voice_params,$user_key)
    {	
		try {
			// 实例化一个认证对象，入参需要传入腾讯云账户 SecretId 和 SecretKey，此处还需注意密钥对的保密
			// 代码泄露可能会导致 SecretId 和 SecretKey 泄露，并威胁账号下所有资源的安全性。以下代码示例仅供参考，建议采用更安全的方式来使用密钥，请参见：https://cloud.tencent.com/document/product/1278/85305
			// 密钥可前往官网控制台 https://console.cloud.tencent.com/cam/capi 进行获取
			$cred = new Credential($user_key['secret_id'],$user_key['secret_key']);
			// 实例化一个http选项，可选的，没有特殊需求可以跳过
			$httpProfile = new HttpProfile();
			//$httpProfile->setEndpoint("asr.ap-beijing.tencentcloudapi.com");
			$httpProfile->setEndpoint("asr.tencentcloudapi.com");

			// 实例化一个client选项，可选的，没有特殊需求可以跳过
			$clientProfile = new ClientProfile();
			$clientProfile->setHttpProfile($httpProfile);
			// 实例化要请求产品的client对象,clientProfile是可选的
			//地区
			$client = new AsrClient($cred, $user_key['region'], $clientProfile);

			// 实例化一个请求对象,每个接口都会对应一个request对象
			$req = new SentenceRecognitionRequest();

			$req->fromJsonString(json_encode($voice_params));
			// 返回的resp是一个SentenceRecognitionResponse的实例，与请求对象对应
			$resp = $client->SentenceRecognition($req);

			// 输出json格式的字符串回包
			return $resp->toJsonString();
		}
		catch(TencentCloudSDKException $e) {
			\think\facade\Log::error('腾讯云语音识别异常: ' . $e->getMessage());
			return null;
		}
    }
	
	/**
	 * 清理和验证UUID
	 * @param string $uuid 原始UUID
	 * @return string|null 清理后的UUID，如果无效则返回null
	 */
	private function sanitizeUuid($uuid)
	{
		// 移除所有非字母数字和连字符的字符
		$cleaned = preg_replace('/[^a-zA-Z0-9\-]/', '', $uuid);
		
		// 验证UUID格式（标准UUID格式：xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx）
		if (preg_match('/^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/i', $cleaned)) {
			return $cleaned;
		}
		
		return null;
	}
	
	/**
	 * 验证base64编码的数据
	 * @param string $data 待验证的数据
	 * @return bool 是否为有效的base64编码
	 */
	private function isValidBase64($data)
	{
		// 检查是否为空
		if (empty($data)) {
			return false;
		}
		
		// 检查base64字符集
		if (!preg_match('/^[a-zA-Z0-9\/\r\n+]*={0,2}$/', $data)) {
			return false;
		}
		
		// 尝试解码
		$decoded = base64_decode($data, true);
		if ($decoded === false) {
			return false;
		}
		
		// 检查重新编码是否一致
		return base64_encode($decoded) === $data;
	}
	
	/**
	 * 验证AMR文件格式
	 * @param string $fileContent 文件内容
	 * @return bool 是否为有效的AMR文件
	 */
	private function isValidAmrFile($fileContent)
	{
		// AMR文件头标识
		$amrHeader = '#!AMR';
		
		// 检查文件头
		if (strncmp($fileContent, $amrHeader, strlen($amrHeader)) === 0) {
			return true;
		}
		
		return false;
	}
}

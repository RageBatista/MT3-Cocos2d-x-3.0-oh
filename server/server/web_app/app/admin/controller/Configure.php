<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use think\Response;
use think\facade\View;
use app\model\Server as S;
use app\model\Config as C;
use app\model\PayChannel as PC;

class Configure extends BaseController
{
    private function resolveNoticeFilePath(): string
    {
		$root = rtrim(app()->getRootPath(), DIRECTORY_SEPARATOR);
		$serverDir = $root . DIRECTORY_SEPARATOR . 'public' . DIRECTORY_SEPARATOR . 'server';
		$phpPath = $serverDir . DIRECTORY_SEPARATOR . 'notice.php';
		$htmlPath = $serverDir . DIRECTORY_SEPARATOR . 'notice.html';
		if (is_file($phpPath)) {
			return $phpPath;
		}
		if (is_file($htmlPath)) {
			return $htmlPath;
		}
		return $phpPath;
    }

    private function ensureNoticeFileReady(string $filePath): bool
    {
		$dir = dirname($filePath);
		if (!is_dir($dir) && !@mkdir($dir, 0755, true) && !is_dir($dir)) {
			return false;
		}
		if (!is_file($filePath) && @file_put_contents($filePath, '') === false) {
			return false;
		}
		return true;
    }

    public function serverConfig()
    {
        return view('server_config',['title'=>$this->config['server_title']]);
    }
    public function serverList()
    {
		$server = new S();
		$post = $this->request->post();
		$getServerList = $server->getServerList($post);
        return jsonp($getServerList);
		
    }
    public function serverAdd()
    {
        return view('server_add');
    }
    public function serverAddSubmit()
    {
 $post = $this->request->post();
		// 验证 CSRF Token
		if (!$this->checkToken($post['csrf_token'] ?? '')) {
			return notify(0, '非法请求：CSRF令牌无效');
		}
	foreach($post as $key=>$val){
		if($val==null){
			return notify(0,'请将所有选项填写完整');
		}
	}
	
	// 安全验证: 验证端口号格式（双重保护）
	if(isset($post['serverport'])){
		if(!is_numeric($post['serverport'])){
			return notify(0,'服务器端口必须是数字');
		}
		$port = intval($post['serverport']);
		if($port < 1 || $port > 65535){
			return notify(0,'服务器端口必须在1-65535范围内');
		}
	}

	// 强制验证比率字段为数字
	$numericFields = ['xianyu', 'vip', 'charge'];
	foreach($numericFields as $field) {
		if (isset($post[$field])) {
			if (!is_numeric($post[$field])) {
				return notify(0, "参数 {$field} 必须是数字");
			}
			if ($post[$field] < 0) {
				return notify(0, "参数 {$field} 不能为负数");
			}
		}
	}

	// XSS防护：对所有文本字段进行转义处理
	// 排除 numericFields 和 id, serverport (前面已验证)
	foreach($post as $key => $val) {
		if (!in_array($key, array_merge($numericFields, ['id', 'serverport', 'csrf_token']))) {
			// 使用 validateInput 进行清理 (包括 removing SQL keywords and htmlspecialchars)
			// 注意：validateInput 会移除 'select' 等词汇，用于服务器名称可能过于激进？
			// 这里我们使用 htmlspecialchars 即可，避免 Server Model 再次 save 时出问题
			// 但 Server Model 是 save($data)，最终是 insert/update。
			// 为了防止 Stored XSS，必须 htmlspecialchars。
			 $post[$key] = htmlspecialchars((string)$val, ENT_QUOTES, 'UTF-8');
		}
	}
	
	$server = new S();
	$addServer = $server->addServer($post);
	
	// 记录成功的操作
	$userLog = new \app\model\UserLog();
	$serverName = $post['name'] ?? '未知';
	$logMessage = "新增区服 - 区服名称:{$serverName}, IP:{$this->genericVariable['ip']}";
	$userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
	
	return notify(1,'新增成功');
	
    }
    public function serverEdit()
    {
		$server = new S();
		$get = $this->request->get();
		if(!isset($get['id'])){
			return '参数异常<br/><a href="#" onclick="history.back();return false;">返回上一页</a>';
		}
		$getServer = $server->getServer($get['id']);
		if(!$getServer){
			 return '大区不存在<br/><a href="#" onclick="history.back();return false;">返回上一页</a>';
		}
        return view('server_edit',['getServer'=>$getServer]);
    }
    public function serverEditSubmit()
    {
 $post = $this->request->post();
		// 验证 CSRF Token
		if (!$this->checkToken($post['csrf_token'] ?? '')) {
			return notify(0, '非法请求：CSRF令牌无效');
		}
	foreach($post as $key=>$val){
		if($val==null){
			return notify(0,'请将所有选项填写完整');
		}
	}
	
	// 安全验证: 验证端口号格式（双重保护）
	if(isset($post['serverport'])){
		if(!is_numeric($post['serverport'])){
			return notify(0,'服务器端口必须是数字');
		}
		$port = intval($post['serverport']);
		if($port < 1 || $port > 65535){
			return notify(0,'服务器端口必须在1-65535范围内');
		}
	}

	// 强制验证比率字段为数字
	$numericFields = ['xianyu', 'vip', 'charge'];
	foreach($numericFields as $field) {
		if (isset($post[$field])) {
			if (!is_numeric($post[$field])) {
				return notify(0, "参数 {$field} 必须是数字");
			}
			if ($post[$field] < 0) {
				return notify(0, "参数 {$field} 不能为负数");
			}
		}
	}

	// XSS防护：对所有文本字段进行转义处理
	foreach($post as $key => $val) {
		if (!in_array($key, array_merge($numericFields, ['id', 'serverport', 'csrf_token']))) {
			 $post[$key] = htmlspecialchars((string)$val, ENT_QUOTES, 'UTF-8');
		}
	}
	
	$server = new S();
	$upServer = $server->upServer($post);
	
	// 记录成功的操作
	$userLog = new \app\model\UserLog();
	$serverId = $post['id'] ?? '未知';
	$serverName = $post['name'] ?? '未知';
	$logMessage = "编辑区服 - 区服ID:{$serverId}, 区服名称:{$serverName}, IP:{$this->genericVariable['ip']}";
	$userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
	
	return notify(1,'编辑成功');
	
    }
    public function serverDel()
    {
 $server = new S();
	$post = $this->request->post();
		// 验证 CSRF Token
		if (!$this->checkToken($post['csrf_token'] ?? '')) {
			return notify(0, '非法请求：CSRF令牌无效');
		}
	if(!isset($post['id']) || $post['id'] == null){
		return notify(0,'区服信息有误');
	}
	$getServer = $server->getServer($post['id']);
	if(!$getServer){
		return notify(0,'大区信息不存在');
	}
	
	// 记录删除前的服务器信息
	$serverName = $getServer['name'] ?? '未知';
	$serverId = $post['id'];
	
	$delServer = $server->delServer($post['id']);
	
	// 记录成功的删除操作
	$userLog = new \app\model\UserLog();
	$logMessage = "删除区服 - 区服ID:{$serverId}, 区服名称:{$serverName}, IP:{$this->genericVariable['ip']}";
	$userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
	
	return notify(1,'删除成功');
	   }
    public function serverTitle()
    {
		$config = new C();
		$post = $this->request->post();
		// 验证 CSRF Token
		if (!$this->checkToken($post['csrf_token'] ?? '')) {
			return notify(0, '非法请求：CSRF令牌无效');
		}
		$data = [
			'keys'=>'server_title',
			'values'=>$post['title']
		];
		$upConfig = $config->upConfig($data);
		return notify(1,'保存成功');
    }
    public function makeServerList()
    {
		$server = new S();
		// 验证 CSRF Token (Assuming passed as POST param even if currently null in JS)
		$token = $this->request->post('csrf_token', '');
		if (!$this->checkToken($token)) {
			return notify(0, '非法请求：CSRF令牌无效');
		}
		$makeServerList = $server->makeServerList();
		if(!$makeServerList){
			return notify(0,'至少有一个可用大区');
		}
		$serverTitle = $this->config['server_title'];
		$i=1;
		foreach($makeServerList as $key=>$val){
			$serverIndex = [
				'I'=>$i,
				'D'=>$val['serverid'],
				'A'=>$val['groupname'],
				'N'=>$val['name'],
				'P'=>$val['serverip'],
				'T'=>$val['serverport'],
				'S'=>$val['deng'],
				'B'=>1,
				'C'=>0,
				'KS'=>$val['opentime'],
				'NS'=>$val['biao']
			];
			foreach($serverIndex as $key=>$val){
				if(!is_string($val)){
					$serverIndex[$key]=(string)$val;
				}
			}
			$GameServerInfo[] = $serverIndex;
			$i++;
		}
		$serverTitle = json_decode($serverTitle,true);
		$serverTitle['GameServerInfo'] = $GameServerInfo;
		$filename = 'server/index.html';
		$fp= fopen($filename, "w+");
		$len = fwrite($fp, json_encode($serverTitle,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE));
		fclose($fp);
		
		return notify(1,'保存成功');
    }
	
    public function sysConfig()
    {
        return view('sys_config');
    }
	
    public function upSys()
    {
		$config = new C();
		$post = $this->request->post();
		// 验证 CSRF Token
		if (!$this->checkToken($post['csrf_token'] ?? '')) {
			return notify(0, '非法请求：CSRF令牌无效');
		}
		foreach($post as $key=>$val){
			if ($key === 'csrf_token') continue;
			
			// XSS 防护：清洗输入
			// 因为 validateInput 会过滤 SQL 关键字（如 'select', 'update'），对于普通配置文本可能误杀
			// 所以对于 'agent_notice' 等文本域，仅使用 htmlspecialchars
			// 对于 URL 类 (logo, icon, background) 使用 validateInput (它包含 strip tags 和 sql filters)
			
			if (in_array($key, ['logo', 'icon', 'background', 'name'])) {
				$val = $this->validateInput($val);
			} else {
				$val = htmlspecialchars((string)$val, ENT_QUOTES, 'UTF-8');
			}

			$data = [
				'keys'=>$key,
				'values'=>$val
			];
			$upConfig = $config->upConfig($data);
		}
		return notify(1,'保存成功');
    }
	
    public function noticeConfig()
    {
		$file_path = $this->resolveNoticeFilePath();
		if (!$this->ensureNoticeFileReady($file_path)) {
			return notify(0, '公告文件目录不可写，请检查/public/server权限');
		}
		$str = (string)file_get_contents($file_path);
        return view('notice_config',['str'=>$str]);
    }
    public function upNotice()
    {
		$post = $this->request->post();
		// 验证 CSRF Token
		if (!$this->checkToken($post['csrf_token'] ?? '')) {
			return notify(0, '非法请求：CSRF令牌无效');
		}
		$file_path = $this->resolveNoticeFilePath();
		if (!$this->ensureNoticeFileReady($file_path)) {
			return notify(0, '公告文件目录不可写，请检查/public/server权限');
		}
		$notice = $post['notice'];
		if (@file_put_contents($file_path, (string)$notice) === false) {
			return notify(0, '公告保存失败，请检查文件写入权限');
		}
		return notify(1,'保存成功');
		}
	
    public function payConfig()
    {
	// ===== 安全限制：超级管理员不允许访问支付配置 =====
	if($this->myAdmin['id'] == 1){
		return '<div style="padding: 50px; text-align: center; font-family: Arial;">
			<div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 15px; padding: 40px; color: white; box-shadow: 0 10px 30px rgba(0,0,0,0.2); max-width: 600px; margin: 50px auto;">
				<i class="mdi mdi-shield-lock" style="font-size: 80px; display: block; margin-bottom: 20px;"></i>
				<h2 style="margin: 20px 0; font-weight: bold;">🛡️ 访问受限</h2>
				<p style="font-size: 18px; line-height: 1.8; margin: 20px 0;">
					为保障系统安全，<strong style="color: #ffd700;">超级管理员</strong>无法访问支付配置页面。<br/>
					此限制是为了防止最高权限账号被盗后修改支付设置。
				</p>
				<div style="background: rgba(255, 255, 255, 0.15); padding: 15px; border-radius: 10px; margin: 20px 0; border-left: 4px solid #ffd700;">
					<p style="margin: 0; font-size: 14px; text-align: left;">
						<i class="mdi mdi-information"></i> <strong>如需管理支付配置：</strong>
					</p>
					<ul style="text-align: left; margin: 10px 0 0 20px; font-size: 14px;">
						<li>请使用普通管理员账号登录</li>
						<li>或联系系统管理员协助操作</li>
					</ul>
				</div>
				<div style="margin-top: 30px;">
					<a href="javascript:history.back();" style="display: inline-block; padding: 12px 40px; background: white; color: #667eea; text-decoration: none; border-radius: 8px; font-size: 16px; font-weight: bold;">
						<i class="mdi mdi-arrow-left"></i> 返回
					</a>
				</div>
			</div>
		</div>';
	}
	// ===== 安全检查通过 =====
	
        return view('pay_config');
    }
    
    
    public function payChannel()
    {
		$post = $this->request->post();
		$pay = new PC();
		$getPayList = $pay->getPayList($post);
        return jsonp($getPayList);
    }
    public function addPayChannel()
    {
        return view('add_pay_channel');
    }
    public function addChannelSub()
    {
 $pay = new PC();
 $post = $this->request->post();
		// 验证 CSRF Token
		if (!$this->checkToken($post['csrf_token'] ?? '')) {
			return notify(0, '非法请求：CSRF令牌无效');
		}
 foreach($post as $key=>$val){
  if($val==null){
   return notify(0,'请将所有选项填写完整');
  }
 }
 
 $addChannel = $pay->addChannel($post);
 
 // 记录添加操作（包含详细信息）
 $userLog = new \app\model\UserLog();
 $logMessage = "添加支付通道 - 类型:{$post['channel']}, 备注:{$post['name']}, PID:{$post['pay_pid']}, IP:{$this->genericVariable['ip']}";
 $userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
 
 return notify(1,'新增成功');
    }
    public function delPayChannel()
    {
 $pay = new PC();
	$id = $this->request->post('id',null);
	// 验证 CSRF Token (Need to get token from post separately or expect it in post)
	// Note: delPayChannel uses post('id'). The token should be in post.
	$token = $this->request->post('csrf_token', '');
	if (!$this->checkToken($token)) {
		return notify(0, '非法请求：CSRF令牌无效');
	}
	if($id==null){
		return notify(0,'未查询到此通道信息');
	}
	$getChannel = $pay->getChannel($id);
	if(!$getChannel){
		return notify(0,'未查询到此通道信息');
	}
	
	// 记录删除操作（包含通道详细信息）
	$userLog = new \app\model\UserLog();
	$logMessage = "删除支付通道 - ID:{$id}, 类型:{$getChannel['channel']}, 备注:{$getChannel['name']}, IP:{$this->genericVariable['ip']}";
	$userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
	
	$pay->delChannel($id);
	return notify(1,'删除成功');
	   }
	   public function editPayChannel()
	{
		$pay = new PC();
		$id = $this->request->get('id',null);
		if($id==null){
			return '通道信息异常<br/><a href="#" onclick="history.back();return false;">返回上一页</a>';
		}
		$getChannel = $pay->getChannel($id);
		if(!$getChannel){
			return '通道信息异常<br/><a href="#" onclick="history.back();return false;">返回上一页</a>';
		}
		
		      return view('edit_pay_channel',[
			'getChannel'=>$getChannel
		]);
		  }
	public function upChannelSub()
	{
		$pay = new PC();
		$post = $this->request->post();
		
		// 验证 CSRF Token
		if (!$this->checkToken($post['csrf_token'] ?? '')) {
			return notify(0, '非法请求：CSRF令牌无效');
		}

		foreach($post as $key=>$val){
			// pay_key 为空时不验证（后面会通过逻辑排除）
			if($key === 'pay_key' && empty($val)) {
				continue;
			}
			if($val==null){
				return notify(0,'请将所有选项填写完整');
			}
		}
		
		// 如果 pay_key 为空，则不修改（从数据中移除）
		if (empty($post['pay_key'])) {
			unset($post['pay_key']);
		}
		
		// 获取旧的通道信息用于日志记录
		$oldChannel = $pay->getChannel($post['id']);
		
		$editChannel = $pay->editChannel($post);
		
		// 记录更新操作（包含详细信息）
		$userLog = new \app\model\UserLog();
		$logMessage = "更新支付通道 - ID:{$post['id']}, 类型:{$post['channel']}, 备注:{$post['name']}, IP:{$this->genericVariable['ip']}";
		$userLog->addAdminLog($this->myAdmin['username'], $logMessage, $this->genericVariable);
		
		return notify(1,'保存成功');
		  }
}

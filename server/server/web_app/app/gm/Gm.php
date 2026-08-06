<?php
namespace app\gm;

use app\service\GmJmxcExecutorService;

#[\AllowDynamicProperties]
class Gm
{
	private const REGISTERED_COMMANDS = [
		'nonvoice', 'unnonvoice', 'coquest', 'clearbag', 'forgmbid',
		'superunforbiduser', 'superforbiduser', 'createrole', 'kick',
		'baitantimeclear', 'checkcode', 'hideme', 'showme', 'battleend',
		'cangbatou', 'addlevel', 'addrechargecurrency', 'subfushi',
		'addvipexp', 'setvip', 'addgold', 'changebindtel', 'addsuperitem',
		'addtitle', 'deltitle', 'addhyd', 'award', 'offlinetime', 'addpet',
		'addpetskill', 'delpetskill', 'addpetexp', 'addlife', 'addbanggong',
		'addfactionmoney', 'bpgx', 'yaofangrefresh', 'dismissguild',
		'adddingzhiequip', 'setdays', 'sysmailbycond', 'post', 'zmd',
		'destroyzone', 'reload', 'stopgamegs', 'readpackandpet', 'sysmail',
		'setpetgrow', 'setpetattack', 'setpetdefend', 'setpetmagic',
		'setpetphyforce', 'setpetspeed',
	];

	private const HIGH_RISK_COMMANDS = [
		'addgold', 'addrechargecurrency', 'subfushi', 'setvip', 'addsuperitem',
		'sysmail', 'sysmailbycond', 'destroyzone', 'reload', 'stopgamegs',
		'dismissguild', 'superforbiduser', 'superunforbiduser',
		'adddingzhiequip', 'addfactionmoney',
	];

	/** JMX认证用户名 */
	private $jmxUsername = '';

	/** JMX认证密码 */
	private $jmxPassword = '';

	/** JMX认证Token（二次验证） */
	private $jmxToken = '';

	/** JMX配置是否完整可用 */
	private $jmxAuthReady = false;

	/** Java 可执行文件 */
	private $javaBin = 'java';

	/** 命令执行服务 */
	private $commandExecutor = null;

	/**
	 * 构造函�?- 自动调用初始�?	 */
	public function __construct()
	{
		$this->_initialize();
	}

	/**
	 * 初始化方�?	 * 设置环境变量和JMX配置
	 */
	public function _initialize()
	{
		$locale='en_US.UTF-8';
		setlocale(LC_ALL,$locale);
		putenv('LC_ALL='.$locale);
		$jmxc = app()->getRootPath().'jmxc/jmxc.jar';
		$this->flag = strtoupper((string)PHP_OS_FAMILY) === 'WINDOWS' ? '' : 'export LANG="zh_CN.UTF-8" && ';
		$this->jmxcPath=$jmxc;
		$this->javaBin = (string)env('JMX_JAVA_BIN', 'java');
		$this->commandExecutor = new GmJmxcExecutorService();

		// 加载JMX认证配置
		$this->loadJmxConfig();
	}

	/**
	 * 加载JMX认证配置
	 * 从多个可能的配置文件读取用户名和密码
	 * 优先�? 1) app/admin/security_config.php  2) config/security.php
	 */
	private function loadJmxConfig()
	{
		try {
			$config = null;

			// 首先尝试从admin目录的security_config.php加载
			$adminConfigPath = app()->getAppPath() . 'admin/security_config.php';
			if (file_exists($adminConfigPath)) {
				$adminConfig = include $adminConfigPath;
				if ($adminConfig && isset($adminConfig['jmx_auth']) && $adminConfig['jmx_auth']['enabled']) {
					$config = $adminConfig['jmx_auth'];
					\think\facade\Log::info('JMX配置来源: app/admin/security_config.php');
				}
			}

			// 如果admin配置没有，尝试从主config加载
			if (!$config) {
				$config = config('security.jmx_auth');
				if ($config && $config['enabled']) {
					\think\facade\Log::info('JMX配置来源: config/security.php');
				}
			}

			// 应用配置
			if ($config && isset($config['enabled']) && $config['enabled']) {
				$this->jmxUsername = $config['username'] ?? '';
				$this->jmxPassword = $config['password'] ?? '';
				$this->jmxToken = $config['token'] ?? '';
				$this->jmxAuthReady = ($this->jmxUsername !== '' && $this->jmxPassword !== '' && $this->jmxToken !== '');
			}

			// 记录配置状态
			$hasAuth = $this->jmxAuthReady;
			$hasToken = !empty($this->jmxToken);
			\think\facade\Log::info('JMX配置状态: ' . ($hasAuth ? '已启用认证,Token=' . ($hasToken ? '已配置' : '未配置') : '未配置认证或配置不完整'));
		} catch (\Exception $e) {
			\think\facade\Log::error('JMX配置加载失败: ' . $e->getMessage());
		}
	}

	private function buildAuditSummary(array $data, string $gmCommand): string
	{
		$serverip = ($data['gmlocal'] == 1) ? '127.0.0.1' : ($data['serverip'] ?? 'unknown');
		$port = intval($data['gmport'] ?? 0);
		$userId = $this->resolveGmUserId($data);
		$playerid = intval($data['playerid'] ?? 0);
		$cmd = $this->sanitizeGmCommandForLog($gmCommand);
		return 'server=' . $serverip . ', port=' . $port . ', userId=' . $userId . ', playerId=' . $playerid . ', token=' . (!empty($this->jmxToken) ? 'configured' : 'missing') . ', command=' . $cmd;
	}

	private function resolveServerIp(array $data)
	{
		$serverip = (($data['gmlocal'] ?? 0) == 1) ? '127.0.0.1' : ($data['serverip'] ?? '');
		return filter_var($serverip, FILTER_VALIDATE_IP);
	}

	private function buildJavaPrefix(): string
	{
		return $this->flag . escapeshellarg($this->javaBin);
	}

	private function resolveGmUserId(array $data): int
	{
		if (isset($data['gm_userid']) && is_numeric($data['gm_userid'])) {
			return max(0, intval($data['gm_userid']));
		}
		if (isset($data['userid']) && is_numeric($data['userid'])) {
			return max(0, intval($data['userid']));
		}
		return 0;
	}

	private function buildGmArgs(string $serverip, int $gmport, int $playerid, array $data = []): array
	{
		$gmUserId = $this->resolveGmUserId($data);
		$args = [
			$this->jmxUsername,
			$this->jmxPassword,
			$serverip,
			(string)$gmport,
			'gm',
			'userId=' . $gmUserId,
			'roleId=' . max(0, intval($playerid)),
		];

		if (!empty($this->jmxToken)) {
			$args[] = 'token=' . $this->jmxToken;
		}

		return $args;
	}

	private function buildJmxArgs(string $serverip, int $gmport, string $functionName): array
	{
		return [
			$this->jmxUsername,
			$this->jmxPassword,
			$serverip,
			(string)$gmport,
			$functionName,
		];
	}

	private function escapeArgs(array $args): string
	{
		$escaped = array_map(static fn($arg) => escapeshellarg((string)$arg), $args);
		return implode(' ', $escaped);
	}

	private function sanitizeLogText(string $text): string
	{
		$text = preg_replace('/token=[^\s\'"]+/i', 'token=***', $text);
		$text = preg_replace('/(password=)[^\s\'"]+/i', '$1***', (string)$text);
		$text = preg_replace('/(mobile|phone|tel)=?[0-9]{7,}/i', '$1=***', (string)$text);
		$text = preg_replace('/\b1[3-9][0-9]{9}\b/', '1**********', (string)$text);
		return (string)$text;
	}

	private function sanitizeGmCommandForLog(string $gmCommand): string
	{
		$cmd = str_replace(["\r", "\n", "\t"], ' ', $gmCommand);
		$cmd = $this->sanitizeLogText($cmd);
		$cmd = preg_replace('/(sysmail|sysmailbycond)\s+(.{0,120})/i', '$1 ***', (string)$cmd);
		if (strlen($cmd) > 200) {
			$cmd = substr($cmd, 0, 200) . '...';
		}
		return trim((string)$cmd);
	}

	private function envFlag(string $key, bool $default = false): bool
	{
		$value = env($key, $default ? 'true' : 'false');
		if (is_bool($value)) {
			return $value;
		}
		return in_array(strtolower((string)$value), ['1', 'true', 'on', 'yes'], true);
	}

	private function getCommandName(string $gmCommand): string
	{
		$normalized = trim(str_replace(["\r", "\n", "\t"], ' ', $gmCommand));
		if ($normalized === '') {
			return '';
		}
		$parts = preg_split('/\s+/', $normalized);
		return strtolower((string)($parts[0] ?? ''));
	}

	private function isRegisteredCommand(string $commandName): bool
	{
		return in_array(strtolower($commandName), self::REGISTERED_COMMANDS, true);
	}

	private function isHighRiskCommand(string $commandName): bool
	{
		return in_array(strtolower($commandName), self::HIGH_RISK_COMMANDS, true);
	}

	private function hasHighRiskApproval(array $data): bool
	{
		if (!$this->envFlag('GM_HIGH_RISK_APPROVAL_REQUIRED', true)) {
			return true;
		}
		$expected = trim((string)env('GM_HIGH_RISK_APPROVAL_CODE', ''));
		$provided = trim((string)($data['approval_code'] ?? $data['gm_approval_code'] ?? ''));
		return $expected !== '' && $provided !== '' && hash_equals($expected, $provided);
	}

	private function isBreakGlassAllowed(array $data): bool
	{
		if (!$this->envFlag('GM_BREAK_GLASS_ENABLED', false)) {
			return false;
		}
		$expected = trim((string)env('GM_BREAK_GLASS_APPROVAL_CODE', ''));
		$provided = trim((string)($data['break_glass_code'] ?? $data['approval_code'] ?? ''));
		return $expected !== '' && $provided !== '' && hash_equals($expected, $provided);
	}

	private function ipMatchesCidr(string $ip, string $cidr): bool
	{
		if (strpos($cidr, '/') === false) {
			return $ip === $cidr;
		}
		[$subnet, $bits] = explode('/', $cidr, 2);
		$ipLong = ip2long($ip);
		$subnetLong = ip2long($subnet);
		$bits = intval($bits);
		if ($ipLong === false || $subnetLong === false || $bits < 0 || $bits > 32) {
			return false;
		}
		$mask = -1 << (32 - $bits);
		return (($ipLong & $mask) === ($subnetLong & $mask));
	}

	private function isAllowedJmxTarget(string $serverip, int $gmport): bool
	{
		$raw = trim((string)env('GM_JMX_ALLOWED_TARGETS', '127.0.0.1:*'));
		if ($raw === '') {
			return false;
		}
		foreach (preg_split('/[,;\s]+/', $raw) as $entry) {
			$entry = trim((string)$entry);
			if ($entry === '') {
				continue;
			}
			$host = $entry;
			$port = '*';
			if (strpos($entry, ':') !== false) {
				[$host, $port] = explode(':', $entry, 2);
			}
			$host = trim($host);
			$port = trim($port);
			$portOk = ($port === '*' || intval($port) === $gmport);
			$hostOk = ($host === '*' || $this->ipMatchesCidr($serverip, $host));
			if ($hostOk && $portOk) {
				return true;
			}
		}
		return false;
	}

	/**
	 * 构建JMX命令基础部分（包含认证信息和Token）
	 */
	private function buildJmxBaseCommand($serverip, $gmport, $playerid)
	{
		$args = $this->buildGmArgs((string)$serverip, intval($gmport), intval($playerid));
		return $this->buildJavaPrefix() . ' -jar ' . escapeshellarg($this->jmxcPath) . ' ' . $this->escapeArgs($args);
	}

	/**
	 * 构建完整的GM命令
	 * @param array $data 包含serverip, gmport, playerid等参数
	 * @param string $gmCommand GM命令字符串
	 * @return string 完整的shell命令
	 */
	private function buildGmCommand($data, $gmCommand)
	{
		$serverip = $this->resolveServerIp($data);
		if ($serverip === false) {
			return ''; // 无效IP，由调用方处理
		}

		$gmport = intval($data['gmport']);
		$playerid = intval($data['playerid']);
		$args = $this->buildGmArgs($serverip, $gmport, $playerid, (array)$data);
		$args[] = (string)$gmCommand;
		return $this->buildJavaPrefix() . ' -jar ' . escapeshellarg($this->jmxcPath) . ' ' . $this->escapeArgs($args);
	}

	private function buildJmxFunctionCommand(array $data, string $functionName): string
	{
		$serverip = $this->resolveServerIp($data);
		if ($serverip === false) {
			return '';
		}

		$gmport = intval($data['gmport'] ?? 0);
		if($gmport < 1 || $gmport > 65535){
			return '';
		}

		$args = $this->buildJmxArgs($serverip, $gmport, $functionName);
		return $this->buildJavaPrefix() . ' -jar ' . escapeshellarg($this->jmxcPath) . ' ' . $this->escapeArgs($args);
	}

	private function buildGmCommandByClassPath(array $data, string $gmCommand): string
	{
		$serverip = $this->resolveServerIp($data);
		if ($serverip === false) {
			return '';
		}

		$gmport = intval($data['gmport'] ?? 0);
		$playerid = intval($data['playerid'] ?? 0);
		$args = $this->buildGmArgs($serverip, $gmport, $playerid, $data);
		$args[] = $gmCommand;

		return $this->buildJavaPrefix() . ' -cp ' . escapeshellarg($this->jmxcPath) . ' jmxc ' . $this->escapeArgs($args);
	}

	private function buildJmxFunctionCommandByClassPath(array $data, string $functionName): string
	{
		$serverip = $this->resolveServerIp($data);
		if ($serverip === false) {
			return '';
		}

		$gmport = intval($data['gmport'] ?? 0);
		if($gmport < 1 || $gmport > 65535){
			return '';
		}

		$args = $this->buildJmxArgs($serverip, $gmport, $functionName);
		return $this->buildJavaPrefix() . ' -cp ' . escapeshellarg($this->jmxcPath) . ' jmxc ' . $this->escapeArgs($args);
	}

	public function probeOnlineCount($data): array
	{
		if (!$this->jmxAuthReady) {
			return [
				'success' => false,
				'online' => 0,
				'source' => 'jmx',
				'message' => 'JMX认证未启用或配置不完整'
			];
		}

		$cmd = $this->buildJmxFunctionCommand($data, 'GetMaxOnlineNum');
		if ($cmd === '') {
			return [
				'success' => false,
				'online' => 0,
				'source' => 'jmx',
				'message' => '服务器IP或端口无效'
			];
		}
		$serverip = $this->resolveServerIp((array)$data);
		$gmport = intval($data['gmport'] ?? 0);
		if ($serverip === false || !$this->isAllowedJmxTarget((string)$serverip, $gmport)) {
			\think\facade\Log::warning('JMX在线探测拒绝: 目标不在白名单|server=' . ($serverip ?: 'invalid') . '|port=' . $gmport);
			return [
				'success' => false,
				'online' => 0,
				'source' => 'jmx',
				'message' => 'JMX目标不在白名单'
			];
		}

		$fallbackCmd = $this->buildJmxFunctionCommandByClassPath((array)$data, 'GetMaxOnlineNum');
		$execResult = $this->commandExecutor->execute($cmd, $fallbackCmd);
		$out = $execResult['output'];
		$ret = intval($execResult['exitCode']);
		if (!empty($execResult['usedFallback'])) {
			\think\facade\Log::warning('JMX在线探测失败，尝试 -cp jmxc 回退链路');
		}
		if ($ret !== 0) {
			return [
				'success' => false,
				'online' => 0,
				'source' => 'jmx',
				'message' => '返回码=' . $ret
			];
		}

		$lastLine = trim((string)end($out));
		if (!is_numeric($lastLine)) {
			return [
				'success' => false,
				'online' => 0,
				'source' => 'jmx',
				'message' => '返回结果非数字'
			];
		}

		return [
			'success' => true,
			'online' => max(0, intval($lastLine)),
			'source' => 'jmx',
			'message' => '探测成功'
		];
	}
	
	/**
	 * 安全执行GM命令（防止命令注入）
	 * @param array $data 包含serverip, gmport, playerid等参数
	 * @param string $gmCommand GM命令字符串
	 * @return array 执行结果
	 */
	private function safeExecGmCommand($data, $gmCommand)
	{
		if (!$this->jmxAuthReady) {
			\think\facade\Log::error('GM命令执行失败: JMX认证未启用或配置不完整');
			return ['error' => 'JMX auth is not configured'];
		}
		if (!is_file($this->jmxcPath)) {
			\think\facade\Log::error('GM命令执行失败: jmxc.jar不存在 ' . $this->jmxcPath);
			return ['error' => 'jmxc.jar not found'];
		}

		// 验证端口
		$gmport = intval($data['gmport']);
		if($gmport < 1 || $gmport > 65535){
			\think\facade\Log::error('GM命令执行失败: 无效的端口 ' . $gmport);
			return ['error' => 'Invalid GM port'];
		}

		$serverip = $this->resolveServerIp((array)$data);
		if ($serverip === false) {
			\think\facade\Log::error('GM命令执行失败: 无效的服务器IP');
			return ['error' => 'Invalid server IP'];
		}
		if (!$this->isAllowedJmxTarget((string)$serverip, $gmport)) {
			\think\facade\Log::warning('GM命令执行拒绝: JMX目标不在白名单|server=' . $serverip . '|port=' . $gmport);
			return ['error' => 'JMX target is not allowed'];
		}

		// 验证玩家ID（必须是数字）
		$playerid = intval($data['playerid']);
		if($playerid < 0){
			\think\facade\Log::error('GM命令执行失败: 无效的玩家ID ' . $playerid);
			return ['error' => 'Invalid player ID'];
		}

		$commandName = $this->getCommandName((string)$gmCommand);
		if (!$this->isRegisteredCommand($commandName)) {
			\think\facade\Log::warning('GM命令执行拒绝: 命令未注册|cmd=' . $this->sanitizeGmCommandForLog((string)$gmCommand));
			return ['error' => 'GM command is not registered'];
		}
		if ($this->isHighRiskCommand($commandName) && !$this->hasHighRiskApproval((array)$data)) {
			\think\facade\Log::warning('GM命令执行拒绝: 高危命令缺少审批|cmd=' . $commandName);
			return ['error' => 'High risk GM command requires approval'];
		}

		// 使用统一的buildGmCommand方法构建命令（包含Token）
		$cmd = $this->buildGmCommand($data, $gmCommand);

		// 检查命令构建是否成功
		if (empty($cmd)) {
			\think\facade\Log::error('GM命令执行失败: 命令构建失败');
			return ['error' => 'Invalid server IP'];
		}

		// 记录要执行的命令
		\think\facade\Log::info('执行GM命令概要: ' . $this->buildAuditSummary($data, $gmCommand));

		// 执行命令并捕获输出和返回码
		$fallbackCmd = $this->buildGmCommandByClassPath((array)$data, (string)$gmCommand);
		$execResult = $this->commandExecutor->execute($cmd, $fallbackCmd);
		$out = $execResult['output'];
		$ret = intval($execResult['exitCode']);
		if (!empty($execResult['usedFallback'])) {
			\think\facade\Log::warning('GM命令执行失败，尝试 -cp jmxc 回退链路');
		}

		// 记录执行结果
		if ($ret !== 0) {
			$joinedOut = $this->sanitizeLogText(implode("\n", $out));
			\think\facade\Log::error('GM命令执行失败: 返回码=' . $ret . ', 输出=' . $joinedOut);
			return ['error' => '命令执行失败', 'code' => $ret, 'output' => $joinedOut];
		}

		if (empty($out)) {
			\think\facade\Log::warning('GM命令执行成功但没有输出');
		} else {
			\think\facade\Log::info('GM命令执行成功: ' . $this->sanitizeLogText(implode("\n", $out)));
		}

		return $out;
	}

	public function getOnlineCount($data): int
	{
		$result = $this->probeOnlineCount($data);
		if (!$result['success']) {
			\think\facade\Log::warning('JMX在线人数获取失败: ' . $result['message']);
		}
		return intval($result['online'] ?? 0);
	}
	public function nonvoice($data)
	{
		// 使用安全执行方法
		$gmCommand = 'nonvoice ' . intval($data['playerid']) . ' 64000000 GM 0';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function unnonvoice($data)
	{
		// 使用安全执行方法
		$gmCommand = 'unnonvoice ' . intval($data['playerid']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function coquest($data)
	{
		$gmCommand = 'coquest ';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function clearbag($data)
	{
		$gmCommand = 'clearbag ';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function forbid($data)
	{
		$gmCommand = 'forgmbid ' . intval($data['playerid']) . ' 999999 GM命令封号';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function unforbid($data)
	{
		$gmCommand = 'superunforbiduser ' . intval($data['playerid']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}

	public function superforbiduser($data)
	{
		$gmCommand = 'superforbiduser ' . intval($data['playerid']) . ' 999999 GM命令全服封号';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function superunforbiduser($data)
	{
		$gmCommand = 'superunforbiduser ' . intval($data['playerid']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	
	public function createrole0($data)
	{
		$gmCommand = 'createrole 0';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	
	public function createrole1($data)
	{
		$gmCommand = 'createrole 1';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	
	public function kick($data)
	{
		$gmCommand = 'kick ' . intval($data['playerid']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function baitantimeclear($data)
	{
		$gmCommand = 'baitantimeclear';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function checkcode($data)
	{
		$gmCommand = 'checkcode 1';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function hideme($data)
	{
		$gmCommand = 'hideme';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function showme($data)
	{
		$gmCommand = 'showme';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function battleEndSuccess($data)
	{
		// Java端期望格式: battleend <角色ID>
		$gmCommand = 'battleend ' . intval($data['playerid']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function battleEndFail($data)
	{
		// Java端期望格式: battleend <角色ID> (当前以平局结束战斗)
		$gmCommand = 'battleend ' . intval($data['playerid']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function cangbatou($data)
	{
		// 一键使用背包藏宝图命令
		$gmCommand = 'cangbatou';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function addlevel($data)
	{
		$gmCommand = 'addlevel ' . intval($data['number']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function addRechargecurrency($data)
	{
		$gmCommand = 'addRechargecurrency 3 ' . intval($data['number']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}

	// 兼容旧方法名
	public function addqian($data)
	{
		return $this->addRechargecurrency($data);
	}
	public function subfushi($data)
	{
		$gmCommand = 'subfushi ' . intval($data['playerid']) . ' ' . intval($data['number']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function addvipexp($data)
	{
		$gmCommand = 'addvipexp ' . intval($data['number']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function setvip($data)
	{
		$gmCommand = 'setvip ' . intval($data['number']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function addgold($data)
	{
		$gmCommand = 'addgold ' . intval($data['number']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function changebindtel($data)
	{
		$gmCommand = 'changebindtel ' . intval($data['playerid']) . ' ' . intval($data['mobile']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function addsuperitem($data)
	{
		// Java后端命令格式: addsuperitem <物品ID> [数量] [角色ID]
		// 重要：角色ID必须作为命令参数传递，否则Java端会使用GM角色ID而非目标玩家ID
		$itemid = intval($data['itemid']);
		$number = isset($data['number']) ? intval($data['number']) : 1;
		$playerid = intval($data['playerid']);

		// 支持单个物品和批量物品字符串 (格式: itemid|number,itemid|number)
		if (isset($data['itemstr']) && !empty($data['itemstr'])) {
			// 批量添加物品，使用itemstr参数
			// 格式: itemid|number,itemid|number
			$itemstr = str_replace(['"', '\\', "'"], '', $data['itemstr']);
			$items = explode(',', $itemstr);
			$result = [];
			foreach ($items as $item) {
				$parts = explode('|', $item);
				$pid = intval(trim($parts[0]));
				$pnum = isset($parts[1]) ? intval(trim($parts[1])) : 1;
				if ($pid > 0) {
					// 必须包含角色ID作为第三个参数
					$gmCommand = 'addsuperitem ' . $pid . ' ' . $pnum . ' ' . $playerid;
					$ret = $this->safeExecGmCommand($data, $gmCommand);
					if (is_array($ret)) {
						$result = array_merge($result, $ret);
					}
				}
			}
			return $result;
		} else {
			// 单个物品 - 确保物品ID有效
			if ($itemid <= 0) {
				\think\facade\Log::error('addsuperitem物品ID无效|itemid=' . $data['itemid']);
				return ['error' => '物品ID必须是有效的数字'];
			}
			// 必须包含角色ID作为第三个参数
			$gmCommand = 'addsuperitem ' . $itemid . ' ' . $number . ' ' . $playerid;
			return $this->safeExecGmCommand($data, $gmCommand);
		}
	}
	public function addtitle($data)
	{
		$gmCommand = 'addtitle ' . intval($data['titleid']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function deltitle($data)
	{
		$gmCommand = 'deltitle ' . intval($data['titleid']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function addhyd($data)
	{
		$gmCommand = 'addhyd ' . intval($data['number']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function addRechargecurrencyS($data)
	{
		$gmCommand = 'addRechargecurrency ' . intval($data['moneyType']) . ' ' . intval($data['number']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}

	// 兼容旧方法名
	public function addqianS($data)
	{
		return $this->addRechargecurrencyS($data);
	}
	public function award($data)
	{
		$gmCommand = 'award ' . intval($data['awardid']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function offlinetime($data)
	{
		$gmCommand = 'offlinetime ' . intval($data['number']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function addpet($data)
	{
		$gmCommand = 'addpet ' . intval($data['petid']) . ' ' . intval($data['level']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function addpetskill($data)
	{
		$gmCommand = 'addpetskill ' . intval($data['skillid']) . ' 1 1';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function delpetskill($data)
	{
		$gmCommand = 'delpetskill ' . intval($data['skillid']) . ' 1 1';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function addpetexp($data)
	{
		$gmCommand = 'addpetexp ' . intval($data['number']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function addlife($data)
	{
		$gmCommand = 'addlife ' . intval($data['number']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function addbanggong($data)
	{
		$gmCommand = 'addbanggong ' . intval($data['number']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function addfactionmoney($data)
	{
		$gmCommand = 'addfactionmoney ' . intval($data['number']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function bpgx($data)
	{
		$gmCommand = 'bpgx';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function yaofangrefresh($data)
	{
		$gmCommand = 'yaofangrefresh';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function dismissguild($data)
	{
		$gmCommand = 'dismissguild';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function adddingzhiequip($data)
	{
		$playerid = intval($data['playerid']);
		$equipid = intval($data['equipid'] ?? 0);
		$skillid = intval($data['skillid'] ?? 0);
		$effectid = intval($data['effectid'] ?? 0);
		$suitid = intval($data['suitid'] ?? 0);
		$baseattr = str_replace(['"', '\\', "'"], '', (string)($data['baseattr'] ?? ''));
		$shuangjia = str_replace(['"', '\\', "'"], '', (string)($data['shuangjia'] ?? ''));
		$ronglian = str_replace(['"', '\\', "'"], '', (string)($data['ronglian'] ?? ''));

		$gmCommand = 'adddingzhiequip ' . $playerid . ' ' . $equipid . ' ' . $skillid . ' ' . $effectid . ' ' . $suitid . ' ' . $baseattr . ' ' . $shuangjia . ' ' . $ronglian;
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function cmd($data)
	{
		if (!$this->isBreakGlassAllowed((array)$data)) {
			\think\facade\Log::warning('自定义GM命令被拒绝|原因=break-glass未启用或审批码无效');
			return ['error' => 'Custom GM command is disabled'];
		}
		\think\facade\Log::info('执行自定义GM命令|cmd=' . $this->sanitizeGmCommandForLog((string)($data['cmd'] ?? '')));
		return $this->safeExecGmCommand($data, $data['cmd']);
	}
	public function rolecmd($data)
	{
		if (!$this->isBreakGlassAllowed((array)$data)) {
			\think\facade\Log::warning('角色GM命令被拒绝|原因=break-glass未启用或审批码无效');
			return ['error' => 'Role GM command is disabled'];
		}
		$cmd = trim($data['cmd']);
		\think\facade\Log::info('执行角色GM命令|cmd=' . $this->sanitizeGmCommandForLog($cmd));
		
		// 特殊处理：自动为 addsuperitem 命令添加角色ID参数
		if (preg_match('/^addsuperitem\s+(\d+)\s*(\d*)/i', $cmd, $matches)) {
			$itemid = intval($matches[1]);
			$number = isset($matches[2]) && !empty($matches[2]) ? intval($matches[2]) : 1;
			$playerid = intval($data['playerid']);
			
			// 构建完整的命令，包含角色ID
			$cmd = 'addsuperitem ' . $itemid . ' ' . $number . ' ' . $playerid;
			\think\facade\Log::info('自动修正addsuperitem命令|原始=' . $this->sanitizeGmCommandForLog((string)$data['cmd']) . '|修正后=' . $this->sanitizeGmCommandForLog($cmd));
		}
		
		return $this->safeExecGmCommand($data, $cmd);
	}
	public function setdays($data)
	{
		$gmCommand = 'setdays ' . intval($data['setdays']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	/**
	 * 条件邮件发送（已使用新命令名sysmailbycond，原mailbycond命令已废弃）
	 * @param array $data 邮件参数
	 * @return array 执行结果
	 */
	public function mailbycond($data)
	{
		//sysmailbycond title content duration awardContent:1|100,2|100 condContent:1|10|100,2|11|15
		// 不在此处转义，让 safeExecGmCommand -> buildGmCommand 统一处理转义
		$gmCommand = 'sysmailbycond ' . $data['mailTitle'] . ' ' . $data['mailInfo'] . ' ' . intval($data['lastTime']) . ' ' . $data['itemstr'] . ' 1|' . intval($data['levelmin']) . '|' . intval($data['levelmax']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function post($data)
	{
		// 不在此处转义，让 safeExecGmCommand -> buildGmCommand 统一处理转义
		$gmCommand = 'post ' . $data['notice'];
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function zmd($data)
	{
		// 不在此处转义，让 safeExecGmCommand -> buildGmCommand 统一处理转义
		$gmCommand = 'zmd ' . $data['notice'];
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function destroyzone($data)
	{
		$gmCommand = 'destroyzone';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function reload($data)
	{
		$gmCommand = 'reload';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function stopgs($data)
	{
		$gmCommand = 'stopgamegs ' . intval($data['gsTime']);
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function readpackandpet($data)
	{
		// 读取当前角色的背包和宠物信息（无需参数）
		$gmCommand = 'readpackandpet';
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	public function mail($data)
	{
		// mail命令参数需要直接拼接，不能使用escapeshellarg添加单引号
		// Java后端会解析GM命令字符串，多余的引号会导致NumberFormatException
		// 为安全起见，过滤掉可能破坏命令结构的特殊字符
		$title = str_replace(['"', '\\'], '', $data['title']);
		$content = str_replace(['"', '\\'], '', $data['content']);
		$awardContent = str_replace(['"', '\\', "'"], '', $data['awardContent']);

		$gmCommand = 'sysmail ' . intval($data['playerid']) . ' ' . $title . ' ' . $content . ' ' . intval($data['duration']) . ' ' . $awardContent;
		return $this->safeExecGmCommand($data, $gmCommand);
	}

	public function setpetvalue($data)
	{
		// 根据valuetype调用对应的参战宠物资质命令
		$valuetype = intval($data['valuetype']);
		$number = intval($data['number']);

		// valuetype映射：1=成长 2=攻击 3=防御 4=法术 5=体质 6=速度
		$cmdMap = [
			1 => 'setpetgrow',      // 成长资质
			2 => 'setpetattack',    // 攻击资质
			3 => 'setpetdefend',    // 防御资质
			4 => 'setpetmagic',     // 法术资质
			5 => 'setpetphyforce',  // 体质资质
			6 => 'setpetspeed',     // 速度资质
		];

		if (!isset($cmdMap[$valuetype])) {
			\think\facade\Log::warning('setpetvalue不支持的资质类型|valuetype=' . $valuetype);
			return ['error' => '不支持的资质类型，请选择其他选项'];
		}

		$gmCommand = $cmdMap[$valuetype] . ' ' . $number;
		return $this->safeExecGmCommand($data, $gmCommand);
	}
	
	/**
		* 检查角色是否在线（P0安全加固：移除假成功语义）
		*
		* @param array $data
		* @return array
		*/
	public function checkRoleOnline($data)
	{
		// P0: 显式失败，不允许假成功语义
		\think\facade\Log::error('GM方法未实现: checkRoleOnline', [
			'playerid' => $data['playerid'] ?? 'unknown',
			'serverip' => $data['serverip'] ?? 'unknown'
		]);
		return [
			'error' => 'GM方法未实现: checkRoleOnline，无法检查角色在线状态'
		];
	}

	/**
		* 获取角色数据（P0安全加固：移除假成功语义）
		*
		* @param array $data
		* @return array
		*/
	public function getRoleData($data)
	{
		// P0: 显式失败，不允许假成功语义
		\think\facade\Log::error('GM方法未实现: getRoleData', [
			'playerid' => $data['playerid'] ?? 'unknown',
			'serverip' => $data['serverip'] ?? 'unknown'
		]);
		return [
			'error' => 'GM方法未实现: getRoleData，无法获取角色数据'
		];
	}

	/**
		* 创建角色（P0安全加固：移除假成功语义）
		*
		* @param array $data
		* @return array
		*/
	public function createRole($data)
	{
		// P0: 显式失败，不允许假成功语义
		\think\facade\Log::error('GM方法未实现: createRole', [
			'rolename' => $data['rolename'] ?? 'unknown',
			'serverip' => $data['serverip'] ?? 'unknown'
		]);
		return [
			'error' => 'GM方法未实现: createRole，无法创建角色'
		];
	}

	/**
		* 迁移角色属性（P0安全加固：移除假成功语义）
		*
		* @param array $data
		* @return array
		*/
	public function migrateRoleAttributes($data)
	{
		// P0: 显式失败，不允许假成功语义
		\think\facade\Log::error('GM方法未实现: migrateRoleAttributes', [
			'source_playerid' => $data['source_playerid'] ?? 'unknown',
			'target_playerid' => $data['target_playerid'] ?? 'unknown'
		]);
		return [
			'error' => 'GM方法未实现: migrateRoleAttributes，无法迁移角色属性'
		];
	}

	/**
		* 迁移角色物品（P0安全加固：移除假成功语义）
		*
		* @param array $data
		* @return array
		*/
	public function migrateRoleItems($data)
	{
		// P0: 显式失败，不允许假成功语义
		\think\facade\Log::error('GM方法未实现: migrateRoleItems', [
			'source_playerid' => $data['source_playerid'] ?? 'unknown',
			'target_playerid' => $data['target_playerid'] ?? 'unknown'
		]);
		return [
			'error' => 'GM方法未实现: migrateRoleItems，无法迁移角色物品'
		];
	}

	/**
		* 迁移角色宠物（P0安全加固：移除假成功语义）
		*
		* @param array $data
		* @return array
		*/
	public function migrateRolePets($data)
	{
		// P0: 显式失败，不允许假成功语义
		\think\facade\Log::error('GM方法未实现: migrateRolePets', [
			'source_playerid' => $data['source_playerid'] ?? 'unknown',
			'target_playerid' => $data['target_playerid'] ?? 'unknown'
		]);
		return [
			'error' => 'GM方法未实现: migrateRolePets，无法迁移角色宠物'
		];
	}

	/**
		* 删除角色（P0安全加固：移除假成功语义）
		*
		* @param array $data
		* @return array
		*/
	public function deleteRole($data)
	{
		// P0: 显式失败，不允许假成功语义
		\think\facade\Log::error('GM方法未实现: deleteRole', [
			'playerid' => $data['playerid'] ?? 'unknown',
			'serverip' => $data['serverip'] ?? 'unknown'
		]);
		return [
			'error' => 'GM方法未实现: deleteRole，无法删除角色'
		];
	}

	/**
		* 恢复角色数据（P0安全加固：移除假成功语义）
		*
		* @param array $data
		* @return array
		*/
	public function restoreRoleData($data)
	{
		// P0: 显式失败，不允许假成功语义
		\think\facade\Log::error('GM方法未实现: restoreRoleData', [
			'playerid' => $data['playerid'] ?? 'unknown',
			'serverip' => $data['serverip'] ?? 'unknown'
		]);
		return [
			'error' => 'GM方法未实现: restoreRoleData，无法恢复角色数据'
		];
	}
}

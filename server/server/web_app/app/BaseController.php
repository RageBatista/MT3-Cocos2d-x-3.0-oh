<?php
declare (strict_types = 1);

namespace app;

use think\App;
use think\exception\ValidateException;
use think\Validate;
use think\facade\View;
use think\facade\Cookie;
use think\facade\Session;
use think\facade\Request;
use think\facade\Log;
use app\model\Config;
use cznet\IpLocation;
use app\model\Agent as AG;

/**
 * 控制器基础类
 */
 
#[\AllowDynamicProperties]
abstract class BaseController
{
    /**
     * Request实例
     * @var \think\Request
     */
    protected $request;

    /**
     * 应用实例
     * @var \think\App
     */
    protected $app;

    /**
     * 是否批量验证
     * @var bool
     */
    protected $batchValidate = false;

    /**
     * 控制器中间件
     * @var array
     */
    protected $middleware = [];

    /**
     * 通用变量
     * @var array
     */
    protected $genericVariable = [];
    
    /**
     * 系统配置
     * @var array
     */
    protected $config = [];
    
    /**
     * 应用名称
     * @var string
     */
    protected $app_name;
    
    /**
     * 控制器名称
     * @var string
     */
    protected $controller_name;
    
    /**
     * 当前管理员信息（私有属性，防止篡改）
     * @var array
     */
    private $myAdmin = [];
    
    /**
     * 获取当前管理员信息
     * @return array
     */
    protected function getMyAdmin()
    {
        return $this->myAdmin;
    }
    
    /**
     * 设置当前管理员信息（仅限内部使用）
     * @param array $admin
     */
    protected function setMyAdmin($admin)
    {
        $this->myAdmin = $admin;
    }
    
    /**
     * 魔术方法 - 允许通过属性访问获取 myAdmin（向后兼容）
     * @param string $name 属性名
     * @return mixed
     */
    public function __get($name)
    {
        if ($name === 'myAdmin') {
            return $this->myAdmin;
        }
        throw new \Exception('Undefined property: ' . get_class($this) . '::$' . $name);
    }
    
    /**
     * 魔术方法 - 防止外部修改 myAdmin
     * @param string $name 属性名
     * @param mixed $value 属性值
     * @throws \Exception
     */
    public function __set($name, $value)
    {
        if ($name === 'myAdmin') {
            throw new \Exception('Cannot modify myAdmin directly. Use setMyAdmin() method instead.');
        }
        // 仅允许设置白名单中的属性，防止关键属性被覆盖
        $allowedProperties = ['middleware'];
        if (!in_array($name, $allowedProperties)) {
            throw new \Exception("Cannot set property '{$name}' directly.");
        }
        $this->$name = $value;
    }

    /**
     * 构造方法
     * @access public
     * @param  App  $app  应用对象
     */
    public function __construct(App $app)
    {
        $this->app     = $app;
        $this->request = $this->app->request;
        // 控制器初始化
        $this->initialize();
    }

    // 初始化
	
    protected function initialize()
    {
		ini_set('date.timezone','Asia/Shanghai');
        
		$location = new IpLocation();
        $locationData = $location->getlocation($this->request->ip());
        
        $country = '未知';
        $area = '未知';
        if (is_array($locationData)) {
            $country = $locationData['country'] ?? '未知';
            $area = $locationData['area'] ?? '未知';
        }
        
		$genericVariable = [
			'ip' => $this->request->ip(),
			'city' => $country.'-'.$area,
			'time' => time(),
			'date' => date('Y-m-d H:i:s')
		];
		$this->genericVariable = $genericVariable;
		try {
			$config = new Config();
			$configData = $config->getConfig();
			$this->config = is_array($configData) ? $configData : [];
		} catch (\Throwable $e) {
			$this->config = [];
			Log::error('初始化加载系统配置失败: ' . $e->getMessage());
		}
		
		
		$app = app('http')->getName();
		$controller = Request::controller();
		$this->app_name = $app;
		$this->controller_name = $controller;
		// 生成并注入 CSRF Token
		$csrf_token = '';
		if (class_exists('\\think\\facade\\Session')) {
			try {
				$csrf_token = $this->buildToken();
			} catch (\Throwable $e) {
				// Session 未就绪时忽略
			}
		}
		
		View::assign([
			'config' => $this->config,
			'app'  => $app,
			'controller'  => $controller,
			'csrf_token' => $csrf_token
		]);
		if($app=='admin'||$app=='agent'){
			if ($app=='admin') {
			    $username = Session::get('player_admin_username') ?: Session::get('username_1');
			} else {
			    $username = Session::get('player_admin_username') ?: Session::get('username_2');
			}
			$AG = new AG();
			$findAdmin = $AG->getByUsername($username);
			$this->setMyAdmin($findAdmin);
			View::assign([
				'myAdmin' => $findAdmin
			]);
		}
		
		// 黑名单模型按需初始化，避免在请求启动阶段强依赖数据库驱动
		// $BIP = new BIP();
	}

    /**
     * 验证数据
     * @access protected
     * @param  array        $data     数据
     * @param  string|array $validate 验证器名或者验证规则数组
     * @param  array        $message  提示信息
     * @param  bool         $batch    是否批量验证
     * @return array|string|true
     * @throws ValidateException
     */
    protected function validate(array $data, string|array $validate, array $message = [], bool $batch = false)
    {
        if (is_array($validate)) {
            $v = new Validate();
            $v->rule($validate);
        } else {
            if (strpos($validate, '.')) {
                // 支持场景
                [$validate, $scene] = explode('.', $validate);
            }
            $class = false !== strpos($validate, '\\') ? $validate : $this->app->parseClass('validate', $validate);
            $v     = new $class();
            if (!empty($scene)) {
                $v->scene($scene);
            }
        }

        $v->message($message);

        // 是否批量验证
        if ($batch || $this->batchValidate) {
            $v->batch(true);
        }

        return $v->failException(true)->check($data);
    }

    /**
     * 输入验证和清理方法
     * @access protected
     * @param  string $input 输入字符串
     * @return string 清理后的字符串
     * @deprecated P2标记：此方法使用黑名单过滤方式，易被绕过（如 "selselectect" → "select"）。
     *             请使用ThinkPHP ORM参数绑定防止SQL注入，使用htmlspecialchars()防止XSS。
     *             此方法保留仅为向后兼容，请勿在新代码中使用。
     */
    protected function validateInput($input)
    {
        if (empty($input)) {
            return '';
        }
        
        // 移除前后空格
        $input = trim($input);
        
        // 移除反斜杠
        $input = stripslashes($input);
        
        // 转义HTML特殊字符
        $input = htmlspecialchars($input, ENT_QUOTES, 'UTF-8');
        
        // 移除SQL注入相关的危险字符
        $dangerous_chars = ["'", '"', ';', '--', '/*', '*/', 'union', 'select', 'insert', 'update', 'delete', 'drop', 'create', 'alter'];
        foreach ($dangerous_chars as $char) {
            $input = str_ireplace($char, '', $input);
        }
        
        // 限制长度
        if (strlen($input) > 255) {
            $input = substr($input, 0, 255);
        }
        
        return $input;
    }

    /**
     * 验证数字输入
     * @access protected
     * @param  mixed $input 输入值
     * @return int 验证后的整数
     */
    protected function validateInt($input)
    {
        return intval($input);
    }

    /**
     * 验证邮箱格式
     * @access protected
     * @param  string $email 邮箱地址
     * @return bool 是否有效
     */
    protected function validateEmail($email)
    {
        return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    }

    /**
     * 验证URL格式
     * @access protected
     * @param  string $url URL地址
     * @return bool 是否有效
     */
    protected function validateUrl($url)
    {
        return filter_var($url, FILTER_VALIDATE_URL) !== false;
    }

    /**
     * 生成CSRF Token
     * @return string
     */
    protected function buildToken()
    {
        $token = Session::get('__csrf_token__');
        if (!$token) {
            $token = md5(uniqid((string)mt_rand(), true));
            Session::set('__csrf_token__', $token);
        }
        return $token;
    }

    /**
     * 验证CSRF Token
     * @param string $token
     * @return bool
     */
    protected function checkToken($token)
    {
        $sessionToken = Session::get('__csrf_token__');
        return $sessionToken && hash_equals($sessionToken, (string)$token);
    }

    /**
     * 确保获取当前玩家信息（统一Session fallback逻辑）
     * 优先从中间件注入的 $this->request->player 获取，
     * 若中间件未注入则从Session中恢复玩家信息。
     * @return array|null 玩家信息，未登录返回null
     */
    protected function ensurePlayer()
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

        // Session fallback：中间件未注入时从Session恢复
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
                // getPlayerInfo返回null，构建最小信息
                return $this->attachPlayerDisplayUid([
                    'id' => $playerId,
                    'username' => $playerUsername,
                    'profile' => [],
                    'servers' => []
                ]);
            } catch (\Exception $e) {
                \think\facade\Log::error('ensurePlayer exception', [
                    'user_id' => $playerId,
                    'username' => $playerUsername,
                    'error' => $e->getMessage()
                ]);
                // 异常时也返回最小信息，避免阻断用户
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

    /**
     * 为玩家信息附加展示用角色UID
     */
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

    /**
     * 解析当前应展示的角色UID
     */
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

            // CDK授权链路：Session 中 id 即游戏角色ID
            if ($sessionCdk !== '' && $sessionId > 0) {
                $roleExists = \think\facade\Db::name('user_bind')
                    ->where('playerid', $sessionId)
                    ->find();

                if (!empty($roleExists)) {
                    return $sessionId;
                }

                // 兜底：若 cdk 标记与 session id 不匹配角色数据，视为历史脏会话并清理
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
                $serverRoleUid = \think\facade\Db::name('user_bind')
                    ->where('userid', $userId)
                    ->where('serverid', $serverId)
                    ->order('playerid', 'asc')
                    ->value('playerid');

                if (!empty($serverRoleUid)) {
                    return intval($serverRoleUid);
                }
            }

            $defaultRoleUid = \think\facade\Db::name('user_bind')
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

    /**
     * 判断当前会话是否为 CDK 授权链路
     */
    protected function isCdkLoginSession(): bool
    {
        if (!function_exists('getSession')) {
            return false;
        }

        $loginMode = strtolower(trim((string)getSession('login_mode', '')));
        $cdk = trim((string)getSession('cdk', ''));

        return $loginMode === 'cdk' || $cdk !== '';
    }

    /**
     * 解析当前会话中的角色ID
     */
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

    /**
     * 解析当前会话可访问的角色列表
     * - 账号登录：返回账号下所有角色
     * - CDK登录：仅返回当前授权角色
     */
    protected function resolveAccessibleRoles(array $player, int $serverId = 0): array
    {
        $fields = 'userid,serverid,playerid,playername';

        if ($this->isCdkLoginSession()) {
            $roleId = $this->resolveSessionRoleId($player);
            if ($roleId <= 0) {
                return [];
            }

            $query = \think\facade\Db::name('user_bind')
                ->where('playerid', $roleId);

            if ($serverId > 0) {
                $query->where('serverid', $serverId);
            }

            $row = $query->field($fields)->find();
            if ($row) {
                return [$row];
            }

            // 兜底：角色绑定缺失时仍返回当前授权角色，避免前端下拉为空
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

        $query = \think\facade\Db::name('user_bind')
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

        // 兼容历史混合会话：尝试按 session roleid 回查单角色
        $roleId = $this->resolveSessionRoleId($player);
        if ($roleId <= 0) {
            return [];
        }

        $query = \think\facade\Db::name('user_bind')
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

    /**
     * 解析当前会话对应的账号ID（用于 uid 口径的业务表）
     */
    protected function resolveSessionUserId(array $player): int
    {
        if (!$this->isCdkLoginSession()) {
            return intval($player['id'] ?? 0);
        }

        $roleId = $this->resolveSessionRoleId($player);
        if ($roleId <= 0) {
            return 0;
        }

        $uid = \think\facade\Db::name('user_bind')
            ->where('playerid', $roleId)
            ->value('userid');

        return intval($uid ?: 0);
    }

}

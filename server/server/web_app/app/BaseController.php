<?php
declare (strict_types = 1);

namespace app;

use think\App;
use think\exception\ValidateException;
use think\Validate;
use think\facade\View;
use think\facade\Session;
use think\facade\Request;
use think\facade\Log;
use app\model\Config;
use app\model\Agent as AG;
use app\traits\CsrfTrait;
use app\traits\PlayerSessionTrait;
use app\service\IpLocationService;

#[\AllowDynamicProperties]
abstract class BaseController
{
    use CsrfTrait;
    use PlayerSessionTrait;

    protected $request;

    protected $app;

    protected $batchValidate = false;

    protected $middleware = [];

    protected $genericVariable = [];

    protected $config = [];

    protected $app_name;

    protected $controller_name;

    private $myAdmin = [];

    protected function getMyAdmin()
    {
        return $this->myAdmin;
    }

    protected function setMyAdmin($admin)
    {
        $this->myAdmin = $admin;
    }

    public function __get($name)
    {
        if ($name === 'myAdmin') {
            return $this->myAdmin;
        }
        throw new \Exception('Undefined property: ' . get_class($this) . '::$' . $name);
    }

    public function __set($name, $value)
    {
        if ($name === 'myAdmin') {
            throw new \Exception('Cannot modify myAdmin directly. Use setMyAdmin() method instead.');
        }
        $allowedProperties = ['middleware'];
        if (!in_array($name, $allowedProperties)) {
            throw new \Exception("Cannot set property '{$name}' directly.");
        }
        $this->$name = $value;
    }

    public function __construct(App $app)
    {
        $this->app     = $app;
        $this->request = $this->app->request;
        $this->initialize();
    }

    protected function initialize()
    {
        ini_set('date.timezone','Asia/Shanghai');

        $ipLocation = IpLocationService::locate($this->request->ip());

        $genericVariable = [
            'ip' => $this->request->ip(),
            'city' => $ipLocation['city'],
            'time' => time(),
            'date' => date('Y-m-d H:i:s')
        ];
        $this->genericVariable = $genericVariable;
        $defaultConfig = [
            'name' => 'GM管理后台',
            'logo' => '/favicon.ico',
            'icon' => '/favicon.ico',
            'background' => '',
            'agent_notice' => '',
        ];
        try {
            $config = new Config();
            $configData = $config->getConfig();
            $this->config = is_array($configData) ? array_merge($defaultConfig, $configData) : $defaultConfig;
        } catch (\Throwable $e) {
            $this->config = $defaultConfig;
            Log::error('初始化加载系统配置失败: ' . $e->getMessage());
        }

        $app = app('http')->getName();
        $controller = Request::controller();
        $this->app_name = $app;
        $this->controller_name = $controller;

        $csrf_token = '';
        if (class_exists('\\think\\facade\\Session')) {
            try {
                $csrf_token = $this->buildToken();
            } catch (\Throwable $e) {
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
    }

    protected function validate(array $data, string|array $validate, array $message = [], bool $batch = false)
    {
        if (is_array($validate)) {
            $v = new Validate();
            $v->rule($validate);
        } else {
            if (strpos($validate, '.')) {
                [$validate, $scene] = explode('.', $validate);
            }
            $class = false !== strpos($validate, '\\') ? $validate : $this->app->parseClass('validate', $validate);
            $v     = new $class();
            if (!empty($scene)) {
                $v->scene($scene);
            }
        }

        $v->message($message);

        if ($batch || $this->batchValidate) {
            $v->batch(true);
        }

        return $v->failException(true)->check($data);
    }

    protected function validateInput($input)
    {
        if (empty($input)) {
            return '';
        }

        $input = trim($input);
        $input = stripslashes($input);
        $input = htmlspecialchars($input, ENT_QUOTES, 'UTF-8');

        $dangerous_chars = ["'", '"', ';', '--', '/*', '*/', 'union', 'select', 'insert', 'update', 'delete', 'drop', 'create', 'alter'];
        foreach ($dangerous_chars as $char) {
            $input = str_ireplace($char, '', $input);
        }

        if (strlen($input) > 255) {
            $input = substr($input, 0, 255);
        }

        return $input;
    }

    protected function validateInt($input)
    {
        return intval($input);
    }

    protected function validateEmail($email)
    {
        return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    }

    protected function validateUrl($url)
    {
        return filter_var($url, FILTER_VALIDATE_URL) !== false;
    }
}

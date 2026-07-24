<?php
// 应用公共文件

/*回调*/
if(!function_exists('notify'))
{
    function notify($code,$msg,$data=[])
    {
        $result = [
            'code'=>$code,
            'msg'=>$msg
        ];
        if(!empty($data)){
            $result['data']=$data;
        }
        return json($result);
    }
}
if (!function_exists('password')) {

    /**
     * 密码加密算法
     * @param $value 需要加密的值
     * @param $type  加密类型，默认为md5 （md5, hash）
     * @return mixed
     */
    function password($password,$hash=null)
    {
		if($hash==null){
			$return = password_hash($password, PASSWORD_DEFAULT);
		}else{
			$return = password_verify($password, $hash);
		}
		return $return;
    }

}

if (!function_exists('isJson')) {

    /**
     * 判断json字符串
     */

	function isJson($string) {
		if($string==null){
			return false;
		}else{
			return is_array(json_decode($string, true));
		}
	}
}
if (!function_exists('agentTree')) {

    /**
     * 密码加密算法
     * @param $value 需要加密的值
     * @param $type  加密类型，默认为md5 （md5, hash）
     * @return mixed
     */
	 
    function agentTree($lastagent,$id=null)
    {
		if($id==$lastagent['id']){
			return false;
		}
		$agentTree = json_decode($lastagent['agent_tree']);
		$agentTree[] = '@'.$lastagent['id'].'@';
		$agentTree = json_encode($agentTree);
		return $agentTree;
    }
}

if (!function_exists('adminLogout')) {

    function adminLogout()
    {
	session_unset();
	\think\facade\Session::clear();
	\think\facade\Cookie::delete('adminToken');
	
	return redirect('/login');
    }

}

if (!function_exists('safeUnserialize')) {
    /**
     * 安全的反序列化函数
     * 防止反序列化漏洞攻击
     * 
     * @param string|null $data 需要反序列化的数据
     * @param mixed $default 反序列化失败时返回的默认值
     * @param array $allowedClasses 允许的类（默认只允许基本类型，不允许对象）
     * @return mixed 反序列化后的数据或默认值
     */
    function safeUnserialize($data, $default = [], $allowedClasses = false)
    {
        if ($data === null || $data === '') {
            return $default;
        }
        
        if (!is_string($data)) {
            return $default;
        }
        
        if (!preg_match('/^([asbdioO]:|N;)/', $data)) {
            return $default;
        }
        
        if ($allowedClasses === false && preg_match('/O:\d+:"/', $data)) {
            \think\facade\Log::warning('检测到可疑的对象反序列化尝试: ' . substr($data, 0, 200));
            return $default;
        }
        
        try {
            if (version_compare(PHP_VERSION, '7.0.0') >= 0) {
                $result = @unserialize($data, ['allowed_classes' => $allowedClasses]);
            } else {
                $result = @unserialize($data);
            }
            
            if ($result === false && $data !== serialize(false)) {
                return $default;
            }
            
            return $result;
            
        } catch (\Exception $e) {
            \think\facade\Log::error('反序列化失败: ' . $e->getMessage());
            return $default;
        } catch (\Error $e) {
            \think\facade\Log::error('反序列化错误: ' . $e->getMessage());
            return $default;
        }
    }
}

if (!function_exists('app_path')) {
    /**
     * ThinkPHP 版本兼容：补齐 app_path() 助手函数。
     * 某些环境下该函数不存在，会导致应用启动阶段直接报 500。
     */
    function app_path($path = '')
    {
        $base = __DIR__ . DIRECTORY_SEPARATOR;
        if ($path === '' || $path === null) {
            return $base;
        }
        return $base . ltrim((string)$path, '/\\');
    }
}

$playerCommonFile = app_path() . 'player' . DIRECTORY_SEPARATOR . 'common.php';
if (file_exists($playerCommonFile)) {
    require_once $playerCommonFile;
}

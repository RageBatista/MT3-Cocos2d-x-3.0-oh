<?php
namespace app\middleware;

use think\facade\Log;
use think\facade\Config;

class Security
{
    public function handle($request, \Closure $next)
    {
        // 获取安全配置
        $securityConfig = Config::get('security');
        
        // SQL注入检测
        if ($securityConfig['sql_injection']['enabled']) {
            $this->checkSqlInjection($request, $securityConfig);
        }
        
        // XSS检测
        if ($securityConfig['xss_protection']['enabled']) {
            $this->checkXss($request, $securityConfig);
        }
        
        // IP黑名单检查
        if ($securityConfig['ip_blacklist']['enabled']) {
            $this->checkIpBlacklist($request, $securityConfig);
        }
        
        return $next($request);
    }
    
    /**
     * 检测SQL注入攻击
     */
    private function checkSqlInjection($request, $config)
    {
        $dangerousChars = $config['sql_injection']['dangerous_chars'];
        $maxLength = $config['sql_injection']['max_length'];
        
        // 检查GET参数
        $getParams = $request->get();
        foreach ($getParams as $key => $value) {
            if (is_string($value)) {
                if (strlen($value) > $maxLength) {
                    $this->logAttack('SQL_INJECTION_LENGTH', $request, $value);
                    $this->blockRequest('输入长度超出限制');
                }
                
                foreach ($dangerousChars as $char) {
                    if (stripos($value, $char) !== false) {
                        $this->logAttack('SQL_INJECTION_CHAR', $request, $value);
                        $this->blockRequest('检测到危险字符');
                    }
                }
            }
        }
        
        // 检查POST参数
        $postParams = $request->post();
        foreach ($postParams as $key => $value) {
            if (is_string($value)) {
                if (strlen($value) > $maxLength) {
                    $this->logAttack('SQL_INJECTION_LENGTH', $request, $value);
                    $this->blockRequest('输入长度超出限制');
                }
                
                foreach ($dangerousChars as $char) {
                    if (stripos($value, $char) !== false) {
                        $this->logAttack('SQL_INJECTION_CHAR', $request, $value);
                        $this->blockRequest('检测到危险字符');
                    }
                }
            }
        }
    }
    
    /**
     * 检测XSS攻击
     */
    private function checkXss($request, $config)
    {
        $dangerousTags = $config['xss_protection']['dangerous_tags'];
        $dangerousAttributes = $config['xss_protection']['dangerous_attributes'];
        
        // 检查GET参数
        $getParams = $request->get();
        foreach ($getParams as $key => $value) {
            if (is_string($value)) {
                foreach ($dangerousTags as $tag) {
                    if (stripos($value, '<' . $tag) !== false) {
                        $this->logAttack('XSS_TAG', $request, $value);
                        $this->blockRequest('检测到危险标签');
                    }
                }
                
                foreach ($dangerousAttributes as $attr) {
                    if (stripos($value, $attr . '=') !== false) {
                        $this->logAttack('XSS_ATTRIBUTE', $request, $value);
                        $this->blockRequest('检测到危险属性');
                    }
                }
            }
        }
        
        // 检查POST参数
        $postParams = $request->post();
        foreach ($postParams as $key => $value) {
            if (is_string($value)) {
                foreach ($dangerousTags as $tag) {
                    if (stripos($value, '<' . $tag) !== false) {
                        $this->logAttack('XSS_TAG', $request, $value);
                        $this->blockRequest('检测到危险标签');
                    }
                }
                
                foreach ($dangerousAttributes as $attr) {
                    if (stripos($value, $attr . '=') !== false) {
                        $this->logAttack('XSS_ATTRIBUTE', $request, $value);
                        $this->blockRequest('检测到危险属性');
                    }
                }
            }
        }
    }
    
    /**
     * 检查IP黑名单
     */
    private function checkIpBlacklist($request, $config)
    {
        $clientIp = $request->ip();
        $blacklist = $config['ip_blacklist']['blacklist'];
        $whitelist = $config['ip_blacklist']['whitelist'];
        
        // 检查白名单
        if (in_array($clientIp, $whitelist)) {
            return;
        }
        
        // 检查黑名单
        if (in_array($clientIp, $blacklist)) {
            $this->logAttack('IP_BLACKLIST', $request, $clientIp);
            $this->blockRequest('您的IP已被禁止访问');
        }
    }
    
    /**
     * 记录攻击日志
     */
    private function logAttack($type, $request, $value)
    {
        $logData = [
            'type' => $type,
            'ip' => $request->ip(),
            'url' => $request->url(),
            'method' => $request->method(),
            'user_agent' => $request->header('user-agent'),
            'value' => $value,
            'time' => date('Y-m-d H:i:s')
        ];
        
        Log::warning('Security Attack: ' . json_encode($logData, JSON_UNESCAPED_UNICODE));
    }
    
    /**
     * 阻止请求
     */
    private function blockRequest($message)
    {
        header('HTTP/1.1 403 Forbidden');
        exit('访问被拒绝: ' . $message);
    }
} 
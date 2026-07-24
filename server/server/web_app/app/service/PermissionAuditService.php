<?php
namespace app\service;

/**
 * 权限审计日志服务
 * 用于记录权限变更和敏感操作
 */
class PermissionAuditService
{
    /**
     * 记录权限变更
     * @param string $operator 操作者
     * @param string $target 目标
     * @param string $action 操作类型
     * @param array $details 详细信息
     * @param bool $success 是否成功
     * @param string $reason 失败原因
     */
    public static function logPermissionChange($operator, $target, $action, $details = [], $success = true, $reason = '')
    {
        $log = new \app\model\AdminLog();
        $logData = [
            'username' => $operator,
            'info' => $action . ' - 目标: ' . $target . ($reason ? ' - 原因: ' . $reason : ''),
            'date' => date('Y-m-d H:i:s'),
            'time' => time(),
            'ip' => \think\facade\Request::ip(),
            'city' => self::getCity()
        ];
        
        // 添加详细信息
        if (!empty($details)) {
            $logData['info'] .= ' - 详情: ' . json_encode($details, JSON_UNESCAPED_UNICODE);
        }
        
        $log->save($logData);
    }
    
    /**
     * 记录GM操作
     * @param string $operator 操作者
     * @param string $gmAction GM操作类型
     * @param array $details 详细信息
     * @param bool $success 是否成功
     * @param string $reason 失败原因
     */
    public static function logGMOperation($operator, $gmAction, $details = [], $success = true, $reason = '')
    {
        $log = new \app\model\AdminLog();
        $logData = [
            'username' => $operator,
            'info' => 'GM操作 - ' . $gmAction . ($reason ? ' - 原因: ' . $reason : ''),
            'date' => date('Y-m-d H:i:s'),
            'time' => time(),
            'ip' => \think\facade\Request::ip(),
            'city' => self::getCity()
        ];
        
        // 添加详细信息
        if (!empty($details)) {
            $logData['info'] .= ' - 详情: ' . json_encode($details, JSON_UNESCAPED_UNICODE);
        }
        
        $log->save($logData);
    }
    
    /**
     * 记录操作审计
     * @param string $operator 操作者
     * @param string $module 模块
     * @param string $action 操作
     * @param array $details 详细信息
     * @param bool $success 是否成功
     */
    public static function logOperation($operator, $module, $action, $details = [], $success = true)
    {
        $log = new \app\model\AdminLog();
        $logData = [
            'username' => $operator,
            'info' => $module . ' - ' . $action . ($success ? ' - 成功' : ' - 失败'),
            'date' => date('Y-m-d H:i:s'),
            'time' => time(),
            'ip' => \think\facade\Request::ip(),
            'city' => self::getCity()
        ];
        
        // 添加详细信息
        if (!empty($details)) {
            $logData['info'] .= ' - 详情: ' . json_encode($details, JSON_UNESCAPED_UNICODE);
        }
        
        $log->save($logData);
    }
    
    /**
     * 获取城市信息
     * @return string
     */
    private static function getCity()
    {
        try {
            $location = new \cznet\IpLocation();
            $location = $location->getlocation(\think\facade\Request::ip());
            return $location['country'] . '-' . $location['area'];
        } catch (\Exception $e) {
            return '未知';
        }
    }
}

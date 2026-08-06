<?php
namespace app\service;

/**
 * 权限审计日志服务
 * 用于记录权限变更和敏感操作
 */
class PermissionAuditService
{
    public static function logPermissionChange($operator, $target, $action, $details = [], $success = true, $reason = '')
    {
        $info = $action . ' - 目标: ' . $target . ($reason ? ' - 原因: ' . $reason : '');
        if (!empty($details)) {
            $info .= ' - 详情: ' . json_encode($details, JSON_UNESCAPED_UNICODE);
        }

        self::writeAdminAuditLog((string)$operator, $info);
    }

    public static function logGMOperation($operator, $gmAction, $details = [], $success = true, $reason = '')
    {
        $info = 'GM操作 - ' . $gmAction . ($reason ? ' - 原因: ' . $reason : '');
        if (!empty($details)) {
            $info .= ' - 详情: ' . json_encode($details, JSON_UNESCAPED_UNICODE);
        }

        self::writeAdminAuditLog((string)$operator, $info);
    }

    public static function logOperation($operator, $module, $action, $details = [], $success = true)
    {
        $info = $module . ' - ' . $action . ($success ? ' - 成功' : ' - 失败');
        if (!empty($details)) {
            $info .= ' - 详情: ' . json_encode($details, JSON_UNESCAPED_UNICODE);
        }

        self::writeAdminAuditLog((string)$operator, $info);
    }

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

    private static function writeAdminAuditLog(string $operator, string $info): void
    {
        $log = new \app\model\AdminLog();
        $log->addAdminLog($operator, $info, [
            'date' => date('Y-m-d H:i:s'),
            'time' => (string)time(),
            'ip' => (string)\think\facade\Request::ip(),
            'city' => self::getCity(),
        ]);
    }
}

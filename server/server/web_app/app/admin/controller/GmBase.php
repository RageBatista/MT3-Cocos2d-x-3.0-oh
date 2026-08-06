<?php
declare(strict_types=1);

namespace app\admin\controller;

use app\BaseController;
use app\service\PermissionAuditService;

class GmBase extends BaseController
{
    protected function checkGMPermission(): bool
    {
        $currentUser = $this->myAdmin;
        if (!isset($currentUser['type']) || (int)$currentUser['type'] !== 1) {
            $this->logGMOperation($currentUser, '未授权GM操作', false, '非管理员');
            return false;
        }
        return true;
    }

    protected function logGMOperation($currentUser, string $action, bool $success, string $reason = ''): void
    {
        PermissionAuditService::logGMOperation(
            $currentUser['username'] ?? 'unknown',
            $action,
            [],
            $success,
            $reason
        );
    }

    protected function requireGMPermission()
    {
        if (!$this->checkGMPermission()) {
            return notify(0, '无权执行GM操作');
        }
        return null;
    }

    protected function requireCSRF(): ?\think\Response
    {
        $token = $this->request->post('csrf_token', '');
        if (!$this->checkToken($token)) {
            return notify(0, '非法请求：CSRF令牌无效');
        }
        return null;
    }
}

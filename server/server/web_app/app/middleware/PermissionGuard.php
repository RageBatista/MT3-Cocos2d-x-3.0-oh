<?php
declare(strict_types=1);

namespace app\middleware;

use think\Response;
use think\facade\Session;
use think\facade\Log;

class PermissionGuard
{
    public function handle($request, \Closure $next)
    {
        $app = strtolower((string)app('http')->getName());
        if (!in_array($app, ['admin', 'agent'], true)) {
            return $next($request);
        }

        $controller = strtolower((string)$request->controller());
        $action = strtolower((string)$request->action());
        $key = $app . '.' . $controller . '.' . $action;

        $rules = (array)config('permission.rules', []);
        if (!isset($rules[$key])) {
            if ($app === 'admin' && strpos($controller, 'gm') === 0) {
                Log::warning('GM权限拒绝访问: 未配置权限规则', [
                    'route_key' => $key,
                ]);
                return Response::create(json_encode([
                    'code' => 403,
                    'msg' => 'GM权限未配置，已拒绝访问',
                    'request_id' => function_exists('build_request_id') ? build_request_id() : ''
                ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES), 'json', 403);
            }
            return $next($request);
        }

        $adminType = intval(Session::get('player_admin_type', 0));
        $adminUser = (string)Session::get('player_admin_username', '');
        $allowTypes = (array)$rules[$key];
        if (!in_array($adminType, $allowTypes, true)) {
            Log::warning('权限拒绝访问', [
                'user' => $adminUser,
                'admin_type' => $adminType,
                'route_key' => $key,
            ]);
            return Response::create(json_encode([
                'code' => 403,
                'msg' => '无权限访问该资源',
                'request_id' => function_exists('build_request_id') ? build_request_id() : ''
            ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES), 'json', 403);
        }

        return $next($request);
    }
}

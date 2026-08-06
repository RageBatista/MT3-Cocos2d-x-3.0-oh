<?php
declare(strict_types=1);

use think\facade\Route;

if (!function_exists('web_admin_route_definitions')) {
    function web_admin_route_definitions(): array
    {
        return require __DIR__ . '/web_admin_routes.php';
    }
}

if (!function_exists('web_admin_join_route')) {
    function web_admin_join_route(string $prefix, string $path): string
    {
        $prefix = trim($prefix, '/');
        $path = trim($path, '/');
        if ($prefix === '' && $path === '') {
            return '/';
        }
        if ($prefix === '') {
            return $path;
        }
        if ($path === '') {
            return $prefix;
        }
        return $prefix . '/' . $path;
    }
}

if (!function_exists('web_admin_register_route_set')) {
    function web_admin_register_route_set(array $routeSet, string $urlPrefix, string $targetPrefix): void
    {
        foreach ($routeSet as $method => $routes) {
            foreach ($routes as $path => $target) {
                $rule = web_admin_join_route($urlPrefix, (string)$path);
                $routeTarget = $targetPrefix === '' ? $target : $targetPrefix . '.' . $target;
                Route::rule($rule, $routeTarget, (string)$method)->completeMatch();
            }
        }
    }
}

if (!function_exists('web_admin_register_global_routes')) {
    function web_admin_register_global_routes(): void
    {
        $definitions = web_admin_route_definitions();
        foreach (['admin', 'agent'] as $module) {
            web_admin_register_route_set($definitions[$module] ?? [], $module, $module);
        }
    }
}

if (!function_exists('web_admin_register_module_routes')) {
    function web_admin_register_module_routes(string $module): void
    {
        $definitions = web_admin_route_definitions();
        web_admin_register_route_set($definitions[$module] ?? [], '', '');
    }
}

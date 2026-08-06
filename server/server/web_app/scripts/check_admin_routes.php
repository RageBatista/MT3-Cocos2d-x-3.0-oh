<?php
declare(strict_types=1);

$command = escapeshellarg(PHP_BINARY) . ' think route:list';
$lines = [];
$exitCode = 0;
exec($command, $lines, $exitCode);

if ($exitCode !== 0) {
    fwrite(STDERR, "route:list failed with exit code {$exitCode}\n");
    exit(1);
}

$routeList = implode("\n", $lines);

$checks = [
    ['name' => 'login page', 'rule' => 'login', 'route' => 'login.Index/index', 'methods' => ['get', 'head']],
    ['name' => 'login submit', 'rule' => 'login/submit', 'route' => 'login.Index/submit', 'methods' => ['post'], 'exact' => true],
    ['name' => 'admin home', 'rule' => 'admin', 'route' => 'admin.Index/index', 'methods' => ['get', 'head']],
    ['name' => 'admin player page', 'rule' => 'admin/player/list', 'route' => 'admin.Player/list', 'methods' => ['get', 'head']],
    ['name' => 'admin player bind page', 'rule' => 'admin/player/bindList', 'route' => 'admin.Player/bindList', 'methods' => ['get', 'head']],
    ['name' => 'admin player bind data', 'rule' => 'admin/player/bind_list_table', 'route' => 'admin.Player/bind_list_table', 'methods' => ['get', 'post']],
    ['name' => 'admin player delete', 'rule' => 'admin/player/del', 'route' => 'admin.Player/del', 'methods' => ['post'], 'exact' => true],
    ['name' => 'admin agent page', 'rule' => 'admin/agent/list', 'route' => 'admin.Agent/list', 'methods' => ['get', 'head']],
    ['name' => 'admin agent status', 'rule' => 'admin/agent/status', 'route' => 'admin.Agent/status', 'methods' => ['post'], 'exact' => true],
    ['name' => 'admin order page', 'rule' => 'admin/order/list', 'route' => 'admin.Order/list', 'methods' => ['get', 'head']],
    ['name' => 'admin order refund', 'rule' => 'admin/order/tuikuan', 'route' => 'admin.Order/tuikuan', 'methods' => ['post'], 'exact' => true],
    ['name' => 'admin config page', 'rule' => 'admin/configure/serverConfig', 'route' => 'admin.Configure/serverConfig', 'methods' => ['get', 'head']],
    ['name' => 'admin config delete', 'rule' => 'admin/configure/serverDel', 'route' => 'admin.Configure/serverDel', 'methods' => ['post'], 'exact' => true],
    ['name' => 'admin gm page', 'rule' => 'admin/gm/player', 'route' => 'admin.GmPlayer/player', 'methods' => ['get', 'head']],
    ['name' => 'admin gm submit', 'rule' => 'admin/gm/playerSub', 'route' => 'admin.GmPlayer/playerSub', 'methods' => ['post'], 'exact' => true],
    ['name' => 'admin gm clean data page', 'rule' => 'admin/gm/cleanData', 'route' => 'admin.GmCleanData/clean_data', 'methods' => ['get', 'head']],
    ['name' => 'admin gm clean data statistics', 'rule' => 'admin/gm/getDataStatistics', 'route' => 'admin.GmCleanData/getDataStatistics', 'methods' => ['post'], 'exact' => true],
    ['name' => 'admin gm clean data query', 'rule' => 'admin/gm/queryCleanData', 'route' => 'admin.GmCleanData/queryCleanData', 'methods' => ['post'], 'exact' => true],
    ['name' => 'admin gm clean data submit', 'rule' => 'admin/gm/doCleanData', 'route' => 'admin.GmCleanData/doCleanData', 'methods' => ['post'], 'exact' => true],
    ['name' => 'admin gm clean all submit', 'rule' => 'admin/gm/doCleanAll', 'route' => 'admin.GmCleanData/doCleanAll', 'methods' => ['post'], 'exact' => true],
    ['name' => 'admin settlement page', 'rule' => 'admin/settlement/index', 'route' => 'admin.Settlement/index', 'methods' => ['get', 'head']],
    ['name' => 'admin settlement submit', 'rule' => 'admin/settlement/settle', 'route' => 'admin.Settlement/settle', 'methods' => ['post'], 'exact' => true],
    ['name' => 'agent player page', 'rule' => 'agent/player/list', 'route' => 'agent.Player/list', 'methods' => ['get', 'head']],
    ['name' => 'agent player bind page', 'rule' => 'agent/player/bindList', 'route' => 'agent.Player/bindList', 'methods' => ['get', 'head']],
    ['name' => 'agent player bind data', 'rule' => 'agent/player/bind_list_table', 'route' => 'agent.Player/bind_list_table', 'methods' => ['get', 'post']],
    ['name' => 'agent order page', 'rule' => 'agent/order/list', 'route' => 'agent.Order/list', 'methods' => ['get', 'head']],
    ['name' => 'legacy sdk login', 'rule' => 'api/sdk/user_login', 'route' => 'api.Sdk/user_login', 'methods' => ['get', 'post']],
    ['name' => 'legacy sdk register', 'rule' => 'api/sdk/user_register', 'route' => 'api.Sdk/user_register', 'methods' => ['get', 'post']],
    ['name' => 'legacy sdk ios register', 'rule' => 'api/sdk/user_regapp', 'route' => 'api.Sdk/user_regapp', 'methods' => ['get', 'post']],
    ['name' => 'legacy sdk ios login', 'rule' => 'api/sdk/user_app', 'route' => 'api.Sdk/user_app', 'methods' => ['get', 'post']],
    ['name' => 'sdk compat login', 'rule' => 'api/sdk/login', 'route' => 'api.Sdk/user_login', 'methods' => ['get', 'post']],
    ['name' => 'sdk compat register', 'rule' => 'api/sdk/register', 'route' => 'api.Sdk/user_register', 'methods' => ['get', 'post']],
    ['name' => 'api v1 sdk login', 'rule' => 'api/v1/sdk/login', 'route' => 'api.Sdk/user_login', 'methods' => ['get', 'post']],
    ['name' => 'api v1 sdk register', 'rule' => 'api/v1/sdk/register', 'route' => 'api.Sdk/user_register', 'methods' => ['get', 'post']],
    ['name' => 'legacy pay items', 'rule' => 'api/pay/getpayitem', 'route' => 'api.Pay/getpayitem', 'methods' => ['get']],
    ['name' => 'legacy pay order', 'rule' => 'api/pay/getpay', 'route' => 'api.Pay/getpay', 'methods' => ['get', 'post']],
    ['name' => 'legacy pay callback', 'rule' => 'api/call/epay', 'route' => 'api.Call/epay', 'methods' => ['get', 'post']],
    ['name' => 'legacy pay return', 'rule' => 'api/notify/epay', 'route' => 'api.Notify/epay', 'methods' => ['get', 'post']],
    ['name' => 'legacy voice receive', 'rule' => 'api/voice/receive', 'route' => 'api.Voice/receive', 'methods' => ['post'], 'exact' => true],
    ['name' => 'legacy voice iat', 'rule' => 'api/voice/iat', 'route' => 'api.Voice/iat', 'methods' => ['get'], 'exact' => true],
    ['name' => 'legacy charge award list', 'rule' => 'api/chargeaward/getchargeitem', 'route' => 'api.ChargeAward/getchargeitem', 'methods' => ['get', 'post']],
    ['name' => 'legacy faq index', 'rule' => 'api/faq/index', 'route' => 'api.Faq/index', 'methods' => ['get'], 'exact' => true],
    ['name' => 'api v1 pay callback', 'rule' => 'api/v1/pay/callback/epay', 'route' => 'api.Call/epay', 'methods' => ['get', 'post']],
];

$failures = [];
foreach ($checks as $check) {
    $pattern = '/^\|\s*' . preg_quote($check['rule'], '/') . '\s*\|\s*'
        . preg_quote($check['route'], '/') . '\s*\|\s*([a-z|]+)\s*\|/mi';

    if (!preg_match($pattern, $routeList, $matches)) {
        $failures[] = $check['name'] . ': missing route ' . $check['rule'] . ' -> ' . $check['route'];
        continue;
    }

    $actualMethods = array_filter(explode('|', strtolower(trim($matches[1]))));
    $expectedMethods = $check['methods'];
    foreach ($expectedMethods as $method) {
        if (!in_array($method, $actualMethods, true)) {
            $failures[] = $check['name'] . ': missing method ' . $method . ' on ' . $check['rule'];
        }
    }

    if (!empty($check['exact'])) {
        sort($actualMethods);
        $sortedExpected = $expectedMethods;
        sort($sortedExpected);
        if ($actualMethods !== $sortedExpected) {
            $failures[] = $check['name'] . ': expected methods '
                . implode('|', $sortedExpected) . ', got ' . implode('|', $actualMethods);
        }
    }
}

$forbiddenPatterns = [
    '/testpay/i' => 'TestPay debug route must not be registered',
    '/admin\.TestPay/i' => 'TestPay controller target must not be registered',
    '/admin\.Gm\//i' => 'legacy admin.Gm controller target must not be registered',
];

foreach ($forbiddenPatterns as $pattern => $message) {
    if (preg_match($pattern, $routeList)) {
        $failures[] = $message;
    }
}

$ajaxRouteFailures = checkStaticAjaxRoutes(__DIR__ . '/../route/web_admin_routes.php', __DIR__ . '/../app');
foreach ($ajaxRouteFailures as $ajaxRouteFailure) {
    $failures[] = $ajaxRouteFailure;
}

$apiAppRouteFailures = checkApiApplicationRoutes(__DIR__ . '/../app/api/route/app.php');
foreach ($apiAppRouteFailures as $apiAppRouteFailure) {
    $failures[] = $apiAppRouteFailure;
}

if ($failures !== []) {
    fwrite(STDERR, "Admin route regression failed:\n");
    foreach ($failures as $failure) {
        fwrite(STDERR, ' - ' . $failure . "\n");
    }
    exit(1);
}

echo 'Admin route regression OK: ' . count($checks) . " checks passed.\n";

function checkStaticAjaxRoutes(string $routeConfigFile, string $appRoot): array
{
    $routeConfig = include $routeConfigFile;
    $methodMap = [];
    foreach ($routeConfig as $app => $groups) {
        foreach ($groups as $methodGroup => $rules) {
            foreach ($rules as $rule => $target) {
                $key = $app . '/' . $rule;
                $methods = array_map('strtolower', explode('|', $methodGroup));
                $methodMap[$key] = array_values(array_unique(array_merge($methodMap[$key] ?? [], $methods)));
            }
        }
    }

    $failures = [];
    foreach (['admin', 'agent'] as $app) {
        $viewRoot = $appRoot . '/' . $app . '/view';
        if (!is_dir($viewRoot)) {
            continue;
        }

        $iterator = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($viewRoot));
        foreach ($iterator as $file) {
            if (!$file->isFile() || strtolower($file->getExtension()) !== 'html') {
                continue;
            }

            $lines = file($file->getPathname());
            foreach ($lines as $lineNumber => $line) {
                if (!preg_match_all('#/index\.php\?s=/\{\$app\}/([^"\'\s&]+)#', $line, $matches)) {
                    continue;
                }

                foreach ($matches[1] as $endpoint) {
                    $requiredMethod = detectStaticAjaxMethod($line, $lines, $lineNumber);
                    if ($requiredMethod === null) {
                        continue;
                    }

                    $route = $app . '/' . $endpoint;
                    $registeredMethods = findRegisteredRouteMethods($route, $methodMap);
                    if ($registeredMethods === null || !in_array($requiredMethod, $registeredMethods, true)) {
                        $failures[] = sprintf(
                            'static ajax route mismatch: %s:%d requires %s %s, registered %s',
                            normalizePath($file->getPathname()),
                            $lineNumber + 1,
                            strtoupper($requiredMethod),
                            $route,
                            $registeredMethods ? implode('|', $registeredMethods) : 'MISSING'
                        );
                    }
                }
            }
        }
    }

    return $failures;
}

function checkApiApplicationRoutes(string $routeFile): array
{
    if (!is_file($routeFile)) {
        return ['api application route file is missing: ' . $routeFile];
    }

    $content = file_get_contents($routeFile);
    if ($content === false) {
        return ['api application route file is not readable: ' . $routeFile];
    }

    $requiredSnippets = [
        "sdk/user_login', 'Sdk/user_login" => '/api/sdk/user_login must be registered inside api app as sdk/user_login',
        "sdk/user_register', 'Sdk/user_register" => '/api/sdk/user_register must be registered inside api app as sdk/user_register',
        "sdk/login', 'Sdk/user_login" => '/api/sdk/login compatibility route must be registered inside api app',
        "sdk/register', 'Sdk/user_register" => '/api/sdk/register compatibility route must be registered inside api app',
        "v1', function" => '/api/v1 group must be registered inside api app',
        "game/bind', 'Game/bind" => '/api/game/bind must be registered inside api app',
    ];

    $failures = [];
    foreach ($requiredSnippets as $snippet => $message) {
        if (strpos($content, $snippet) === false) {
            $failures[] = $message;
        }
    }

    return $failures;
}

function detectStaticAjaxMethod(string $line, array $lines, int $lineNumber): ?string
{
    if (strpos($line, '$.post') !== false) {
        return 'post';
    }

    if (strpos($line, 'url') === false) {
        return null;
    }

    $start = max(0, $lineNumber - 5);
    $window = implode('', array_slice($lines, $start, 14));
    if (preg_match('/type\s*:\s*["\']POST["\']/i', $window)) {
        return 'post';
    }
    if (preg_match('/type\s*:\s*["\']GET["\']/i', $window)) {
        return 'get';
    }

    return null;
}

function findRegisteredRouteMethods(string $route, array $methodMap): ?array
{
    if (isset($methodMap[$route])) {
        return $methodMap[$route];
    }

    foreach ($methodMap as $registeredRoute => $methods) {
        $pattern = '#^' . preg_replace('#:[^/]+#', '[^/]+', preg_quote($registeredRoute, '#')) . '$#';
        if (preg_match($pattern, $route)) {
            return $methods;
        }
    }

    return null;
}

function normalizePath(string $path): string
{
    return str_replace('\\', '/', $path);
}

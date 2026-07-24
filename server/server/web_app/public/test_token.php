<?php
// 临时调试脚本，用于测试 AuthService 的 token 生成与 Check.php 匹配情况
require __DIR__ . '/vendor/autoload.php';

// 加载环境变量
if (is_file(__DIR__ . '/.env')) {
    $env = parse_ini_file(__DIR__ . '/.env', true);
    foreach ($env as $key => $val) {
        $name = strtoupper($key);
        if (is_array($val)) {
            foreach ($val as $k => $v) {
                $item = $name . '_' . strtoupper($k);
                putenv("$item=$v");
            }
        } else {
            putenv("$name=$val");
        }
    }
}

$secret = getenv('ADMIN_AUTH_SECRET_KEY');
echo "Secret: {$secret}\n";

$admin = [
    'id' => 1,
    'username' => 'admin188',
    'password' => '$2y$10$O9wR/LqJt4Z1W/z9vN5Y/.y/L7wP9uD1i3M4Y6V9t9Q9G8c5m8WJ2', // 假设哈希
];

$data = $admin['id'] . $admin['username'] . $admin['password'];
$token = hash_hmac('sha256', $data, $secret);

echo "Token: {$token}\n";

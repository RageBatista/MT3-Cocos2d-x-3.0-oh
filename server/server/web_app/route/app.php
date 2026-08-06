<?php
// +----------------------------------------------------------------------
// | ThinkPHP [ WE CAN DO IT JUST THINK ]
// +----------------------------------------------------------------------
// | Copyright (c) 2006~2018 http://thinkphp.cn All rights reserved.
// +----------------------------------------------------------------------
// | Licensed ( http://www.apache.org/licenses/LICENSE-2.0 )
// +----------------------------------------------------------------------
// | Author: liu21st <liu21st@gmail.com>
// +----------------------------------------------------------------------
use think\facade\Route;

require_once __DIR__ . '/web_admin_route_helper.php';

Route::get('think', function () {
    return 'hello,ThinkPHP6!';
});

Route::get('hello/:name', 'index/hello');

// 生产强制路由模式下的基础入口
Route::rule('/', 'index.Index/index', 'GET|HEAD');
Route::rule('login', 'login.Index/index', 'GET|HEAD');
Route::rule('login/', 'login.Index/index', 'GET|HEAD');
Route::rule('login/index', 'login.Index/index', 'GET|HEAD');
Route::post('login/submit', 'login.Index/submit');
Route::post('login/index/submit', 'login.Index/submit');

// Admin/Agent后台路由统一由 route/web_admin_routes.php 定义，避免根路由与模块路由漂移。
web_admin_register_global_routes();

// Player auth routes
require __DIR__ . '/player.php';

// Legacy compatibility routes
// 说明：
// 1) 跨应用路由目标使用 `api.Controller/action`（点号）避免被解析为 `app\controller\api\...`
// 2) 兼容部分环境对 `.php` 路径片段做后缀裁剪后的 pathinfo 形态
Route::rule('enlist/submit_code', 'api.Enlist/submitCode', 'GET|POST');
Route::rule('api/enlist/submit_code', 'api.Enlist/submitCode', 'GET|POST');
Route::rule('user/api/index.php/role/set', 'api.LegacyRole/set', 'GET|POST');
Route::rule('user/api/index.php/role/get', 'api.LegacyRole/get', 'GET|POST');
Route::rule('user/api/index/role/set', 'api.LegacyRole/set', 'GET|POST');
Route::rule('user/api/index/role/get', 'api.LegacyRole/get', 'GET|POST');
Route::rule('api/sdk/user_login', 'api.Sdk/user_login', 'GET|POST');
Route::rule('api/sdk/user_register', 'api.Sdk/user_register', 'GET|POST');
Route::rule('api/sdk/user_regapp', 'api.Sdk/user_regapp', 'GET|POST');
Route::rule('api/sdk/user_app', 'api.Sdk/user_app', 'GET|POST');
Route::rule('api/sdk/login', 'api.Sdk/user_login', 'GET|POST');
Route::rule('api/sdk/register', 'api.Sdk/user_register', 'GET|POST');
Route::get('api/pay/getpayitem', 'api.Pay/getpayitem');
Route::rule('api/pay/getpay', 'api.Pay/getpay', 'GET|POST');
Route::rule('api/call/epay', 'api.Call/epay', 'GET|POST');
Route::rule('api/call/test', 'api.Call/test', 'GET|POST');
Route::rule('api/call/checkurl', 'api.Call/checkurl', 'GET|POST');
Route::rule('api/call/epay1', 'api.Call/epay1', 'GET|POST');
Route::rule('api/notify/epay', 'api.Notify/epay', 'GET|POST');
Route::post('api/voice/receive', 'api.Voice/receive');
Route::get('api/voice/iat', 'api.Voice/iat');
Route::rule('api/chargeaward/getchargeitem', 'api.ChargeAward/getchargeitem', 'GET|POST');
Route::rule('api/chargeaward/receiveday', 'api.ChargeAward/receiveday', 'GET|POST');
Route::rule('api/chargeaward/receiverole', 'api.ChargeAward/receiverole', 'GET|POST');
Route::rule('api/chargeaward/modifypass', 'api.ChargeAward/modifypass', 'GET|POST');
Route::get('api/faq/index', 'api.Faq/index');
Route::get('api/faq/search', 'api.Faq/search');

// API v1 routes（新接口统一入口，逐步替代 legacy 路径）
Route::group('api/v1', function () {
    Route::rule('sdk/login', 'api.Sdk/user_login', 'GET|POST');
    Route::rule('sdk/register', 'api.Sdk/user_register', 'GET|POST');
    Route::rule('sdk/register-ios', 'api.Sdk/user_regapp', 'GET|POST');
    Route::rule('sdk/login-ios', 'api.Sdk/user_app', 'GET|POST');
    Route::get('pay/items', 'api.Pay/getpayitem');
    Route::rule('pay/order', 'api.Pay/getpay', 'GET|POST');
    Route::rule('pay/callback/epay', 'api.Call/epay', 'GET|POST');
    Route::rule('pay/return/epay', 'api.Notify/epay', 'GET|POST');
    Route::rule('role/get', 'api.LegacyRole/get', 'GET|POST');
    Route::rule('role/set', 'api.LegacyRole/set', 'GET|POST');
});

// Game API routes（SDK登录 + 角色绑定 + 客服 + 转区 + 返利 + 反馈）
Route::rule('api/game/sdk', 'api.Game/sdk', 'GET|POST');
Route::rule('api/game/bind', 'api.Game/bind', 'GET|POST');
Route::rule('api/game/kefu', 'api.Game/kefu', 'GET|POST');
Route::rule('api/game/zhuanqu', 'api.Game/zhuanqu', 'GET|POST');
Route::rule('api/game/zhuanquSub', 'api.Game/zhuanquSub', 'GET|POST');
Route::rule('api/game/rebate', 'api.Game/rebate', 'GET|POST');
Route::rule('api/game/fankui', 'api.Game/fankui', 'GET|POST');
Route::rule('api/game/fankuiSub', 'api.Game/fankuiSub', 'GET|POST');

// 未命中路由统一返回 404，避免抛出控制器不存在警告日志
Route::miss(function () {
    return \think\Response::create('Not Found', 'html', 404);
});

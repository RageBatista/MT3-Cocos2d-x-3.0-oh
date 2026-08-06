<?php
declare(strict_types=1);

use think\facade\Route;

// API application routes. Requests such as /api/sdk/user_login enter the
// "api" app first, so the route path matched inside this file is sdk/user_login.
Route::rule('sdk/user_login', 'Sdk/user_login', 'GET|POST');
Route::rule('sdk/user_register', 'Sdk/user_register', 'GET|POST');
Route::rule('sdk/user_regapp', 'Sdk/user_regapp', 'GET|POST');
Route::rule('sdk/user_app', 'Sdk/user_app', 'GET|POST');
Route::rule('sdk/login', 'Sdk/user_login', 'GET|POST');
Route::rule('sdk/register', 'Sdk/user_register', 'GET|POST');

Route::get('pay/getpayitem', 'Pay/getpayitem');
Route::rule('pay/getpay', 'Pay/getpay', 'GET|POST');
Route::rule('call/epay', 'Call/epay', 'GET|POST');
Route::rule('call/test', 'Call/test', 'GET|POST');
Route::rule('call/checkurl', 'Call/checkurl', 'GET|POST');
Route::rule('call/epay1', 'Call/epay1', 'GET|POST');
Route::rule('notify/epay', 'Notify/epay', 'GET|POST');
Route::post('voice/receive', 'Voice/receive');
Route::get('voice/iat', 'Voice/iat');
Route::rule('chargeaward/getchargeitem', 'ChargeAward/getchargeitem', 'GET|POST');
Route::rule('chargeaward/receiveday', 'ChargeAward/receiveday', 'GET|POST');
Route::rule('chargeaward/receiverole', 'ChargeAward/receiverole', 'GET|POST');
Route::rule('chargeaward/modifypass', 'ChargeAward/modifypass', 'GET|POST');
Route::get('faq/index', 'Faq/index');
Route::get('faq/search', 'Faq/search');

Route::group('v1', function () {
    Route::rule('sdk/login', 'Sdk/user_login', 'GET|POST');
    Route::rule('sdk/register', 'Sdk/user_register', 'GET|POST');
    Route::rule('sdk/register-ios', 'Sdk/user_regapp', 'GET|POST');
    Route::rule('sdk/login-ios', 'Sdk/user_app', 'GET|POST');
    Route::get('pay/items', 'Pay/getpayitem');
    Route::rule('pay/order', 'Pay/getpay', 'GET|POST');
    Route::rule('pay/callback/epay', 'Call/epay', 'GET|POST');
    Route::rule('pay/return/epay', 'Notify/epay', 'GET|POST');
    Route::rule('role/get', 'LegacyRole/get', 'GET|POST');
    Route::rule('role/set', 'LegacyRole/set', 'GET|POST');
});

Route::rule('game/sdk', 'Game/sdk', 'GET|POST');
Route::rule('game/bind', 'Game/bind', 'GET|POST');
Route::rule('game/kefu', 'Game/kefu', 'GET|POST');
Route::rule('game/zhuanqu', 'Game/zhuanqu', 'GET|POST');
Route::rule('game/zhuanquSub', 'Game/zhuanquSub', 'GET|POST');
Route::rule('game/rebate', 'Game/rebate', 'GET|POST');
Route::rule('game/fankui', 'Game/fankui', 'GET|POST');
Route::rule('game/fankuiSub', 'Game/fankuiSub', 'GET|POST');

Route::rule('enlist/submit_code', 'Enlist/submitCode', 'GET|POST');

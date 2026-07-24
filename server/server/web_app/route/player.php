<?php
// Player模块路由配置
// 整合玩家服务中心和梦幻授权控制台

use think\facade\Route;

// ==================== 认证相关路由（不需要登录） ====================
Route::group('player/auth', function () {
    Route::get('login', 'player.Auth/login');
    Route::post('doLogin', 'player.Auth/doLogin');
    Route::get('register', 'player.Auth/register');
    Route::post('doRegister', 'player.Auth/doRegister');
    Route::get('forgot', 'player.Auth/forgot');
    Route::post('doForgot', 'player.Auth/doForgot');
    Route::get('logout', 'player.Auth/logout');
    Route::get('resetPassword', 'player.Auth/resetPassword');
    Route::post('doResetPassword', 'player.Auth/doResetPassword');
});

// ==================== CDK授权路由（入口无需登录，控制台与发放操作需授权） ====================
Route::group('player/cdk', function () {
    Route::get('/', 'player.Cdk/index');
    Route::get('index', 'player.Cdk/index');
    Route::post('auth', 'player.Cdk/auth');
    Route::post('existing', 'player.Cdk/existing');
    Route::get('servers', 'player.Cdk/servers');
    Route::get('logout', 'player.Cdk/logout');
    Route::get('dashboard', 'player.Cdk/dashboard');
    Route::get('senditem', 'player.SendItem/index');
    // 兼容历史入口和不同大小写写法，避免出现404
    Route::get('sendItem', 'player.SendItem/index');
    Route::get('senditem/index', 'player.SendItem/index');
    Route::post('senditem/prepareOp', 'player.SendItem/prepareOp');
    Route::post('senditem/sendItem', 'player.SendItem/sendItem');
    Route::post('senditem/rechargeXianyu', 'player.SendItem/rechargeXianyu');
    Route::post('senditem/getItemList', 'player.SendItem/getItemList');
    Route::post('senditem/switchServer', 'player.SendItem/switchServer');
});

// ==================== 管理员登录路由 ====================
Route::group('player/admin', function () {
    Route::get('login', 'player.Admin/login');
    Route::post('doLogin', 'player.Admin/doLogin');
    Route::get('logout', 'player.Admin/logout');
    Route::get('captcha', 'player.Admin/captcha');
});

// ==================== 首页（不需要登录） ====================
Route::get('player', 'player.Index/index');
Route::get('player/index', 'player.Index/index');

// ==================== 需要登录的玩家路由 ====================
Route::group('player', function () {
    // 个人资料
    Route::get('profile', 'player.Profile/index');
    Route::post('profile/update', 'player.Profile/update');
    Route::get('profile/password', 'player.Profile/password');
    Route::post('profile/updatePassword', 'player.Profile/updatePassword');
    Route::get('profile/avatar', 'player.Profile/avatar');
    Route::post('profile/uploadAvatar', 'player.Profile/uploadAvatar');
    
    // 服务器
    Route::get('server', 'player.Server/index');
    Route::get('server/detail', 'player.Server/detail');
    
    // 角色
    Route::get('role', 'player.Role/index');
    Route::get('role/detail', 'player.Role/detail');
    Route::get('role/getByServer', 'player.Role/getByServer');
    
    // 订单
    Route::get('order', 'player.Order/index');
    Route::get('order/detail', 'player.Order/detail');
    
    // 充值
    Route::get('recharge', 'player.Recharge/index');
    Route::post('recharge/createOrder', 'player.Recharge/createOrder');
    
    // 反馈
    Route::get('feedback', 'player.Feedback/index');
    Route::post('feedback/submit', 'player.Feedback/submit');
    
    // 客服
    Route::get('service', 'player.Service/index');
    
    // 转区申请
    Route::get('transfer', 'player.Transfer/index');
    Route::post('transfer/submit', 'player.Transfer/submit');
    Route::get('transfer/detail', 'player.Transfer/detail');
    Route::get('transfer/getRoles', 'player.Transfer/getRoles');

});

// ==================== 兼容旧路由（重定向到新路由） ====================
// 梦幻授权控制台旧路由兼容
Route::get('login/auth', function() {
    return redirect('/player/cdk/index');
});

Route::get('login/auth/auth', function() {
    return redirect('/player/cdk/index');
});

Route::get('login/auth/dashboard', function() {
    return redirect('/player/cdk/dashboard');
});

Route::get('login/auth/senditem', function() {
    return redirect('/player/cdk/senditem');
});

Route::get('login/auth/sendItem', function() {
    return redirect('/player/cdk/senditem');
});

Route::get('login/auth/senditem/index', function() {
    return redirect('/player/cdk/senditem');
});

Route::get('login/auth/logout', function() {
    return redirect('/player/cdk/logout');
});

Route::get('login/auth/success', function() {
    return redirect('/player/cdk/dashboard');
});

Route::get('login/index', function() {
    return redirect('/player/admin/login');
});

Route::get('login/user', function() {
    return redirect('/player/cdk/index');
});

Route::post('login/index/submit', function() {
    return redirect('/player/admin/doLogin');
});

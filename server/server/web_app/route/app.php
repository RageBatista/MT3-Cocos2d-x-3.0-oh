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

Route::get('think', function () {
    return 'hello,ThinkPHP6!';
});

Route::get('hello/:name', 'index/hello');

// 物品管理路由
Route::get('admin/item/test', 'admin.Item/test');
Route::get('admin/item/itemList', 'admin.Item/itemList');
Route::post('admin/item/itemSync', 'admin.Item/itemSync');
Route::post('admin/item/list_table', 'admin.Item/list_table');
Route::post('admin/item/clearAll', 'admin.Item/clearAll');

// Player auth routes
require __DIR__ . '/player.php';

// Admin GM CDK routes
Route::group('admin/gm', function () {
    Route::get('cdk', 'admin.Gm/cdk');
    Route::post('cdkQuery', 'admin.Gm/cdkQuery');
    Route::get('cdkListUnused', 'admin.Gm/cdkListUnused');
    Route::get('cdkListUsed', 'admin.Gm/cdkListUsed');
    Route::get('cdkStats', 'admin.Gm/cdkStats');
    Route::post('cdkGenerate', 'admin.Gm/cdkGenerate');
    Route::post('cdkUpdateUid', 'admin.Gm/cdkUpdateUid');
    Route::post('cdkDelete', 'admin.Gm/cdkDelete');
    Route::post('cdkUpdatePass', 'admin.Gm/cdkUpdatePass');
});

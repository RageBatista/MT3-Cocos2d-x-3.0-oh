<?php

use think\facade\Route;

// login 应用内路由（用于强制路由模式）
Route::rule('/', 'Index/index', 'GET|HEAD');
Route::rule('index', 'Index/index', 'GET|HEAD');
Route::post('submit', 'Index/submit');


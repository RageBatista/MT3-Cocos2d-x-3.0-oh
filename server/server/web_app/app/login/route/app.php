<?php
declare(strict_types=1);

use think\facade\Route;

Route::rule('/', 'Index/index', 'GET|HEAD')->completeMatch();
Route::rule('index', 'Index/index', 'GET|HEAD')->completeMatch();
Route::post('submit', 'Index/submit')->completeMatch();
Route::post('index/submit', 'Index/submit')->completeMatch();

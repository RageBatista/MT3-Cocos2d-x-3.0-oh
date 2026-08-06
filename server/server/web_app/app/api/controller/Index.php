<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;

class Index extends BaseController
{
    public function index()
    {
		return notify(1, 'API服务在线', [
			'service' => 'api/index',
			'status' => 'ok'
		]);
    }
}

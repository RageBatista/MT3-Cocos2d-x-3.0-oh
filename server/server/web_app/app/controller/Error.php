<?php
declare (strict_types = 1);

namespace app\controller;

use think\Response;

/**
 * 全局空控制器兜底：
 * 当请求路由到不存在的控制器/动作时，统一返回 404，避免二次异常噪音。
 */
class Error
{
    public function index(): Response
    {
        return $this->notFound();
    }

    public function __call(string $name, array $arguments): Response
    {
        return $this->notFound();
    }

    private function notFound(): Response
    {
        return Response::create('Not Found', 'html', 404);
    }
}

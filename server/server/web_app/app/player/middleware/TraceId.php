<?php
namespace app\player\middleware;

use think\Response;

/**
 * TraceId 中间件 — 全链路请求追踪
 *
 * 每个请求进入时生成或透传 X-Request-ID，贯穿整个请求周期：
 *   - 若客户端/上游网关已注入 X-Request-ID，则复用（校验格式防注入）
 *   - 否则自动生成 UUID v4 格式的 trace_id
 *   - 将 trace_id 绑定到请求对象（$request->traceId）
 *   - 在响应头中回写 X-Request-ID，方便前端/日志关联
 *   - 通过 PHP 全局变量（$_SERVER['TRACE_ID']）让 logPlayerAction 等函数读取
 */
class TraceId
{
    public function handle($request, \Closure $next): Response
    {
        // 1. 读取或生成 trace_id
        $incoming = trim((string)$request->header('x-request-id', ''));

        // 仅接受标准 UUID v4 格式（防止上游注入任意字符串）
        if ($incoming !== '' && preg_match(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i',
            $incoming
        )) {
            $traceId = strtolower($incoming);
        } else {
            $traceId = self::generateUuidV4();
        }

        // 2. 绑定到请求对象
        $request->traceId = $traceId;

        // 3. 通过 $_SERVER 全局变量共享给辅助函数（logPlayerAction 等）
        $_SERVER['TRACE_ID'] = $traceId;

        // 4. 继续处理请求
        $response = $next($request);

        // 5. 在响应头中回写 trace_id
        if (method_exists($response, 'header')) {
            $response->header(['X-Request-ID' => $traceId]);
        }

        return $response;
    }

    /**
     * 生成符合 RFC 4122 的 UUID v4
     */
    private static function generateUuidV4(): string
    {
        $data = random_bytes(16);
        $data[6] = chr((ord($data[6]) & 0x0f) | 0x40); // version 4
        $data[8] = chr((ord($data[8]) & 0x3f) | 0x80); // variant bits

        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }
}

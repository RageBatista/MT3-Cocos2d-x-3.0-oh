<?php
namespace app;

use think\db\exception\DataNotFoundException;
use think\db\exception\ModelNotFoundException;
use think\exception\Handle;
use think\exception\HttpException;
use think\exception\HttpResponseException;
use think\exception\ValidateException;
use think\facade\Log;
use think\Response;
use Throwable;

/**
 * 应用异常处理类
 */
class ExceptionHandle extends Handle
{
    /**
     * 不需要记录信息（日志）的异常类列表
     * @var array
     */
    protected $ignoreReport = [
        HttpException::class,
        HttpResponseException::class,
        ModelNotFoundException::class,
        DataNotFoundException::class,
        ValidateException::class,
    ];

    /**
     * 记录异常信息（包括日志或者其它方式记录）
     *
     * @access public
     * @param  Throwable $exception
     * @return void
     */
    public function report(Throwable $exception): void
    {
        // 记录详细的异常信息
        $logData = [
            'message' => $exception->getMessage(),
            'code' => $exception->getCode(),
            'file' => $exception->getFile(),
            'line' => $exception->getLine(),
            'exception_class' => get_class($exception),
        ];
        
        // 添加请求上下文信息
        $request = app('request');
        if ($request) {
            $logData['request_uri'] = $request->url();
            $logData['request_method'] = $request->method();
            $logData['request_ip'] = $request->ip();
            $logData['request_user_agent'] = $request->header('user-agent');
            
            // 添加请求参数（排除敏感信息）
            $params = $request->param();
            $logData['request_params'] = $this->filterSensitiveParams($params);
        }
        
        // 添加堆栈跟踪（截断以避免日志过大）
        $trace = $exception->getTraceAsString();
        if (strlen($trace) > 5000) {
            $trace = substr($trace, 0, 5000) . '...[truncated]';
        }
        $logData['trace'] = $trace;
        
        // 根据异常类型选择日志级别
        // 将上下文数据 JSON 编码到消息中，避免 ThinkPHP JSON 日志丢失 context 参数
        $contextJson = json_encode($logData, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        if ($exception instanceof HttpException) {
            $statusCode = $exception->getStatusCode();
            Log::warning("HTTP Exception [{$statusCode}] {$contextJson}");
        } elseif ($exception instanceof ValidateException) {
            Log::info("Validation Exception {$contextJson}");
        } else {
            Log::error("Exception caught {$contextJson}");
        }
        
        // 调用父类方法
        parent::report($exception);
    }
    
    /**
     * 过滤敏感参数
     * @param array $params
     * @return array
     */
    protected function filterSensitiveParams(array $params): array
    {
        $sensitiveKeys = ['password', 'passwd', 'pwd', 'token', 'secret', 'key', 'auth'];
        
        foreach ($params as $key => $value) {
            if (is_string($key)) {
                foreach ($sensitiveKeys as $sensitiveKey) {
                    if (stripos($key, $sensitiveKey) !== false) {
                        $params[$key] = '***FILTERED***';
                        break;
                    }
                }
            }
            
            // 递归处理嵌套数组
            if (is_array($value)) {
                $params[$key] = $this->filterSensitiveParams($value);
            }
        }
        
        return $params;
    }

    /**
     * Render an exception into an HTTP response.
     *
     * @access public
     * @param \think\Request   $request
     * @param Throwable $e
     * @return Response
     */
    public function render($request, Throwable $e): Response
    {
        // 添加自定义异常处理机制

        // 其他错误交给系统处理
        return parent::render($request, $e);
    }
}

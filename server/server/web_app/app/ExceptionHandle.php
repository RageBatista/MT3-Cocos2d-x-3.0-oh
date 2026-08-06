<?php
namespace app;

use think\db\exception\DataNotFoundException;
use think\db\exception\ModelNotFoundException;
use think\exception\Handle;
use think\exception\HttpException;
use think\exception\HttpResponseException;
use think\exception\ValidateException;
use think\facade\Cache;
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
        $request = app('request');

        // 404 高频扫描降噪：降级为 info 并按 IP + 方法 + URI 做限频
        if ($exception instanceof HttpException && $exception->getStatusCode() === 404) {
            $this->reportNotFoundException($exception, $request);
            parent::report($exception);
            return;
        }

        // 记录详细的异常信息
        $logData = [
            'message' => $exception->getMessage(),
            'code' => $exception->getCode(),
            'file' => $exception->getFile(),
            'line' => $exception->getLine(),
            'exception_class' => get_class($exception),
        ];
        
        // 添加请求上下文信息
        if ($request) {
            $logData['request_uri'] = $request->url();
            $logData['request_method'] = $request->method();
            $logData['request_ip'] = $request->ip();
            $logData['request_user_agent'] = $this->truncateLogString((string) $request->header('user-agent'), 512);
            
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
            if ($statusCode >= 500) {
                Log::error("HTTP Exception [{$statusCode}] {$contextJson}");
            } else {
                Log::warning("HTTP Exception [{$statusCode}] {$contextJson}");
            }
        } elseif ($exception instanceof ValidateException) {
            Log::info("Validation Exception {$contextJson}");
        } else {
            Log::error("Exception caught {$contextJson}");
        }
        
        // 调用父类方法
        parent::report($exception);
    }

    /**
     * 404 异常限频记录，避免 warning 日志被扫描请求刷屏。
     * @param Throwable $exception
     * @param mixed $request
     * @return void
     */
    private function reportNotFoundException(Throwable $exception, $request): void
    {
        $requestUri = $request ? (string) $request->url() : '';
        $requestMethod = $request ? (string) $request->method() : '';
        $requestIp = $request ? (string) $request->ip() : '';
        $cacheKey = 'log:404:' . md5($requestMethod . '|' . $requestUri . '|' . $requestIp);

        // 5 分钟内相同来源 + 路径仅记录一次
        try {
            if (Cache::get($cacheKey)) {
                return;
            }
            Cache::set($cacheKey, 1, 300);
        } catch (Throwable $cacheException) {
            // 缓存异常不应影响主异常处理流程，降级为直接记录
        }

        $logData = [
            'message' => $exception->getMessage(),
            'exception_class' => get_class($exception),
            'request_uri' => $requestUri,
            'request_method' => $requestMethod,
            'request_ip' => $requestIp,
            'request_user_agent' => $request ? $this->truncateLogString((string) $request->header('user-agent'), 256) : '',
        ];

        $contextJson = json_encode($logData, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        Log::info("HTTP Exception [404] {$contextJson}");
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
     * 截断日志字段，防止超长内容导致日志膨胀。
     * @param string $value
     * @param int $maxLength
     * @return string
     */
    private function truncateLogString(string $value, int $maxLength): string
    {
        if (strlen($value) <= $maxLength) {
            return $value;
        }
        return substr($value, 0, $maxLength) . '...[truncated]';
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

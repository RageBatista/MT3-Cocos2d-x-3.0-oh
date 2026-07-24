package fire.util;

import java.sql.SQLException;
import java.util.concurrent.atomic.AtomicLong;

import org.apache.log4j.Logger;

/**
 * 统一异常处理工具类
 * 
 * 功能：
 * 1. 替代 printStackTrace()，使用日志框架记录
 * 2. 替代空 catch 块，提供合理的异常处理
 * 3. 提供异常统计和监控
 * 
 * @作者 GSXDB 团队
 * @版本1.0.0
 * @日期 2026-03-04
 */
public class ExceptionHandler {

    private static final Logger logger = Logger.getLogger("EXCEPTION");
    
    /**
     * 异常统计计数器
     */
    private static final AtomicLong exceptionCount = new AtomicLong(0);
    private static final AtomicLong sqlExceptionCount = new AtomicLong(0);
    private static final AtomicLong ioExceptionCount = new AtomicLong(0);
    private static final AtomicLong runtimeExceptionCount = new AtomicLong(0);
    
    /**
     * 处理异常 - 记录到日志并统计
     * 
     * @param e 异常对象
     * @param context 异常上下文信息（如类名、方法名）
     */
    public static void handleException(Throwable e, String context) {
        if (e == null) {
            logger.warn("ExceptionHandler.handleException called with null exception");
            return;
        }
        
        exceptionCount.incrementAndGet();
        
        // 分类统计
        if (e instanceof SQLException) {
            sqlExceptionCount.incrementAndGet();
            logger.error("SQL异常 in " + context + ": " + e.getMessage(), e);
        } else if (e instanceof java.io.IOException) {
            ioExceptionCount.incrementAndGet();
            logger.error("IO异常 in " + context + ": " + e.getMessage(), e);
        } else if (e instanceof RuntimeException) {
            runtimeExceptionCount.incrementAndGet();
            logger.error("运行时异常 in " + context + ": " + e.getMessage(), e);
        } else {
            logger.error("异常 in " + context + ": " + e.getMessage(), e);
        }
    }
    
    /**
     * 处理异常 - 简化版本（仅记录）
     * 
     * @param e 异常对象
     * @param context 异常上下文信息
     * @param level 日志级别 (ERROR, WARN, INFO)
     */
    public static void handleException(Throwable e, String context, LogLevel level) {
        if (e == null) {
            return;
        }
        
        exceptionCount.incrementAndGet();
        
        String message = "异常 in " + context + ": " + e.getMessage();
        
        switch (level) {
            case FATAL:
                logger.fatal(message, e);
                break;
            case ERROR:
                logger.error(message, e);
                break;
            case WARN:
                logger.warn(message, e);
                break;
            case INFO:
                logger.info(message, e);
                break;
            default:
                logger.error(message, e);
        }
    }
    
    /**
     * 静默处理异常（用于资源关闭等场景）
     * 仅在 DEBUG 级别记录日志
     * 
     * @param e 异常对象
     * @param context 异常上下文信息
     */
    public static void handleSilently(Throwable e, String context) {
        if (e != null && logger.isDebugEnabled()) {
            logger.debug("静默处理异常 in " + context + ": " + e.getMessage());
        }
    }
    
    /**
     * 处理 SQL 异常（专门用于数据库操作）
     * 
     * @param e SQL 异常
     * @param sql SQL 语句（如果有）
     * @param context 上下文信息
     */
    public static void handleSqlException(SQLException e, String sql, String context) {
        sqlExceptionCount.incrementAndGet();
        exceptionCount.incrementAndGet();
        
        String message = "SQL异常 in " + context;
        if (sql != null && !sql.isEmpty()) {
            message += ", SQL: " + sql;
        }
        message += ", ErrorCode: " + e.getErrorCode() + ", SQLState: " + e.getSQLState();
        
        logger.error(message, e);
    }
    
    /**
     * 获取异常统计信息
     * 
     * @return 统计信息字符串
     */
    public static String getStatistics() {
        return String.format(
            "异常统计 - 总计: %d, SQL: %d, IO: %d, Runtime: %d",
            exceptionCount.get(),
            sqlExceptionCount.get(),
            ioExceptionCount.get(),
            runtimeExceptionCount.get()
        );
    }
    
    /**
     * 重置统计计数器
     */
    public static void resetStatistics() {
        exceptionCount.set(0);
        sqlExceptionCount.set(0);
        ioExceptionCount.set(0);
        runtimeExceptionCount.set(0);
    }
    
    /**
     * 日志级别枚举
     */
    public enum LogLevel {
        FATAL, ERROR, WARN, INFO, DEBUG
    }
    
    /**
     * 构建上下文信息
     * 
     * @param className 类名
     * @param methodName 方法名
     * @param additionalInfo 附加信息
     * @return 完整的上下文字符串
     */
    public static String buildContext(String className, String methodName, String additionalInfo) {
        StringBuilder context = new StringBuilder();
        if (className != null && !className.isEmpty()) {
            context.append(className);
            if (methodName != null && !methodName.isEmpty()) {
                context.append(".").append(methodName).append("()");
            }
        }
        if (additionalInfo != null && !additionalInfo.isEmpty()) {
            if (context.length() > 0) {
                context.append(" - ");
            }
            context.append(additionalInfo);
        }
        return context.toString();
    }
    
    /**
     * 快捷方法：在 catch 块中使用
     * 
     * 示例：
     * <前>
     * 尝试 {
     *     // 代码
     * } catch (Exception e) {
     *     ExceptionHandler.handle(e, "MyClass.myMethod");
     * }
     * </前>
     */
    public static void handle(Throwable e, String context) {
        handleException(e, context);
    }
    
    /**
     * 快捷方法：带类名的异常处理
     */
    public static void handle(Throwable e, Class<?> clazz, String methodName) {
        handleException(e, buildContext(clazz.getSimpleName(), methodName, null));
    }
}

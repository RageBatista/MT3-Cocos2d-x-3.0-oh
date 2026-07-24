//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;
import org.apache.log4j.Logger;

public class GMOperationLogger {
    private static final Logger GM_OPERATION_LOG = Logger.getLogger("GM_OPERATION");
    private static final Logger GM_SECURITY_LOG = Logger.getLogger("GM_SECURITY");
    private static final Logger GM_AUDIT_LOG = Logger.getLogger("GM_AUDIT");
    private static final Logger GM_ERROR_LOG = Logger.getLogger("GM_ERROR");
    private static final AtomicLong totalCommands = new AtomicLong(0L);
    private static final AtomicLong successfulCommands = new AtomicLong(0L);
    private static final AtomicLong failedCommands = new AtomicLong(0L);
    private static final AtomicLong securityBlocked = new AtomicLong(0L);
    private static final ConcurrentHashMap<Integer, AtomicLong> userCommandStats = new ConcurrentHashMap();
    private static final ConcurrentHashMap<String, AtomicLong> commandUsageStats = new ConcurrentHashMap();
    private static final SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");

    public static void logCommandStart(int userId, long roleId, String command, String[] parameters, String clientIP) {
        totalCommands.incrementAndGet();
        ((AtomicLong)userCommandStats.computeIfAbsent(userId, (k) -> new AtomicLong(0L))).incrementAndGet();
        ((AtomicLong)commandUsageStats.computeIfAbsent(command.toLowerCase(), (k) -> new AtomicLong(0L))).incrementAndGet();
        String timestamp = dateFormatter.format(new Date());
        String paramStr = parameters != null && parameters.length > 0 ? Arrays.toString(parameters) : "[]";
        String sanitizedParams = sanitizeParameters(command, paramStr);
        GM_OPERATION_LOG.info(String.format("[START] %s | UserId:%d | RoleId:%d | Command:%s | Params:%s | IP:%s | Session:%s", timestamp, userId, roleId, command, sanitizedParams, clientIP != null ? clientIP : "N/A", generateSessionId(userId, roleId)));
        if (isHighRiskCommand(command)) {
            GM_AUDIT_LOG.warn(String.format("[HIGH_RISK] User:%d executed high-risk command: %s with params: %s", userId, command, sanitizedParams));
        }

        if (userId == 4096) {
            GM_AUDIT_LOG.info(String.format("[WEB_BACKEND] RoleId:%d | Command:%s | Params:%s | IP:%s", roleId, command, sanitizedParams, clientIP));
        }

    }

    public static void logCommandSuccess(int userId, long roleId, String command, String[] parameters, String result, long executionTimeMs) {
        successfulCommands.incrementAndGet();
        String timestamp = dateFormatter.format(new Date());
        String paramStr = parameters != null && parameters.length > 0 ? Arrays.toString(parameters) : "[]";
        String sanitizedParams = sanitizeParameters(command, paramStr);
        String sanitizedResult = sanitizeResult(result);
        GM_OPERATION_LOG.info(String.format("[SUCCESS] %s | UserId:%d | RoleId:%d | Command:%s | Params:%s | Result:%s | Time:%dms | Session:%s", timestamp, userId, roleId, command, sanitizedParams, sanitizedResult, executionTimeMs, generateSessionId(userId, roleId)));
        if (executionTimeMs > 1000L) {
            GM_OPERATION_LOG.warn(String.format("[SLOW_COMMAND] Command:%s took %dms to execute for user:%d", command, executionTimeMs, userId));
        }

    }

    public static void logCommandFailure(int userId, long roleId, String command, String[] parameters, String errorReason, Throwable exception) {
        failedCommands.incrementAndGet();
        String timestamp = dateFormatter.format(new Date());
        String paramStr = parameters != null && parameters.length > 0 ? Arrays.toString(parameters) : "[]";
        String sanitizedParams = sanitizeParameters(command, paramStr);
        GM_ERROR_LOG.error(String.format("[FAILURE] %s | UserId:%d | RoleId:%d | Command:%s | Params:%s | Error:%s | Session:%s", timestamp, userId, roleId, command, sanitizedParams, errorReason != null ? errorReason : "Unknown", generateSessionId(userId, roleId)));
        if (exception != null) {
            GM_ERROR_LOG.error("Exception details for failed GM command:", exception);
        }

    }

    public static void logSecurityBlock(int userId, long roleId, String command, String reason, String clientIP) {
        securityBlocked.incrementAndGet();
        String timestamp = dateFormatter.format(new Date());
        GM_SECURITY_LOG.warn(String.format("[BLOCKED] %s | UserId:%d | RoleId:%d | Command:%s | Reason:%s | IP:%s | Session:%s", timestamp, userId, roleId, command, reason, clientIP != null ? clientIP : "N/A", generateSessionId(userId, roleId)));
        long userBlockCount = ((AtomicLong)userCommandStats.getOrDefault(userId, new AtomicLong(0L))).get();
        if (userBlockCount > 5L) {
            GM_SECURITY_LOG.error(String.format("[SUSPICIOUS_USER] UserId:%d has been blocked %d times, possible attack attempt", userId, userBlockCount));
        }

    }

    public static void logInjectionAttempt(int userId, long roleId, String command, String maliciousInput, String attackType, String clientIP) {
        String timestamp = dateFormatter.format(new Date());
        GM_SECURITY_LOG.error(String.format("[INJECTION_ATTACK] %s | UserId:%d | RoleId:%d | Command:%s | Attack:%s | Input:%s | IP:%s", timestamp, userId, roleId, command, attackType, maliciousInput.length() > 100 ? maliciousInput.substring(0, 100) + "..." : maliciousInput, clientIP != null ? clientIP : "N/A"));
    }

    public static void logGMLogin(int userId, long roleId, String username, String clientIP, boolean success) {
        String timestamp = dateFormatter.format(new Date());
        if (success) {
            GM_AUDIT_LOG.info(String.format("[GM_LOGIN] %s | UserId:%d | RoleId:%d | Username:%s | IP:%s | Status:SUCCESS", timestamp, userId, roleId, username != null ? username : "N/A", clientIP != null ? clientIP : "N/A"));
        } else {
            GM_SECURITY_LOG.warn(String.format("[GM_LOGIN_FAILED] %s | UserId:%d | RoleId:%d | Username:%s | IP:%s | Status:FAILED", timestamp, userId, roleId, username != null ? username : "N/A", clientIP != null ? clientIP : "N/A"));
        }

    }

    public static Map<String, Object> getStatistics() {
        Map<String, Object> stats = new HashMap();
        stats.put("totalCommands", totalCommands.get());
        stats.put("successfulCommands", successfulCommands.get());
        stats.put("failedCommands", failedCommands.get());
        stats.put("securityBlocked", securityBlocked.get());
        stats.put("successRate", String.format("%.2f%%", totalCommands.get() > 0L ? (double)successfulCommands.get() / (double)totalCommands.get() * (double)100.0F : (double)0.0F));
        List<Map<String, Object>> topUsers = (List)userCommandStats.entrySet().stream().sorted(Entry.comparingByValue((a, b) -> Long.compare(b.get(), a.get()))).limit(5L).map((entry) -> {
            Map<String, Object> userStat = new HashMap();
            userStat.put("userId", entry.getKey());
            userStat.put("commandCount", ((AtomicLong)entry.getValue()).get());
            return userStat;
        }).collect(Collectors.toList());
        stats.put("topUsers", topUsers);
        List<Map<String, Object>> topCommands = (List)commandUsageStats.entrySet().stream().sorted(Entry.comparingByValue((a, b) -> Long.compare(b.get(), a.get()))).limit(10L).map((entry) -> {
            Map<String, Object> cmdStat = new HashMap();
            cmdStat.put("command", entry.getKey());
            cmdStat.put("usageCount", ((AtomicLong)entry.getValue()).get());
            return cmdStat;
        }).collect(Collectors.toList());
        stats.put("topCommands", topCommands);
        return stats;
    }

    public static Map<String, Object> getUserStatistics(int userId) {
        Map<String, Object> userStats = new HashMap();
        userStats.put("userId", userId);
        userStats.put("totalCommands", ((AtomicLong)userCommandStats.getOrDefault(userId, new AtomicLong(0L))).get());
        return userStats;
    }

    public static void resetStatistics() {
        totalCommands.set(0L);
        successfulCommands.set(0L);
        failedCommands.set(0L);
        securityBlocked.set(0L);
        userCommandStats.clear();
        commandUsageStats.clear();
        GM_AUDIT_LOG.info("GM操作统计数据已重置");
    }

    private static String sanitizeParameters(String command, String parameters) {
        if (parameters == null) {
            return "[]";
        } else {
            if (isSensitiveCommand(command)) {
                parameters = parameters.replaceAll("(password|pwd|pass)=[^,\\]]+", "$1=***");
                parameters = parameters.replaceAll("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}", "***@***.***");
            }

            if (parameters.length() > 200) {
                parameters = parameters.substring(0, 200) + "...";
            }

            return parameters;
        }
    }

    private static String sanitizeResult(String result) {
        if (result == null) {
            return "N/A";
        } else {
            if (result.length() > 100) {
                result = result.substring(0, 100) + "...";
            }

            return result;
        }
    }

    private static String generateSessionId(int userId, long roleId) {
        return String.format("GM-%d-%d-%d", userId, roleId, System.currentTimeMillis() % 100000L);
    }

    private static boolean isHighRiskCommand(String command) {
        Set<String> highRiskCommands = new HashSet(Arrays.asList("kick", "forbid", "restart", "reload", "cleardata", "resetdata", "dismissguild", "destroyzone", "maintenance"));
        return highRiskCommands.contains(command.toLowerCase());
    }

    private static boolean isSensitiveCommand(String command) {
        Set<String> sensitiveCommands = new HashSet(Arrays.asList("changepassword", "setpassword", "mail", "sendmail", "announce"));
        return sensitiveCommands.contains(command.toLowerCase());
    }

    public static String generateReport() {
        Map<String, Object> stats = getStatistics();
        StringBuilder report = new StringBuilder();
        report.append("=== GM操作统计报告 ===\n");
        report.append(String.format("生成时间: %s\n", dateFormatter.format(new Date())));
        report.append(String.format("总指令数: %s\n", stats.get("totalCommands")));
        report.append(String.format("成功指令: %s\n", stats.get("successfulCommands")));
        report.append(String.format("失败指令: %s\n", stats.get("failedCommands")));
        report.append(String.format("安全拦截: %s\n", stats.get("securityBlocked")));
        report.append(String.format("成功率: %s\n", stats.get("successRate")));
        report.append("\n=== 活跃用户TOP5 ===\n");

        for(Map<String, Object> user : (List<Map<String, Object>>)stats.get("topUsers")) {
            report.append(String.format("用户%s: %s条指令\n", user.get("userId"), user.get("commandCount")));
        }

        report.append("\n=== 常用指令TOP10 ===\n");

        for(Map<String, Object> cmd : (List<Map<String, Object>>)stats.get("topCommands")) {
            report.append(String.format("%s: %s次\n", cmd.get("command"), cmd.get("usageCount")));
        }

        return report.toString();
    }
}

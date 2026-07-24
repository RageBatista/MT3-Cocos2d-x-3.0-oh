//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.monitor;

import fire.log.Logger;
import gnet.link.ConnectedUsers;
import gnet.link.Onlines;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;

public class GameServerMonitor {
    private static final Logger LOG = Logger.getLogger("GAME_MONITOR");
    private static final Logger ALERT_LOG = Logger.getLogger("GAME_ALERT");
    private static final GameServerMonitor INSTANCE = new GameServerMonitor();
    private final ConcurrentHashMap<Integer, AtomicInteger> disconnectReasons = new ConcurrentHashMap();
    private final ConcurrentHashMap<String, AtomicInteger> operationCounts = new ConcurrentHashMap();
    private final ConcurrentHashMap<Long, AtomicInteger> roleOperationCounts = new ConcurrentHashMap();
    private static final int DISCONNECT_REASON_4_THRESHOLD = 10;
    private static final int HIGH_FREQUENCY_OPERATION_THRESHOLD = 50;
    private static final int ROLE_OPERATION_THRESHOLD = 100;
    private final AtomicLong currentWindowStart = new AtomicLong(System.currentTimeMillis());
    private final AtomicLong totalConnections = new AtomicLong(0L);
    private final AtomicLong totalDisconnections = new AtomicLong(0L);
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(2);

    private GameServerMonitor() {
        this.startMonitoringTasks();
    }

    public static GameServerMonitor getInstance() {
        return INSTANCE;
    }

    public void recordDisconnect(long roleId, int reason) {
        this.totalDisconnections.incrementAndGet();
        AtomicInteger count = (AtomicInteger)this.disconnectReasons.computeIfAbsent(reason, (k) -> new AtomicInteger(0));
        int currentCount = count.incrementAndGet();
        LOG.info("DISCONNECT_EVENT: roleId=" + roleId + ", reason=" + reason + ", totalCount=" + currentCount);
        if (reason == 4 && currentCount >= 10) {
            this.triggerDisconnectAlert(reason, currentCount);
        }

    }

    public void recordOperation(long roleId, String operationType) {
        AtomicInteger globalCount = (AtomicInteger)this.operationCounts.computeIfAbsent(operationType, (k) -> new AtomicInteger(0));
        int currentGlobalCount = globalCount.incrementAndGet();
        AtomicInteger roleCount = (AtomicInteger)this.roleOperationCounts.computeIfAbsent(roleId, (k) -> new AtomicInteger(0));
        int currentRoleCount = roleCount.incrementAndGet();
        if (LOG.isDebugEnabled()) {
            LOG.debug("OPERATION_EVENT: roleId=" + roleId + ", operation=" + operationType + ", roleCount=" + currentRoleCount + ", globalCount=" + currentGlobalCount);
        }

        if (currentGlobalCount >= 50) {
            this.triggerHighFrequencyOperationAlert(operationType, currentGlobalCount);
        }

        if (currentRoleCount >= 100) {
            this.triggerRoleOperationAlert(roleId, currentRoleCount);
        }

    }

    public void recordConnection(long roleId) {
        this.totalConnections.incrementAndGet();
        LOG.info("CONNECTION_EVENT: roleId=" + roleId + ", totalConnections=" + this.totalConnections.get());
    }

    private void triggerDisconnectAlert(int reason, int count) {
        String alertMessage = "HIGH_DISCONNECT_ALERT: reason=" + reason + ", count=" + count + " in current window, threshold=" + 10;
        ALERT_LOG.error(alertMessage);
        LOG.error(alertMessage);
        this.sendAlert("连接断开告警", alertMessage);
    }

    private void triggerHighFrequencyOperationAlert(String operationType, int count) {
        String alertMessage = "HIGH_FREQUENCY_OPERATION_ALERT: operation=" + operationType + ", count=" + count + " in current window, threshold=" + 50;
        ALERT_LOG.warn(alertMessage);
        LOG.warn(alertMessage);
        this.sendAlert("高频操作告警", alertMessage);
    }

    private void triggerRoleOperationAlert(long roleId, int count) {
        String alertMessage = "ROLE_HIGH_OPERATION_ALERT: roleId=" + roleId + ", count=" + count + " in current window, threshold=" + 100;
        ALERT_LOG.warn(alertMessage);
        LOG.warn(alertMessage);
        this.sendAlert("角色高频操作告警", alertMessage);
    }

    private void sendAlert(String title, String message) {
        LOG.info("ALERT_SENT: title=" + title + ", message=" + message);
    }

    public String getMonitorStats() {
        StringBuilder stats = new StringBuilder();
        stats.append("=== 游戏服务器监控统计 ===\n");
        int currentOnlineRoles = this.getCurrentOnlineRoles();
        int currentConnectedUsers = this.getCurrentConnectedUsers();
        stats.append("当前在线角色数: ").append(currentOnlineRoles).append("\n");
        stats.append("当前连接用户数: ").append(currentConnectedUsers).append("\n");
        stats.append("累计连接数: ").append(this.totalConnections.get()).append("\n");
        stats.append("累计断开数: ").append(this.totalDisconnections.get()).append("\n");
        stats.append("断开原因统计:\n");

        for(Map.Entry<Integer, AtomicInteger> entry : this.disconnectReasons.entrySet()) {
            stats.append("  原因").append(entry.getKey()).append(": ").append(((AtomicInteger)entry.getValue()).get()).append("\n");
        }

        stats.append("操作统计:\n");

        for(Map.Entry<String, AtomicInteger> entry : this.operationCounts.entrySet()) {
            stats.append("  ").append((String)entry.getKey()).append(": ").append(((AtomicInteger)entry.getValue()).get()).append("\n");
        }

        stats.append("有操作记录的角色数: ").append(this.roleOperationCounts.size()).append("\n");
        return stats.toString();
    }

    private int getCurrentOnlineRoles() {
        try {
            Onlines onlines = Onlines.getInstance();
            if (onlines != null) {
                ConnectedUsers connectedUsers = onlines.getConnectedUsers();
                if (connectedUsers != null) {
                    return connectedUsers.size();
                }
            }

            return 0;
        } catch (Exception e) {
            LOG.error("Error getting current online roles count", e);
            return 0;
        }
    }

    private int getCurrentConnectedUsers() {
        try {
            Onlines onlines = Onlines.getInstance();
            if (onlines != null) {
                ConnectedUsers connectedUsers = onlines.getConnectedUsers();
                if (connectedUsers != null) {
                    return connectedUsers.size();
                }
            }

            return 0;
        } catch (Exception e) {
            LOG.error("Error getting current connected users count", e);
            return 0;
        }
    }

    public void resetStats() {
        this.disconnectReasons.clear();
        this.operationCounts.clear();
        this.roleOperationCounts.clear();
        this.currentWindowStart.set(System.currentTimeMillis());
        LOG.info("Monitor statistics reset");
    }

    private void startMonitoringTasks() {
        this.scheduler.scheduleAtFixedRate(() -> {
            try {
                String stats = this.getMonitorStats();
                LOG.info("PERIODIC_STATS:\n" + stats);
            } catch (Exception e) {
                LOG.error("Error in periodic stats task", e);
            }

        }, 5L, 5L, TimeUnit.MINUTES);
        this.scheduler.scheduleAtFixedRate(() -> {
            try {
                LOG.info("Hourly stats reset");
                this.resetStats();
            } catch (Exception e) {
                LOG.error("Error in hourly reset task", e);
            }

        }, 1L, 1L, TimeUnit.HOURS);
        LOG.info("GameServerMonitor monitoring tasks started");
    }

    public void shutdown() {
        this.scheduler.shutdown();

        try {
            if (!this.scheduler.awaitTermination(10L, TimeUnit.SECONDS)) {
                this.scheduler.shutdownNow();
            }
        } catch (InterruptedException var2) {
            this.scheduler.shutdownNow();
            Thread.currentThread().interrupt();
        }

        LOG.info("GameServerMonitor shutdown completed");
    }

    public boolean isHealthy() {
        AtomicInteger reason4Count = (AtomicInteger)this.disconnectReasons.get(4);
        if (reason4Count != null && reason4Count.get() > 20) {
            return false;
        } else {
            for(AtomicInteger count : this.operationCounts.values()) {
                if (count.get() > 100) {
                    return false;
                }
            }

            return true;
        }
    }
}

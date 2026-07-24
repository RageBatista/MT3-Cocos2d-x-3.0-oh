//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.util;

import com.zaxxer.hikari.HikariPoolMXBean;
import java.lang.management.ManagementFactory;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicLong;
import javax.management.MBeanServer;
import javax.management.ObjectName;
import org.apache.log4j.Logger;

public class HikariCPMonitor {
    private static final Logger logger = Logger.getLogger(HikariCPMonitor.class);
    private static final Logger performanceLogger = Logger.getLogger("HIKARICP_PERFORMANCE");
    private static volatile HikariCPMonitor instance;
    private static final Object LOCK = new Object();
    private ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(2, (r) -> {
        Thread t = new Thread(r, "HikariCP-Monitor");
        t.setDaemon(true);
        return t;
    });
    private volatile boolean monitoring = false;
    private final AtomicLong totalConnectionsRequested = new AtomicLong(0L);
    private final AtomicLong totalConnectionsCreated = new AtomicLong(0L);
    private final AtomicLong totalConnectionTimeouts = new AtomicLong(0L);
    private final AtomicLong totalConnectionErrors = new AtomicLong(0L);
    private int monitoringIntervalSeconds = 30;
    private boolean enableDetailedLogging = true;
    private boolean enablePerformanceAlerts = true;
    private int maxActiveConnectionsThreshold = 18;
    private int maxWaitingThreadsThreshold = 10;
    private long maxConnectionTimeThreshold = 5000L;
    private double minSuccessRateThreshold = 0.95;

    private HikariCPMonitor() {
    }

    public static HikariCPMonitor getInstance() {
        if (instance == null) {
            synchronized(LOCK) {
                if (instance == null) {
                    instance = new HikariCPMonitor();
                }
            }
        }

        return instance;
    }

    public void startMonitoring() {
        if (this.monitoring) {
            logger.warn("HikariCP monitoring is already running");
        } else {
            logger.info("Starting HikariCP monitoring...");
            this.monitoring = true;
            this.scheduler.scheduleAtFixedRate(this::collectMetrics, (long)this.monitoringIntervalSeconds, (long)this.monitoringIntervalSeconds, TimeUnit.SECONDS);
            this.scheduler.scheduleAtFixedRate(this::performanceAnalysis, 60L, 60L, TimeUnit.SECONDS);
            logger.info("HikariCP monitoring started with interval: " + this.monitoringIntervalSeconds + " seconds");
        }
    }

    public void stopMonitoring() {
        if (this.monitoring) {
            logger.info("Stopping HikariCP monitoring...");
            this.monitoring = false;
            if (this.scheduler != null && !this.scheduler.isShutdown()) {
                this.scheduler.shutdown();

                try {
                    if (!this.scheduler.awaitTermination(10L, TimeUnit.SECONDS)) {
                        this.scheduler.shutdownNow();
                    }
                } catch (InterruptedException e) {
                    this.scheduler.shutdownNow();
                    Thread.currentThread().interrupt();
                }
            }

            logger.info("HikariCP monitoring stopped");
        }
    }

    private void collectMetrics() {
        try {
            HikariCPDataSourceManager manager = HikariCPDataSourceManager.getInstance();
            if (!manager.isAvailable()) {
                return;
            }

            HikariPoolMXBean poolBean = manager.getPoolMXBean();
            if (poolBean == null) {
                return;
            }

            int activeConnections = poolBean.getActiveConnections();
            int idleConnections = poolBean.getIdleConnections();
            int totalConnections = poolBean.getTotalConnections();
            int waitingThreads = poolBean.getThreadsAwaitingConnection();
            if (this.enableDetailedLogging) {
                performanceLogger.info(String.format("HikariCP Metrics - Active: %d, Idle: %d, Total: %d, Waiting: %d", activeConnections, idleConnections, totalConnections, waitingThreads));
            }

            if (this.enablePerformanceAlerts) {
                this.checkAlertConditions(activeConnections, waitingThreads);
            }

            this.recordToJMX(activeConnections, idleConnections, totalConnections, waitingThreads);
        } catch (Exception e) {
            logger.error("Error collecting HikariCP metrics", e);
        }

    }

    private void performanceAnalysis() {
        try {
            long totalRequested = this.totalConnectionsRequested.get();
            long totalCreated = this.totalConnectionsCreated.get();
            long totalTimeouts = this.totalConnectionTimeouts.get();
            long totalErrors = this.totalConnectionErrors.get();
            if (totalRequested > 0L) {
                double successRate = (double)(totalRequested - totalErrors) / (double)totalRequested;
                double timeoutRate = (double)totalTimeouts / (double)totalRequested;
                double creationRate = (double)totalCreated / (double)totalRequested;
                performanceLogger.info(String.format("HikariCP Performance Analysis - Success Rate: %.2f%%, Timeout Rate: %.2f%%, Creation Rate: %.2f%%", successRate * (double)100.0F, timeoutRate * (double)100.0F, creationRate * (double)100.0F));
                if (successRate < this.minSuccessRateThreshold) {
                    logger.warn("HikariCP success rate is below threshold: " + successRate * (double)100.0F + "%");
                    this.suggestPerformanceTuning();
                }
            }
        } catch (Exception e) {
            logger.error("Error performing HikariCP performance analysis", e);
        }

    }

    private void checkAlertConditions(int activeConnections, int waitingThreads) {
        if (activeConnections >= this.maxActiveConnectionsThreshold) {
            logger.warn(String.format("HikariCP Alert: High active connections - Current: %d, Threshold: %d", activeConnections, this.maxActiveConnectionsThreshold));
        }

        if (waitingThreads >= this.maxWaitingThreadsThreshold) {
            logger.warn(String.format("HikariCP Alert: High waiting threads - Current: %d, Threshold: %d", waitingThreads, this.maxWaitingThreadsThreshold));
        }

    }

    private void recordToJMX(int active, int idle, int total, int waiting) {
        try {
            MBeanServer server = ManagementFactory.getPlatformMBeanServer();
            new ObjectName("fire.util:type=HikariCPMonitor");
        } catch (Exception e) {
            logger.debug("Failed to record JMX metrics", e);
        }

    }

    private void suggestPerformanceTuning() {
        logger.info("HikariCP Performance Tuning Suggestions:");
        logger.info("1. Consider increasing maximumPoolSize if CPU and memory allow");
        logger.info("2. Check database server performance and network latency");
        logger.info("3. Review connection timeout settings");
        logger.info("4. Analyze slow queries and optimize database indexes");
        logger.info("5. Consider connection pool warm-up during application startup");
    }

    public String getPerformanceReport() {
        StringBuilder report = new StringBuilder();
        report.append("=== HikariCP Performance Report ===\n");

        try {
            HikariCPDataSourceManager manager = HikariCPDataSourceManager.getInstance();
            if (manager.isAvailable()) {
                HikariPoolMXBean poolBean = manager.getPoolMXBean();
                if (poolBean != null) {
                    report.append("Connection Pool Status:\n");
                    report.append("  Active Connections: ").append(poolBean.getActiveConnections()).append("\n");
                    report.append("  Idle Connections: ").append(poolBean.getIdleConnections()).append("\n");
                    report.append("  Total Connections: ").append(poolBean.getTotalConnections()).append("\n");
                    report.append("  Waiting Threads: ").append(poolBean.getThreadsAwaitingConnection()).append("\n");
                }
            }

            report.append("\nStatistics:\n");
            report.append("  Total Connections Requested: ").append(this.totalConnectionsRequested.get()).append("\n");
            report.append("  Total Connections Created: ").append(this.totalConnectionsCreated.get()).append("\n");
            report.append("  Total Connection Timeouts: ").append(this.totalConnectionTimeouts.get()).append("\n");
            report.append("  Total Connection Errors: ").append(this.totalConnectionErrors.get()).append("\n");
            long totalRequested = this.totalConnectionsRequested.get();
            if (totalRequested > 0L) {
                double successRate = (double)(totalRequested - this.totalConnectionErrors.get()) / (double)totalRequested;
                report.append("  Success Rate: ").append(String.format("%.2f%%", successRate * (double)100.0F)).append("\n");
            }
        } catch (Exception e) {
            report.append("Error generating performance report: ").append(e.getMessage()).append("\n");
        }

        return report.toString();
    }

    public void recordConnectionRequest() {
        this.totalConnectionsRequested.incrementAndGet();
    }

    public void recordConnectionCreated() {
        this.totalConnectionsCreated.incrementAndGet();
    }

    public void recordConnectionTimeout() {
        this.totalConnectionTimeouts.incrementAndGet();
    }

    public void recordConnectionError() {
        this.totalConnectionErrors.incrementAndGet();
    }

    public void resetStatistics() {
        this.totalConnectionsRequested.set(0L);
        this.totalConnectionsCreated.set(0L);
        this.totalConnectionTimeouts.set(0L);
        this.totalConnectionErrors.set(0L);
        logger.info("HikariCP statistics reset");
    }

    public void setMonitoringInterval(int seconds) {
        this.monitoringIntervalSeconds = seconds;
    }

    public void setDetailedLogging(boolean enabled) {
        this.enableDetailedLogging = enabled;
    }

    public void setPerformanceAlerts(boolean enabled) {
        this.enablePerformanceAlerts = enabled;
    }

    public void setMaxActiveConnectionsThreshold(int threshold) {
        this.maxActiveConnectionsThreshold = threshold;
    }

    public void setMaxWaitingThreadsThreshold(int threshold) {
        this.maxWaitingThreadsThreshold = threshold;
    }

    public boolean isMonitoring() {
        return this.monitoring;
    }
}

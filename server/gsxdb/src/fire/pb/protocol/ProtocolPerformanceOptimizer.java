//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.protocol;

import fire.log.Logger;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;

public class ProtocolPerformanceOptimizer {
    private static final Logger LOG = Logger.getLogger("PROTOCOL_OPTIMIZER");
    private static final ProtocolPerformanceOptimizer INSTANCE = new ProtocolPerformanceOptimizer();
    public static final int PROTOCOL_TYPE_1021 = 1021;
    public static final int PROTOCOL_TYPE_SHOP_PRICE = 22022;
    public static final int PROTOCOL_TYPE_MARKET_BROWSE = 26055;
    public static final int PROTOCOL_TYPE_CHARGE = 23942;
    private final ConcurrentHashMap<Integer, ProtocolStats> protocolStats = new ConcurrentHashMap();
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

    private ProtocolPerformanceOptimizer() {
        this.startPerformanceMonitoring();
    }

    public static ProtocolPerformanceOptimizer getInstance() {
        return INSTANCE;
    }

    public void recordProtocolExecution(int protocolType, long startTime, long endTime) {
        long processTime = endTime - startTime;
        ProtocolStats stats = (ProtocolStats)this.protocolStats.computeIfAbsent(protocolType, (k) -> new ProtocolStats());
        stats.recordExecution(processTime);
        if (this.isHighFrequencyProtocol(protocolType)) {
            if (LOG.isDebugEnabled()) {
                LOG.debug("高频协议执行: type=" + protocolType + ", 耗时=" + processTime + "ms");
            }

            if (processTime > this.getPerformanceThreshold(protocolType)) {
                LOG.warn("协议处理耗时过长: type=" + protocolType + ", 耗时=" + processTime + "ms, 阈值=" + this.getPerformanceThreshold(protocolType) + "ms");
            }
        }

    }

    public boolean isHighFrequencyProtocol(int protocolType) {
        return protocolType == 1021 || protocolType == 22022 || protocolType == 26055 || protocolType == 23942;
    }

    public long getPerformanceThreshold(int protocolType) {
        switch (protocolType) {
            case 1021:
                return 100L;
            case 22022:
                return 200L;
            case 23942:
                return 500L;
            case 26055:
                return 150L;
            default:
                return 1000L;
        }
    }

    public boolean needsOptimization(int protocolType) {
        ProtocolStats stats = (ProtocolStats)this.protocolStats.get(protocolType);
        if (stats == null) {
            return false;
        } else {
            long avgTime = stats.getAverageProcessTime();
            long threshold = this.getPerformanceThreshold(protocolType);
            int currentMinuteCount = stats.currentMinuteCount.get();
            return (double)avgTime > (double)threshold * 0.8 || currentMinuteCount > 100;
        }
    }

    public String getOptimizationSuggestion(int protocolType) {
        ProtocolStats stats = (ProtocolStats)this.protocolStats.get(protocolType);
        if (stats == null) {
            return "无统计数据";
        } else {
            StringBuilder suggestion = new StringBuilder();
            long avgTime = stats.getAverageProcessTime();
            long threshold = this.getPerformanceThreshold(protocolType);
            int currentMinuteCount = stats.currentMinuteCount.get();
            if (avgTime > threshold) {
                suggestion.append("处理时间过长，建议优化算法逻辑; ");
            }

            if (currentMinuteCount > 100) {
                suggestion.append("调用频率过高，建议添加缓存或频率限制; ");
            }

            if (stats.maxProcessTime.get() > threshold * 2L) {
                suggestion.append("存在异常慢的请求，建议检查数据库查询; ");
            }

            return suggestion.length() > 0 ? suggestion.toString() : "性能正常";
        }
    }

    public String getPerformanceReport() {
        StringBuilder report = new StringBuilder();
        report.append("=== 协议性能报告 ===\n");

        for(Integer protocolType : this.protocolStats.keySet()) {
            ProtocolStats stats = (ProtocolStats)this.protocolStats.get(protocolType);
            report.append("协议类型 ").append(protocolType).append(": ").append(stats.getStatsString()).append("\n");
            if (this.needsOptimization(protocolType)) {
                report.append("  ⚠️ 需要优化: ").append(this.getOptimizationSuggestion(protocolType)).append("\n");
            }
        }

        return report.toString();
    }

    private void startPerformanceMonitoring() {
        this.scheduler.scheduleAtFixedRate(() -> {
            try {
                for(ProtocolStats stats : this.protocolStats.values()) {
                    stats.resetMinuteCount();
                }

                if (LOG.isInfoEnabled()) {
                    LOG.info("协议性能监控报告:\n" + this.getPerformanceReport());
                }

                for(Integer protocolType : this.protocolStats.keySet()) {
                    if (this.needsOptimization(protocolType)) {
                        LOG.warn("协议 " + protocolType + " 需要性能优化: " + this.getOptimizationSuggestion(protocolType));
                    }
                }
            } catch (Exception e) {
                LOG.error("性能监控任务执行失败", e);
            }

        }, 1L, 1L, TimeUnit.MINUTES);
        LOG.info("协议性能监控已启动");
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

        LOG.info("协议性能监控已关闭");
    }

    public void clearStats() {
        this.protocolStats.clear();
        LOG.info("协议性能统计数据已清除");
    }

    public String getProtocolStats(int protocolType) {
        ProtocolStats stats = (ProtocolStats)this.protocolStats.get(protocolType);
        return stats == null ? "协议类型 " + protocolType + ": 无统计数据" : "协议类型 " + protocolType + ": " + stats.getStatsString();
    }

    private static class ProtocolStats {
        private final AtomicLong totalCount;
        private final AtomicLong totalProcessTime;
        private final AtomicInteger currentMinuteCount;
        private final AtomicLong maxProcessTime;
        private final AtomicLong minProcessTime;

        private ProtocolStats() {
            this.totalCount = new AtomicLong(0L);
            this.totalProcessTime = new AtomicLong(0L);
            this.currentMinuteCount = new AtomicInteger(0);
            this.maxProcessTime = new AtomicLong(0L);
            this.minProcessTime = new AtomicLong(Long.MAX_VALUE);
        }

        public void recordExecution(long processTime) {
            this.totalCount.incrementAndGet();
            this.totalProcessTime.addAndGet(processTime);
            this.currentMinuteCount.incrementAndGet();

            for(long currentMax = this.maxProcessTime.get(); processTime > currentMax && !this.maxProcessTime.compareAndSet(currentMax, processTime); currentMax = this.maxProcessTime.get()) {
            }

            for(long currentMin = this.minProcessTime.get(); processTime < currentMin && !this.minProcessTime.compareAndSet(currentMin, processTime); currentMin = this.minProcessTime.get()) {
            }

        }

        public void resetMinuteCount() {
            this.currentMinuteCount.set(0);
        }

        public long getAverageProcessTime() {
            long count = this.totalCount.get();
            return count > 0L ? this.totalProcessTime.get() / count : 0L;
        }

        public String getStatsString() {
            return String.format("总次数:%d, 平均耗时:%dms, 最大耗时:%dms, 最小耗时:%dms, 当前分钟:%d次", this.totalCount.get(), this.getAverageProcessTime(), this.maxProcessTime.get(), this.minProcessTime.get() == Long.MAX_VALUE ? 0L : this.minProcessTime.get(), this.currentMinuteCount.get());
        }
    }
}

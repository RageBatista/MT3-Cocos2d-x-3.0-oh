//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.protocol;

import fire.log.Logger;

public class ProtocolInterceptor {
    private static final Logger LOG = Logger.getLogger("PROTOCOL_INTERCEPTOR");

    public static ProtocolContext beforeProtocolExecution(int protocolType, String protocolName) {
        ProtocolContext context = new ProtocolContext(protocolType, protocolName);
        if (LOG.isDebugEnabled()) {
            LOG.debug("协议开始执行: type=" + protocolType + ", name=" + protocolName);
        }

        return context;
    }

    public static void afterProtocolExecution(ProtocolContext context, boolean success, Throwable exception) {
        long endTime = System.currentTimeMillis();
        long executionTime = endTime - context.getStartTime();
        ProtocolPerformanceOptimizer.getInstance().recordProtocolExecution(context.getProtocolType(), context.getStartTime(), endTime);
        if (success) {
            if (LOG.isDebugEnabled()) {
                LOG.debug("协议执行成功: type=" + context.getProtocolType() + ", name=" + context.getProtocolName() + ", 耗时=" + executionTime + "ms");
            }
        } else {
            LOG.error("协议执行失败: type=" + context.getProtocolType() + ", name=" + context.getProtocolName() + ", 耗时=" + executionTime + "ms", exception);
        }

        if (ProtocolPerformanceOptimizer.getInstance().isHighFrequencyProtocol(context.getProtocolType())) {
            handleHighFrequencyProtocol(context, executionTime, success);
        }

    }

    private static void handleHighFrequencyProtocol(ProtocolContext context, long executionTime, boolean success) {
        int protocolType = context.getProtocolType();
        long threshold = ProtocolPerformanceOptimizer.getInstance().getPerformanceThreshold(protocolType);
        if (executionTime > threshold) {
            LOG.warn("高频协议执行超时: type=" + protocolType + ", name=" + context.getProtocolName() + ", 耗时=" + executionTime + "ms, 阈值=" + threshold + "ms");
        }

        if (protocolType == 1021 && executionTime > 50L) {
            LOG.info("协议1021执行较慢，建议检查商城数据缓存");
        }

    }

    public static <T> T executeProtocol(int protocolType, String protocolName, ProtocolExecutor<T> executor) throws Exception {
        ProtocolContext context = beforeProtocolExecution(protocolType, protocolName);

        try {
            T result = executor.execute();
            afterProtocolExecution(context, true, (Throwable)null);
            return result;
        } catch (Exception e) {
            afterProtocolExecution(context, false, e);
            throw e;
        }
    }

    public static class ProtocolContext {
        private final int protocolType;
        private final long startTime;
        private final String protocolName;

        public ProtocolContext(int protocolType, String protocolName) {
            this.protocolType = protocolType;
            this.protocolName = protocolName;
            this.startTime = System.currentTimeMillis();
        }

        public int getProtocolType() {
            return this.protocolType;
        }

        public long getStartTime() {
            return this.startTime;
        }

        public String getProtocolName() {
            return this.protocolName;
        }

        public long getElapsedTime() {
            return System.currentTimeMillis() - this.startTime;
        }
    }

    @FunctionalInterface
    public interface ProtocolExecutor<T> {
        T execute() throws Exception;
    }
}

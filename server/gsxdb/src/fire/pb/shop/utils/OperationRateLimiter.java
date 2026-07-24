//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop.utils;

import fire.log.Logger;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;

public class OperationRateLimiter {
    private static final Logger LOG = Logger.getLogger("SHOP_RATE_LIMITER");
    private static final OperationRateLimiter INSTANCE = new OperationRateLimiter();
    public static final String SHOP_PRICE_QUERY = "SHOP_PRICE_QUERY";
    public static final String MARKET_ATTENTION_BROWSE = "MARKET_ATTENTION_BROWSE";
    public static final String CHARGE_REQUEST = "CHARGE_REQUEST";
    public static final String MARKET_BUY = "MARKET_BUY";
    public static final String MARKET_UP = "MARKET_UP";
    public static final String MARKET_DOWN = "MARKET_DOWN";
    private static final long DEFAULT_COOLDOWN = 1000L;
    private static final long CHARGE_COOLDOWN = 3000L;
    private static final long MARKET_BROWSE_COOLDOWN = 500L;
    private static final int MAX_OPERATIONS_PER_MINUTE = 30;
    private static final long MINUTE_IN_MILLIS = 60000L;
    private final ConcurrentHashMap<String, AtomicLong> lastOperationTime = new ConcurrentHashMap();
    private final ConcurrentHashMap<String, OperationCounter> operationCounters = new ConcurrentHashMap();

    private OperationRateLimiter() {
        this.startCleanupThread();
    }

    public static OperationRateLimiter getInstance() {
        return INSTANCE;
    }

    public boolean checkOperationLimit(long roleId, String operationType) {
        String key = roleId + ":" + operationType;
        long currentTime = System.currentTimeMillis();
        long cooldown = this.getCooldownTime(operationType);
        AtomicLong lastTime = (AtomicLong)this.lastOperationTime.computeIfAbsent(key, (k) -> new AtomicLong(0L));
        long lastOperationTimeValue = lastTime.get();
        if (currentTime - lastOperationTimeValue < cooldown) {
            if (LOG.isDebugEnabled()) {
                LOG.debug("Role " + roleId + " operation " + operationType + " blocked by cooldown. Last: " + lastOperationTimeValue + ", Current: " + currentTime + ", Cooldown: " + cooldown);
            }

            return false;
        } else {
            String counterKey = roleId + ":counter";
            OperationCounter counter = (OperationCounter)this.operationCounters.computeIfAbsent(counterKey, (k) -> new OperationCounter());
            if (!counter.incrementAndCheck()) {
                LOG.warn("Role " + roleId + " exceeded operation frequency limit. Current count: " + counter.getCurrentCount() + ", Max allowed: " + 30 + " per minute");
                return false;
            } else {
                lastTime.set(currentTime);
                if (LOG.isDebugEnabled()) {
                    LOG.debug("Role " + roleId + " operation " + operationType + " allowed. Count: " + counter.getCurrentCount() + "/" + 30);
                }

                return true;
            }
        }
    }

    private long getCooldownTime(String operationType) {
        switch (operationType) {
            case "CHARGE_REQUEST":
                return 3000L;
            case "MARKET_ATTENTION_BROWSE":
                return 500L;
            case "SHOP_PRICE_QUERY":
            case "MARKET_BUY":
            case "MARKET_UP":
            case "MARKET_DOWN":
            default:
                return 1000L;
        }
    }

    public void recordBlockedOperation(long roleId, String operationType, String reason) {
        LOG.warn("BLOCKED_OPERATION: Role=" + roleId + ", Operation=" + operationType + ", Reason=" + reason + ", Time=" + System.currentTimeMillis());
    }

    public String getOperationStats(long roleId) {
        String counterKey = roleId + ":counter";
        OperationCounter counter = (OperationCounter)this.operationCounters.get(counterKey);
        return counter != null ? "Role " + roleId + " operations: " + counter.getCurrentCount() + "/" + 30 : "Role " + roleId + " operations: 0/" + 30;
    }

    private void startCleanupThread() {
        Thread cleanupThread = new Thread(() -> {
            while(true) {
                try {
                    Thread.sleep(300000L);
                    this.cleanupExpiredData();
                } catch (InterruptedException e) {
                    LOG.error("Cleanup thread interrupted", e);
                    return;
                }
            }
        });
        cleanupThread.setDaemon(true);
        cleanupThread.setName("OperationRateLimiter-Cleanup");
        cleanupThread.start();
        LOG.info("OperationRateLimiter cleanup thread started");
    }

    private void cleanupExpiredData() {
        long now = System.currentTimeMillis();
        AtomicInteger cleanedOperations = new AtomicInteger(0);
        AtomicInteger cleanedCounters = new AtomicInteger(0);
        this.lastOperationTime.entrySet().removeIf((entry) -> {
            if (now - ((AtomicLong)entry.getValue()).get() > 600000L) {
                cleanedOperations.incrementAndGet();
                return true;
            } else {
                return false;
            }
        });
        this.operationCounters.entrySet().removeIf((entry) -> {
            OperationCounter counter = (OperationCounter)entry.getValue();
            if (now - counter.windowStart.get() > 120000L) {
                cleanedCounters.incrementAndGet();
                return true;
            } else {
                return false;
            }
        });
        if (cleanedOperations.get() > 0 || cleanedCounters.get() > 0) {
            LOG.info("Cleaned up expired data: " + cleanedOperations.get() + " operations, " + cleanedCounters.get() + " counters");
        }

    }

    private static class OperationCounter {
        private final AtomicInteger count;
        private final AtomicLong windowStart;

        private OperationCounter() {
            this.count = new AtomicInteger(0);
            this.windowStart = new AtomicLong(System.currentTimeMillis());
        }

        public boolean incrementAndCheck() {
            long now = System.currentTimeMillis();
            long windowStartTime = this.windowStart.get();
            if (now - windowStartTime > 60000L && this.windowStart.compareAndSet(windowStartTime, now)) {
                this.count.set(1);
                return true;
            } else {
                int currentCount = this.count.incrementAndGet();
                return currentCount <= 30;
            }
        }

        public int getCurrentCount() {
            return this.count.get();
        }
    }
}

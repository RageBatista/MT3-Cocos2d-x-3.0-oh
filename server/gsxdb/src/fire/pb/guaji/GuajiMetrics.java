package fire.pb.guaji;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.atomic.LongAdder;

/**
 * 轻量级指标采集器，供挂机系统埋点使用。
 */
public final class GuajiMetrics {
    private static final String START_ATTEMPT = "guaji_start_attempt_total";
    private static final String START_SUCCESS = "guaji_start_success_total";
    private static final String START_FAILURE = "guaji_start_failure_total";
    private static final String STOP_TOTAL = "guaji_stop_total";
    private static final String SCHEDULER_DELAY_SUM = "guaji_scheduler_delay_millis_sum";
    private static final String SCHEDULER_DELAY_COUNT = "guaji_scheduler_delay_count";

    private static final ConcurrentMap<String, LongAdder> COUNTERS = new ConcurrentHashMap<>();

    private GuajiMetrics() {
    }

    public static void recordStartAttempt(String source) {
        increment(START_ATTEMPT, source);
    }

    public static void recordStartSuccess(String source) {
        increment(START_SUCCESS, source);
    }

    public static void recordStartFailure(String reason) {
        increment(START_FAILURE, reason);
    }

    public static void recordStop(String reason) {
        increment(STOP_TOTAL, reason);
    }

    public static void recordSchedulerDelay(long delayMillis) {
        if (delayMillis < 0) {
            return;
        }
        add(SCHEDULER_DELAY_SUM, "all", delayMillis);
        add(SCHEDULER_DELAY_COUNT, "all", 1L);
    }

    public static Map<String, Long> snapshot() {
        if (COUNTERS.isEmpty()) {
            return Collections.emptyMap();
        }
        Map<String, Long> snapshot = new HashMap<>(COUNTERS.size());
        for (Map.Entry<String, LongAdder> entry : COUNTERS.entrySet()) {
            snapshot.put(entry.getKey(), entry.getValue().sum());
        }
        return snapshot;
    }

    private static void increment(String metric, String label) {
        add(metric, label, 1L);
    }

    private static void add(String metric, String label, long delta) {
        if (label == null) {
            label = "unknown";
        }
        if (delta <= 0) {
            return;
        }
        String key = metric + "|" + label;
        COUNTERS.computeIfAbsent(key, k -> new LongAdder()).add(delta);
    }
}

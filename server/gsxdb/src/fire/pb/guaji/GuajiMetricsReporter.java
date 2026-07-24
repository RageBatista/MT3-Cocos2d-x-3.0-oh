package fire.pb.guaji;

import mkdb.Executor;
import org.apache.log4j.Logger;

import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * 周期性导出挂机指标到日志，方便外部采集。
 */
final class GuajiMetricsReporter implements Runnable {
    private static final Logger LOGGER = Logger.getLogger(GuajiMetricsReporter.class);
    private static final AtomicBoolean STARTED = new AtomicBoolean(false);
    private static final long REPORT_PERIOD_SECONDS = 60L;

    private GuajiMetricsReporter() {
    }

    static void ensureStarted() {
        if (STARTED.get()) {
            return;
        }
        if (!STARTED.compareAndSet(false, true)) {
            return;
        }

        Executor executor = Executor.getInstance();
        if (executor == null) {
            STARTED.set(false);
            LOGGER.warn("guaji_metrics_reporter_delay|reason=executor_not_ready");
            return;
        }

        executor.scheduleAtFixedRate(new GuajiMetricsReporter(),
                REPORT_PERIOD_SECONDS,
                REPORT_PERIOD_SECONDS,
                TimeUnit.SECONDS);
        LOGGER.info("guaji_metrics_reporter_started|periodSec=" + REPORT_PERIOD_SECONDS);
    }

    @Override
    public void run() {
        try {
            Map<String, Long> snapshot = GuajiMetrics.snapshot();
            if (snapshot.isEmpty()) {
                if (LOGGER.isDebugEnabled()) {
                    LOGGER.debug("guaji_metrics_snapshot|empty");
                }
                return;
            }

            StringBuilder logLine = new StringBuilder("guaji_metrics_snapshot");
            snapshot.forEach((key, value) -> logLine.append('|').append(key).append('=').append(value));
            LOGGER.info(logLine.toString());
        } catch (Throwable t) {
            LOGGER.error("guaji_metrics_reporter_error", t);
        }
    }

    static void ensureStartedAsync() {
        ensureStarted();
        if (!STARTED.get()) {
            Executor executor = Executor.getInstance();
            if (executor != null) {
                executor.schedule(GuajiMetricsReporter::ensureStarted, 5L, TimeUnit.SECONDS);
            }
        }
    }
}

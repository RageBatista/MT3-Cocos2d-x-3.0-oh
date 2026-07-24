//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc.NpcAI;

import fire.msp.npc.GCheckNpcMove;
import fire.pb.GsClient;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import mkdb.Mkdb;

public class NpcAITimer {
    private static final NpcAITimer instance = new NpcAITimer();
    private ScheduledFuture<?> timer = null;
    private static final int INTERVAL = 500;

    public synchronized void start() {
        if (null == this.timer) {
            this.timer = Mkdb.executor().scheduleAtFixedRate(new TimeSchedule(), 0L, 500L, TimeUnit.MILLISECONDS);
        }
    }

    public synchronized void end() {
        if (null != this.timer) {
            this.timer.cancel(true);
            this.timer = null;
        }

    }

    public static synchronized NpcAITimer getInstance() {
        return instance;
    }

    private NpcAITimer() {
    }

    private class TimeSchedule implements Runnable {
        private TimeSchedule() {
        }

        public void run() {
            long tick = System.currentTimeMillis();
            GsClient.pSendWhileCommit(new GCheckNpcMove(tick));
        }
    }
}

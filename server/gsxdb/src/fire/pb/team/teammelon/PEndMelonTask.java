//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team.teammelon;

import java.util.TimerTask;

public class PEndMelonTask extends TimerTask {
    public final long battlemelonid;

    public void run() {
        (new PTeamRollMelonInfo(this.battlemelonid, 1)).submit();
    }

    public PEndMelonTask(long battlemelonid) {
        this.battlemelonid = battlemelonid;
    }
}

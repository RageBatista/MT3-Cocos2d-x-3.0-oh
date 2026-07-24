//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.msp.npc.GRemoveNpcFromScene;
import fire.pb.GsClient;
import fire.pb.map.Npc;
import fire.pb.map.SceneNpcManager;
import java.util.LinkedList;
import java.util.List;
import mkdb.Procedure;
import xtable.Npcs;

public class PRemoveNpcFromGS extends Procedure {
    private List<Long> npckeys;
    boolean notifyscene = true;
    public String trace;

    public PRemoveNpcFromGS(long npckey, String trace) {
        this.npckeys = new LinkedList();
        this.npckeys.add(npckey);
        this.trace = trace;
    }

    public PRemoveNpcFromGS(List<Long> npckeys, boolean notifyscene) {
        this.npckeys = npckeys;
        this.notifyscene = notifyscene;
    }

    protected boolean process() {
        for(long npckey : this.npckeys) {
            Npc npc = (Npc)SceneNpcManager.getInstance().getNpcs().remove(npckey);
            if (npc != null) {
                Npcs.remove(npckey);
                if (npc.getFuture() != null) {
                    npc.getFuture().cancel(false);
                }

                if (this.notifyscene) {
                    GsClient.pSendWhileCommit(new GRemoveNpcFromScene(npckey, this.trace));
                }
            }
        }

        return true;
    }
}

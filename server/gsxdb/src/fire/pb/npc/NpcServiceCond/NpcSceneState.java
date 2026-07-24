//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc.NpcServiceCond;

import fire.pb.scene.manager.SceneNpcManager;
import fire.pb.scene.movable.NPC;

public class NpcSceneState implements Condition {
    public boolean CheckCond(long roleid, int args1, int args2) {
        NPC npc = SceneNpcManager.getInstance().getNpcByKey(roleid);
        return npc == null ? false : false;
    }
}

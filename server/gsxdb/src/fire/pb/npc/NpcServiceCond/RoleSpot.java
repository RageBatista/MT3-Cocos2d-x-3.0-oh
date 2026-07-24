//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc.NpcServiceCond;

import fire.pb.triggers.TriggerRole;

public class RoleSpot implements Condition {
    public boolean CheckCond(long roleid, int args1, int args2) {
        TriggerRole trole = new TriggerRole(roleid, true);
        boolean triggered = trole.isTriggered(args1);
        if (args2 == 0) {
            return !triggered;
        } else {
            return triggered;
        }
    }
}

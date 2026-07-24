//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc.NpcServiceCond;

import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;

public class RoleTeam implements Condition {
    public boolean CheckCond(long roleid, int args1, int args2) {
        BuffAgent agent = new BuffRoleImpl(roleid, true);
        if (agent.existState(507006)) {
            if (args1 == 1) {
                return true;
            }

            if (args1 == 0) {
                return false;
            }
        } else if (args1 == 1) {
            return false;
        }

        return true;
    }
}

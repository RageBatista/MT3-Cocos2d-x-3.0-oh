//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc.NpcServiceCond;

import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;

public class RoleState implements Condition {
    public boolean CheckCond(long roleid, int args1, int args2) {
        BuffAgent agent = new BuffRoleImpl(roleid, true);
        return agent.existState(args1);
    }
}

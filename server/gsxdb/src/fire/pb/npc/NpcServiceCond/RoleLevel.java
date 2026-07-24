//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc.NpcServiceCond;

import fire.pb.PropRole;

public class RoleLevel implements Condition {
    public boolean CheckCond(long roleid, int args1, int args2) {
        PropRole prole = new PropRole(roleid, true);
        return prole.getLevel() >= args1 && prole.getLevel() <= args2;
    }
}

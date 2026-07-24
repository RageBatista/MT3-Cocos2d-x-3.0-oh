//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc.NpcServiceCond;

import java.util.Map;
import xtable.Properties;

public class RoleHasTuPo implements Condition {
    public boolean CheckCond(long roleid, int args1, int args2) {
        Map<Integer, Integer> tupotips = Properties.selectTupotips(roleid);
        Integer st = (Integer)tupotips.get(args1);
        return st != null && st == 1;
    }
}

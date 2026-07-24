//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc.NpcServiceCond;

import xbean.CircleTaskInfo;
import xbean.CircleTaskMap;
import xtable.Rolecircletask;

public class RoleQuestUnState implements Condition {
    public boolean CheckCond(long roleid, int args1, int args2) {
        CircleTaskMap quest_map = Rolecircletask.select(roleid);
        if (null == quest_map) {
            return false;
        } else {
            CircleTaskInfo sqinfo = (CircleTaskInfo)quest_map.getTaskmap().get(args1);
            if (null == sqinfo) {
                return false;
            } else {
                return sqinfo.getQueststate() != args2;
            }
        }
    }
}

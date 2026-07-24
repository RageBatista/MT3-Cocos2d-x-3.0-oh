//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc.NpcServiceCond;

import xbean.CircleTaskInfo;
import xbean.CircleTaskMap;
import xtable.Rolecircletask;

public class RoleQuestState implements Condition {
    public boolean CheckCond(long roleid, int args1, int args2) {
        CircleTaskMap quest_map = Rolecircletask.select(roleid);
        if (null == quest_map) {
            return false;
        } else {
            CircleTaskInfo quest_info = (CircleTaskInfo)quest_map.getTaskmap().get(args1);
            if (null == quest_info) {
                return false;
            } else {
                return quest_info.getQueststate() == args2;
            }
        }
    }
}

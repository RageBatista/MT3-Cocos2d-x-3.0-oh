//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc.NpcServiceCond;

import fire.pb.mission.UtilHelper;
import xbean.CircleTaskInfo;
import xbean.CircleTaskMap;
import xtable.Rolecircletask;

public class RoleHasQuest implements Condition {
    public boolean CheckCond(long roleid, int args1, int args2) {
        if (UtilHelper.isSpecialQuest(args1)) {
            CircleTaskMap quest_map = Rolecircletask.select(roleid);
            if (null == quest_map) {
                return args2 <= 0;
            } else {
                CircleTaskInfo quest_info = (CircleTaskInfo)quest_map.getTaskmap().get(args1);
                if (null == quest_info) {
                    return args2 <= 0;
                } else if (args2 > 0) {
                    return quest_info.getQuesttype() != 0;
                } else if (quest_info.getQuesttype() != 1030001 && quest_info.getQuesttype() != 1030002) {
                    return quest_info.getQuesttype() == 0;
                } else {
                    return quest_info.getQueststate() != 4;
                }
            }
        } else {
            return false;
        }
    }
}

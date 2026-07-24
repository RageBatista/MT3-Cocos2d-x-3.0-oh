//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Runnable;
import mkdb.Executor;
import mkdb.logs.Listener;
import mkdb.logs.Note;
import xtable.Roleid2battleid;

public class PropertiesListener implements Listener {
    public void onChanged(Object key) {
    }

    public void onRemoved(Object key) {
    }

    public void onChanged(Object key, String fullVarName, Note note) {
        long roleId = (Long)key;
        Executor.getInstance().submit(new NotifyMemberHpMpChange(roleId));
    }

    public class NotifyMemberHpMpChange extends Runnable {
        private long roleId;

        NotifyMemberHpMpChange(long roleId) {
            this.roleId = roleId;
        }

        public void run() {
            Long battleId = Roleid2battleid.select(this.roleId);
            if (battleId == null) {
                Team team = TeamManager.selectTeamByRoleId(this.roleId);
                if (team != null) {
                    team.notifyHpMpChange(this.roleId);
                }
            }
        }
    }
}

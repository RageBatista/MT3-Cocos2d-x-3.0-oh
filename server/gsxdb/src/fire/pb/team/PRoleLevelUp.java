//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import java.util.List;
import mkdb.Procedure;

public class PRoleLevelUp extends Procedure {
    private final long roleId;
    private final int level;

    public PRoleLevelUp(long roleId, int level) {
        this.roleId = roleId;
        this.level = level;
    }

    protected boolean process() {
        Team team = TeamManager.selectTeamByRoleId(this.roleId);
        if (team == null) {
            return true;
        } else {
            List<Long> roleIds = team.getAllMemberIds();
            SUpdateMemberLevel sUpdateMemberLevel = new SUpdateMemberLevel(this.roleId, this.level);
            psendWhileCommit(roleIds, sUpdateMemberLevel);
            return true;
        }
    }
}

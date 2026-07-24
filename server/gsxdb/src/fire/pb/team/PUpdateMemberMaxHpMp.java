//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import java.util.Set;
import mkdb.Procedure;
import xtable.Roleid2battleid;

public class PUpdateMemberMaxHpMp extends Procedure {
    private final long roleId;
    private final int maxhp;
    private final int maxmp;

    public PUpdateMemberMaxHpMp(long roleId, int maxhp, int maxmp) {
        this.roleId = roleId;
        this.maxhp = maxhp;
        this.maxmp = maxmp;
    }

    protected boolean process() {
        Long battleId = Roleid2battleid.select(this.roleId);
        if (battleId != null) {
            return true;
        } else {
            Team team = TeamManager.selectTeamByRoleId(this.roleId);
            if (team == null) {
                return true;
            } else {
                Set<Long> roleIds = team.getAllMemberIdSet();
                SUpdateMemberMaxHPMP update = new SUpdateMemberMaxHPMP(this.roleId, this.maxhp, this.maxmp);
                psend(roleIds, update);
                return true;
            }
        }
    }
}

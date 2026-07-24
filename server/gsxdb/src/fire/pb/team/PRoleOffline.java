//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import mkdb.Lockeys;
import mkdb.Procedure;
import xtable.Locks;
import xtable.Roleid2teamid;

public class PRoleOffline extends Procedure {
    private long roleId;

    public PRoleOffline(long roleId) {
        this.roleId = roleId;
    }

    protected boolean process() {
        Long teamId = Roleid2teamid.select(this.roleId);
        if (teamId == null) {
            return true;
        } else {
            try {
                Team team = new Team(teamId, false);
                this.lock(Lockeys.get(Locks.ROLELOCK, team.getAllMemberIds()));
                if (team.isInTeam(this.roleId)) {
                    team.roleOffline(this.roleId);
                    TeamManager.logger.debug("队员  roleid=" + this.roleId + " 下线。");
                }
            } catch (Exception e) {
                TeamManager.logger.error(e);
            }

            return true;
        }
    }
}

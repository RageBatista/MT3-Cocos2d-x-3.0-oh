//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import fire.pb.map.Role;
import java.util.ArrayList;
import java.util.List;
import mkdb.Lockeys;
import mkdb.Procedure;
import xbean.Properties;
import xbean.TeamInfo;
import xtable.Locks;
import xtable.Roleid2teamid;
import xtable.Team;

public class PSendAndModifyTeamApplierids extends Procedure {
    private final long roleId;

    public PSendAndModifyTeamApplierids(long roleId) {
        this.roleId = roleId;
    }

    protected boolean process() throws Exception {
        Long teamid = Roleid2teamid.select(this.roleId);
        if (teamid != null) {
            TeamInfo teamInfo = Team.get(teamid);
            if (teamInfo == null) {
                return false;
            }

            fire.pb.team.Team team = new fire.pb.team.Team(teamid, false);
            this.lock(Lockeys.get(Locks.ROLELOCK, team.getTeamInfo().getApplierids().keySet().toArray()));
            long now = System.currentTimeMillis();
            SAddTeamApply sAddTeamApply = new SAddTeamApply();
            List<Long> timeoutList = new ArrayList();

            for(Long applierRoleId : team.getTeamInfo().getApplierids().keySet()) {
                if (now - (Long)team.getTeamInfo().getApplierids().get(applierRoleId) <= 36000000L) {
                    TeamApplyBasic teamApplyBasic = new TeamApplyBasic();
                    Properties applierProperty = xtable.Properties.select(applierRoleId);
                    teamApplyBasic.level = applierProperty.getLevel() + applierProperty.getZhuansheng() * 1000;
                    teamApplyBasic.roleid = applierRoleId;
                    teamApplyBasic.rolename = applierProperty.getRolename();
                    teamApplyBasic.school = applierProperty.getSchool();
                    teamApplyBasic.shape = applierProperty.getShape();
                    Role.fillPlayerComponents(applierRoleId, teamApplyBasic.components);
                    sAddTeamApply.applylist.add(teamApplyBasic);
                } else {
                    timeoutList.add(applierRoleId);
                }
            }

            for(Long key : timeoutList) {
                team.getTeamInfo().getApplierids().remove(key);
            }

            Procedure.psendWhileCommit(this.roleId, sAddTeamApply);
        }

        return true;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import fire.pb.map.Role;
import java.util.Map;
import mkdb.Procedure;
import xbean.Properties;
import xtable.Roleid2teamid;

public class PSendTeamApplierids extends Procedure {
    private final long roleId;

    public PSendTeamApplierids(long roleId) {
        this.roleId = roleId;
    }

    protected boolean process() throws Exception {
        Long teamid = Roleid2teamid.select(this.roleId);
        if (teamid != null) {
            Team team = new Team(teamid, true);

            for(Map.Entry<Long, Long> e : team.getTeamInfo().getApplierids().entrySet()) {
                long roleid = (Long)e.getKey();
                SAddTeamApply sAddTeamApply = new SAddTeamApply();
                TeamApplyBasic teamApplyBasic = new TeamApplyBasic();
                Properties applierProperty = xtable.Properties.select(roleid);
                teamApplyBasic.level = applierProperty.getLevel() + applierProperty.getZhuansheng() * 1000;
                teamApplyBasic.roleid = roleid;
                teamApplyBasic.rolename = applierProperty.getRolename();
                teamApplyBasic.school = applierProperty.getSchool();
                teamApplyBasic.shape = applierProperty.getShape();
                Role.fillPlayerComponents(roleid, teamApplyBasic.components);
                sAddTeamApply.applylist.add(teamApplyBasic);
                Procedure.psendWhileCommit(this.roleId, sAddTeamApply);
            }
        }

        return true;
    }
}

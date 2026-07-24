//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import fire.pb.PropRole;
import fire.pb.StateCommon;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;
import mkdb.Procedure;
import xbean.FormBean;
import xbean.Properties;

public class PSetFormationProc extends Procedure {
    private final long roleId;
    private final int formation;

    public PSetFormationProc(long roleId, int formId) {
        this.roleId = roleId;
        this.formation = formId;
    }

    protected boolean process() throws Exception {
        Team team = TeamManager.getTeamByRoleId(this.roleId);
        Properties prop = xtable.Properties.get(this.roleId);
        PropRole prole = new PropRole(this.roleId, false);
        if (!this.checkForm(prop)) {
            return false;
        } else {
            int formLevel = prole.getFormLevel(this.formation);
            prop.setDefultform(this.formation);
            if (team != null && team.getTeamInfo().getTeamleaderid() == this.roleId) {
                team.changeFormationWithSP(this.formation, formLevel, true);
            }

            SSetMyFormation sSetMyFormation = new SSetMyFormation();
            sSetMyFormation.formation = this.formation;
            sSetMyFormation.entersend = 0;
            Procedure.psendWhileCommit(this.roleId, sSetMyFormation);
            return true;
        }
    }

    private boolean checkForm(Properties prop) {
        if (!this.checkOnline(this.roleId)) {
            TeamManager.logger.debug("FAIL:光环设置者不在线,roleid: " + this.roleId);
            return false;
        } else if (!this.checkSetedFormationValid(this.formation, prop)) {
            TeamManager.logger.debug("FAIL:设置的光环不合法,formation: " + this.formation);
            return false;
        } else {
            BuffAgent buffagent = new BuffRoleImpl(this.roleId);
            if (!buffagent.canAddBuff(516008)) {
                TeamManager.logger.debug("FAIL:设置者处于不可以设置光环的状态，例如战斗,roleid: " + this.roleId);
                return false;
            } else {
                return true;
            }
        }
    }

    private boolean checkOnline(long roleId) {
        return StateCommon.isOnline(roleId);
    }

    private boolean checkSetedFormationValid(int formation, Properties prop) {
        if (formation >= 0 && formation <= 10) {
            if (formation == 0) {
                return true;
            }

            FormBean formLevel = (FormBean)prop.getFormationsmap().get(formation);
            if (formLevel != null && formLevel.getLevel() > 0) {
                return true;
            }
        }

        return false;
    }
}

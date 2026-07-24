//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import fire.pb.StateCommon;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;
import fire.pb.buff.Module;
import fire.pb.talk.MessageMgr;
import java.util.List;
import mkdb.Procedure;
import xtable.Roleid2teamid;

public class PCreateTeam extends Procedure {
    private final long leaderRoleId;
    private long teamId = -1L;

    public PCreateTeam(long leaderRoleId) {
        this.leaderRoleId = leaderRoleId;
    }

    protected boolean process() throws Exception {
        BuffAgent buffagent = new BuffRoleImpl(this.leaderRoleId, false);
        if (buffagent.existBuff(500019)) {
            MessageMgr.sendMsgNotify(this.leaderRoleId, 141133, (List)null);
            return false;
        } else if (!buffagent.canAddBuff(507006)) {
            MessageMgr.sendMsgNotify(this.leaderRoleId, 141618, (List)null);
            TeamManager.logger.info("PCreateTeam玩家(roleId=" + this.leaderRoleId + ")处于不能组队的状态");
            return false;
        } else if (Module.existState(this.leaderRoleId, 507026)) {
            MessageMgr.sendMsgNotify(this.leaderRoleId, 160202, (List)null);
            TeamManager.logger.info("PCreateTeam玩家(roleId=" + this.leaderRoleId + ")处于副本中,不能组队");
            return false;
        } else {
            if (StateCommon.isOnline(this.leaderRoleId)) {
                if (Roleid2teamid.get(this.leaderRoleId) == null) {
                    Team team = TeamManager.getInstance().createNewTeam(this.leaderRoleId);
                    if (team == null) {
                        TeamManager.logger.error("FAIL:PCreateTeam创建队伍失败（可能由于状态冲突）。");
                        return false;
                    }

                    this.teamId = team.teamId;
                    TeamManager.logger.info("SUCC:PCreateTeam创建队伍, leaderRoleId: " + team.teamId);
                    return true;
                }

                TeamManager.logger.error("FAIL:PCreateTeam玩家已经在队伍中, leaderRoleId: " + this.leaderRoleId);
            } else {
                TeamManager.logger.error("FAIL:PCreateTeam玩家已经不在线, leaderRoleId: " + this.leaderRoleId);
            }

            return false;
        }
    }

    public long getTeamId() {
        return this.teamId;
    }
}

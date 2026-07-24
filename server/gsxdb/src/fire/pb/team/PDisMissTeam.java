//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;
import fire.pb.talk.MessageMgr;
import java.util.Set;
import mkdb.Lockeys;
import mkdb.Procedure;
import xtable.Locks;
import xtable.Properties;

public class PDisMissTeam extends Procedure {
    public static int REASON_SYSTEM = 1;
    public static int REASON_LEADER = 2;
    public static int REASON_LEADER_QUIT = 3;
    private final long teamId;
    private final int reason;

    public PDisMissTeam(long teamId, int reason) {
        this.teamId = teamId;
        this.reason = reason;
    }

    protected boolean process() {
        Team team = TeamManager.getTeamByTeamID(this.teamId);
        if (team == null) {
            return false;
        } else {
            this.lock(Lockeys.get(Locks.ROLELOCK, team.getAllMemberIds()));
            long leaderId = team.getTeamLeaderId();
            if (this.reason == REASON_LEADER) {
                BuffAgent brole = new BuffRoleImpl(leaderId, false);
                if (!brole.canAddBuff(516026)) {
                    return false;
                }
            }

            Set<Long> roleIds = team.getAllMemberIdSet();
            team.dismissTeam();
            if (this.reason == REASON_LEADER) {
                String name = Properties.selectRolename(leaderId);

                for(long id : roleIds) {
                    if (id != leaderId) {
                        MessageMgr.psendMsgNotifyWhileCommit(id, 142585, MessageMgr.getStringList(new Object[]{name}));
                    } else {
                        MessageMgr.psendMsgNotifyWhileCommit(id, 141049, MessageMgr.getStringList(new Object[]{name}));
                    }
                }
            } else if (this.reason != REASON_SYSTEM && this.reason == REASON_LEADER_QUIT) {
            }

            return true;
        }
    }
}

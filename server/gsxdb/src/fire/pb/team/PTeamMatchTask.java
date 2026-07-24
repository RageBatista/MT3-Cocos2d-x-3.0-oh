//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.TimerTask;
import mkdb.Lockeys;
import mkdb.Procedure;
import xbean.ETeamMatch;
import xbean.InviteInfo;
import xbean.Properties;
import xbean.TeamInfo;
import xbean.TeamInvite;
import xbean.TeamMatch;
import xbean.TeamMember;
import xtable.Locks;
import xtable.Roleid2teamid;
import xtable.Targetid2teammatch;
import xtable.Team;
import xtable.Teaminvite;

public class PTeamMatchTask extends TimerTask {
    public void run() {
        Procedure teammatchtask = new Procedure() {
            protected boolean process() {
                ETeamMatch temp = Targetid2teammatch.select(0);
                if (temp == null) {
                    return true;
                } else {
                    HashSet<Long> teamids = new HashSet();
                    HashSet<Long> roleids = new HashSet();

                    for(Long teamid : temp.getTeamid2matchdata().keySet()) {
                        if (teamid != null) {
                            TeamInfo teamInfo = Team.select(teamid);
                            if (teamInfo != null) {
                                List<Long> ids = new ArrayList();
                                ids.add(teamInfo.getTeamleaderid());

                                for(TeamMember member : teamInfo.getMembers()) {
                                    ids.add(member.getRoleid());
                                }

                                roleids.addAll(ids);
                                teamids.add(teamid);
                            }
                        }
                    }

                    roleids.addAll(temp.getRoleid2matchdata().keySet());
                    this.lock(Lockeys.get(Locks.TEAMLOCK, teamids));
                    this.lock(Lockeys.get(Locks.ROLELOCK, roleids));
                    ETeamMatch ematch = Targetid2teammatch.get(0);
                    if (ematch == null) {
                        return true;
                    } else {
                        long cur = System.currentTimeMillis();

                        label101:
                        for(TeamMatch e : ematch.getTeammatchdatalist()) {
                            if (cur >= e.getTimestamp()) {
                                Iterator var25 = ematch.getRolematchdatalist().iterator();

                                while(true) {
                                    TeamMatch e1;
                                    Long teamid;
                                    while(true) {
                                        if (!var25.hasNext()) {
                                            continue label101;
                                        }

                                        e1 = (TeamMatch)var25.next();
                                        if (cur >= e1.getTimestamp()) {
                                            teamid = Roleid2teamid.select(e.getRoleid());
                                            if (teamid != null) {
                                                TeamInfo teaminfo = Team.select(teamid);
                                                if (teaminfo != null && e.getTargetid() == e1.getTargetid() && PTeamMatchTask.this.checkLevel(e1.getRoleid(), e)) {
                                                    InviteInfo invitedInfo = Teaminvite.select(e1.getRoleid());
                                                    if (invitedInfo == null) {
                                                        break;
                                                    }

                                                    if (invitedInfo.getBeinginvited()) {
                                                        if (cur - invitedInfo.getInviting().getInvitetime() <= 20000L) {
                                                            continue;
                                                        }
                                                        break;
                                                    } else {
                                                        boolean find = false;

                                                        for(TeamInvite invited : invitedInfo.getInvited()) {
                                                            if (cur - invited.getInvitetime() <= 20000L && invited.getRoleid() == e.getRoleid()) {
                                                                find = true;
                                                                break;
                                                            }
                                                        }

                                                        if (!find) {
                                                            break;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    long time = cur + 7000L;
                                    long teamtime = cur + 3000L;
                                    e.setTimestamp(teamtime);
                                    e1.setTimestamp(time);
                                    TeamMatch teammatch = (TeamMatch)ematch.getTeamid2matchdata().get(teamid);
                                    teammatch.setTimestamp(teamtime);
                                    TeamMatch teammatch1 = (TeamMatch)ematch.getRoleid2matchdata().get(e1.getRoleid());
                                    teammatch1.setTimestamp(time);
                                    SForceInviteJointTeam teammsg = new SForceInviteJointTeam();
                                    teammsg.roleid = e1.getRoleid();
                                    Procedure.psendWhileCommit(e.getRoleid(), teammsg);
                                }
                            }
                        }

                        return true;
                    }
                }
            }
        };
        teammatchtask.submit();
    }

    public boolean checkTeam(TeamInfo teaminfo) {
        return true;
    }

    public boolean checkLevel(long roleid, TeamMatch teammatch) {
        Properties prop = xtable.Properties.select(roleid);
        int level = prop.getLevel();
        return level >= teammatch.getLevelmin() && level <= teammatch.getLevelmax();
    }
}

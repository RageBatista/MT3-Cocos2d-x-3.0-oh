//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import fire.pb.battle.pvp.PvPTeamHandle;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;
import fire.pb.buff.Module;
import fire.pb.event.LeaveTeamSpecialQuestEvent;
import fire.pb.event.Poster;
import fire.pb.talk.MessageMgr;
import java.util.List;
import mkdb.Lockeys;
import mkdb.Procedure;
import xbean.BattleInfo;
import xbean.Pod;
import xbean.TeamInfo;
import xbean.TeamMember;
import xtable.Battle;
import xtable.Locks;
import xtable.Properties;
import xtable.Roleid2battleid;
import xtable.Roleid2teamid;
import xtable.Watcherid2battleid;

public class PQuitTeamProc extends Procedure {
    private final long leverRoleId;

    public PQuitTeamProc(long roleId) {
        this.leverRoleId = roleId;
    }

    protected boolean process() {
        Team team = null;
        Long leverTeamId = Roleid2teamid.select(this.leverRoleId);
        if (leverTeamId == null) {
            return true;
        } else {
            BattleInfo battleinfo = null;
            Long battleid = null;
            if (Module.existState(this.leverRoleId, 507005)) {
                battleid = Watcherid2battleid.select(this.leverRoleId);
            } else {
                battleid = Roleid2battleid.select(this.leverRoleId);
            }

            if (battleid != null) {
                battleinfo = Battle.get(battleid);
            }

            TeamInfo teamInfo = xtable.Team.get(leverTeamId);
            if (teamInfo == null) {
                return false;
            } else {
                team = new Team(leverTeamId, false);
                if (!team.isInTeam(this.leverRoleId)) {
                    return true;
                } else {
                    this.lock(Lockeys.get(Locks.ROLELOCK, team.getAllMemberIdSet()));
                    if (checkPvP(this.leverRoleId, team.isTeamLeader(this.leverRoleId)) != 0) {
                        return true;
                    } else {
                        if (this.checkRoleIsLeader(this.leverRoleId, team)) {
                            TeamManager.logger.debug("INFO:离开者是队长,TeamId: " + leverTeamId);
                            if (!this.checkLeadLeverStatus(this.leverRoleId)) {
                                TeamManager.logger.info("FAIL:队长离开者处于不能离队状态,TeamId: " + leverTeamId);
                            } else if (team.passiveSwitchLeaderWithSP(-1)) {
                                team.removeTeamMemberWithSP(this.leverRoleId, true);
                                MessageMgr.psendMsgNotifyWhileCommit(team.getAllMemberIdSet(), 141198, 0, MessageMgr.getStringList(new Object[]{Properties.selectRolename(this.leverRoleId)}));
                                team.refreshAllAppliersWithSendProtocol(team.getTeamInfo().getTeamleaderid());
                                MessageMgr.psendMsgNotifyWhileCommit(this.leverRoleId, 141049, (List)null);
                                TeamManager.logger.info("SUCC:队伍中还存在其他在线成员,交换队长,再删除原队长，TeamId: " + leverTeamId);
                            } else {
                                PDisMissTeam pDisMissTeam = new PDisMissTeam(team.teamId, PDisMissTeam.REASON_LEADER_QUIT);
                                Procedure.pexecute(pDisMissTeam);
                                MessageMgr.psendMsgNotifyWhileCommit(this.leverRoleId, 141049, (List)null);
                                TeamManager.logger.info("SUCC:队伍中不存在其他在线成员,解散队伍,TeamId: " + leverTeamId);
                            }
                        } else {
                            TeamManager.logger.info("INFO:离开者不是队长,TeamId: " + leverTeamId);
                            if (!this.checkNormalLeverStatus(this.leverRoleId)) {
                                if (battleinfo != null) {
                                    battleinfo.getAbsentteamroleids().remove(this.leverRoleId);
                                    battleinfo.getQuitteamroleids().add(this.leverRoleId);
                                }
                            } else {
                                team.removeTeamMemberWithSP(this.leverRoleId, true);
                                MessageMgr.psendMsgNotifyWhileCommit(team.getAllMemberIdSet(), 141198, 0, MessageMgr.getStringList(new Object[]{Properties.selectRolename(this.leverRoleId)}));
                                MessageMgr.psendMsgNotifyWhileCommit(this.leverRoleId, 141049, (List)null);
                                TeamManager.logger.info("SUCC:从队伍中删除离队者,RoleId: " + this.leverRoleId);
                            }
                        }

                        Poster.getPoster().dispatchEvent(new LeaveTeamSpecialQuestEvent(this.leverRoleId));
                        return true;
                    }
                }
            }
        }
    }

    private static int checkPvP(long leverRoleId, boolean isLeader) {
        return PvPTeamHandle.onQuitTeamProc(leverRoleId, isLeader);
    }

    private boolean checkRoleIsLeader(long leverRoleId, Team team) {
        return team.getTeamInfo().getTeamleaderid() == leverRoleId;
    }

    private boolean checkLeadLeverStatus(long leverRoleId) {
        BuffAgent agent = new BuffRoleImpl(leverRoleId);
        return agent.canAddBuff(516004);
    }

    private boolean checkNormalLeverStatus(long leverRoleId) {
        BuffAgent agent = new BuffRoleImpl(leverRoleId);
        return agent.canAddBuff(516004);
    }

    public boolean switchTeamLeader(Team team) {
        TeamInfo teamInfo = team.getTeamInfo();
        if (teamInfo.getMembers().size() != 0 && ((TeamMember)teamInfo.getMembers().get(0)).getState() != 4) {
            long newLeaderId = ((TeamMember)teamInfo.getMembers().get(0)).getRoleid();
            teamInfo.setSwitchleaderid(-1L);
            long oldLeaderId = teamInfo.getTeamleaderid();
            TeamMember newMember = Pod.newTeamMember();
            newMember.setRoleid(oldLeaderId);
            newMember.setState(2);

            for(TeamMember member : teamInfo.getMembers()) {
                if (member.getState() == 3) {
                    member.setState(2);
                }
            }

            teamInfo.setTeamleaderid(newLeaderId);
            teamInfo.getMembers().set(0, newMember);
            if (oldLeaderId == teamInfo.getCommanderroleid()) {
                team.SetCommanderRoleId(newLeaderId);
            }

            return true;
        } else {
            return false;
        }
    }
}

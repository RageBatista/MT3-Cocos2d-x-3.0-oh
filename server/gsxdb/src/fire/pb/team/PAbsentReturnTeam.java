//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import fire.pb.battle.watch.PSendWatchBattle;
import fire.pb.event.ArriveTeamSpecialQuestEvent;
import fire.pb.event.LeaveTeamSpecialQuestEvent;
import fire.pb.event.Poster;
import fire.pb.talk.MessageMgr;
import java.util.ArrayList;
import java.util.List;
import mkdb.Procedure;
import xbean.BattleInfo;
import xbean.TeamInfo;
import xtable.Battle;
import xtable.Locks;
import xtable.Roleid2battleid;
import xtable.Roleid2teamid;
import xtable.Team;

public class PAbsentReturnTeam extends Procedure {
    private final long memberRoleId;
    private final long absent;

    public PAbsentReturnTeam(long roleid, int absent) {
        this.memberRoleId = roleid;
        this.absent = (long)absent;
    }

    protected boolean process() throws Exception {
        Long teamId = Roleid2teamid.select(this.memberRoleId);
        BattleInfo battleinfo = null;
        if (teamId != null) {
            Long battleid = Roleid2battleid.select(this.memberRoleId);
            if (battleid != null) {
                battleinfo = Battle.get(battleid);
                if (this.absent == 0L) {
                    MessageMgr.psendMsgNotify(this.memberRoleId, 162135, (List)null);
                } else {
                    MessageMgr.psendMsgNotify(this.memberRoleId, 162141, (List)null);
                }

                return true;
            } else {
                TeamInfo teaminfo = Team.get(teamId);
                if (teaminfo == null) {
                    return false;
                } else {
                    fire.pb.team.Team team = new fire.pb.team.Team(teamId, false);
                    if (!team.isInTeam(this.memberRoleId)) {
                        return true;
                    } else {
                        long leaderRoleId = team.getTeamInfo().getTeamleaderid();
                        List<Long> roleids = new ArrayList();
                        roleids.add(leaderRoleId);
                        roleids.add(this.memberRoleId);
                        this.lock(Locks.ROLELOCK, roleids);
                        if (!TeamManager.getInstance().checkOnline(this.memberRoleId)) {
                            TeamManager.logger.info("FAIL:成员不在线 , memberRoleId" + this.memberRoleId);
                        } else if (this.absent == 1L) {
                            if (team.getTeamMemberState(this.memberRoleId) == 2) {
                                TeamManager.logger.info("FAIL:队员已经处于暂离中 , memberRoleId" + this.memberRoleId);
                            } else if (!TeamManager.getInstance().checkMemberAbsentStatusValid(this.memberRoleId)) {
                                if (battleinfo != null) {
                                    battleinfo.getQuitteamroleids().remove(this.memberRoleId);
                                    battleinfo.getAbsentteamroleids().add(this.memberRoleId);
                                    MessageMgr.psendMsgNotify(this.memberRoleId, 160035, (List)null);
                                } else {
                                    TeamManager.logger.info("FAIL:成员处在不可暂离队伍的状态 , memberRoleId" + this.memberRoleId);
                                }
                            } else if (team.isTeamLeader(this.memberRoleId)) {
                                if (team.allMemberAbsent()) {
                                    TeamManager.logger.info("CAbsentReturnTeam:SUCC:所有成员都在暂离队长不能暂离了");
                                    return true;
                                }

                                if (team.passiveSwitchLeaderWithSP(2)) {
                                    TeamManager.logger.info("CAbsentReturnTeam:SUCC:队长暂离交换队长，TeamId: ");
                                }
                            } else {
                                team.setTeamMemberStateWithSP(this.memberRoleId, 2);
                                if (team.getTeamInfo().getSwitchleaderid() == this.memberRoleId) {
                                    team.getTeamInfo().setSwitchleaderid(0L);
                                    Procedure.psendWhileCommit(team.getTeamInfo().getTeamleaderid(), new STeamError(28));
                                }

                                TeamManager.getInstance().delTeamMatchAsyn(this.memberRoleId);
                                TeamManager.logger.info("SUCC:成员暂离队伍 , memberRoleId" + this.memberRoleId);
                            }

                            Poster.getPoster().dispatchEvent(new LeaveTeamSpecialQuestEvent(this.memberRoleId));
                        } else if (team.getTeamMemberState(this.memberRoleId) != 2 && team.getTeamMemberState(this.memberRoleId) != 3) {
                            TeamManager.logger.info("FAIL:队员不处于暂离中 , memberRoleId" + this.memberRoleId);
                        } else if (!TeamManager.getInstance().checkMemberReturnStatusValid(this.memberRoleId)) {
                            TeamManager.logger.info("FAIL:成员处在不可归队的状态 , memberRoleId" + this.memberRoleId);
                            MessageMgr.psendMsgNotify(this.memberRoleId, 141412, (List)null);
                        } else if (team.isMemberInReturnScale(this.memberRoleId)) {
                            if (TeamManager.getInstance().checkTeamInReturnState(team)) {
                                team.setTeamMemberStateWithSP(this.memberRoleId, 3);
                                MessageMgr.psendMsgNotifyWhileCommit(this.memberRoleId, 143867, (List)null);
                                TeamManager.logger.debugWhileCommit("SUCC:成员回归队伍 , memberRoleId" + this.memberRoleId);
                                if (TeamManager.getInstance().checkTeamInFightState(team)) {
                                    Procedure.pexecuteWhileCommit(new PSendWatchBattle(this.memberRoleId, team.getTeamLeaderId()));
                                }
                            } else {
                                if (!TeamManager.getInstance().checkTeamReturnStatusValid(team)) {
                                    TeamManager.logger.info("FAIL: 队伍处于不可归队的状态，teamId" + teamId);
                                    return true;
                                }

                                team.setTeamMemberStateWithSP(this.memberRoleId, 1);
                                Poster.getPoster().dispatchEvent(new ArriveTeamSpecialQuestEvent(team.getTeamLeaderId(), this.memberRoleId));
                                TeamManager.logger.debugWhileCommit("SUCC:队伍处在可以归队的状态，改变队员为正常状态 , memberRoleId" + this.memberRoleId);
                            }
                        } else {
                            psend(this.memberRoleId, new STeamError(26));
                            MessageMgr.psendMsgNotify(this.memberRoleId, 141205, (List)null);
                            TeamManager.logger.info("FAIL:在回归范围之外 , memberRoleId" + this.memberRoleId);
                        }

                        return true;
                    }
                }
            }
        } else {
            return true;
        }
    }
}

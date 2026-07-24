//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import fire.pb.PropRole;
import fire.pb.StateCommon;
import fire.pb.battle.pvp.PvPTeamHandle;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;
import fire.pb.event.ArriveTeamSpecialQuestEvent;
import fire.pb.event.Poster;
import fire.pb.main.ConfigManager;
import fire.pb.map.MapConfig;
import fire.pb.map.Role;
import fire.pb.map.RoleManager;
import fire.pb.talk.MessageMgr;
import java.util.ArrayList;
import java.util.List;
import mkdb.Procedure;
import xbean.Properties;
import xbean.TeamInfo;
import xtable.Locks;
import xtable.Roleid2teamid;
import xtable.Team;

public class PAcceptToTeam extends Procedure {
    private final long leaderRoleId;
    private final long applierRoleId;
    private final int accept;
    private final boolean needapply;
    private boolean needCheck;

    public boolean isNeedCheck() {
        return this.needCheck;
    }

    public void setNeedCheck(boolean needCheck) {
        this.needCheck = needCheck;
    }

    public PAcceptToTeam(long leaderRoleId, long applierRoleId, int accept, boolean needaapply) {
        this.leaderRoleId = leaderRoleId;
        this.applierRoleId = applierRoleId;
        this.accept = accept;
        this.needapply = needaapply;
        this.needCheck = true;
    }

    public PAcceptToTeam(long leaderRoleId, long applierRoleId, int accept, boolean needaapply, boolean needCheck) {
        this.leaderRoleId = leaderRoleId;
        this.applierRoleId = applierRoleId;
        this.accept = accept;
        this.needapply = needaapply;
        this.needCheck = needCheck;
    }

    protected boolean process() throws Exception {
        Long teamId = Roleid2teamid.select(this.leaderRoleId);
        if (teamId == null) {
            return true;
        } else {
            TeamInfo teamInfo = Team.get(teamId);
            if (teamInfo == null) {
                return true;
            } else {
                fire.pb.team.Team team = new fire.pb.team.Team(teamId, false);
                if (!team.isTeamLeader(this.leaderRoleId)) {
                    return true;
                } else {
                    if (this.accept == 1) {
                        ArrayList<Long> roleids = new ArrayList();
                        roleids.addAll(team.getAllMemberIds());
                        roleids.add(this.applierRoleId);
                        this.lock(Locks.ROLELOCK, roleids);
                    }

                    if (this.applierRoleId != 0L) {
                        if (this.accept == 0) {
                            team.removeTeamApplyWithSendProtocol(this.applierRoleId);
                            PropRole prole = new PropRole(team.getTeamInfo().getTeamleaderid(), true);
                            List<String> name = new ArrayList();
                            name.add(prole.getName());
                            MessageMgr.psendMsgNotifyWhileCommit(this.applierRoleId, 140640, name);
                            return true;
                        } else {
                            team.removeTimeoutTeamApplys();
                            PropRole prole = new PropRole(this.applierRoleId, true);
                            if (!this.checkOnline(this.applierRoleId)) {
                                team.removeTeamApplyWithSendProtocol(this.applierRoleId);
                                MessageMgr.sendMsgNotify(this.leaderRoleId, 160215, (List)null);
                                TeamManager.logger.info("FAIL:PAcceptToTeam:申请者不在线, applierRoleId" + this.applierRoleId);
                                return true;
                            } else if (!this.checkApplierNotInTeam(this.applierRoleId)) {
                                team.removeTeamApplyWithSendProtocol(this.applierRoleId);
                                psend(this.leaderRoleId, new STeamError(3));
                                TeamManager.logger.info("FAIL:PAcceptToTeam:申请者已经在队伍中, applierRoleId" + this.applierRoleId);
                                return true;
                            } else if (!this.checkApplierStatusValid(this.applierRoleId)) {
                                team.removeTeamApplyWithSendProtocol(this.applierRoleId);
                                MessageMgr.psendMsgNotify(this.leaderRoleId, 141619, (List)null);
                                TeamManager.logger.info("FAIL:PAcceptToTeam:申请者处于不可以组队的状态, applierRoleId" + this.applierRoleId);
                                return true;
                            } else if (!this.checkTeamExist(team, this.leaderRoleId)) {
                                TeamManager.logger.info("FAIL:PAcceptToTeam:玩家不是一个队伍的队长, leaderRoleId" + this.leaderRoleId);
                                return true;
                            } else if (!this.checkTeamNotFull(team)) {
                                psend(this.leaderRoleId, new STeamError(11));
                                TeamManager.logger.info("FAIL:PAcceptToTeam:队伍人数已满, teamId" + teamId);
                                return true;
                            } else if (this.needapply && !team.getTeamInfo().getApplierids().containsKey(this.applierRoleId)) {
                                MessageMgr.psendMsgNotifyWhileRollback(this.leaderRoleId, 150174, (List)null);
                                SRemoveTeamApply sRemoveTeamApply = new SRemoveTeamApply();
                                sRemoveTeamApply.applyids.add(this.applierRoleId);
                                psend(team.getTeamInfo().getTeamleaderid(), sRemoveTeamApply);
                                TeamManager.logger.info("PAcceptToTeam:申请者不在队伍的申请列表中,或者申请超时, teamId" + teamId);
                                return true;
                            } else if (!this.checkMap()) {
                                MessageMgr.psendMsgNotifyWhileRollback(this.leaderRoleId, 145050, (List)null);
                                return true;
                            } else if (checkPvP(this.leaderRoleId, this.applierRoleId) != 0) {
                                return true;
                            } else {
                                team.removeTeamApplyWithSendProtocol(this.applierRoleId);
                                TeamManager.logger.debugWhileCommit("SUCC：PAcceptToTeam:加入申请者, teamId" + teamId);
                                boolean ok = team.addNewMemberWithSP(this.applierRoleId);
                                if (ok) {
                                    int ret = TeamManager.getInstance().execGotoLeader(this.applierRoleId, team, true, 2);
                                    if (ret == 0) {
                                        Properties applierprop = xtable.Properties.get(this.applierRoleId);
                                        List<String> params = new ArrayList();
                                        params.add(applierprop.getRolename());
                                        MessageMgr.sendMsgNotify(this.leaderRoleId, 160196, params);
                                    }
                                }

                                Poster.getPoster().dispatchEvent(new ArriveTeamSpecialQuestEvent(this.leaderRoleId, this.applierRoleId));
                                if (team.isAbsentMember(this.applierRoleId)) {
                                    List<String> p = new ArrayList();
                                    p.add(prole.getName());
                                    MessageMgr.psendMsgNotifyWhileCommit(this.leaderRoleId, 150121, p);
                                }

                                return ok;
                            }
                        }
                    } else {
                        SRemoveTeamApply sRemoveTeamApply = new SRemoveTeamApply();

                        for(long roleId : team.getTeamInfo().getApplierids().keySet()) {
                            sRemoveTeamApply.applyids.add(roleId);
                        }

                        psendWhileCommit(team.getTeamInfo().getTeamleaderid(), sRemoveTeamApply);
                        team.getTeamInfo().getApplierids().clear();
                        return true;
                    }
                }
            }
        }
    }

    private boolean checkMap() {
        boolean inWaiting1 = false;
        boolean inWaiting = false;
        Role invitMaprole = RoleManager.getInstance().getRoleByID(this.leaderRoleId);
        Role desMaprole = RoleManager.getInstance().getRoleByID(this.applierRoleId);
        if (invitMaprole != null && desMaprole != null) {
            int srcMapId = invitMaprole.getMapId();
            MapConfig cfg = (MapConfig)ConfigManager.getInstance().getConf(MapConfig.class).get(srcMapId);
            int desMapId = desMaprole.getMapId();
            MapConfig descfg = (MapConfig)ConfigManager.getInstance().getConf(MapConfig.class).get(desMapId);
            if (!inWaiting && !inWaiting1) {
                if (cfg != null && descfg != null) {
                    return cfg.getSafemap() == descfg.getSafemap() && cfg.getSafemap() == 1 ? true : true;
                } else {
                    return true;
                }
            } else {
                return false;
            }
        } else {
            return true;
        }
    }

    private static int checkPvP(long leaderRoleId, long applierRoleId) {
        return PvPTeamHandle.onAcceptToTeam(leaderRoleId, applierRoleId);
    }

    private boolean checkOnline(long roleId) {
        return StateCommon.isOnline(roleId);
    }

    private boolean checkApplierNotInTeam(long applierRoleId) {
        return Roleid2teamid.get(applierRoleId) == null;
    }

    private boolean checkApplierStatusValid(long applierRoleId) {
        BuffAgent buffagent = new BuffRoleImpl(applierRoleId, true);
        if (!buffagent.canAddBuff(507006)) {
            TeamManager.logger.info("玩家(roleId=" + applierRoleId + ")处于不能组队的状态");
            return false;
        } else {
            return true;
        }
    }

    private boolean checkTeamExist(fire.pb.team.Team team, long leaderRoleId) {
        TeamInfo teamInfo = team.getTeamInfo();
        return teamInfo.getTeamleaderid() == leaderRoleId;
    }

    private boolean checkTeamNotFull(fire.pb.team.Team team) {
        return team.getTeamInfo().getMembers().size() < 4;
    }
}

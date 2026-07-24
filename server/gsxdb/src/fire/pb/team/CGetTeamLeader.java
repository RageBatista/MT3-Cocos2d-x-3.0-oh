//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.StateCommon;
import fire.pb.battle.pvp.PvPTeamHandle;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;
import fire.pb.item.Pack;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import gnet.link.Role;
import java.util.Arrays;
import java.util.List;
import mkdb.Lockeys;
import mkdb.Procedure;
import xbean.TeamMember;
import xtable.Locks;
import xtable.Roleid2teamid;

public class CGetTeamLeader extends __CGetTeamLeader__ {
    private long now = 0L;
    Team team;
    public static final int PROTOCOL_TYPE = 794450;
    public long roleid;

    protected void process() {
        TeamManager.logger.debug("Enter: " + this.getClass());
        final long roleid1 = Onlines.getInstance().findRoleid(this);
        if (roleid1 >= 0L) {
            final long roleid2 = this.roleid;
            Procedure submit = new Procedure() {
                protected boolean process() {
                    Long teamId = Roleid2teamid.select(roleid1);
                    if (teamId != null) {
                        CGetTeamLeader.this.team = new Team(teamId, false);
                        if (!CGetTeamLeader.this.team.isInTeam(roleid2)) {
                            return true;
                        } else {
                            Long[] roleids = new Long[2];
                            if (roleid1 < roleid2) {
                                roleids[0] = roleid1;
                                roleids[1] = roleid2;
                            } else {
                                roleids[0] = roleid2;
                                roleids[1] = roleid1;
                            }

                            this.lock(Lockeys.get(Locks.ROLELOCK, roleids));
                            CGetTeamLeader.this.now = System.currentTimeMillis();
                            Role currentLeaderRole = Onlines.getInstance().find(roleid2);
                            if (!currentLeaderRole.isOnline()) {
                                Pack applicantPack = new Pack(roleid1, false);
                                if (applicantPack.getCurrency(2) < 1000L) {
                                    MessageMgr.psendMsgNotifyWhileRollback(roleid1, 146502, Arrays.<String>asList("见过寒碜的，但没见过你这么寒碜的！先准备1000两黄金吧！"));
                                    return false;
                                } else {
                                    long deductResult = applicantPack.subGold(-1000L, "强行申请队长", YYLoggerTuJingEnum.tujing_Value_zhuanpan, 0);
                                    if (deductResult == 0L) {
                                        MessageMgr.psendMsgNotifyWhileRollback(roleid1, 146502, Arrays.<String>asList("遇到了一些意外情况！"));
                                        return false;
                                    } else {
                                        if (CGetTeamLeader.this.team.switchTeamLeaderWithSP(roleid1)) {
                                            CGetTeamLeader.this.team.getTeamInfo().setSuccessswitchtime(CGetTeamLeader.this.now);
                                            MessageMgr.psendMsgNotifyWhileCommit(roleid1, 146502, Arrays.<String>asList("你小子运气不错，别人几十年才能当上队长，你这么年轻就能当上队长了！扣除1000两黄金"));
                                        }

                                        return true;
                                    }
                                }
                            } else if (CGetTeamLeader.checkPvP(roleid1, roleid2) != 0) {
                                return true;
                            } else {
                                if (!CGetTeamLeader.this.checkLeaderOnline(roleid1)) {
                                    TeamManager.logger.debug("FAIL:申请者不在线,LeaderID: " + roleid1);
                                } else if (!CGetTeamLeader.this.checkTeamStatusValid(CGetTeamLeader.this.team)) {
                                    TeamManager.logger.debug("FAIL:队伍处于不可以换队长的状态（例如飞行、战斗）,teamId: " + teamId);
                                } else if (!CGetTeamLeader.this.checkTeamNotInSwitchStatus(CGetTeamLeader.this.team)) {
                                    MessageMgr.psendMsgNotify(roleid1, 141210, (List)null);
                                    TeamManager.logger.debug("FAIL:队伍处于更换队长申请状态,teamId: " + teamId);
                                } else if (!CGetTeamLeader.this.checkTeamNoSuccSwitchIn2min(CGetTeamLeader.this.team)) {
                                    MessageMgr.psendMsgNotify(roleid1, 141209, (List)null);
                                    TeamManager.logger.debug("FAIL:队伍2分钟内成功更换过队长,teamId: " + teamId);
                                } else {
                                    BuffRoleImpl buffRole = new BuffRoleImpl(roleid2);
                                    if (!((BuffAgent)buffRole).canAddBuff(507007)) {
                                        TeamManager.logger.debug("FAIL:新队长处于不能当队长的状态,newLeaderRoleId: " + roleid2);
                                    } else {
                                        TeamManager.logger.debug("SUCC:可以发出更换队长邀请,teamId: " + teamId);
                                        CGetTeamLeader.this.team.getTeamInfo().setSwitchleaderid(roleid1);
                                        CGetTeamLeader.this.team.getTeamInfo().setSwitchleadertime(CGetTeamLeader.this.now);
                                        SAskforGetLeader sAskforGetLeader = new SAskforGetLeader();
                                        sAskforGetLeader.leaderid = roleid1;
                                        TeamManager.getInstance().delTeamMatch(roleid2);
                                        System.out.println("老队长id : " + roleid2);
                                        System.out.println("新队长id : " + roleid2);
                                        psendWhileCommit(roleid2, new SRequestSetLeaderSucc(roleid2));
                                        psendWhileCommit(roleid2, sAskforGetLeader);
                                        MessageMgr.psendMsgNotifyWhileCommit(roleid2, 141251, (List)null);
                                    }
                                }

                                return true;
                            }
                        }
                    } else {
                        return true;
                    }
                }
            };
            submit.submit();
        }

    }

    private static int checkPvP(long applicantRoleId, long leaderRoleId) {
        return PvPTeamHandle.onSetTeamLeader(applicantRoleId, leaderRoleId);
    }

    private boolean checkLeaderOnline(long roleid) {
        return StateCommon.isOnline(roleid);
    }

    private boolean checkTeamStatusValid(Team team) {
        BuffRoleImpl buffRole = new BuffRoleImpl(team.getTeamLeaderId());
        int result = ((BuffAgent)buffRole).checkCanAddBuff(507007);
        return result == 0;
    }

    private boolean checkTeamNotInSwitchStatus(Team team) {
        if (team.getTeamInfo().getSwitchleaderid() == -1L) {
            return true;
        } else if (this.now - team.getTeamInfo().getSwitchleadertime() > 20000L) {
            team.getTeamInfo().setSwitchleaderid(-1L);
            return true;
        } else {
            return false;
        }
    }

    private boolean checkTeamNoSuccSwitchIn2min(Team team) {
        return this.now - team.getTeamInfo().getSuccessswitchtime() > 500L;
    }

    private boolean checkNewLeaderNormal(Team team, long roleid) {
        for(TeamMember member : team.getTeamInfo().getMembers()) {
            if (member.getRoleid() == roleid) {
                if (member.getState() == 2) {
                    return false;
                }

                return true;
            }
        }

        return false;
    }

    public int getType() {
        return 794450;
    }

    public CGetTeamLeader() {
    }

    public CGetTeamLeader(long roleid) {
        this.roleid = roleid;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream os) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            os.marshal(this.roleid);
            return os;
        }
    }

    public OctetsStream unmarshal(OctetsStream os) throws MarshalException {
        this.roleid = os.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return os;
        }
    }

    public boolean equals(Object obj) {
        if (obj == this) {
            return true;
        } else if (obj instanceof CGetTeamLeader) {
            CGetTeamLeader other = (CGetTeamLeader)obj;
            return this.roleid == other.roleid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int hash = 0;
        hash += (int)this.roleid;
        return hash;
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("(");
        sb.append(this.roleid).append(",");
        sb.append(")");
        return sb.toString();
    }

    public int compareTo(CGetTeamLeader other) {
        if (other == this) {
            return 0;
        } else {
            int cmp = Long.signum(this.roleid - other.roleid);
            return cmp != 0 ? cmp : cmp;
        }
    }
}

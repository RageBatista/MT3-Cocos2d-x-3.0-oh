//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.StateCommon;
import fire.pb.battle.pvp.PvPTeamHandle;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import mkdb.Lockeys;
import mkdb.Procedure;
import xbean.TeamMember;
import xtable.Locks;
import xtable.Roleid2teamid;

public class CSetTeamLeader1 extends __CSetTeamLeader1__ {
    private long now = 0L;
    Team team;
    public static final int PROTOCOL_TYPE = 820500;
    public long roleid;

    protected void process() {
        TeamManager.logger.debug("Enter: " + this.getClass());
        final long oldLeaderRoleId = Onlines.getInstance().findRoleid(this);
        if (oldLeaderRoleId >= 0L) {
            final long newLeaderRoleId = this.roleid;
            Procedure setTeamLeaderP = new Procedure() {
                protected boolean process() {
                    Long teamId = Roleid2teamid.select(oldLeaderRoleId);
                    CSetTeamLeader1.this.team = new Team(teamId, false);
                    Set<Long> roleIds = CSetTeamLeader1.this.team.getAllMemberIdSet();
                    ArrayList<Long> list = new ArrayList(roleIds);
                    if (teamId != null) {
                        CSetTeamLeader1.this.team = new Team(teamId, false);
                        if (!CSetTeamLeader1.this.team.isTeamLeader((Long)list.get(0))) {
                            return true;
                        } else if (!CSetTeamLeader1.this.team.isInTeam(newLeaderRoleId)) {
                            return true;
                        } else {
                            Long[] roleids = new Long[2];
                            if ((Long)list.get(0) < newLeaderRoleId) {
                                roleids[0] = (Long)list.get(0);
                                roleids[1] = newLeaderRoleId;
                            } else {
                                roleids[0] = newLeaderRoleId;
                                roleids[1] = (Long)list.get(0);
                            }

                            this.lock(Lockeys.get(Locks.ROLELOCK, roleids));
                            CSetTeamLeader1.this.now = System.currentTimeMillis();
                            if (CSetTeamLeader1.checkPvP((Long)list.get(0), newLeaderRoleId) != 0) {
                                System.out.println(1111);
                                return true;
                            } else {
                                if (!CSetTeamLeader1.this.checkTeamStatusValid(CSetTeamLeader1.this.team)) {
                                    TeamManager.logger.debug("FAIL:队伍处于不可以换队长的状态（例如飞行、战斗）,teamId: " + teamId);
                                } else if (!CSetTeamLeader1.this.checkTeamNotInSwitchStatus(CSetTeamLeader1.this.team)) {
                                    MessageMgr.psendMsgNotify((Long)list.get(0), 141210, (List)null);
                                    TeamManager.logger.debug("FAIL:队伍处于更换队长申请状态,teamId: " + teamId);
                                } else if (!CSetTeamLeader1.this.checkTeamNoSuccSwitchIn2min(CSetTeamLeader1.this.team)) {
                                    MessageMgr.psendMsgNotify((Long)list.get(0), 141209, (List)null);
                                    TeamManager.logger.debug("FAIL:队伍2分钟内成功更换过队长,teamId: " + teamId);
                                } else if (!CSetTeamLeader1.this.checkNewLeaderNormal(CSetTeamLeader1.this.team, newLeaderRoleId)) {
                                    psend(newLeaderRoleId, new STeamError(25));
                                    TeamManager.logger.debug("FAIL:新队长不处于正常状态,newLeaderRoleId: " + newLeaderRoleId);
                                } else if (StateCommon.isTrusteeshipState(newLeaderRoleId)) {
                                    MessageMgr.psendMsgNotify((Long)list.get(0), 160408, (List)null);
                                } else {
                                    BuffAgent buffagent = new BuffRoleImpl(newLeaderRoleId);
                                    if (!buffagent.canAddBuff(507007)) {
                                        TeamManager.logger.debug("FAIL:新队长处于不能当队长的状态,newLeaderRoleId: " + newLeaderRoleId);
                                    } else {
                                        TeamManager.logger.debug("SUCC:可以发出更换队长邀请,teamId: " + teamId);
                                        CSetTeamLeader1.this.team.getTeamInfo().setSwitchleaderid(newLeaderRoleId);
                                        CSetTeamLeader1.this.team.getTeamInfo().setSwitchleadertime(CSetTeamLeader1.this.now);
                                        SAskforSetLeader sAskforSetLeader = new SAskforSetLeader();
                                        sAskforSetLeader.leaderid = (Long)list.get(0);
                                        TeamManager.getInstance().delTeamMatch((Long)list.get(0));
                                        psendWhileCommit((Long)list.get(0), new SRequestSetLeaderSucc(newLeaderRoleId));
                                        psendWhileCommit(newLeaderRoleId, sAskforSetLeader);
                                        MessageMgr.psendMsgNotifyWhileCommit((Long)list.get(0), 141251, (List)null);
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
            setTeamLeaderP.submit();
        }
    }

    private static int checkPvP(long oldLeaderRoleId, long newLeaderRoleId) {
        return PvPTeamHandle.onSetTeamLeader(oldLeaderRoleId, newLeaderRoleId);
    }

    private boolean checkLeaderOnline(long leaderRoleId) {
        return StateCommon.isOnline(leaderRoleId);
    }

    private boolean checkTeamStatusValid(Team team) {
        BuffAgent buffagent = new BuffRoleImpl(team.getTeamLeaderId());
        int conflictId = buffagent.checkCanAddBuff(507007);
        return conflictId == 0;
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

    private boolean checkNewLeaderNormal(Team team, long memberRoleId) {
        for(TeamMember member : team.getTeamInfo().getMembers()) {
            if (member.getRoleid() == memberRoleId) {
                if (member.getState() == 2) {
                    return false;
                }

                return true;
            }
        }

        return false;
    }

    public int getType() {
        return 820500;
    }

    public CSetTeamLeader1() {
    }

    public CSetTeamLeader1(long _roleid_) {
        this.roleid = _roleid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.roleid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CSetTeamLeader1) {
            CSetTeamLeader1 _o_ = (CSetTeamLeader1)_o1_;
            return this.roleid == _o_.roleid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CSetTeamLeader1 _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.roleid - _o_.roleid);
            return _c_ != 0 ? _c_ : _c_;
        }
    }
}

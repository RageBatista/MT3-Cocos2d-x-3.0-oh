//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.PropRole;
import fire.pb.StateCommon;
import fire.pb.battle.pvp.PvPTeamHandle;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;
import fire.pb.event.LeaveTeamSpecialQuestEvent;
import fire.pb.event.Poster;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.List;
import mkdb.Lockeys;
import mkdb.Procedure;
import xbean.TeamMember;
import xtable.Locks;
import xtable.Roleid2teamid;

public class CExpelMember extends __CExpelMember__ {
    Team team;
    public static final int PROTOCOL_TYPE = 794442;
    public long roleid;

    protected void process() {
        TeamManager.logger.debug("Enter: " + this.getClass());
        final long leaderRoleId = Onlines.getInstance().findRoleid(this);
        if (leaderRoleId >= 0L) {
            final long expeledRoleId = this.roleid;
            Procedure expelMemberP = new Procedure() {
                protected boolean process() {
                    Long teamId = Roleid2teamid.select(leaderRoleId);
                    if (teamId == null) {
                        return true;
                    } else {
                        CExpelMember.this.team = new Team(teamId, false);
                        if (!CExpelMember.this.team.isTeamLeader(leaderRoleId)) {
                            return true;
                        } else {
                            Long[] roleids = new Long[2];
                            if (leaderRoleId < expeledRoleId) {
                                roleids[0] = leaderRoleId;
                                roleids[1] = expeledRoleId;
                            } else {
                                roleids[0] = expeledRoleId;
                                roleids[1] = leaderRoleId;
                            }

                            this.lock(Lockeys.get(Locks.ROLELOCK, (Object[])roleids));
                            if (CExpelMember.checkPvP(leaderRoleId, expeledRoleId) != 0) {
                                return true;
                            } else {
                                if (!CExpelMember.this.checkLeaderInTeam(leaderRoleId, CExpelMember.this.team)) {
                                    TeamManager.logger.debug("FAIL:踢人者不在队伍中或者不是队长,踢人者Id: " + leaderRoleId);
                                } else if (!CExpelMember.this.checkLeaderOnline(leaderRoleId)) {
                                    TeamManager.logger.debug("FAIL:踢人者不在线,踢人者Id: " + leaderRoleId);
                                } else if (!CExpelMember.this.checkExpeledIsMember(CExpelMember.this.team, expeledRoleId)) {
                                    TeamManager.logger.debug("FAIL:被踢者不是踢人者队伍成员,被踢者Id: " + expeledRoleId);
                                } else if (!CExpelMember.this.checkTeamLeaderState(leaderRoleId)) {
                                    TeamManager.logger.debug("FAIL:队伍状态不允许,被踢者Id: " + expeledRoleId);
                                } else {
                                    CExpelMember.this.team.removeTeamMemberWithSP(expeledRoleId, false);
                                    PropRole prole = new PropRole(CExpelMember.this.team.getTeamInfo().getTeamleaderid(), true);
                                    List<String> name = new ArrayList();
                                    name.add(prole.getName());
                                    MessageMgr.psendMsgNotifyWhileCommit(expeledRoleId, 140641, name);
                                    PropRole expelrole = new PropRole(expeledRoleId, true);
                                    List<String> expelname = new ArrayList();
                                    expelname.add(expelrole.getName());

                                    for(long memberId : CExpelMember.this.team.getAllMemberIds()) {
                                        MessageMgr.psendMsgNotifyWhileCommit(memberId, 141208, expelname);
                                    }

                                    TeamManager.logger.debug("SUCC:队伍踢人,被踢者Id: " + expeledRoleId);
                                }

                                Poster.getPoster().dispatchEvent(new LeaveTeamSpecialQuestEvent(expeledRoleId));
                                return true;
                            }
                        }
                    }
                }
            };
            expelMemberP.submit();
        }
    }

    private static int checkPvP(long leaderRoleId, long expeledRoleId) {
        return PvPTeamHandle.onExpelMember(leaderRoleId, expeledRoleId);
    }

    private boolean checkLeaderInTeam(long leaderRoleId, Team team) {
        return team.getTeamInfo() != null && team.getTeamInfo().getTeamleaderid() == leaderRoleId;
    }

    private boolean checkLeaderOnline(long leaderRoleId) {
        return StateCommon.isOnline(leaderRoleId);
    }

    private boolean checkExpeledIsMember(Team team, long expeledRoleId) {
        for(TeamMember member : team.getTeamInfo().getMembers()) {
            if (member.getRoleid() == expeledRoleId) {
                return true;
            }
        }

        return false;
    }

    private boolean checkTeamLeaderState(long roleId) {
        BuffAgent buffagent = new BuffRoleImpl(roleId);
        return buffagent.canAddBuff(516002);
    }

    public int getType() {
        return 794442;
    }

    public CExpelMember() {
    }

    public CExpelMember(long _roleid_) {
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
        } else if (_o1_ instanceof CExpelMember) {
            CExpelMember _o_ = (CExpelMember)_o1_;
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

    public int compareTo(CExpelMember _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.roleid - _o_.roleid);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}

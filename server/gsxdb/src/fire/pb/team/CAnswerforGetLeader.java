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
import java.util.List;
import mkdb.Lockeys;
import mkdb.Procedure;
import xbean.TeamMember;
import xtable.Locks;
import xtable.Roleid2teamid;

public class CAnswerforGetLeader extends __CAnswerforGetLeader__ {
    private long now = 0L;
    Team team;
    public static final int PROTOCOL_TYPE = 794473;
    public byte agree;
    public long role;

    protected void process() {
        TeamManager.logger.debug("Enter: " + this.getClass());
        System.out.println("role :" + this.role);
        final long newLeaderRoleId = this.role;
        if (newLeaderRoleId >= 0L) {
            Procedure getTeamLeaderP = new Procedure() {
                protected boolean process() {
                    Long teamId = Roleid2teamid.select(newLeaderRoleId);
                    CAnswerforGetLeader.this.now = System.currentTimeMillis();
                    if (teamId != null) {
                        CAnswerforGetLeader.this.team = new Team(teamId, false);
                        long oldLeaderRoleId = CAnswerforGetLeader.this.team.getTeamInfo().getTeamleaderid();
                        if (!CAnswerforGetLeader.this.team.isInTeam(newLeaderRoleId)) {
                            TeamManager.logger.debug("回应者不是一个队伍的队员, newLeaderRoleId: " + newLeaderRoleId);
                            MessageMgr.psendMsgNotifyWhileCommit(newLeaderRoleId, 141056, (List)null);
                            psend(oldLeaderRoleId, new STeamError(31));
                            return true;
                        } else {
                            Long[] roleids = new Long[2];
                            if (oldLeaderRoleId < newLeaderRoleId) {
                                roleids[0] = oldLeaderRoleId;
                                roleids[1] = newLeaderRoleId;
                            } else {
                                roleids[0] = newLeaderRoleId;
                                roleids[1] = oldLeaderRoleId;
                            }

                            this.lock(Lockeys.get(Locks.ROLELOCK, roleids));
                            if (CAnswerforGetLeader.this.agree == 0) {
                                if (!CAnswerforGetLeader.this.checkAnwserIsNewLeader(CAnswerforGetLeader.this.team, newLeaderRoleId)) {
                                    TeamManager.logger.debug("FAIL:回应者不是要任命的新队长, teamId: " + teamId);
                                    psend(newLeaderRoleId, new STeamError(31));
                                    return true;
                                } else {
                                    CAnswerforGetLeader.this.team.getTeamInfo().setSwitchleaderid(-1L);
                                    CAnswerforGetLeader.this.team.getTeamInfo().setSwitchleadertime(-1L);
                                    psend(newLeaderRoleId, new STeamError(28));
                                    TeamManager.logger.debug("SUCC:拒绝成为队长, roleid: " + newLeaderRoleId);
                                    return true;
                                }
                            } else if (CAnswerforGetLeader.checkPvP(oldLeaderRoleId, newLeaderRoleId) != 0) {
                                return true;
                            } else {
                                if (!CAnswerforGetLeader.this.checkLeaderOnline(newLeaderRoleId)) {
                                    TeamManager.logger.debug("FAIL:回应者不在线, roleid: " + newLeaderRoleId);
                                } else if (!CAnswerforGetLeader.this.checkTeamStatusValid(CAnswerforGetLeader.this.team)) {
                                    TeamManager.logger.debug("FAIL:队伍处于不可换队长状态（飞行或战斗不能）, teamId: " + teamId);
                                } else if (!CAnswerforGetLeader.this.checkAnwserIsNewLeader(CAnswerforGetLeader.this.team, newLeaderRoleId)) {
                                    TeamManager.logger.debug("FAIL:回应者不是要任命的新队长, teamId: " + teamId);
                                } else if (CAnswerforGetLeader.this.team.switchTeamLeaderWithSP(newLeaderRoleId)) {
                                    CAnswerforGetLeader.this.team.getTeamInfo().setSuccessswitchtime(CAnswerforGetLeader.this.now);
                                    TeamManager.logger.debugWhileCommit("SUCC:队伍更换队长, teamId: " + teamId);
                                } else {
                                    TeamManager.logger.debug("FAIL:队伍更换队长失败, teamId: " + teamId);
                                }

                                return true;
                            }
                        }
                    } else {
                        return true;
                    }
                }
            };
            getTeamLeaderP.submit();
        }
    }

    private static int checkPvP(long oldLeaderRoleId, long newLeaderRoleId) {
        return PvPTeamHandle.onAnswerforSetLeader(oldLeaderRoleId, newLeaderRoleId);
    }

    private boolean checkLeaderOnline(long leaderRoleId) {
        return StateCommon.isOnline(leaderRoleId);
    }

    private boolean checkNewLeaderNormal(Team team, long memberRoleId) {
        for(TeamMember member : team.getTeamInfo().getMembers()) {
            if (member.getRoleid() == memberRoleId && member.getState() == 1) {
                return true;
            }
        }

        return false;
    }

    private boolean checkTeamStatusValid(Team team) {
        BuffAgent agent = new BuffRoleImpl(team.getTeamLeaderId(), true);
        int conflictId = agent.checkCanAddBuff(507007);
        return conflictId == 0;
    }

    private boolean checkTeamInSwitchStatus(Team team) {
        if (team.getTeamInfo().getSwitchleaderid() == -1L) {
            return false;
        } else if (this.now - team.getTeamInfo().getSwitchleadertime() > 20000L) {
            team.getTeamInfo().setSwitchleaderid(-1L);
            return false;
        } else {
            return true;
        }
    }

    private boolean checkAnwserIsNewLeader(Team team, long newLeaderId) {
        return team.getTeamInfo().getSwitchleaderid() == newLeaderId;
    }

    private boolean checkTeamNoSuccSwitchIn2min(Team team) {
        return this.now - team.getTeamInfo().getSuccessswitchtime() > 500L;
    }

    public int getType() {
        return 794473;
    }

    public CAnswerforGetLeader() {
    }

    public CAnswerforGetLeader(byte _agree_, long _role_) {
        this.agree = _agree_;
        this.role = _role_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.agree);
            _os_.marshal(this.role);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.agree = _os_.unmarshal_byte();
        this.role = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CAnswerforGetLeader) {
            CAnswerforGetLeader _o_ = (CAnswerforGetLeader)_o1_;
            if (this.agree != _o_.agree) {
                return false;
            } else {
                return this.role == _o_.role;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.agree;
        _h_ += (int)this.role;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.agree).append(",");
        _sb_.append(this.role).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CAnswerforGetLeader _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.agree - _o_.agree;
            if (_c_ != 0) {
                return _c_;
            } else {
                _c_ = Long.signum(this.role - _o_.role);
                return _c_ != 0 ? _c_ : _c_;
            }
        }
    }
}

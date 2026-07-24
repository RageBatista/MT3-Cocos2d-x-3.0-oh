//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.StateCommon;
import gnet.link.Onlines;
import mkdb.Lockeys;
import mkdb.Procedure;
import xtable.Locks;
import xtable.Roleid2teamid;

public class CRequestSetTeamLevel extends __CRequestSetTeamLevel__ {
    Team team;
    public static final int PROTOCOL_TYPE = 794462;
    public int minlevel;
    public int maxlevel;

    protected void process() {
        TeamManager.logger.debug("Enter: " + this.getClass());
        final long leaderRoleId = Onlines.getInstance().findRoleid(this);
        if (leaderRoleId >= 0L) {
            Procedure setTeamLevelP = new Procedure() {
                protected boolean process() {
                    Long teamId = Roleid2teamid.select(leaderRoleId);
                    if (teamId != null) {
                        CRequestSetTeamLevel.this.team = new Team(teamId, false);
                        if (!CRequestSetTeamLevel.this.team.isTeamLeader(leaderRoleId)) {
                            return true;
                        } else {
                            Long[] roleids = new Long[1];
                            roleids[0] = leaderRoleId;
                            this.lock(Lockeys.get(Locks.ROLELOCK, (Object[])roleids));
                            if (!CRequestSetTeamLevel.this.checkOnline(leaderRoleId)) {
                                TeamManager.logger.debug("FAIL:设置者不在线,roleid: " + leaderRoleId);
                            } else if (!CRequestSetTeamLevel.this.checkSetedLevelValid(CRequestSetTeamLevel.this.minlevel, CRequestSetTeamLevel.this.maxlevel)) {
                                TeamManager.logger.debug("FAIL:设置的等级不合法,minlevel: " + CRequestSetTeamLevel.this.minlevel + " ;maxlevel: " + CRequestSetTeamLevel.this.maxlevel);
                            } else {
                                TeamManager.logger.debug("SUCC:可以设置队伍等级要求, minlevel: " + CRequestSetTeamLevel.this.minlevel + " ;maxlevel: " + CRequestSetTeamLevel.this.maxlevel);
                                CRequestSetTeamLevel.this.team.getTeamInfo().setMinlevel(CRequestSetTeamLevel.this.minlevel);
                                CRequestSetTeamLevel.this.team.getTeamInfo().setMaxlevel(CRequestSetTeamLevel.this.maxlevel);
                                SSetTeamLevel sSetTeamLevel = new SSetTeamLevel();
                                sSetTeamLevel.minlevel = CRequestSetTeamLevel.this.minlevel;
                                sSetTeamLevel.maxlevel = CRequestSetTeamLevel.this.maxlevel;
                                Procedure.psendWhileCommit(CRequestSetTeamLevel.this.team.getTeamBroadcastSet(), sSetTeamLevel);
                            }

                            return true;
                        }
                    } else {
                        return true;
                    }
                }
            };
            setTeamLevelP.submit();
        }
    }

    private boolean checkOnline(long roleId) {
        return StateCommon.isOnline(roleId);
    }

    private boolean checkLeaderInTeam(long leaderRoleId, Team team) {
        return team.getTeamInfo().getTeamleaderid() == leaderRoleId;
    }

    private boolean checkSetedLevelValid(int minLevel, int maxLevel) {
        if (minLevel > maxLevel) {
            return false;
        } else if (minLevel >= 1 && minLevel <= 155) {
            return maxLevel >= 1 && maxLevel <= 155;
        } else {
            return false;
        }
    }

    public int getType() {
        return 794462;
    }

    public CRequestSetTeamLevel() {
    }

    public CRequestSetTeamLevel(int _minlevel_, int _maxlevel_) {
        this.minlevel = _minlevel_;
        this.maxlevel = _maxlevel_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.minlevel);
            _os_.marshal(this.maxlevel);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.minlevel = _os_.unmarshal_int();
        this.maxlevel = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CRequestSetTeamLevel) {
            CRequestSetTeamLevel _o_ = (CRequestSetTeamLevel)_o1_;
            if (this.minlevel != _o_.minlevel) {
                return false;
            } else {
                return this.maxlevel == _o_.maxlevel;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.minlevel;
        _h_ += this.maxlevel;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.minlevel).append(",");
        _sb_.append(this.maxlevel).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CRequestSetTeamLevel _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.minlevel - _o_.minlevel;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.maxlevel - _o_.maxlevel;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

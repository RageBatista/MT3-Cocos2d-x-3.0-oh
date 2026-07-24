//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.List;
import mkdb.Procedure;
import xbean.TeamMember;
import xtable.Roleid2teamid;

public class CSwapMember extends __CSwapMember__ {
    public static final int PROTOCOL_TYPE = 794452;
    public int index1;
    public int index2;

    protected void process() {
        TeamManager.logger.debug("Enter: " + this.getClass());
        final long leaderRoleId = Onlines.getInstance().findRoleid(this);
        if (leaderRoleId >= 0L) {
            Procedure swapMemberP = new Procedure() {
                protected boolean process() {
                    Long teamId = Roleid2teamid.select(leaderRoleId);
                    Team team = null;
                    if (teamId != null) {
                        team = new Team(teamId, false);
                        if (!CSwapMember.this.checkleaderInTeam(leaderRoleId, team)) {
                            MessageMgr.psendMsgNotify(leaderRoleId, 141192, (List)null);
                            TeamManager.logger.debug("FAIL:申请交换的人不是队长,  leaderRoleId:" + leaderRoleId);
                        } else if (!CSwapMember.this.checkIndexValid(team, (long)CSwapMember.this.index1, (long)CSwapMember.this.index2)) {
                            TeamManager.logger.debug("FAIL:申请交换的两队员index不合法,  index1: " + CSwapMember.this.index1 + " ;index2: " + CSwapMember.this.index2);
                        } else if (!CSwapMember.this.checkMemsberStateValid(team, CSwapMember.this.index1, CSwapMember.this.index2)) {
                            psend(leaderRoleId, new STeamError(25));
                            MessageMgr.psendMsgNotify(leaderRoleId, 141193, (List)null);
                            TeamManager.logger.debug("FAIL:要交换的两队员必须都处于正常状态,  index1: " + CSwapMember.this.index1 + " ;index2: " + CSwapMember.this.index2);
                        } else {
                            TeamManager.logger.debug("SUCC:可以交换队员,  index1: " + CSwapMember.this.index1 + " ;index2: " + CSwapMember.this.index2);
                            team.switchTeamMemberWithSP(CSwapMember.this.index1, CSwapMember.this.index2);
                        }

                        return true;
                    } else {
                        return true;
                    }
                }
            };
            swapMemberP.submit();
        }
    }

    private boolean checkleaderInTeam(long leaderRoleId, Team team) {
        return team != null && team.getTeamInfo().getTeamleaderid() == leaderRoleId;
    }

    private boolean checkIndexValid(Team team, long index_1, long index_2) {
        return index_1 >= 1L && index_1 <= (long)team.getTeamInfo().getMembers().size() && index_2 >= 1L && index_2 <= (long)team.getTeamInfo().getMembers().size() && index_1 != index_2;
    }

    private boolean checkMemsberStateValid(Team team, int index_1, int index_2) {
        return ((TeamMember)team.getTeamInfo().getMembers().get(index_1 - 1)).getState() == 1 && ((TeamMember)team.getTeamInfo().getMembers().get(index_2 - 1)).getState() == 1;
    }

    public int getType() {
        return 794452;
    }

    public CSwapMember() {
    }

    public CSwapMember(int _index1_, int _index2_) {
        this.index1 = _index1_;
        this.index2 = _index2_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.index1);
            _os_.marshal(this.index2);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.index1 = _os_.unmarshal_int();
        this.index2 = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CSwapMember) {
            CSwapMember _o_ = (CSwapMember)_o1_;
            if (this.index1 != _o_.index1) {
                return false;
            } else {
                return this.index2 == _o_.index2;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.index1;
        _h_ += this.index2;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.index1).append(",");
        _sb_.append(this.index2).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CSwapMember _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.index1 - _o_.index1;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.index2 - _o_.index2;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

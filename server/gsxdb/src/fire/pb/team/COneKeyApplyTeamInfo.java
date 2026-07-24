//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;
import mkdb.Procedure;
import xbean.TeamMember;

public class COneKeyApplyTeamInfo extends __COneKeyApplyTeamInfo__ {
    public static final int PROTOCOL_TYPE = 794517;
    public long teamid;

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            Procedure onekeyteammatch = new Procedure() {
                protected boolean process() {
                    Team team = null;
                    team = TeamManager.getTeamByTeamID(COneKeyApplyTeamInfo.this.teamid);
                    if (team != null) {
                        SOneKeyApplyTeamInfo msg = new SOneKeyApplyTeamInfo();
                        msg.teamid = COneKeyApplyTeamInfo.this.teamid;
                        msg.memberlist.add(team.getTeamMemeberSimple(team.getTeamLeaderId()));

                        for(TeamMember member : team.getTeamInfo().getMembers()) {
                            long memberid = member.getRoleid();
                            msg.memberlist.add(team.getTeamMemeberSimple(memberid));
                        }

                        Procedure.psendWhileCommit(roleid, msg);
                    }

                    return true;
                }
            };
            onekeyteammatch.submit();
        }
    }

    public int getType() {
        return 794517;
    }

    public COneKeyApplyTeamInfo() {
    }

    public COneKeyApplyTeamInfo(long _teamid_) {
        this.teamid = _teamid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.teamid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.teamid = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof COneKeyApplyTeamInfo) {
            COneKeyApplyTeamInfo _o_ = (COneKeyApplyTeamInfo)_o1_;
            return this.teamid == _o_.teamid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.teamid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.teamid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(COneKeyApplyTeamInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.teamid - _o_.teamid);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}

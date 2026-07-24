//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SRequestClanFightTeamRoleNum extends __SRequestClanFightTeamRoleNum__ {
    public static final int PROTOCOL_TYPE = 794562;
    public int teamnum;
    public int rolenum;

    protected void process() {
    }

    public int getType() {
        return 794562;
    }

    public SRequestClanFightTeamRoleNum() {
    }

    public SRequestClanFightTeamRoleNum(int _teamnum_, int _rolenum_) {
        this.teamnum = _teamnum_;
        this.rolenum = _rolenum_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.teamnum);
            _os_.marshal(this.rolenum);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.teamnum = _os_.unmarshal_int();
        this.rolenum = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SRequestClanFightTeamRoleNum) {
            SRequestClanFightTeamRoleNum _o_ = (SRequestClanFightTeamRoleNum)_o1_;
            if (this.teamnum != _o_.teamnum) {
                return false;
            } else {
                return this.rolenum == _o_.rolenum;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.teamnum;
        _h_ += this.rolenum;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.teamnum).append(",");
        _sb_.append(this.rolenum).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SRequestClanFightTeamRoleNum _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.teamnum - _o_.teamnum;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.rolenum - _o_.rolenum;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

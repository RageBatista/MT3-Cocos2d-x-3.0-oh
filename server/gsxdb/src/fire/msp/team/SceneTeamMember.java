//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.msp.team;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SceneTeamMember implements Marshal, Comparable<SceneTeamMember> {
    public long roleid;
    public int state;

    public SceneTeamMember() {
    }

    public SceneTeamMember(long _roleid_, int _state_) {
        this.roleid = _roleid_;
        this.state = _state_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.roleid);
        _os_.marshal(this.state);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.state = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SceneTeamMember) {
            SceneTeamMember _o_ = (SceneTeamMember)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else {
                return this.state == _o_.state;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.state;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.state).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SceneTeamMember _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = Long.signum(this.roleid - _o_.roleid);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.state - _o_.state;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

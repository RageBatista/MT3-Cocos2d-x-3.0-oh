//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ApplyClan implements Marshal, Comparable<ApplyClan> {
    public long clankey;
    public int applystate;

    public ApplyClan() {
    }

    public ApplyClan(long _clankey_, int _applystate_) {
        this.clankey = _clankey_;
        this.applystate = _applystate_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.clankey);
        _os_.marshal(this.applystate);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.clankey = _os_.unmarshal_long();
        this.applystate = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ApplyClan) {
            ApplyClan _o_ = (ApplyClan)_o1_;
            if (this.clankey != _o_.clankey) {
                return false;
            } else {
                return this.applystate == _o_.applystate;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.clankey;
        _h_ += this.applystate;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.clankey).append(",");
        _sb_.append(this.applystate).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(ApplyClan _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.clankey - _o_.clankey);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.applystate - _o_.applystate;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

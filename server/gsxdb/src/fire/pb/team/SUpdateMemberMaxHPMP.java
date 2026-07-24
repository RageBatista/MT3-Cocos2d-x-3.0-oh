//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SUpdateMemberMaxHPMP extends __SUpdateMemberMaxHPMP__ {
    public static final int PROTOCOL_TYPE = 794461;
    public long roleid;
    public int maxhp;
    public int maxmp;

    protected void process() {
    }

    public int getType() {
        return 794461;
    }

    public SUpdateMemberMaxHPMP() {
    }

    public SUpdateMemberMaxHPMP(long _roleid_, int _maxhp_, int _maxmp_) {
        this.roleid = _roleid_;
        this.maxhp = _maxhp_;
        this.maxmp = _maxmp_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.roleid);
            _os_.marshal(this.maxhp);
            _os_.marshal(this.maxmp);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.maxhp = _os_.unmarshal_int();
        this.maxmp = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SUpdateMemberMaxHPMP) {
            SUpdateMemberMaxHPMP _o_ = (SUpdateMemberMaxHPMP)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (this.maxhp != _o_.maxhp) {
                return false;
            } else {
                return this.maxmp == _o_.maxmp;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.maxhp;
        _h_ += this.maxmp;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.maxhp).append(",");
        _sb_.append(this.maxmp).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SUpdateMemberMaxHPMP _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.roleid - _o_.roleid);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.maxhp - _o_.maxhp;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.maxmp - _o_.maxmp;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}

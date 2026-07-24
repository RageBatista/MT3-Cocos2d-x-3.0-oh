//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SUpdateMemberHPMP extends __SUpdateMemberHPMP__ {
    public static final int PROTOCOL_TYPE = 794460;
    public long roleid;
    public int hp;
    public int mp;

    protected void process() {
    }

    public int getType() {
        return 794460;
    }

    public SUpdateMemberHPMP() {
    }

    public SUpdateMemberHPMP(long _roleid_, int _hp_, int _mp_) {
        this.roleid = _roleid_;
        this.hp = _hp_;
        this.mp = _mp_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.roleid);
            _os_.marshal(this.hp);
            _os_.marshal(this.mp);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
        this.hp = _os_.unmarshal_int();
        this.mp = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SUpdateMemberHPMP) {
            SUpdateMemberHPMP _o_ = (SUpdateMemberHPMP)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else if (this.hp != _o_.hp) {
                return false;
            } else {
                return this.mp == _o_.mp;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.hp;
        _h_ += this.mp;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.hp).append(",");
        _sb_.append(this.mp).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SUpdateMemberHPMP _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.roleid - _o_.roleid);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.hp - _o_.hp;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.mp - _o_.mp;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SPetRecover extends __SPetRecover__ {
    public static final int PROTOCOL_TYPE = 788586;
    public int petid;
    public long uniqid;

    protected void process() {
    }

    public int getType() {
        return 788586;
    }

    public SPetRecover() {
    }

    public SPetRecover(int _petid_, long _uniqid_) {
        this.petid = _petid_;
        this.uniqid = _uniqid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petid);
            _os_.marshal(this.uniqid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petid = _os_.unmarshal_int();
        this.uniqid = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SPetRecover) {
            SPetRecover _o_ = (SPetRecover)_o1_;
            if (this.petid != _o_.petid) {
                return false;
            } else {
                return this.uniqid == _o_.uniqid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petid;
        _h_ += (int)this.uniqid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petid).append(",");
        _sb_.append(this.uniqid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SPetRecover _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.petid - _o_.petid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = Long.signum(this.uniqid - _o_.uniqid);
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

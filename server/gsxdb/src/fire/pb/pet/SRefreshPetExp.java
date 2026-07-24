//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SRefreshPetExp extends __SRefreshPetExp__ {
    public static final int PROTOCOL_TYPE = 788438;
    public int petkey;
    public long curexp;

    protected void process() {
    }

    public int getType() {
        return 788438;
    }

    public SRefreshPetExp() {
    }

    public SRefreshPetExp(int _petkey_, long _curexp_) {
        this.petkey = _petkey_;
        this.curexp = _curexp_;
    }

    public final boolean _validator_() {
        if (this.petkey < 1) {
            return false;
        } else {
            return this.curexp >= 0L;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.marshal(this.curexp);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        this.curexp = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SRefreshPetExp) {
            SRefreshPetExp _o_ = (SRefreshPetExp)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else {
                return this.curexp == _o_.curexp;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += (int)this.curexp;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.curexp).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SRefreshPetExp _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.petkey - _o_.petkey;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = Long.signum(this.curexp - _o_.curexp);
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

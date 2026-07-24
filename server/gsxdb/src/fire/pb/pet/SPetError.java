//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SPetError extends __SPetError__ {
    public static final int PROTOCOL_TYPE = 788449;
    public int peterror;

    protected void process() {
    }

    public int getType() {
        return 788449;
    }

    public SPetError() {
    }

    public SPetError(int _peterror_) {
        this.peterror = _peterror_;
    }

    public final boolean _validator_() {
        return this.peterror <= -1;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.peterror);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.peterror = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SPetError) {
            SPetError _o_ = (SPetError)_o1_;
            return this.peterror == _o_.peterror;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.peterror;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.peterror).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SPetError _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.peterror - _o_.peterror;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}

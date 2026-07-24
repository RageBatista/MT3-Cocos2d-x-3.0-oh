//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SPingJi extends __SPingJi__ {
    public static final int PROTOCOL_TYPE = 795667;
    public byte grade;
    public int exp;

    protected void process() {
    }

    public int getType() {
        return 795667;
    }

    public SPingJi() {
    }

    public SPingJi(byte _grade_, int _exp_) {
        this.grade = _grade_;
        this.exp = _exp_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.grade);
            _os_.marshal(this.exp);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.grade = _os_.unmarshal_byte();
        this.exp = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SPingJi) {
            SPingJi _o_ = (SPingJi)_o1_;
            if (this.grade != _o_.grade) {
                return false;
            } else {
                return this.exp == _o_.exp;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.grade;
        _h_ += this.exp;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.grade).append(",");
        _sb_.append(this.exp).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SPingJi _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.grade - _o_.grade;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.exp - _o_.exp;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

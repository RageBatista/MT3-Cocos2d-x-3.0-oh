//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RoleColorType implements Marshal, Comparable<RoleColorType> {
    public int colorpos1;
    public int colorpos2;

    public RoleColorType() {
    }

    public RoleColorType(int _colorpos1_, int _colorpos2_) {
        this.colorpos1 = _colorpos1_;
        this.colorpos2 = _colorpos2_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.colorpos1);
        _os_.marshal(this.colorpos2);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.colorpos1 = _os_.unmarshal_int();
        this.colorpos2 = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RoleColorType) {
            RoleColorType _o_ = (RoleColorType)_o1_;
            if (this.colorpos1 != _o_.colorpos1) {
                return false;
            } else {
                return this.colorpos2 == _o_.colorpos2;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.colorpos1;
        _h_ += this.colorpos2;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.colorpos1).append(",");
        _sb_.append(this.colorpos2).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(RoleColorType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.colorpos1 - _o_.colorpos1;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.colorpos2 - _o_.colorpos2;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

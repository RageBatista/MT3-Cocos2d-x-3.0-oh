//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class FormBean implements Marshal, Comparable<FormBean> {
    public int activetimes;
    public int level;
    public int exp;

    public FormBean() {
    }

    public FormBean(int _activetimes_, int _level_, int _exp_) {
        this.activetimes = _activetimes_;
        this.level = _level_;
        this.exp = _exp_;
    }

    public final boolean _validator_() {
        if (this.level < 0) {
            return false;
        } else {
            return this.exp >= 0;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.activetimes);
        _os_.marshal(this.level);
        _os_.marshal(this.exp);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.activetimes = _os_.unmarshal_int();
        this.level = _os_.unmarshal_int();
        this.exp = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof FormBean) {
            FormBean _o_ = (FormBean)_o1_;
            if (this.activetimes != _o_.activetimes) {
                return false;
            } else if (this.level != _o_.level) {
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
        _h_ += this.activetimes;
        _h_ += this.level;
        _h_ += this.exp;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.activetimes).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(this.exp).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(FormBean _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.activetimes - _o_.activetimes;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.level - _o_.level;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.exp - _o_.exp;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}

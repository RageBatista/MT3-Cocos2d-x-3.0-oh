//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class FunOpenClose implements Marshal, Comparable<FunOpenClose> {
    public int key;
    public int state;

    public FunOpenClose() {
    }

    public FunOpenClose(int _key_, int _state_) {
        this.key = _key_;
        this.state = _state_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.key);
        _os_.marshal(this.state);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.key = _os_.unmarshal_int();
        this.state = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof FunOpenClose) {
            FunOpenClose _o_ = (FunOpenClose)_o1_;
            if (this.key != _o_.key) {
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
        _h_ += this.key;
        _h_ += this.state;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.key).append(",");
        _sb_.append(this.state).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(FunOpenClose _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.key - _o_.key;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.state - _o_.state;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

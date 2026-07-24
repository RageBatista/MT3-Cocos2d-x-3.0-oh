//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission.activelist;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SimpleActivityInfo implements Marshal, Comparable<SimpleActivityInfo> {
    public int num;
    public int num2;
    public int activevalue;

    public SimpleActivityInfo() {
    }

    public SimpleActivityInfo(int _num_, int _num2_, int _activevalue_) {
        this.num = _num_;
        this.num2 = _num2_;
        this.activevalue = _activevalue_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.num);
        _os_.marshal(this.num2);
        _os_.marshal(this.activevalue);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.num = _os_.unmarshal_int();
        this.num2 = _os_.unmarshal_int();
        this.activevalue = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SimpleActivityInfo) {
            SimpleActivityInfo _o_ = (SimpleActivityInfo)_o1_;
            if (this.num != _o_.num) {
                return false;
            } else if (this.num2 != _o_.num2) {
                return false;
            } else {
                return this.activevalue == _o_.activevalue;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.num;
        _h_ += this.num2;
        _h_ += this.activevalue;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.num).append(",");
        _sb_.append(this.num2).append(",");
        _sb_.append(this.activevalue).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SimpleActivityInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.num - _o_.num;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.num2 - _o_.num2;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.activevalue - _o_.activevalue;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}

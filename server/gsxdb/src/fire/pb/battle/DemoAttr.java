//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class DemoAttr implements Marshal, Comparable<DemoAttr> {
    public int fighterid;
    public int attrid;
    public int value;

    public DemoAttr() {
    }

    public DemoAttr(int _fighterid_, int _attrid_, int _value_) {
        this.fighterid = _fighterid_;
        this.attrid = _attrid_;
        this.value = _value_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.fighterid);
        _os_.marshal(this.attrid);
        _os_.marshal(this.value);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.fighterid = _os_.unmarshal_int();
        this.attrid = _os_.unmarshal_int();
        this.value = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof DemoAttr) {
            DemoAttr _o_ = (DemoAttr)_o1_;
            if (this.fighterid != _o_.fighterid) {
                return false;
            } else if (this.attrid != _o_.attrid) {
                return false;
            } else {
                return this.value == _o_.value;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.fighterid;
        _h_ += this.attrid;
        _h_ += this.value;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.fighterid).append(",");
        _sb_.append(this.attrid).append(",");
        _sb_.append(this.value).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(DemoAttr _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.fighterid - _o_.fighterid;
            if (_c_ != 0) {
                return _c_;
            } else {
                _c_ = this.attrid - _o_.attrid;
                if (_c_ != 0) {
                    return _c_;
                } else {
                    _c_ = this.value - _o_.value;
                    return _c_ != 0 ? _c_ : _c_;
                }
            }
        }
    }
}

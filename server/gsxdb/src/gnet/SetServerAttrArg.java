//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package gnet;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SetServerAttrArg implements Marshal, Comparable<SetServerAttrArg> {
    public int gmuserid;
    public int localsid;
    public int attribute;
    public int value;

    public SetServerAttrArg() {
    }

    public SetServerAttrArg(int _gmuserid_, int _localsid_, int _attribute_, int _value_) {
        this.gmuserid = _gmuserid_;
        this.localsid = _localsid_;
        this.attribute = _attribute_;
        this.value = _value_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.gmuserid);
        _os_.marshal(this.localsid);
        _os_.marshal(this.attribute);
        _os_.marshal(this.value);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.gmuserid = _os_.unmarshal_int();
        this.localsid = _os_.unmarshal_int();
        this.attribute = _os_.unmarshal_int();
        this.value = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SetServerAttrArg) {
            SetServerAttrArg _o_ = (SetServerAttrArg)_o1_;
            if (this.gmuserid != _o_.gmuserid) {
                return false;
            } else if (this.localsid != _o_.localsid) {
                return false;
            } else if (this.attribute != _o_.attribute) {
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
        _h_ += this.gmuserid;
        _h_ += this.localsid;
        _h_ += this.attribute;
        _h_ += this.value;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.gmuserid).append(",");
        _sb_.append(this.localsid).append(",");
        _sb_.append(this.attribute).append(",");
        _sb_.append(this.value).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SetServerAttrArg _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = this.gmuserid - _o_.gmuserid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.localsid - _o_.localsid;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.attribute - _o_.attribute;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.value - _o_.value;
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}

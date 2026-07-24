//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ChargeReturnProfit implements Marshal, Comparable<ChargeReturnProfit> {
    public int id;
    public int value;
    public int maxvalue;
    public int status;

    public ChargeReturnProfit() {
    }

    public ChargeReturnProfit(int _id_, int _value_, int _maxvalue_, int _status_) {
        this.id = _id_;
        this.value = _value_;
        this.maxvalue = _maxvalue_;
        this.status = _status_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.id);
        _os_.marshal(this.value);
        _os_.marshal(this.maxvalue);
        _os_.marshal(this.status);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.id = _os_.unmarshal_int();
        this.value = _os_.unmarshal_int();
        this.maxvalue = _os_.unmarshal_int();
        this.status = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ChargeReturnProfit) {
            ChargeReturnProfit _o_ = (ChargeReturnProfit)_o1_;
            if (this.id != _o_.id) {
                return false;
            } else if (this.value != _o_.value) {
                return false;
            } else if (this.maxvalue != _o_.maxvalue) {
                return false;
            } else {
                return this.status == _o_.status;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.id;
        _h_ += this.value;
        _h_ += this.maxvalue;
        _h_ += this.status;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.id).append(",");
        _sb_.append(this.value).append(",");
        _sb_.append(this.maxvalue).append(",");
        _sb_.append(this.status).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(ChargeReturnProfit _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.id - _o_.id;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.value - _o_.value;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.maxvalue - _o_.maxvalue;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.status - _o_.status;
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}

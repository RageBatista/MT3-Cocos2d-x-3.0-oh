//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package gnet;

import com.locojoy.base.Octets;
import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class DiscountGrade implements Marshal {
    public int amount_begin;
    public int discount;
    public int reserved1;
    public Octets reserved2;

    public DiscountGrade() {
        this.reserved2 = new Octets();
    }

    public DiscountGrade(int _amount_begin_, int _discount_, int _reserved1_, Octets _reserved2_) {
        this.amount_begin = _amount_begin_;
        this.discount = _discount_;
        this.reserved1 = _reserved1_;
        this.reserved2 = _reserved2_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.amount_begin);
        _os_.marshal(this.discount);
        _os_.marshal(this.reserved1);
        _os_.marshal(this.reserved2);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.amount_begin = _os_.unmarshal_int();
        this.discount = _os_.unmarshal_int();
        this.reserved1 = _os_.unmarshal_int();
        this.reserved2 = _os_.unmarshal_Octets();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof DiscountGrade) {
            DiscountGrade _o_ = (DiscountGrade)_o1_;
            if (this.amount_begin != _o_.amount_begin) {
                return false;
            } else if (this.discount != _o_.discount) {
                return false;
            } else if (this.reserved1 != _o_.reserved1) {
                return false;
            } else {
                return this.reserved2.equals(_o_.reserved2);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.amount_begin;
        _h_ += this.discount;
        _h_ += this.reserved1;
        _h_ += this.reserved2.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.amount_begin).append(",");
        _sb_.append(this.discount).append(",");
        _sb_.append(this.reserved1).append(",");
        _sb_.append("B").append(this.reserved2.size()).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}

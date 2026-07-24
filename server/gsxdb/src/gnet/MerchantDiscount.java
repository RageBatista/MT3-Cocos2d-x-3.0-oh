//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package gnet;

import com.locojoy.base.Octets;
import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import java.util.ArrayList;
import java.util.Iterator;

public class MerchantDiscount implements Marshal {
    public int id;
    public Octets name;
    public int reserved;
    public ArrayList<DiscountGrade> discount;

    public MerchantDiscount() {
        this.name = new Octets();
        this.discount = new ArrayList();
    }

    public MerchantDiscount(int _id_, Octets _name_, int _reserved_, ArrayList<DiscountGrade> _discount_) {
        this.id = _id_;
        this.name = _name_;
        this.reserved = _reserved_;
        this.discount = _discount_;
    }

    public final boolean _validator_() {
        Iterator iterator = this.discount.iterator();

        DiscountGrade _v_;
        do {
            if (!iterator.hasNext()) {
                return true;
            }

            _v_ = (DiscountGrade)iterator.next();
        } while(_v_._validator_());

        return false;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.id);
        _os_.marshal(this.name);
        _os_.marshal(this.reserved);
        _os_.compact_uint32(this.discount.size());
        Iterator iterator = this.discount.iterator();

        while(iterator.hasNext()) {
            DiscountGrade _v_ = (DiscountGrade)iterator.next();
            _os_.marshal(_v_);
        }

        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.id = _os_.unmarshal_int();
        this.name = _os_.unmarshal_Octets();
        this.reserved = _os_.unmarshal_int();

        for(int _size_ = _os_.uncompact_uint32(); _size_ > 0; --_size_) {
            DiscountGrade _v_ = new DiscountGrade();
            _v_.unmarshal(_os_);
            this.discount.add(_v_);
        }

        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof MerchantDiscount) {
            MerchantDiscount _o_ = (MerchantDiscount)_o1_;
            if (this.id != _o_.id) {
                return false;
            } else if (!this.name.equals(_o_.name)) {
                return false;
            } else if (this.reserved != _o_.reserved) {
                return false;
            } else {
                return this.discount.equals(_o_.discount);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.id;
        _h_ += this.name.hashCode();
        _h_ += this.reserved;
        _h_ += this.discount.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.id).append(",");
        _sb_.append("B").append(this.name.size()).append(",");
        _sb_.append(this.reserved).append(",");
        _sb_.append(this.discount).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class Goods implements Marshal, Comparable<Goods> {
    public int goodsid;
    public int price;
    public int priorperiodprice;

    public Goods() {
    }

    public Goods(int _goodsid_, int _price_, int _priorperiodprice_) {
        this.goodsid = _goodsid_;
        this.price = _price_;
        this.priorperiodprice = _priorperiodprice_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.goodsid);
        _os_.marshal(this.price);
        _os_.marshal(this.priorperiodprice);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.goodsid = _os_.unmarshal_int();
        this.price = _os_.unmarshal_int();
        this.priorperiodprice = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof Goods) {
            Goods _o_ = (Goods)_o1_;
            if (this.goodsid != _o_.goodsid) {
                return false;
            } else if (this.price != _o_.price) {
                return false;
            } else {
                return this.priorperiodprice == _o_.priorperiodprice;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.goodsid;
        _h_ += this.price;
        _h_ += this.priorperiodprice;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.goodsid).append(",");
        _sb_.append(this.price).append(",");
        _sb_.append(this.priorperiodprice).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(Goods _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.goodsid - _o_.goodsid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.price - _o_.price;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.priorperiodprice - _o_.priorperiodprice;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}

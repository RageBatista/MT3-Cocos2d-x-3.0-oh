//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class GoodsLimit implements Marshal, Comparable<GoodsLimit> {
    public int goodsid;
    public int number;

    public GoodsLimit() {
    }

    public GoodsLimit(int _goodsid_, int _number_) {
        this.goodsid = _goodsid_;
        this.number = _number_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.goodsid);
        _os_.marshal(this.number);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.goodsid = _os_.unmarshal_int();
        this.number = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof GoodsLimit) {
            GoodsLimit _o_ = (GoodsLimit)_o1_;
            if (this.goodsid != _o_.goodsid) {
                return false;
            } else {
                return this.number == _o_.number;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.goodsid;
        _h_ += this.number;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.goodsid).append(",");
        _sb_.append(this.number).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(GoodsLimit _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.goodsid - _o_.goodsid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.number - _o_.number;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

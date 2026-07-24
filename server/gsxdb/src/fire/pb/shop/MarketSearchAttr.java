//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class MarketSearchAttr implements Marshal, Comparable<MarketSearchAttr> {
    public int attrid;
    public int attrval;

    public MarketSearchAttr() {
    }

    public MarketSearchAttr(int _attrid_, int _attrval_) {
        this.attrid = _attrid_;
        this.attrval = _attrval_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.attrid);
        _os_.marshal(this.attrval);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.attrid = _os_.unmarshal_int();
        this.attrval = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof MarketSearchAttr) {
            MarketSearchAttr _o_ = (MarketSearchAttr)_o1_;
            if (this.attrid != _o_.attrid) {
                return false;
            } else {
                return this.attrval == _o_.attrval;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.attrid;
        _h_ += this.attrval;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.attrid).append(",");
        _sb_.append(this.attrval).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(MarketSearchAttr _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.attrid - _o_.attrid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.attrval - _o_.attrval;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

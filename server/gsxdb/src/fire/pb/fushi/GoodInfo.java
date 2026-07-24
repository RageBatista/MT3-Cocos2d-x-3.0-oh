//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class GoodInfo implements Marshal, Comparable<GoodInfo> {
    public int goodid;
    public int price;
    public int fushi;
    public int present;
    public int beishu;

    public GoodInfo() {
    }

    public GoodInfo(int _goodid_, int _price_, int _fushi_, int _present_, int _beishu_) {
        this.goodid = _goodid_;
        this.price = _price_;
        this.fushi = _fushi_;
        this.present = _present_;
        this.beishu = _beishu_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.goodid);
        _os_.marshal(this.price);
        _os_.marshal(this.fushi);
        _os_.marshal(this.present);
        _os_.marshal(this.beishu);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.goodid = _os_.unmarshal_int();
        this.price = _os_.unmarshal_int();
        this.fushi = _os_.unmarshal_int();
        this.present = _os_.unmarshal_int();
        this.beishu = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof GoodInfo) {
            GoodInfo _o_ = (GoodInfo)_o1_;
            if (this.goodid != _o_.goodid) {
                return false;
            } else if (this.price != _o_.price) {
                return false;
            } else if (this.fushi != _o_.fushi) {
                return false;
            } else if (this.present != _o_.present) {
                return false;
            } else {
                return this.beishu == _o_.beishu;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.goodid;
        _h_ += this.price;
        _h_ += this.fushi;
        _h_ += this.present;
        _h_ += this.beishu;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.goodid).append(",");
        _sb_.append(this.price).append(",");
        _sb_.append(this.fushi).append(",");
        _sb_.append(this.present).append(",");
        _sb_.append(this.beishu).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(GoodInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.goodid - _o_.goodid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.price - _o_.price;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.fushi - _o_.fushi;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.present - _o_.present;
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = this.beishu - _o_.beishu;
                            return 0 != _c_ ? _c_ : _c_;
                        }
                    }
                }
            }
        }
    }
}

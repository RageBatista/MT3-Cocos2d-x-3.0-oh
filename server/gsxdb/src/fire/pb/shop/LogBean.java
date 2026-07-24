//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class LogBean implements Marshal, Comparable<LogBean> {
    public int itemid;
    public int num;
    public int price;
    public int level;

    public LogBean() {
    }

    public LogBean(int _itemid_, int _num_, int _price_, int _level_) {
        this.itemid = _itemid_;
        this.num = _num_;
        this.price = _price_;
        this.level = _level_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.itemid);
        _os_.marshal(this.num);
        _os_.marshal(this.price);
        _os_.marshal(this.level);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.itemid = _os_.unmarshal_int();
        this.num = _os_.unmarshal_int();
        this.price = _os_.unmarshal_int();
        this.level = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof LogBean) {
            LogBean _o_ = (LogBean)_o1_;
            if (this.itemid != _o_.itemid) {
                return false;
            } else if (this.num != _o_.num) {
                return false;
            } else if (this.price != _o_.price) {
                return false;
            } else {
                return this.level == _o_.level;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.itemid;
        _h_ += this.num;
        _h_ += this.price;
        _h_ += this.level;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.itemid).append(",");
        _sb_.append(this.num).append(",");
        _sb_.append(this.price).append(",");
        _sb_.append(this.level).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(LogBean _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.itemid - _o_.itemid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.num - _o_.num;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.price - _o_.price;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.level - _o_.level;
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}

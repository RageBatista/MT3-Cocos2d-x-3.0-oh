//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ItemRecoverInfoBean implements Marshal, Comparable<ItemRecoverInfoBean> {
    public int itemid;
    public long uniqid;
    public int remaintime;
    public int cost;

    public ItemRecoverInfoBean() {
    }

    public ItemRecoverInfoBean(int _itemid_, long _uniqid_, int _remaintime_, int _cost_) {
        this.itemid = _itemid_;
        this.uniqid = _uniqid_;
        this.remaintime = _remaintime_;
        this.cost = _cost_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.itemid);
        _os_.marshal(this.uniqid);
        _os_.marshal(this.remaintime);
        _os_.marshal(this.cost);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.itemid = _os_.unmarshal_int();
        this.uniqid = _os_.unmarshal_long();
        this.remaintime = _os_.unmarshal_int();
        this.cost = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ItemRecoverInfoBean) {
            ItemRecoverInfoBean _o_ = (ItemRecoverInfoBean)_o1_;
            if (this.itemid != _o_.itemid) {
                return false;
            } else if (this.uniqid != _o_.uniqid) {
                return false;
            } else if (this.remaintime != _o_.remaintime) {
                return false;
            } else {
                return this.cost == _o_.cost;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.itemid;
        _h_ += (int)this.uniqid;
        _h_ += this.remaintime;
        _h_ += this.cost;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.itemid).append(",");
        _sb_.append(this.uniqid).append(",");
        _sb_.append(this.remaintime).append(",");
        _sb_.append(this.cost).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(ItemRecoverInfoBean _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.itemid - _o_.itemid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = Long.signum(this.uniqid - _o_.uniqid);
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.remaintime - _o_.remaintime;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.cost - _o_.cost;
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ItemAddInfo implements Marshal, Comparable<ItemAddInfo> {
    public int itemid;
    public int itemnum;

    public ItemAddInfo() {
    }

    public ItemAddInfo(int _itemid_, int _itemnum_) {
        this.itemid = _itemid_;
        this.itemnum = _itemnum_;
    }

    public final boolean _validator_() {
        if (this.itemid <= 0) {
            return false;
        } else {
            return this.itemnum > 0;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.itemid);
        _os_.marshal(this.itemnum);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.itemid = _os_.unmarshal_int();
        this.itemnum = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ItemAddInfo) {
            ItemAddInfo _o_ = (ItemAddInfo)_o1_;
            if (this.itemid != _o_.itemid) {
                return false;
            } else {
                return this.itemnum == _o_.itemnum;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.itemid;
        _h_ += this.itemnum;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.itemid).append(",");
        _sb_.append(this.itemnum).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(ItemAddInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.itemid - _o_.itemid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.itemnum - _o_.itemnum;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team.teammelon;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class MelonItemBagInfo implements Marshal, Comparable<MelonItemBagInfo> {
    public int itemkey;
    public int bagid;

    public MelonItemBagInfo() {
    }

    public MelonItemBagInfo(int _itemkey_, int _bagid_) {
        this.itemkey = _itemkey_;
        this.bagid = _bagid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.itemkey);
        _os_.marshal(this.bagid);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.itemkey = _os_.unmarshal_int();
        this.bagid = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof MelonItemBagInfo) {
            MelonItemBagInfo _o_ = (MelonItemBagInfo)_o1_;
            if (this.itemkey != _o_.itemkey) {
                return false;
            } else {
                return this.bagid == _o_.bagid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.itemkey;
        _h_ += this.bagid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.itemkey).append(",");
        _sb_.append(this.bagid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(MelonItemBagInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.itemkey - _o_.itemkey;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.bagid - _o_.bagid;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ForturneWheelType implements Marshal, Comparable<ForturneWheelType> {
    public int itemtype;
    public int id;
    public long num;
    public int times;

    public ForturneWheelType() {
    }

    public ForturneWheelType(int _itemtype_, int _id_, long _num_, int _times_) {
        this.itemtype = _itemtype_;
        this.id = _id_;
        this.num = _num_;
        this.times = _times_;
    }

    public final boolean _validator_() {
        if (this.itemtype < 1) {
            return false;
        } else if (this.id < 0) {
            return false;
        } else if (this.num < 0L) {
            return false;
        } else {
            return this.times >= 0;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.itemtype);
        _os_.marshal(this.id);
        _os_.marshal(this.num);
        _os_.marshal(this.times);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.itemtype = _os_.unmarshal_int();
        this.id = _os_.unmarshal_int();
        this.num = _os_.unmarshal_long();
        this.times = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ForturneWheelType) {
            ForturneWheelType _o_ = (ForturneWheelType)_o1_;
            if (this.itemtype != _o_.itemtype) {
                return false;
            } else if (this.id != _o_.id) {
                return false;
            } else if (this.num != _o_.num) {
                return false;
            } else {
                return this.times == _o_.times;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.itemtype;
        _h_ += this.id;
        _h_ += (int)this.num;
        _h_ += this.times;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.itemtype).append(",");
        _sb_.append(this.id).append(",");
        _sb_.append(this.num).append(",");
        _sb_.append(this.times).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(ForturneWheelType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.itemtype - _o_.itemtype;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.id - _o_.id;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = Long.signum(this.num - _o_.num);
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.times - _o_.times;
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}

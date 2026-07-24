//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.move;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class PickUpItem implements Marshal, Comparable<PickUpItem> {
    public long uniqueid;
    public int baseid;
    public Pos pos;

    public PickUpItem() {
        this.pos = new Pos();
    }

    public PickUpItem(long _uniqueid_, int _baseid_, Pos _pos_) {
        this.uniqueid = _uniqueid_;
        this.baseid = _baseid_;
        this.pos = _pos_;
    }

    public final boolean _validator_() {
        return this.pos._validator_();
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.uniqueid);
        _os_.marshal(this.baseid);
        _os_.marshal(this.pos);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.uniqueid = _os_.unmarshal_long();
        this.baseid = _os_.unmarshal_int();
        this.pos.unmarshal(_os_);
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof PickUpItem) {
            PickUpItem _o_ = (PickUpItem)_o1_;
            if (this.uniqueid != _o_.uniqueid) {
                return false;
            } else if (this.baseid != _o_.baseid) {
                return false;
            } else {
                return this.pos.equals(_o_.pos);
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.uniqueid;
        _h_ += this.baseid;
        _h_ += this.pos.hashCode();
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.uniqueid).append(",");
        _sb_.append(this.baseid).append(",");
        _sb_.append(this.pos).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(PickUpItem _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.uniqueid - _o_.uniqueid);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.baseid - _o_.baseid;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.pos.compareTo(_o_.pos);
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}

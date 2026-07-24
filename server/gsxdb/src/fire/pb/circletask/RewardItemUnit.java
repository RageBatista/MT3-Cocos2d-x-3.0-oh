//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RewardItemUnit implements Marshal, Comparable<RewardItemUnit> {
    public int baseid;
    public int num;

    public RewardItemUnit() {
    }

    public RewardItemUnit(int _baseid_, int _num_) {
        this.baseid = _baseid_;
        this.num = _num_;
    }

    public final boolean _validator_() {
        if (this.baseid <= 0) {
            return false;
        } else {
            return this.num > 0;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.baseid);
        _os_.marshal(this.num);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.baseid = _os_.unmarshal_int();
        this.num = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof RewardItemUnit) {
            RewardItemUnit _o_ = (RewardItemUnit)_o1_;
            if (this.baseid != _o_.baseid) {
                return false;
            } else {
                return this.num == _o_.num;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.baseid;
        _h_ += this.num;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.baseid).append(",");
        _sb_.append(this.num).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(RewardItemUnit _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.baseid - _o_.baseid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.num - _o_.num;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

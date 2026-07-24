//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class TrackedMission implements Marshal, Comparable<TrackedMission> {
    public long acceptdate;

    public TrackedMission() {
    }

    public TrackedMission(long _acceptdate_) {
        this.acceptdate = _acceptdate_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.acceptdate);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.acceptdate = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof TrackedMission) {
            TrackedMission _o_ = (TrackedMission)_o1_;
            return this.acceptdate == _o_.acceptdate;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.acceptdate;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.acceptdate).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(TrackedMission _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.acceptdate - _o_.acceptdate);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}

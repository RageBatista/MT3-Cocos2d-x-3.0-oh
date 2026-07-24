//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class InstanceTimes implements Marshal, Comparable<InstanceTimes> {
    public int instanceid;
    public int finishedtimes;
    public int totaltimes;

    public InstanceTimes() {
    }

    public InstanceTimes(int _instanceid_, int _finishedtimes_, int _totaltimes_) {
        this.instanceid = _instanceid_;
        this.finishedtimes = _finishedtimes_;
        this.totaltimes = _totaltimes_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.instanceid);
        _os_.marshal(this.finishedtimes);
        _os_.marshal(this.totaltimes);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.instanceid = _os_.unmarshal_int();
        this.finishedtimes = _os_.unmarshal_int();
        this.totaltimes = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof InstanceTimes) {
            InstanceTimes _o_ = (InstanceTimes)_o1_;
            if (this.instanceid != _o_.instanceid) {
                return false;
            } else if (this.finishedtimes != _o_.finishedtimes) {
                return false;
            } else {
                return this.totaltimes == _o_.totaltimes;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.instanceid;
        _h_ += this.finishedtimes;
        _h_ += this.totaltimes;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.instanceid).append(",");
        _sb_.append(this.finishedtimes).append(",");
        _sb_.append(this.totaltimes).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(InstanceTimes _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.instanceid - _o_.instanceid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.finishedtimes - _o_.finishedtimes;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.totaltimes - _o_.totaltimes;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}

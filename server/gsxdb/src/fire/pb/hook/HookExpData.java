//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.hook;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class HookExpData implements Marshal, Comparable<HookExpData> {
    public short cangetdpoint;
    public short getdpoint;
    public long offlineexp;

    public HookExpData() {
    }

    public HookExpData(short _cangetdpoint_, short _getdpoint_, long _offlineexp_) {
        this.cangetdpoint = _cangetdpoint_;
        this.getdpoint = _getdpoint_;
        this.offlineexp = _offlineexp_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.cangetdpoint);
        _os_.marshal(this.getdpoint);
        _os_.marshal(this.offlineexp);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.cangetdpoint = _os_.unmarshal_short();
        this.getdpoint = _os_.unmarshal_short();
        this.offlineexp = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof HookExpData) {
            HookExpData _o_ = (HookExpData)_o1_;
            if (this.cangetdpoint != _o_.cangetdpoint) {
                return false;
            } else if (this.getdpoint != _o_.getdpoint) {
                return false;
            } else {
                return this.offlineexp == _o_.offlineexp;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.cangetdpoint;
        _h_ += this.getdpoint;
        _h_ += (int)this.offlineexp;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.cangetdpoint).append(",");
        _sb_.append(this.getdpoint).append(",");
        _sb_.append(this.offlineexp).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(HookExpData _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.cangetdpoint - _o_.cangetdpoint;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.getdpoint - _o_.getdpoint;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = Long.signum(this.offlineexp - _o_.offlineexp);
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}

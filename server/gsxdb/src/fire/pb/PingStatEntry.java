//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class PingStatEntry implements Marshal, Comparable<PingStatEntry> {
    public short _max;
    public short _min;
    public short _avg;

    public PingStatEntry() {
    }

    public PingStatEntry(short __max_, short __min_, short __avg_) {
        this._max = __max_;
        this._min = __min_;
        this._avg = __avg_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this._max);
        _os_.marshal(this._min);
        _os_.marshal(this._avg);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this._max = _os_.unmarshal_short();
        this._min = _os_.unmarshal_short();
        this._avg = _os_.unmarshal_short();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof PingStatEntry) {
            PingStatEntry _o_ = (PingStatEntry)_o1_;
            if (this._max != _o_._max) {
                return false;
            } else if (this._min != _o_._min) {
                return false;
            } else {
                return this._avg == _o_._avg;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this._max;
        _h_ += this._min;
        _h_ += this._avg;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this._max).append(",");
        _sb_.append(this._min).append(",");
        _sb_.append(this._avg).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(PingStatEntry _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this._max - _o_._max;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this._min - _o_._min;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this._avg - _o_._avg;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}

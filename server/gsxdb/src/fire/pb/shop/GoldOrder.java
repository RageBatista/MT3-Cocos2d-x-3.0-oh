//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class GoldOrder implements Marshal, Comparable<GoldOrder> {
    public long pid;
    public long number;
    public long price;
    public int publicity;
    public int locktime;
    public int state;
    public long time;

    public GoldOrder() {
        this.pid = 0L;
        this.number = 0L;
        this.price = 0L;
        this.publicity = 0;
        this.locktime = 0;
        this.state = 0;
        this.time = 0L;
    }

    public GoldOrder(long _pid_, long _number_, long _price_, int _publicity_, int _locktime_, int _state_, long _time_) {
        this.pid = _pid_;
        this.number = _number_;
        this.price = _price_;
        this.publicity = _publicity_;
        this.locktime = _locktime_;
        this.state = _state_;
        this.time = _time_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.pid);
        _os_.marshal(this.number);
        _os_.marshal(this.price);
        _os_.marshal(this.publicity);
        _os_.marshal(this.locktime);
        _os_.marshal(this.state);
        _os_.marshal(this.time);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.pid = _os_.unmarshal_long();
        this.number = _os_.unmarshal_long();
        this.price = _os_.unmarshal_long();
        this.publicity = _os_.unmarshal_int();
        this.locktime = _os_.unmarshal_int();
        this.state = _os_.unmarshal_int();
        this.time = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof GoldOrder) {
            GoldOrder _o_ = (GoldOrder)_o1_;
            if (this.pid != _o_.pid) {
                return false;
            } else if (this.number != _o_.number) {
                return false;
            } else if (this.price != _o_.price) {
                return false;
            } else if (this.publicity != _o_.publicity) {
                return false;
            } else if (this.locktime != _o_.locktime) {
                return false;
            } else if (this.state != _o_.state) {
                return false;
            } else {
                return this.time == _o_.time;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.pid;
        _h_ += (int)this.number;
        _h_ += (int)this.price;
        _h_ += this.publicity;
        _h_ += this.locktime;
        _h_ += this.state;
        _h_ += (int)this.time;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.pid).append(",");
        _sb_.append(this.number).append(",");
        _sb_.append(this.price).append(",");
        _sb_.append(this.publicity).append(",");
        _sb_.append(this.locktime).append(",");
        _sb_.append(this.state).append(",");
        _sb_.append(this.time).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(GoldOrder _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.pid - _o_.pid);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = Long.signum(this.number - _o_.number);
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = Long.signum(this.price - _o_.price);
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.publicity - _o_.publicity;
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = this.locktime - _o_.locktime;
                            if (0 != _c_) {
                                return _c_;
                            } else {
                                _c_ = this.state - _o_.state;
                                if (0 != _c_) {
                                    return _c_;
                                } else {
                                    _c_ = Long.signum(this.time - _o_.time);
                                    return 0 != _c_ ? _c_ : _c_;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

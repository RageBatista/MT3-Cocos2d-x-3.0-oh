//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class InstanceInfo implements Marshal, Comparable<InstanceInfo> {
    public int id;
    public int instanceid;
    public int state;
    public int instancestate;
    public long starttime;
    public long endtime;
    public int finishedtimes;
    public int totaltimes;

    public InstanceInfo() {
    }

    public InstanceInfo(int _id_, int _instanceid_, int _state_, int _instancestate_, long _starttime_, long _endtime_, int _finishedtimes_, int _totaltimes_) {
        this.id = _id_;
        this.instanceid = _instanceid_;
        this.state = _state_;
        this.instancestate = _instancestate_;
        this.starttime = _starttime_;
        this.endtime = _endtime_;
        this.finishedtimes = _finishedtimes_;
        this.totaltimes = _totaltimes_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.id);
        _os_.marshal(this.instanceid);
        _os_.marshal(this.state);
        _os_.marshal(this.instancestate);
        _os_.marshal(this.starttime);
        _os_.marshal(this.endtime);
        _os_.marshal(this.finishedtimes);
        _os_.marshal(this.totaltimes);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.id = _os_.unmarshal_int();
        this.instanceid = _os_.unmarshal_int();
        this.state = _os_.unmarshal_int();
        this.instancestate = _os_.unmarshal_int();
        this.starttime = _os_.unmarshal_long();
        this.endtime = _os_.unmarshal_long();
        this.finishedtimes = _os_.unmarshal_int();
        this.totaltimes = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof InstanceInfo) {
            InstanceInfo _o_ = (InstanceInfo)_o1_;
            if (this.id != _o_.id) {
                return false;
            } else if (this.instanceid != _o_.instanceid) {
                return false;
            } else if (this.state != _o_.state) {
                return false;
            } else if (this.instancestate != _o_.instancestate) {
                return false;
            } else if (this.starttime != _o_.starttime) {
                return false;
            } else if (this.endtime != _o_.endtime) {
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
        _h_ += this.id;
        _h_ += this.instanceid;
        _h_ += this.state;
        _h_ += this.instancestate;
        _h_ += (int)this.starttime;
        _h_ += (int)this.endtime;
        _h_ += this.finishedtimes;
        _h_ += this.totaltimes;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.id).append(",");
        _sb_.append(this.instanceid).append(",");
        _sb_.append(this.state).append(",");
        _sb_.append(this.instancestate).append(",");
        _sb_.append(this.starttime).append(",");
        _sb_.append(this.endtime).append(",");
        _sb_.append(this.finishedtimes).append(",");
        _sb_.append(this.totaltimes).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(InstanceInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.id - _o_.id;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.instanceid - _o_.instanceid;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.state - _o_.state;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.instancestate - _o_.instancestate;
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = Long.signum(this.starttime - _o_.starttime);
                            if (0 != _c_) {
                                return _c_;
                            } else {
                                _c_ = Long.signum(this.endtime - _o_.endtime);
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
                }
            }
        }
    }
}

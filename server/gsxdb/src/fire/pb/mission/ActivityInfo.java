//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ActivityInfo implements Marshal, Comparable<ActivityInfo> {
    public int activityid;
    public int state;
    public int activitystate;
    public int finishtimes;
    public int nextid;
    public int nextnextid;

    public ActivityInfo() {
    }

    public ActivityInfo(int _activityid_, int _state_, int _activitystate_, int _finishtimes_, int _nextid_, int _nextnextid_) {
        this.activityid = _activityid_;
        this.state = _state_;
        this.activitystate = _activitystate_;
        this.finishtimes = _finishtimes_;
        this.nextid = _nextid_;
        this.nextnextid = _nextnextid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.activityid);
        _os_.marshal(this.state);
        _os_.marshal(this.activitystate);
        _os_.marshal(this.finishtimes);
        _os_.marshal(this.nextid);
        _os_.marshal(this.nextnextid);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.activityid = _os_.unmarshal_int();
        this.state = _os_.unmarshal_int();
        this.activitystate = _os_.unmarshal_int();
        this.finishtimes = _os_.unmarshal_int();
        this.nextid = _os_.unmarshal_int();
        this.nextnextid = _os_.unmarshal_int();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof ActivityInfo) {
            ActivityInfo _o_ = (ActivityInfo)_o1_;
            if (this.activityid != _o_.activityid) {
                return false;
            } else if (this.state != _o_.state) {
                return false;
            } else if (this.activitystate != _o_.activitystate) {
                return false;
            } else if (this.finishtimes != _o_.finishtimes) {
                return false;
            } else if (this.nextid != _o_.nextid) {
                return false;
            } else {
                return this.nextnextid == _o_.nextnextid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.activityid;
        _h_ += this.state;
        _h_ += this.activitystate;
        _h_ += this.finishtimes;
        _h_ += this.nextid;
        _h_ += this.nextnextid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.activityid).append(",");
        _sb_.append(this.state).append(",");
        _sb_.append(this.activitystate).append(",");
        _sb_.append(this.finishtimes).append(",");
        _sb_.append(this.nextid).append(",");
        _sb_.append(this.nextnextid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(ActivityInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.activityid - _o_.activityid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.state - _o_.state;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.activitystate - _o_.activitystate;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.finishtimes - _o_.finishtimes;
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = this.nextid - _o_.nextid;
                            if (0 != _c_) {
                                return _c_;
                            } else {
                                _c_ = this.nextnextid - _o_.nextnextid;
                                return 0 != _c_ ? _c_ : _c_;
                            }
                        }
                    }
                }
            }
        }
    }
}

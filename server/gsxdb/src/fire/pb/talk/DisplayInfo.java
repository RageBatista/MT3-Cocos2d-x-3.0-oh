//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.talk;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class DisplayInfo implements Marshal, Comparable<DisplayInfo> {
    public static final int DISPLAY_ITEM = 1;
    public static final int DISPLAY_PET = 2;
    public static final int DISPLAY_TASK = 8;
    public static final int DISPLAY_TEAM_APPLY = 9;
    public static final int DISPLAY_ROLL_ITEM = 11;
    public static final int DISPLAY_ACTIVITY_ANSWER = 12;
    public static final int DISPLAY_LIVEDIE = 13;
    public static final int DISPLAY_BATTLE = 14;
    public static final int DISPLAY_SACE_ROLE = 15;
    public int displaytype;
    public long roleid;
    public long shopid;
    public int counterid;
    public int uniqid;
    public long teamid;

    public DisplayInfo() {
    }

    public DisplayInfo(int _displaytype_, long _roleid_, long _shopid_, int _counterid_, int _uniqid_, long _teamid_) {
        this.displaytype = _displaytype_;
        this.roleid = _roleid_;
        this.shopid = _shopid_;
        this.counterid = _counterid_;
        this.uniqid = _uniqid_;
        this.teamid = _teamid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.displaytype);
        _os_.marshal(this.roleid);
        _os_.marshal(this.shopid);
        _os_.marshal(this.counterid);
        _os_.marshal(this.uniqid);
        _os_.marshal(this.teamid);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.displaytype = _os_.unmarshal_int();
        this.roleid = _os_.unmarshal_long();
        this.shopid = _os_.unmarshal_long();
        this.counterid = _os_.unmarshal_int();
        this.uniqid = _os_.unmarshal_int();
        this.teamid = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof DisplayInfo) {
            DisplayInfo _o_ = (DisplayInfo)_o1_;
            if (this.displaytype != _o_.displaytype) {
                return false;
            } else if (this.roleid != _o_.roleid) {
                return false;
            } else if (this.shopid != _o_.shopid) {
                return false;
            } else if (this.counterid != _o_.counterid) {
                return false;
            } else if (this.uniqid != _o_.uniqid) {
                return false;
            } else {
                return this.teamid == _o_.teamid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.displaytype;
        _h_ += (int)this.roleid;
        _h_ += (int)this.shopid;
        _h_ += this.counterid;
        _h_ += this.uniqid;
        _h_ += (int)this.teamid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.displaytype).append(",");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.shopid).append(",");
        _sb_.append(this.counterid).append(",");
        _sb_.append(this.uniqid).append(",");
        _sb_.append(this.teamid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(DisplayInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.displaytype - _o_.displaytype;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = Long.signum(this.roleid - _o_.roleid);
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = Long.signum(this.shopid - _o_.shopid);
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.counterid - _o_.counterid;
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = this.uniqid - _o_.uniqid;
                            if (0 != _c_) {
                                return _c_;
                            } else {
                                _c_ = Long.signum(this.teamid - _o_.teamid);
                                return 0 != _c_ ? _c_ : _c_;
                            }
                        }
                    }
                }
            }
        }
    }
}

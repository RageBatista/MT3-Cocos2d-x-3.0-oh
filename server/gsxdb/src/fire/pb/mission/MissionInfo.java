//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class MissionInfo implements Marshal, Comparable<MissionInfo> {
    public int missionid;
    public int missionstatus;
    public int missionvalue;
    public int missionround;
    public long dstnpckey;

    public MissionInfo() {
    }

    public MissionInfo(int _missionid_, int _missionstatus_, int _missionvalue_, int _missionround_, long _dstnpckey_) {
        this.missionid = _missionid_;
        this.missionstatus = _missionstatus_;
        this.missionvalue = _missionvalue_;
        this.missionround = _missionround_;
        this.dstnpckey = _dstnpckey_;
    }

    public final boolean _validator_() {
        if (this.missionid < 0) {
            return false;
        } else if (this.missionstatus < 0) {
            return false;
        } else {
            return this.dstnpckey >= 0L;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.missionid);
        _os_.marshal(this.missionstatus);
        _os_.marshal(this.missionvalue);
        _os_.marshal(this.missionround);
        _os_.marshal(this.dstnpckey);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.missionid = _os_.unmarshal_int();
        this.missionstatus = _os_.unmarshal_int();
        this.missionvalue = _os_.unmarshal_int();
        this.missionround = _os_.unmarshal_int();
        this.dstnpckey = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof MissionInfo) {
            MissionInfo _o_ = (MissionInfo)_o1_;
            if (this.missionid != _o_.missionid) {
                return false;
            } else if (this.missionstatus != _o_.missionstatus) {
                return false;
            } else if (this.missionvalue != _o_.missionvalue) {
                return false;
            } else if (this.missionround != _o_.missionround) {
                return false;
            } else {
                return this.dstnpckey == _o_.dstnpckey;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.missionid;
        _h_ += this.missionstatus;
        _h_ += this.missionvalue;
        _h_ += this.missionround;
        _h_ += (int)this.dstnpckey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.missionid).append(",");
        _sb_.append(this.missionstatus).append(",");
        _sb_.append(this.missionvalue).append(",");
        _sb_.append(this.missionround).append(",");
        _sb_.append(this.dstnpckey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(MissionInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.missionid - _o_.missionid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.missionstatus - _o_.missionstatus;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.missionvalue - _o_.missionvalue;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.missionround - _o_.missionround;
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = Long.signum(this.dstnpckey - _o_.dstnpckey);
                            return 0 != _c_ ? _c_ : _c_;
                        }
                    }
                }
            }
        }
    }
}

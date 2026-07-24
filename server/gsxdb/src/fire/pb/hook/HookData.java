//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.hook;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class HookData implements Marshal, Comparable<HookData> {
    public short cangetdpoint;
    public short getdpoint;
    public byte isautobattle;
    public short charoptype;
    public int charopid;
    public short petoptype;
    public int petopid;
    public long offlineexp;

    public HookData() {
    }

    public HookData(short _cangetdpoint_, short _getdpoint_, byte _isautobattle_, short _charoptype_, int _charopid_, short _petoptype_, int _petopid_, long _offlineexp_) {
        this.cangetdpoint = _cangetdpoint_;
        this.getdpoint = _getdpoint_;
        this.isautobattle = _isautobattle_;
        this.charoptype = _charoptype_;
        this.charopid = _charopid_;
        this.petoptype = _petoptype_;
        this.petopid = _petopid_;
        this.offlineexp = _offlineexp_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.cangetdpoint);
        _os_.marshal(this.getdpoint);
        _os_.marshal(this.isautobattle);
        _os_.marshal(this.charoptype);
        _os_.marshal(this.charopid);
        _os_.marshal(this.petoptype);
        _os_.marshal(this.petopid);
        _os_.marshal(this.offlineexp);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.cangetdpoint = _os_.unmarshal_short();
        this.getdpoint = _os_.unmarshal_short();
        this.isautobattle = _os_.unmarshal_byte();
        this.charoptype = _os_.unmarshal_short();
        this.charopid = _os_.unmarshal_int();
        this.petoptype = _os_.unmarshal_short();
        this.petopid = _os_.unmarshal_int();
        this.offlineexp = _os_.unmarshal_long();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof HookData) {
            HookData _o_ = (HookData)_o1_;
            if (this.cangetdpoint != _o_.cangetdpoint) {
                return false;
            } else if (this.getdpoint != _o_.getdpoint) {
                return false;
            } else if (this.isautobattle != _o_.isautobattle) {
                return false;
            } else if (this.charoptype != _o_.charoptype) {
                return false;
            } else if (this.charopid != _o_.charopid) {
                return false;
            } else if (this.petoptype != _o_.petoptype) {
                return false;
            } else if (this.petopid != _o_.petopid) {
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
        _h_ += this.isautobattle;
        _h_ += this.charoptype;
        _h_ += this.charopid;
        _h_ += this.petoptype;
        _h_ += this.petopid;
        _h_ += (int)this.offlineexp;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.cangetdpoint).append(",");
        _sb_.append(this.getdpoint).append(",");
        _sb_.append(this.isautobattle).append(",");
        _sb_.append(this.charoptype).append(",");
        _sb_.append(this.charopid).append(",");
        _sb_.append(this.petoptype).append(",");
        _sb_.append(this.petopid).append(",");
        _sb_.append(this.offlineexp).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(HookData _o_) {
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
                    _c_ = this.isautobattle - _o_.isautobattle;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.charoptype - _o_.charoptype;
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = this.charopid - _o_.charopid;
                            if (0 != _c_) {
                                return _c_;
                            } else {
                                _c_ = this.petoptype - _o_.petoptype;
                                if (0 != _c_) {
                                    return _c_;
                                } else {
                                    _c_ = this.petopid - _o_.petopid;
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
                }
            }
        }
    }
}

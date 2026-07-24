//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SPetSetAutoAddPoint extends __SPetSetAutoAddPoint__ {
    public static final int PROTOCOL_TYPE = 788513;
    public int petkey;
    public int str;
    public int iq;
    public int cons;
    public int endu;
    public int agi;

    protected void process() {
    }

    public int getType() {
        return 788513;
    }

    public SPetSetAutoAddPoint() {
    }

    public SPetSetAutoAddPoint(int _petkey_, int _str_, int _iq_, int _cons_, int _endu_, int _agi_) {
        this.petkey = _petkey_;
        this.str = _str_;
        this.iq = _iq_;
        this.cons = _cons_;
        this.endu = _endu_;
        this.agi = _agi_;
    }

    public final boolean _validator_() {
        if (this.petkey < 1) {
            return false;
        } else if (this.str < 0) {
            return false;
        } else if (this.iq < 0) {
            return false;
        } else if (this.cons < 0) {
            return false;
        } else if (this.endu < 0) {
            return false;
        } else {
            return this.agi >= 0;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.marshal(this.str);
            _os_.marshal(this.iq);
            _os_.marshal(this.cons);
            _os_.marshal(this.endu);
            _os_.marshal(this.agi);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        this.str = _os_.unmarshal_int();
        this.iq = _os_.unmarshal_int();
        this.cons = _os_.unmarshal_int();
        this.endu = _os_.unmarshal_int();
        this.agi = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SPetSetAutoAddPoint) {
            SPetSetAutoAddPoint _o_ = (SPetSetAutoAddPoint)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else if (this.str != _o_.str) {
                return false;
            } else if (this.iq != _o_.iq) {
                return false;
            } else if (this.cons != _o_.cons) {
                return false;
            } else if (this.endu != _o_.endu) {
                return false;
            } else {
                return this.agi == _o_.agi;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += this.str;
        _h_ += this.iq;
        _h_ += this.cons;
        _h_ += this.endu;
        _h_ += this.agi;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.str).append(",");
        _sb_.append(this.iq).append(",");
        _sb_.append(this.cons).append(",");
        _sb_.append(this.endu).append(",");
        _sb_.append(this.agi).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SPetSetAutoAddPoint _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.petkey - _o_.petkey;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.str - _o_.str;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.iq - _o_.iq;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.cons - _o_.cons;
                        if (0 != _c_) {
                            return _c_;
                        } else {
                            _c_ = this.endu - _o_.endu;
                            if (0 != _c_) {
                                return _c_;
                            } else {
                                _c_ = this.agi - _o_.agi;
                                return 0 != _c_ ? _c_ : _c_;
                            }
                        }
                    }
                }
            }
        }
    }
}

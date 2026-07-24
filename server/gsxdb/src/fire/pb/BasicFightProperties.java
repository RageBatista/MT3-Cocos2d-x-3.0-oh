//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class BasicFightProperties implements Marshal, Comparable<BasicFightProperties> {
    public short cons;
    public short iq;
    public short str;
    public short endu;
    public short agi;

    public BasicFightProperties() {
    }

    public BasicFightProperties(short _cons_, short _iq_, short _str_, short _endu_, short _agi_) {
        this.cons = _cons_;
        this.iq = _iq_;
        this.str = _str_;
        this.endu = _endu_;
        this.agi = _agi_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.cons);
        _os_.marshal(this.iq);
        _os_.marshal(this.str);
        _os_.marshal(this.endu);
        _os_.marshal(this.agi);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.cons = _os_.unmarshal_short();
        this.iq = _os_.unmarshal_short();
        this.str = _os_.unmarshal_short();
        this.endu = _os_.unmarshal_short();
        this.agi = _os_.unmarshal_short();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof BasicFightProperties) {
            BasicFightProperties _o_ = (BasicFightProperties)_o1_;
            if (this.cons != _o_.cons) {
                return false;
            } else if (this.iq != _o_.iq) {
                return false;
            } else if (this.str != _o_.str) {
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
        _h_ += this.cons;
        _h_ += this.iq;
        _h_ += this.str;
        _h_ += this.endu;
        _h_ += this.agi;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.cons).append(",");
        _sb_.append(this.iq).append(",");
        _sb_.append(this.str).append(",");
        _sb_.append(this.endu).append(",");
        _sb_.append(this.agi).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(BasicFightProperties _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.cons - _o_.cons;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.iq - _o_.iq;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.str - _o_.str;
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

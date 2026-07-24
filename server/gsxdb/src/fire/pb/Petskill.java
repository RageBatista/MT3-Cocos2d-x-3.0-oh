//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class Petskill implements Marshal, Comparable<Petskill> {
    public int skillid;
    public int skillexp;
    public byte skilltype;
    public byte certification;

    public Petskill() {
    }

    public Petskill(int _skillid_, int _skillexp_, byte _skilltype_, byte _certification_) {
        this.skillid = _skillid_;
        this.skillexp = _skillexp_;
        this.skilltype = _skilltype_;
        this.certification = _certification_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        _os_.marshal(this.skillid);
        _os_.marshal(this.skillexp);
        _os_.marshal(this.skilltype);
        _os_.marshal(this.certification);
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.skillid = _os_.unmarshal_int();
        this.skillexp = _os_.unmarshal_int();
        this.skilltype = _os_.unmarshal_byte();
        this.certification = _os_.unmarshal_byte();
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof Petskill) {
            Petskill _o_ = (Petskill)_o1_;
            if (this.skillid != _o_.skillid) {
                return false;
            } else if (this.skillexp != _o_.skillexp) {
                return false;
            } else if (this.skilltype != _o_.skilltype) {
                return false;
            } else {
                return this.certification == _o_.certification;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.skillid;
        _h_ += this.skillexp;
        _h_ += this.skilltype;
        _h_ += this.certification;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.skillid).append(",");
        _sb_.append(this.skillexp).append(",");
        _sb_.append(this.skilltype).append(",");
        _sb_.append(this.certification).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(Petskill _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.skillid - _o_.skillid;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.skillexp - _o_.skillexp;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.skilltype - _o_.skilltype;
                    if (0 != _c_) {
                        return _c_;
                    } else {
                        _c_ = this.certification - _o_.certification;
                        return 0 != _c_ ? _c_ : _c_;
                    }
                }
            }
        }
    }
}

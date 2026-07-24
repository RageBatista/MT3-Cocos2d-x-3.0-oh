//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SSetMyFormation extends __SSetMyFormation__ {
    public static final int PROTOCOL_TYPE = 794475;
    public int formation;
    public int entersend;

    protected void process() {
    }

    public int getType() {
        return 794475;
    }

    public SSetMyFormation() {
    }

    public SSetMyFormation(int _formation_, int _entersend_) {
        this.formation = _formation_;
        this.entersend = _entersend_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.formation);
            _os_.marshal(this.entersend);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.formation = _os_.unmarshal_int();
        this.entersend = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SSetMyFormation) {
            SSetMyFormation _o_ = (SSetMyFormation)_o1_;
            if (this.formation != _o_.formation) {
                return false;
            } else {
                return this.entersend == _o_.entersend;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.formation;
        _h_ += this.entersend;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.formation).append(",");
        _sb_.append(this.entersend).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SSetMyFormation _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.formation - _o_.formation;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.entersend - _o_.entersend;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

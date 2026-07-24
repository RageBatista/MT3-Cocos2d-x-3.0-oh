//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SSetTeamFormation extends __SSetTeamFormation__ {
    public static final int PROTOCOL_TYPE = 794465;
    public int formation;
    public int formationlevel;
    public byte msg;

    protected void process() {
    }

    public int getType() {
        return 794465;
    }

    public SSetTeamFormation() {
    }

    public SSetTeamFormation(int _formation_, int _formationlevel_, byte _msg_) {
        this.formation = _formation_;
        this.formationlevel = _formationlevel_;
        this.msg = _msg_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.formation);
            _os_.marshal(this.formationlevel);
            _os_.marshal(this.msg);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.formation = _os_.unmarshal_int();
        this.formationlevel = _os_.unmarshal_int();
        this.msg = _os_.unmarshal_byte();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SSetTeamFormation) {
            SSetTeamFormation _o_ = (SSetTeamFormation)_o1_;
            if (this.formation != _o_.formation) {
                return false;
            } else if (this.formationlevel != _o_.formationlevel) {
                return false;
            } else {
                return this.msg == _o_.msg;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.formation;
        _h_ += this.formationlevel;
        _h_ += this.msg;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.formation).append(",");
        _sb_.append(this.formationlevel).append(",");
        _sb_.append(this.msg).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SSetTeamFormation _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.formation - _o_.formation;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.formationlevel - _o_.formationlevel;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.msg - _o_.msg;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}

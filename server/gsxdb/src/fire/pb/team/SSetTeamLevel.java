//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SSetTeamLevel extends __SSetTeamLevel__ {
    public static final int PROTOCOL_TYPE = 794463;
    public int minlevel;
    public int maxlevel;

    protected void process() {
    }

    public int getType() {
        return 794463;
    }

    public SSetTeamLevel() {
    }

    public SSetTeamLevel(int _minlevel_, int _maxlevel_) {
        this.minlevel = _minlevel_;
        this.maxlevel = _maxlevel_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.minlevel);
            _os_.marshal(this.maxlevel);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.minlevel = _os_.unmarshal_int();
        this.maxlevel = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SSetTeamLevel) {
            SSetTeamLevel _o_ = (SSetTeamLevel)_o1_;
            if (this.minlevel != _o_.minlevel) {
                return false;
            } else {
                return this.maxlevel == _o_.maxlevel;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.minlevel;
        _h_ += this.maxlevel;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.minlevel).append(",");
        _sb_.append(this.maxlevel).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SSetTeamLevel _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.minlevel - _o_.minlevel;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.maxlevel - _o_.maxlevel;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

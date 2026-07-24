//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CRequestSetFormation extends __CRequestSetFormation__ {
    public static final int PROTOCOL_TYPE = 794464;
    public int formation;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId > 0L) {
            (new PSetFormationProc(roleId, this.formation)).submit();
        }

    }

    public int getType() {
        return 794464;
    }

    public CRequestSetFormation() {
    }

    public CRequestSetFormation(int _formation_) {
        this.formation = _formation_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.formation);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.formation = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CRequestSetFormation) {
            CRequestSetFormation _o_ = (CRequestSetFormation)_o1_;
            return this.formation == _o_.formation;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.formation;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.formation).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CRequestSetFormation _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.formation - _o_.formation;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SOneKeyTeamMatch extends __SOneKeyTeamMatch__ {
    public static final int PROTOCOL_TYPE = 794500;
    public int ret;

    protected void process() {
    }

    public int getType() {
        return 794500;
    }

    public SOneKeyTeamMatch() {
    }

    public SOneKeyTeamMatch(int _ret_) {
        this.ret = _ret_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.ret);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.ret = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SOneKeyTeamMatch) {
            SOneKeyTeamMatch _o_ = (SOneKeyTeamMatch)_o1_;
            return this.ret == _o_.ret;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.ret;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.ret).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SOneKeyTeamMatch _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.ret - _o_.ret;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}

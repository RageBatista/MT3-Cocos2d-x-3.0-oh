//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class STeamError extends __STeamError__ {
    public static final int PROTOCOL_TYPE = 794468;
    public int teamerror;

    protected void process() {
    }

    public int getType() {
        return 794468;
    }

    public STeamError() {
    }

    public STeamError(int _teamerror_) {
        this.teamerror = _teamerror_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.teamerror);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.teamerror = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof STeamError) {
            STeamError _o_ = (STeamError)_o1_;
            return this.teamerror == _o_.teamerror;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.teamerror;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.teamerror).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(STeamError _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.teamerror - _o_.teamerror;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}

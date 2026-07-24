//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SAskforSetLeader extends __SAskforSetLeader__ {
    public static final int PROTOCOL_TYPE = 794454;
    public long leaderid;

    protected void process() {
    }

    public int getType() {
        return 794454;
    }

    public SAskforSetLeader() {
    }

    public SAskforSetLeader(long _leaderid_) {
        this.leaderid = _leaderid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.leaderid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.leaderid = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SAskforSetLeader) {
            SAskforSetLeader _o_ = (SAskforSetLeader)_o1_;
            return this.leaderid == _o_.leaderid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.leaderid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.leaderid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SAskforSetLeader _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.leaderid - _o_.leaderid);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}

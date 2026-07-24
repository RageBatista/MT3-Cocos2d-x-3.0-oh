//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CPetRecover extends __CPetRecover__ {
    public static final int PROTOCOL_TYPE = 788585;
    public long uniqid;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            PPetRecover proc = new PPetRecover(roleId, this.uniqid);
            proc.submit();
        }
    }

    public int getType() {
        return 788585;
    }

    public CPetRecover() {
    }

    public CPetRecover(long _uniqid_) {
        this.uniqid = _uniqid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.uniqid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.uniqid = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CPetRecover) {
            CPetRecover _o_ = (CPetRecover)_o1_;
            return this.uniqid == _o_.uniqid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.uniqid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.uniqid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CPetRecover _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.uniqid - _o_.uniqid);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}

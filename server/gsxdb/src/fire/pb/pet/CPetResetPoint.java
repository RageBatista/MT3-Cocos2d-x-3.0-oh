//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CPetResetPoint extends __CPetResetPoint__ {
    public static final int PROTOCOL_TYPE = 788514;
    public int petkey;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            PPetResetPoint proc = new PPetResetPoint(roleid, this.petkey);
            proc.submit();
        }
    }

    public int getType() {
        return 788514;
    }

    public CPetResetPoint() {
    }

    public CPetResetPoint(int _petkey_) {
        this.petkey = _petkey_;
    }

    public final boolean _validator_() {
        return this.petkey >= 1;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CPetResetPoint) {
            CPetResetPoint _o_ = (CPetResetPoint)_o1_;
            return this.petkey == _o_.petkey;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CPetResetPoint _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.petkey - _o_.petkey;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}

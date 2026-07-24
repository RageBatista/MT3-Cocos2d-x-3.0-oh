//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.product;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CMakexyEquip extends __CMakexyEquip__ {
    public static final int PROTOCOL_TYPE = 800097;
    public int equipid;
    public short maketype;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            PMakexyEquip pmakeEquip = new PMakexyEquip(roleid, this.equipid);
            pmakeEquip.submit();
        }
    }

    public int getType() {
        return 800097;
    }

    public CMakexyEquip() {
    }

    public CMakexyEquip(int _equipid_, short _maketype_) {
        this.equipid = _equipid_;
        this.maketype = _maketype_;
    }

    public final boolean _validator_() {
        if (this.equipid < 1) {
            return false;
        } else {
            return this.maketype >= 0;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.equipid);
            _os_.marshal(this.maketype);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.equipid = _os_.unmarshal_int();
        this.maketype = _os_.unmarshal_short();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CMakexyEquip) {
            CMakexyEquip _o_ = (CMakexyEquip)_o1_;
            if (this.equipid != _o_.equipid) {
                return false;
            } else {
                return this.maketype == _o_.maketype;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.equipid;
        _h_ += this.maketype;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.equipid).append(",");
        _sb_.append(this.maketype).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CMakexyEquip _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = this.equipid - _o_.equipid;
            if (_c_ != 0) {
                return _c_;
            } else {
                _c_ = this.maketype - _o_.maketype;
                return _c_ != 0 ? _c_ : _c_;
            }
        }
    }
}

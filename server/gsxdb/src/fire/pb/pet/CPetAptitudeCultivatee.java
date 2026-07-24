//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CPetAptitudeCultivatee extends __CPetAptitudeCultivatee__ {
    public static final int PROTOCOL_TYPE = 817963;
    public int petkey;
    public int aptid;
    public int itemkey;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            PPetAptitudeCultivatee proc = new PPetAptitudeCultivatee(roleid, this.petkey, this.aptid, this.itemkey);
            proc.submit();
        }
    }

    public int getType() {
        return 817963;
    }

    public CPetAptitudeCultivatee() {
    }

    public CPetAptitudeCultivatee(int _petkey_, int _aptid_, int _itemkey_) {
        this.petkey = _petkey_;
        this.aptid = _aptid_;
        this.itemkey = _itemkey_;
    }

    public final boolean _validator_() {
        if (this.petkey < 1) {
            return false;
        } else if (this.aptid < 0) {
            return false;
        } else {
            return this.itemkey >= 1;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.marshal(this.aptid);
            _os_.marshal(this.itemkey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        this.aptid = _os_.unmarshal_int();
        this.itemkey = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CPetAptitudeCultivatee) {
            CPetAptitudeCultivatee _o_ = (CPetAptitudeCultivatee)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else if (this.aptid != _o_.aptid) {
                return false;
            } else {
                return this.itemkey == _o_.itemkey;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += this.aptid;
        _h_ += this.itemkey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.aptid).append(",");
        _sb_.append(this.itemkey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CPetAptitudeCultivatee _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.petkey - _o_.petkey;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.aptid - _o_.aptid;
                if (0 != _c_) {
                    return _c_;
                } else {
                    _c_ = this.itemkey - _o_.itemkey;
                    return 0 != _c_ ? _c_ : _c_;
                }
            }
        }
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CPetLevelUpInternal extends __CPetLevelUpInternal__ {
    public static final int PROTOCOL_TYPE = 788531;
    public int petkey;
    public int internalid;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            PPetLevelUpInternal proc = new PPetLevelUpInternal(roleid, this.petkey, this.internalid);
            proc.submit();
        }
    }

    public int getType() {
        return 788531;
    }

    public CPetLevelUpInternal() {
    }

    public CPetLevelUpInternal(int _petkey_, int _internalid_) {
        this.petkey = _petkey_;
        this.internalid = _internalid_;
    }

    public final boolean _validator_() {
        if (this.petkey < 1) {
            return false;
        } else {
            return this.internalid >= 1;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.marshal(this.internalid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        this.internalid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CPetLevelUpInternal) {
            CPetLevelUpInternal _o_ = (CPetLevelUpInternal)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else {
                return this.internalid == _o_.internalid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += this.internalid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.internalid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CPetLevelUpInternal _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = this.petkey - _o_.petkey;
            if (_c_ != 0) {
                return _c_;
            } else {
                _c_ = this.internalid - _o_.internalid;
                return _c_ != 0 ? _c_ : _c_;
            }
        }
    }
}

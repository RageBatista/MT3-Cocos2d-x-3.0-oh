//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CPetHuanHua extends __CPetHuanHua__ {
    public static final int PROTOCOL_TYPE = 817941;
    public int petkey;
    public int resultkey;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            PPetHuanHua proc = new PPetHuanHua(roleid, this.petkey, this.resultkey);
            proc.submit();
        }
    }

    public int getType() {
        return 817941;
    }

    public CPetHuanHua() {
    }

    public CPetHuanHua(int _petkey_, int _resultkey_) {
        this.petkey = _petkey_;
        this.resultkey = _resultkey_;
    }

    public final boolean _validator_() {
        if (this.petkey < 1) {
            return false;
        } else {
            return this.resultkey >= 1;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.marshal(this.resultkey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        this.resultkey = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CPetHuanHua) {
            CPetHuanHua _o_ = (CPetHuanHua)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else {
                return this.resultkey == _o_.resultkey;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += this.resultkey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.resultkey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CPetHuanHua _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            int var10000 = this.petkey - _o_.petkey;
            _c_ = this.resultkey - _o_.resultkey;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}

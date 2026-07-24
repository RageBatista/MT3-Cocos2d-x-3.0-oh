//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CPetSynthesize extends __CPetSynthesize__ {
    public static final int PROTOCOL_TYPE = 788517;
    public int petkey1;
    public int petkey2;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            PPetSynthesizeProc proc = new PPetSynthesizeProc(roleid, this.petkey1, this.petkey2);
            proc.submit();
        }
    }

    public int getType() {
        return 788517;
    }

    public CPetSynthesize() {
    }

    public CPetSynthesize(int _petkey1_, int _petkey2_) {
        this.petkey1 = _petkey1_;
        this.petkey2 = _petkey2_;
    }

    public final boolean _validator_() {
        if (this.petkey1 < 1) {
            return false;
        } else {
            return this.petkey2 >= 1;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey1);
            _os_.marshal(this.petkey2);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey1 = _os_.unmarshal_int();
        this.petkey2 = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CPetSynthesize) {
            CPetSynthesize _o_ = (CPetSynthesize)_o1_;
            if (this.petkey1 != _o_.petkey1) {
                return false;
            } else {
                return this.petkey2 == _o_.petkey2;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey1;
        _h_ += this.petkey2;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey1).append(",");
        _sb_.append(this.petkey2).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CPetSynthesize _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.petkey1 - _o_.petkey1;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.petkey2 - _o_.petkey2;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

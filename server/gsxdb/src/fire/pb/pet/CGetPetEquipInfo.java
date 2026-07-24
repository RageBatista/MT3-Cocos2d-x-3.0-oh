//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CGetPetEquipInfo extends __CGetPetEquipInfo__ {
    public static final int PROTOCOL_TYPE = 817937;
    public int petkey;
    public int pos;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L) {
            PGetEquipInfo proc = new PGetEquipInfo(roleid, this.petkey, this.pos);
            proc.submit();
        }
    }

    public int getType() {
        return 817937;
    }

    public CGetPetEquipInfo() {
    }

    public CGetPetEquipInfo(int _petkey_, int _bookkey_) {
        this.petkey = _petkey_;
    }

    public final boolean _validator_() {
        if (this.petkey < 1) {
            return false;
        } else {
            return this.pos >= 1;
        }
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.marshal(this.pos);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        this.pos = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CGetPetEquipInfo) {
            CGetPetEquipInfo _o_ = (CGetPetEquipInfo)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else {
                return this.pos == _o_.pos;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += this.pos;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.pos).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CGetPetEquipInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            int var10000 = this.petkey - _o_.petkey;
            _c_ = this.pos - _o_.pos;
            if (0 != _c_) {
                return _c_;
            } else {
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

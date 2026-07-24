//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CGetPetInfo extends __CGetPetInfo__ {
    public static final int PROTOCOL_TYPE = 788525;
    public long roleid;
    public int petkey;

    protected void process() {
        long reqRoleId = Onlines.getInstance().findRoleid(this);
        if (reqRoleId >= 0L) {
            PetColumn petCol = new PetColumn(this.roleid, 1, true);
            Pet pet = petCol.getPet(this.petkey);
            if (pet != null) {
                fire.pb.PetBean petMarshal = pet.getProtocolPet();
                SGetPetInfo send = new SGetPetInfo(petMarshal);
                Onlines.getInstance().send(reqRoleId, send);
            }
        }
    }

    public int getType() {
        return 788525;
    }

    public CGetPetInfo() {
    }

    public CGetPetInfo(long _roleid_, int _petkey_) {
        this.roleid = _roleid_;
        this.petkey = _petkey_;
    }

    public final boolean _validator_() {
        return this.petkey >= 1;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.roleid);
            _os_.marshal(this.petkey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.roleid = _os_.unmarshal_long();
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
        } else if (_o1_ instanceof CGetPetInfo) {
            CGetPetInfo _o_ = (CGetPetInfo)_o1_;
            if (this.roleid != _o_.roleid) {
                return false;
            } else {
                return this.petkey == _o_.petkey;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.roleid;
        _h_ += this.petkey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.roleid).append(",");
        _sb_.append(this.petkey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CGetPetInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.roleid - _o_.roleid);
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.petkey - _o_.petkey;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

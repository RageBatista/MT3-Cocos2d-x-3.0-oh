//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.PropRole;
import fire.pb.StateCommon;
import gnet.link.Onlines;

public class CShowPetInfo extends __CShowPetInfo__ {
    public static final int PROTOCOL_TYPE = 788456;
    public long masterid;

    protected void process() {
        long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid >= 0L && StateCommon.isOnline(roleid)) {
            PropRole propRole = new PropRole(this.masterid, true);
            if (propRole.getShowpetkey() > 0) {
                PetColumn petCol = new PetColumn(this.masterid, 1, true);
                SShowPetInfo send = new SShowPetInfo(0, petCol.getPet(propRole.getShowpetkey()).getProtocolPet());
                Onlines.getInstance().send(roleid, send);
            }

        }
    }

    public int getType() {
        return 788456;
    }

    public CShowPetInfo() {
    }

    public CShowPetInfo(long _masterid_) {
        this.masterid = _masterid_;
    }

    public final boolean _validator_() {
        return this.masterid >= 1L;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.masterid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.masterid = _os_.unmarshal_long();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CShowPetInfo) {
            CShowPetInfo _o_ = (CShowPetInfo)_o1_;
            return this.masterid == _o_.masterid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += (int)this.masterid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.masterid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CShowPetInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.masterid - _o_.masterid);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}

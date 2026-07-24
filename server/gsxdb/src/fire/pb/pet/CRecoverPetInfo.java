//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;
import mkdb.Procedure;
import xbean.DiscardPet;
import xbean.Petrecoverlist;
import xtable.Petrecover;
import xtable.Petrecyclebin;

public class CRecoverPetInfo extends __CRecoverPetInfo__ {
    public static final int PROTOCOL_TYPE = 788587;
    public long uniqid;

    protected void process() {
        final long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new Procedure() {
                protected boolean process() {
                    Petrecoverlist petRecoverList = Petrecover.select(roleId);
                    if (petRecoverList == null) {
                        return false;
                    } else if (!petRecoverList.getUniqids().contains(CRecoverPetInfo.this.uniqid)) {
                        return false;
                    } else {
                        DiscardPet discardPet = Petrecyclebin.select(CRecoverPetInfo.this.uniqid);
                        if (discardPet == null) {
                            return false;
                        } else {
                            Pet pet = Pet.getPet(discardPet.getPet());
                            SRecoverPetInfo send = new SRecoverPetInfo();
                            send.petinfo = pet.getProtocolPet();
                            Procedure.psendWhileCommit(roleId, send);
                            return true;
                        }
                    }
                }
            }).submit();
        }
    }

    public int getType() {
        return 788587;
    }

    public CRecoverPetInfo() {
    }

    public CRecoverPetInfo(long _uniqid_) {
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
        } else if (_o1_ instanceof CRecoverPetInfo) {
            CRecoverPetInfo _o_ = (CRecoverPetInfo)_o1_;
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

    public int compareTo(CRecoverPetInfo _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = Long.signum(this.uniqid - _o_.uniqid);
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}

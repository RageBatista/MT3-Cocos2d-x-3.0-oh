//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CAllEquipGemFenJie extends __CAllEquipGemFenJie__ {
    public static final int PROTOCOL_TYPE = 817955;
    public int fenjietype;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            PAllEquipGemFenJie pAllEquipGemFenJie = new PAllEquipGemFenJie(roleId, this.fenjietype);
            pAllEquipGemFenJie.submit();
        }
    }

    public int getType() {
        return 817955;
    }

    public CAllEquipGemFenJie() {
    }

    public CAllEquipGemFenJie(int _fenjietype_) {
        this.fenjietype = _fenjietype_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.fenjietype);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.fenjietype = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CAllEquipGemFenJie) {
            CAllEquipGemFenJie _o_ = (CAllEquipGemFenJie)_o1_;
            return this.fenjietype == _o_.fenjietype;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.fenjietype;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.fenjietype).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CAllEquipGemFenJie _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.fenjietype - _o_.fenjietype;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}

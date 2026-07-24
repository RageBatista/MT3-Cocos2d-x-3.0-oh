//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.school.change;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CEquipUpgrade extends __CEquipUpgrade__ {
    public static final int PROTOCOL_TYPE = 817959;
    public int oldkey;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new PEquipUpgrade(roleId, this.oldkey)).submit();
        }
    }

    public int getType() {
        return 817959;
    }

    public CEquipUpgrade() {
    }

    public CEquipUpgrade(int _oldkey_) {
        this.oldkey = _oldkey_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.oldkey);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.oldkey = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CEquipUpgrade) {
            CEquipUpgrade _o_ = (CEquipUpgrade)_o1_;
            return this.oldkey == _o_.oldkey;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.oldkey;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.oldkey).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CEquipUpgrade _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.oldkey - _o_.oldkey;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}

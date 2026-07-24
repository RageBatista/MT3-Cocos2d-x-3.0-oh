//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.school.change;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CChangeEquipEx extends __CChangeEquipEx__ {
    public static final int PROTOCOL_TYPE = 810495;
    public int srcweaponkey;
    public int newitemid;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new PChangeEquipEx(roleId, this.srcweaponkey, this.newitemid)).submit();
        }
    }

    public int getType() {
        return 810495;
    }

    public CChangeEquipEx() {
    }

    public CChangeEquipEx(int _srcweaponkey_, int _newitemid_) {
        this.srcweaponkey = _srcweaponkey_;
        this.newitemid = _newitemid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.srcweaponkey);
            _os_.marshal(this.newitemid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.srcweaponkey = _os_.unmarshal_int();
        this.newitemid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CChangeEquipEx) {
            CChangeEquipEx _o_ = (CChangeEquipEx)_o1_;
            if (this.srcweaponkey != _o_.srcweaponkey) {
                return false;
            } else {
                return this.newitemid == _o_.newitemid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.srcweaponkey;
        _h_ += this.newitemid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.srcweaponkey);
        _sb_.append(",");
        _sb_.append(this.newitemid);
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CChangeEquipEx _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            int var10000 = this.srcweaponkey - _o_.srcweaponkey;
            _c_ = this.newitemid - _o_.newitemid;
            return _c_ != 0 ? _c_ : _c_;
        }
    }
}

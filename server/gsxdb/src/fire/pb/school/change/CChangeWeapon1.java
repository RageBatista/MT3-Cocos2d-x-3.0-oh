//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.school.change;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;
import mkio.Protocol;
public class CChangeWeapon1 extends __CChangeWeapon1__ {
    public static final int PROTOCOL_TYPE = 810497;
    public int srcweaponkey;
    public int newweapontypeid;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new PChangeWeapon1(roleId, this.srcweaponkey, this.newweapontypeid)).submit();
        }
    }

    public int getType() {
        return 810497;
    }

    public CChangeWeapon1() {
    }

    public CChangeWeapon1(int _srcweaponkey_, int _newweapontypeid_) {
        this.srcweaponkey = _srcweaponkey_;
        this.newweapontypeid = _newweapontypeid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.srcweaponkey);
            _os_.marshal(this.newweapontypeid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.srcweaponkey = _os_.unmarshal_int();
        this.newweapontypeid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CChangeWeapon1) {
            CChangeWeapon1 _o_ = (CChangeWeapon1)_o1_;
            if (this.srcweaponkey != _o_.srcweaponkey) {
                return false;
            } else {
                return this.newweapontypeid == _o_.newweapontypeid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.srcweaponkey;
        _h_ += this.newweapontypeid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.srcweaponkey).append(",");
        _sb_.append(this.newweapontypeid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CChangeWeapon1 _o_) {
        if (_o_ == this) {
            return 0;
        } else {

            int _c_ = this.srcweaponkey - _o_.srcweaponkey;
            if (_c_ != 0) {
                return _c_;
            } else {
                _c_ = this.newweapontypeid - _o_.newweapontypeid;
                return _c_ != 0 ? _c_ : _c_;
            }
        }
    }
}

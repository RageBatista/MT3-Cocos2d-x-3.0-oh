//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet.shenshou;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CShenShouChongZhi extends __CShenShouChongZhi__ {
    public static final int PROTOCOL_TYPE = 788529;
    public int petkey;
    public int needpetid;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new PShenShouChongZhi(roleId, this.petkey, this.needpetid)).submit();
        }
    }

    public int getType() {
        return 788529;
    }

    public CShenShouChongZhi() {
    }

    public CShenShouChongZhi(int _petkey_, int _needpetid_) {
        this.petkey = _petkey_;
        this.needpetid = _needpetid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.petkey);
            _os_.marshal(this.needpetid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.petkey = _os_.unmarshal_int();
        this.needpetid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CShenShouChongZhi) {
            CShenShouChongZhi _o_ = (CShenShouChongZhi)_o1_;
            if (this.petkey != _o_.petkey) {
                return false;
            } else {
                return this.needpetid == _o_.needpetid;
            }
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.petkey;
        _h_ += this.needpetid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.petkey).append(",");
        _sb_.append(this.needpetid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CShenShouChongZhi _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.petkey - _o_.petkey;
            if (0 != _c_) {
                return _c_;
            } else {
                _c_ = this.needpetid - _o_.needpetid;
                return 0 != _c_ ? _c_ : _c_;
            }
        }
    }
}

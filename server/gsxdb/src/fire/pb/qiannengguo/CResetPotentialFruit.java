//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.qiannengguo;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.Logger;
import gnet.link.Onlines;

public class CResetPotentialFruit extends __CResetPotentialFruit__ {
    public static final Logger logger = Logger.getLogger("SYSTEM");
    public static final int PROTOCOL_TYPE = 810499;
    public int location;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new PResetPotentialFruit(roleId, this.location)).submit();
        }
    }

    public int getType() {
        return 810499;
    }

    public CResetPotentialFruit() {
    }

    public CResetPotentialFruit(int _location_) {
        this.location = _location_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.location);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.location = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CResetPotentialFruit) {
            CResetPotentialFruit _o_ = (CResetPotentialFruit)_o1_;
            return this.location == _o_.location;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0 + this.location;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.location).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CResetPotentialFruit _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = this.location - _o_.location;
            return 0 != _c_ ? _c_ : _c_;
        }
    }
}

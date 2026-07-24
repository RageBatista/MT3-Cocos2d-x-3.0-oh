//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.zuoqi;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CZuoQiShiYong extends __CZuoQiShiYong__ {
    public static final int PROTOCOL_TYPE = 800020;
    public int zuoqiid;
    public int moxing;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new shiyong(roleId, this.zuoqiid)).submit();
        }

    }

    public int getType() {
        return 800020;
    }

    public CZuoQiShiYong() {
    }

    public CZuoQiShiYong(int _shizhuangid_) {
        this.zuoqiid = _shizhuangid_;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.zuoqiid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.zuoqiid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CZuoQiShiYong) {
            CZuoQiShiYong _o_ = (CZuoQiShiYong)_o1_;
            return this.zuoqiid == _o_.zuoqiid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.zuoqiid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.zuoqiid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CZuoQiShiYong _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            _c_ = this.zuoqiid - _o_.zuoqiid;
            return _c_ != 0 ? _c_ : _c_;
        }
    }
}

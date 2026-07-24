//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.baichong;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import gnet.link.Onlines;

public class CWish extends __CWish__ {
    public static final int PROTOCOL_TYPE = 810020;
    public int times;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new PWish(roleId, this.times)).submit();
        }

    }

    public int getType() {
        return 810020;
    }

    public CWish() {
    }

    public CWish(int _times_) {
        this.times = _times_;
    }

    public final boolean _validator_() {
        return this.times >= 1;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.times);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.times = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof CWish) {
            CWish _o_ = (CWish)_o1_;
            return this.times == _o_.times;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0 + this.times;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.times).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CWish _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = this.times - _o_.times;
            return _c_ != 0 ? _c_ : _c_;
        }
    }
}

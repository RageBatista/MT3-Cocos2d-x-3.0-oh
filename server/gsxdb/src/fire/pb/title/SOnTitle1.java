//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.title;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SOnTitle1 extends __SOnTitle1__ {
    public static final int PROTOCOL_TYPE = 817982;
    public int titleid;

    protected void process() {
    }

    public int getType() {
        return 817982;
    }

    public SOnTitle1() {
    }

    public SOnTitle1(int _titleid_) {
        this.titleid = _titleid_;
    }

    public final boolean _validator_() {
        if (this.titleid < 0) {
            this.titleid = 0;
        }

        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.titleid);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.titleid = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SOnTitle1) {
            SOnTitle1 _o_ = (SOnTitle1)_o1_;
            return this.titleid == _o_.titleid;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.titleid;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.titleid).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }
}

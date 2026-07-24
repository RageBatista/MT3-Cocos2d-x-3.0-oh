//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.guaji;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class Sguaji extends __Sguaji__ {
    public static final int PROTOCOL_TYPE = 800002;
    public int guanbi;

    protected void process() {
    }

    public int getType() {
        return 800002;
    }

    public Sguaji() {
    }

    public Sguaji(int _guanbi_) {
        this.guanbi = _guanbi_;
    }

    public final boolean _validator_() {
        return this.guanbi >= 1;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.guanbi);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.guanbi = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof Sguaji) {
            Sguaji _o_ = (Sguaji)_o1_;
            return this.guanbi == _o_.guanbi;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        _h_ += this.guanbi;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.guanbi).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(Sguaji paramSXiLianEquip) {
        if (paramSXiLianEquip == this) {
            return 0;
        } else {
            int i = 0;
            i = this.guanbi - paramSXiLianEquip.guanbi;
            return 0 != i ? i : i;
        }
    }
}

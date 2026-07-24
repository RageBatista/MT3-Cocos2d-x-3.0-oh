//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.yichu;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SChangeYiChu extends __SChangeYiChu__ {
    public static final int PROTOCOL_TYPE = 800015;
    public int shape;

    protected void process() {
    }

    public int getType() {
        return 800015;
    }

    public SChangeYiChu() {
    }

    public SChangeYiChu(int _shape_) {
        this.shape = _shape_;
    }

    public final boolean _validator_() {
        return this.shape >= 1;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            _os_.marshal(this.shape);
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        this.shape = _os_.unmarshal_int();
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SChangeYiChu) {
            SChangeYiChu _o_ = (SChangeYiChu)_o1_;
            return this.shape == _o_.shape;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0 + this.shape;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(this.shape).append(",");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(SChangeYiChu paramSXiLianEquip) {
        if (paramSXiLianEquip == this) {
            return 0;
        } else {
            int i = this.shape - paramSXiLianEquip.shape;
            return i != 0 ? i : i;
        }
    }
}

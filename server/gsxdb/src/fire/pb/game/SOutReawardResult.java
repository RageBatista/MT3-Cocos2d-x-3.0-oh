//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SOutReawardResult extends __SOutReawardResult__ {
    public static final int PROTOCOL_TYPE = 817970;

    protected void process() {
    }

    public int getType() {
        return 817970;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream octetsStream) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return octetsStream;
        }
    }

    public OctetsStream unmarshal(OctetsStream octetsStream) throws MarshalException {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return octetsStream;
        }
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else if (_o1_ instanceof SOutReawardResult) {
            SOutReawardResult _o_ = (SOutReawardResult)_o1_;
            return true;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        return _h_;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.xilian;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SXiLianEquip extends __SXiLianEquip__ {
    public static final int PROTOCOL_TYPE = 810494;

    protected void process() {
    }

    public int getType() {
        return 810494;
    }

    public SXiLianEquip() {
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream var1) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return var1;
        }
    }

    public OctetsStream unmarshal(OctetsStream var1) throws MarshalException {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return var1;
        }
    }

    public boolean equals(Object var1) {
        if (var1 == this) {
            return true;
        } else {
            return var1 instanceof SXiLianEquip;
        }
    }

    public int hashCode() {
        byte var1 = 0;
        return var1;
    }

    public String toString() {
        StringBuilder var1 = new StringBuilder();
        var1.append("(");
        var1.append(")");
        return var1.toString();
    }

    public int compareTo(SXiLianEquip var1) {
        if (var1 == this) {
            return 0;
        } else {
            byte var2 = 0;
            return var2;
        }
    }
}

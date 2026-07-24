//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.qiannengguo;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ReturnData implements Marshal {
    public int useqiannengguonum;

    public ReturnData() {
        this.useqiannengguonum = 0;
    }

    public ReturnData(int var1) {
        this.useqiannengguonum = var1;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream var1) {
        var1.marshal(this.useqiannengguonum);
        return var1;
    }

    public OctetsStream unmarshal(OctetsStream var1) throws MarshalException {
        this.useqiannengguonum = var1.unmarshal_int();
        return var1;
    }

    public boolean equals(Object var1) {
        if (var1 == this) {
            return true;
        } else if (var1 instanceof ReturnData) {
            ReturnData var2 = (ReturnData)var1;
            return this.useqiannengguonum == var2.useqiannengguonum;
        } else {
            return false;
        }
    }

    public int hashCode() {
        int var1 = 0;
        var1 += this.useqiannengguonum;
        return var1;
    }

    public String toString() {
        StringBuilder var1 = new StringBuilder();
        var1.append("(");
        var1.append(this.useqiannengguonum).append(",");
        var1.append(")");
        return var1.toString();
    }
}

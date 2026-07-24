//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.qiannengguo;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.pb.SCreateRole;

public class SEnterWorld extends __SEnterWorld__ {
    public static final int PROTOCOL_TYPE = 810501;
    public ReturnData returnData;

    protected void process() {
    }

    public int getType() {
        return 810501;
    }

    public SEnterWorld() {
        this.returnData = new ReturnData();
    }

    public SEnterWorld(ReturnData var1) {
        this.returnData = var1;
    }

    public final boolean _validator_() {
        return this.returnData._validator_();
    }

    public OctetsStream marshal(OctetsStream var1) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            var1.marshal(this.returnData);
            return var1;
        }
    }

    public OctetsStream unmarshal(OctetsStream var1) throws MarshalException {
        this.returnData.unmarshal(var1);
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return var1;
        }
    }

    public boolean equals(Object var1) {
        if (var1 == this) {
            return true;
        } else if (var1 instanceof SCreateRole) {
            SEnterWorld var2 = (SEnterWorld)var1;
            return this.returnData.equals(var2.returnData);
        } else {
            return false;
        }
    }

    public int hashCode() {
        int var1 = 0;
        var1 += this.returnData.hashCode();
        return var1;
    }

    public String toString() {
        StringBuilder var1 = new StringBuilder();
        var1.append("(");
        var1.append(this.returnData).append(",");
        var1.append(")");
        return var1.toString();
    }
}

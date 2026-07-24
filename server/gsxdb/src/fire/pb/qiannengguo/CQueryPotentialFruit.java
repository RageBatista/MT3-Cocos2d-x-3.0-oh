//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.qiannengguo;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.Logger;
import gnet.link.Onlines;

public class CQueryPotentialFruit extends __CQueryPotentialFruit__ {
    public static final Logger logger = Logger.getLogger("SYSTEM");
    public static final int PROTOCOL_TYPE = 810501;

    protected void process() {
        long roleId = Onlines.getInstance().findRoleid(this);
        if (roleId >= 0L) {
            (new PQueryPotentialFruit(roleId)).submit();
        }
    }

    public int getType() {
        return 810501;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        return _o1_ == this;
    }

    public int hashCode() {
        return 0;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CQueryPotentialFruit _o_) {
        return _o_ == this ? 0 : 0;
    }
}

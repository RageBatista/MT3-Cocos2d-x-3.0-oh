//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class KickErrConst implements Marshal, Comparable<KickErrConst> {
    public static final int ERR_GM_KICKOUT = 2049;
    public static final int ERR_SERVER_SHUTDOWN = 2050;
    public static final int ERR_GACD_PUNISH = 2051;
    public static final int ERR_RUN_TOO_FAST = 2052;
    public static final int ERR_GACD_WAIGUA = 2053;
    public static final int ERR_XUNBAO_SELLROLE = 2054;
    public static final int ERR_FORBID_USER = 2055;
    public static final int ERR_GACD_KICKOUT = 2056;

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        return _os_;
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        return _os_;
    }

    public boolean equals(Object _o1_) {
        if (_o1_ == this) {
            return true;
        } else {
            return _o1_ instanceof KickErrConst;
        }
    }

    public int hashCode() {
        int _h_ = 0;
        return _h_;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(KickErrConst _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.talk;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class TipsMsgType implements Marshal, Comparable<TipsMsgType> {
    public static final int TIPS_POPMSG = 1;
    public static final int TIPS_NPCTALK = 2;
    public static final int TIPS_MSG_CHANNEL = 3;
    public static final int TIPS_SYSBOARD = 4;
    public static final int TIPS_CONFIRM = 5;
    public static final int TIPS_CLAN = 7;
    public static final int TIPS_CUR_CHANNEL = 8;
    public static final int TIPS_WORLD = 9;
    public static final int TIPS_TEAM_CHANNEL = 13;
    public static final int TIPS_PRO_CHANNEL = 14;
    public static final int TIPS_SYS_CHANNEL = 15;
    public static final int TIPS_ROLE_CHANNEL = 18;

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
            return _o1_ instanceof TipsMsgType;
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

    public int compareTo(TipsMsgType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

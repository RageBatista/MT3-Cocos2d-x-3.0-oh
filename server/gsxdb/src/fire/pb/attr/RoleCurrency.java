//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.attr;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RoleCurrency implements Marshal, Comparable<RoleCurrency> {
    public static final int GUILD_DKP = 1;
    public static final int GUILD_DED = 2;
    public static final int TEACHER_SCORE = 3;
    public static final int ACTIVE_SCORE = 4;
    public static final int HONOR_SCORE = 5;
    public static final int POP_SCORE = 6;
    public static final int FRIEND_SCORE = 7;
    public static final int PROF_CONTR = 9;
    public static final int EREDITPOINT_SCORE = 10;
    public static final int LUANDOU_SCORE = 11;
    public static final int FASHION_SCORE = 12;
    public static final int EQUIP_SCORE = 13;
    public static final int PET_SCORE = 14;

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
            return _o1_ instanceof RoleCurrency;
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

    public int compareTo(RoleCurrency _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

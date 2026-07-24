//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.msp.team;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class TeamChangeType implements Marshal, Comparable<TeamChangeType> {
    public static final int CREATE = 1;
    public static final int DISMISS = 2;
    public static final int SWITCH_LEADER = 3;
    public static final int ADD_NORMAL_MEMBER = 4;
    public static final int ADD_ABSENT_MEMBER = 5;
    public static final int REMOVE_MEMBER = 6;
    public static final int SWITCH_MEMBER = 7;
    public static final int CHANGE_MEMBER_NORMAL = 8;
    public static final int CHANGE_MEMBER_ABSENT = 9;
    public static final int MEMBER_OFFLINE = 10;

    public TeamChangeType() {
    }

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
            return _o1_ instanceof TeamChangeType;
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

    public int compareTo(TeamChangeType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

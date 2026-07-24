//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class OperationType implements Marshal, Comparable<OperationType> {
    public static final int ACTION_ATTACK = 1;
    public static final int ACTION_SKILL = 2;
    public static final int ACTION_USEITEM = 3;
    public static final int ACTION_DEFEND = 4;
    public static final int ACTION_PROTECT = 5;
    public static final int ACTION_SUMMON = 6;
    public static final int ACTION_WITHDRAW = 7;
    public static final int ACTION_CATHCH = 8;
    public static final int ACTION_ESCAPE = 9;
    public static final int ACTION_REST = 10;
    public static final int ACTION_SPECIAL_SKILL = 11;
    public static final int ACTION_SUMMON_INSTANT = 12;
    public static final int ACTION_ESCAPE_INSTANT = 13;
    public static final int ACTION_FAILURE = 14;
    public static final int ACTION_BATTLE_END = 15;
    public static final int ACTION_ENVIRONMENTDEMO = 16;
    public static final int ACTION_ENVIRONMENTCHANGE = 17;
    public static final int ACTION_ROUNDENDDEMO = 18;
    public static final int ACTION_UNIQUE_SKILL = 19;
    public static final int ACTION_FAILURE_NO_WONDER = 20;

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
            return _o1_ instanceof OperationType;
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

    public int compareTo(OperationType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

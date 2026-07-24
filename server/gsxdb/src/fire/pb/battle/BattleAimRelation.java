//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class BattleAimRelation implements Marshal, Comparable<BattleAimRelation> {
    public static final int SELF = 1;
    public static final int SELF_PET = 2;
    public static final int FRIEND_ROLE = 4;
    public static final int FRIEND_PET = 8;
    public static final int FRIEND_NPC = 16;
    public static final int ENERMY_ROLE = 32;
    public static final int ENERMY_PET = 64;
    public static final int ENERMY_NPC = 128;
    public static final int ENERMY_MONSTER = 256;
    public static final int COUPLE = 512;
    public static final int BROTHERS = 1024;
    public static final int MASTER_STUDENT = 2048;
    public static final int FRIEND_MONSTER = 4096;

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
            return _o1_ instanceof BattleAimRelation;
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

    public int compareTo(BattleAimRelation _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

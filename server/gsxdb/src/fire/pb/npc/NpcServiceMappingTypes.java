//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class NpcServiceMappingTypes implements Marshal, Comparable<NpcServiceMappingTypes> {
    public static final int NONE = 0;
    public static final int ACCEPT_CIRCLE_TASK = 1;
    public static final int SUBMIT_CIRCLE_TASK = 2;
    public static final int QUERY_CIRCLE_TASK = 3;
    public static final int QUERY_CIRCLE_TEAM = 4;
    public static final int QUERY_CIRCLE_BATTLE = 5;
    public static final int CIRCLE_PRODUCE = 6;
    public static final int RENXING_CIRCLE_TASK = 7;
    public static final int CHALLENGE_NPC = 9;
    public static final int ENTER_INST = 10;
    public static final int POP_UI = 11;
    public static final int QUERY_CAMERA_URL = 12;
    public static final int ACCEPT_TUPO = 13;

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
            return _o1_ instanceof NpcServiceMappingTypes;
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

    public int compareTo(NpcServiceMappingTypes _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

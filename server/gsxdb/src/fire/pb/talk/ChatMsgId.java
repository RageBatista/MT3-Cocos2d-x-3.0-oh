//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.talk;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ChatMsgId implements Marshal, Comparable<ChatMsgId> {
    public static final int CHAT_SPEED_LIMIT = 140497;
    public static final int CANNOT_USE_TEAM_CHANNEL = 140498;
    public static final int CHAT_WORLD_CHANNEL_TIME_LIMIT = 140500;
    public static final int CHAT_WORLD_CHANNEL_LEVEL_LIMIT = 140501;
    public static final int CANNOT_USE_FACTION_CHANNEL = 141053;
    public static final int CHAT_TEAM_APPLY_CHANNEL_TIME_LIMIT = 150028;
    public static final int CHAT_SCHOOL_CHANNEL_LEVEL_LIMIT = 160471;
    public static final int CHAT_CURRENT_CHANNEL_LEVEL_LIMIT = 142924;

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
            return _o1_ instanceof ChatMsgId;
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

    public int compareTo(ChatMsgId _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

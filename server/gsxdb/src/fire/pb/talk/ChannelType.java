//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.talk;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ChannelType implements Marshal, Comparable<ChannelType> {
    public static final int CHANNEL_CURRENT = 1;
    public static final int CHANNEL_TEAM = 2;
    public static final int CHANNEL_PROFESSION = 3;
    public static final int CHANNEL_CLAN = 4;
    public static final int CHANNEL_WORLD = 5;
    public static final int CHANNEL_SYSTEM = 6;
    public static final int CHANNEL_MESSAGE = 7;
    public static final int CHANNEL_BUBBLE = 8;
    public static final int CHANNEL_SLIDE = 9;
    public static final int CHANNEL_TEAM_APPLY = 14;

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
            return _o1_ instanceof ChannelType;
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

    public int compareTo(ChannelType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

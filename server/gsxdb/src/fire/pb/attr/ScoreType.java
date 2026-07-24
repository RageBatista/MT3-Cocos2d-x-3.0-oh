//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.attr;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ScoreType implements Marshal, Comparable<ScoreType> {
    public static final int ROLE_LEVEL_SCORE = 1;
    public static final int EQUIP_LEVEL_SCORE = 2;
    public static final int EQUIP_EFFCT = 3;
    public static final int EQUIP_SKILL = 4;
    public static final int EQUIP_GEM = 5;
    public static final int SCHOOL_SKILL = 6;
    public static final int GUILD_SKILL = 7;
    public static final int GUILD_SHAVE = 8;
    public static final int PET_LEVEL_SCORE = 9;
    public static final int PET_LOW_SKILL = 10;
    public static final int PET_HIGH_SKILL = 11;
    public static final int PET_GROWING = 12;

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
            return _o1_ instanceof ScoreType;
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

    public int compareTo(ScoreType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

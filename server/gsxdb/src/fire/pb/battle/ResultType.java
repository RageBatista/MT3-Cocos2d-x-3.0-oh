//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ResultType implements Marshal, Comparable<ResultType> {
    public static final int RESULT_HPCHANGE = 1;
    public static final int RESULT_MPCHANGE = 2;
    public static final int RESULT_SPCHANGE = 4;
    public static final int RESULT_ULHPCHANGE = 8;
    public static final int RESULT_REST = 16;
    public static final int RESULT_HURT = 32;
    public static final int RESULT_CRITIC = 64;
    public static final int RESULT_DEFENCE = 128;
    public static final int RESULT_PARRY = 256;
    public static final int RESULT_DODGE = 512;
    public static final int RESULT_RUNAWAY = 1024;
    public static final int RESULT_SEIZE = 2048;
    public static final int RESULT_SUMMONBACK = 4096;
    public static final int RESULT_DEATH = 8192;
    public static final int RESULT_KICKOUT = 16384;
    public static final int RESULT_GHOST = 32768;
    public static final int RESULT_RELIVE = 65536;
    public static final int RESULT_SUMMONPET = 131072;
    public static final int RESULT_IGNORE_PHYDIC_EFEN = 262144;
    public static final int RESULT_ABORBE = 524288;
    public static final int RESULT_FIRE_MANA = 1048576;
    public static final int RESULT_GODBLESS = 2097152;
    public static final int RESULT_EPCHANGE = 4194304;
    public static final int RESULT_DEAD_FULL_RELIVE = 8388608;
    public static final int RESULT_SHAPECHAGE = 16777216;

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
            return _o1_ instanceof ResultType;
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

    public int compareTo(ResultType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

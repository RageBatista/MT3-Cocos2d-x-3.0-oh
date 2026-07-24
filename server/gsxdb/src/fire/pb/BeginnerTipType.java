//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class BeginnerTipType implements Marshal, Comparable<BeginnerTipType> {
    public static final int StudyExtendSkill = 0;
    public static final int GotoSchool = 1;
    public static final int ReleaseApprenticeInfo = 2;
    public static final int ReleaseMasterInfo = 3;
    public static final int UseShilizhengming = 4;
    public static final int BattleSkill = 30001;
    public static final int LevelUp = 30002;
    public static final int AllocateProperty = 30003;
    public static final int AutoFindPath = 30004;
    public static final int UseSkill = 30005;
    public static final int MiniMap = 30006;

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
            return _o1_ instanceof BeginnerTipType;
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

    public int compareTo(BeginnerTipType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

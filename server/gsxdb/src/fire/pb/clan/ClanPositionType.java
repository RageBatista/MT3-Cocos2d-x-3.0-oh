//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ClanPositionType implements Marshal, Comparable<ClanPositionType> {
    public static final int ClanMember = 11;
    public static final int ClanArmyGroupElite4 = 10;
    public static final int ClanArmyGroupElite3 = 9;
    public static final int ClanArmyGroupElite2 = 8;
    public static final int ClanArmyGroupElite1 = 7;
    public static final int ClanArmyGroup4 = 6;
    public static final int ClanArmyGroup3 = 5;
    public static final int ClanArmyGroup2 = 4;
    public static final int ClanArmyGroup1 = 3;
    public static final int ClanViceMaster = 2;
    public static final int ClanMaster = 1;

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
            return _o1_ instanceof ClanPositionType;
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

    public int compareTo(ClanPositionType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

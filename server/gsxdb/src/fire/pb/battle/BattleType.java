//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class BattleType implements Marshal, Comparable<BattleType> {
    public static final int BATTLE_PVE = 10;
    public static final int BATTLE_HIDEAREA = 1100;
    public static final int BATTLE_SHOWAREA = 1200;
    public static final int BATTLE_BOSS = 30;
    public static final int BATTLE_LINE = 40;
    public static final int BATTLE_CLANBOSS = 50;
    public static final int BATTLE_SHOUXI = 60;
    public static final int BATTLE_PVP = 11;
    public static final int BATTLE_LIVEDIE = 21;
    public static final int BATTLE_DUEL_SINGLE = 31;
    public static final int BATTLE_DUEL_TEAM = 41;
    public static final int BATTLE_BINGFENG_WAR = 100;
    public static final int BATTLE_INST_BATTLE = 110;
    public static final int BATTLE_CLAN_FIGHT = 201;

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
            return _o1_ instanceof BattleType;
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

    public int compareTo(BattleType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

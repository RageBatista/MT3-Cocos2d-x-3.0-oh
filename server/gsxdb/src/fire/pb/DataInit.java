//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class DataInit implements Marshal, Comparable<DataInit> {
    public static final int ROLE_LEVEL_MAX = 999999999;
    public static final int ROLE_UP_POINT = 5;
    public static final int PET_UP_POINT = 5;
    public static final int ROLE_UP_PHY = 5;
    public static final int ROLE_UP_ENERGY = 5;
    public static final int PET_INIT_LOY = 80;
    public static final int PET_MAX_LOY = 100;
    public static final int PET_MAX_LIFE = 20000;
    public static final int PET_FIGHT_LIFE_LIMIT = 50;
    public static final int FULL_PETLOY_LEVEL = 30;
    public static final int ROLE_PET_LEVEL_SPACE = 50;
    public static final int ROLE_PET_LEVEL_SPACE_OFEXPITEM = 10;
    public static final int BASENUM = 1000;
    public static final int PET_LEVEL_MAX = 200;
    public static final int PET_USELEVEL_SPACE = 50;
    public static final int AUTO_UPGRADE_LEVEL = 1000;
    public static final int WILD_PET_MAXGENGU = 40;
    public static final int WILD_PET_MINGENGU = 1;
    public static final int PET_UP_LEVEL_ADD_POINT = 5;
    public static final int HAIR_COLOR_SCHEMES_NUM = 4;
    public static final int BODY_COLOR_SCHEMES_NUM = 4;
    public static final int TURNON_REFINE_NEED_ONLINE_TIME = 200;
    public static final int TURNON_REFINE_NEED_FRIEND_LEVEL = 1000;
    public static final int TURNON_REFINE_NEED_ANTIQUE_NUM = 1;
    public static final int COMMEN_ROLE_ADDPOINT = 100;
    public static final int EQUIP_CAN_REPAIR = 157;

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream var1) {
        return var1;
    }

    public OctetsStream unmarshal(OctetsStream var1) throws MarshalException {
        return var1;
    }

    public boolean equals(Object var1) {
        return var1 == this ? true : var1 instanceof DataInit;
    }

    public int hashCode() {
        byte var1 = 0;
        return var1;
    }

    public String toString() {
        StringBuilder var1 = new StringBuilder();
        var1.append("(");
        var1.append(")");
        return var1.toString();
    }

    public int compareTo(DataInit var1) {
        if (var1 == this) {
            return 0;
        } else {
            byte var2 = 0;
            return var2;
        }
    }
}

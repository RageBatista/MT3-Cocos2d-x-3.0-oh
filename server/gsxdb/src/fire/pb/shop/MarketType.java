//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class MarketType implements Marshal, Comparable<MarketType> {
    public static final int CARE_FOR = 1;
    public static final int RARITY_PET = 2;
    public static final int RARITY_EQUIP = 3;
    public static final int RARITY_PET_BOOK = 4;
    public static final int NORMAL_PET_BOOK = 5;
    public static final int NORMAL_PHARMACEUTICAL = 6;
    public static final int COOKING = 7;
    public static final int ZHI_ZAO_FU = 8;
    public static final int LIN_SHI_FU = 9;
    public static final int TASK_ITEM = 10;
    public static final int PET_SHOP = 11;
    public static final int RARITY_EQUIP_FORGING = 12;

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
            return _o1_ instanceof MarketType;
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

    public int compareTo(MarketType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

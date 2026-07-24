//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.master;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class DataConfig implements Marshal, Comparable<DataConfig> {
    public static final int REG_MONEY = 20000;
    public static final int MONEY1 = 10000;
    public static final int MONEY2 = 100000;
    public static final int REN_QI = 100;
    public static final int TAIXUEFUZI_ID = 10215;
    public static final int EVALUATER_LEVEL1 = 120;
    public static final int EVALUATER_LEVEL2 = 100;
    public static final int EVALUATER_LEVEL3 = 80;
    public static final int EVALUATER_LEVEL4 = 60;
    public static final int EVALUATER_LEVEL5 = 40;

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
            return _o1_ instanceof DataConfig;
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

    public int compareTo(DataConfig _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.hook;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class HookDataUpdateEnum implements Marshal, Comparable<HookDataUpdateEnum> {
    public static final int HOOKDATA_CANGETDPOINT = 0;
    public static final int HOOKDATA_GETDPOINT = 1;
    public static final int HOOKDATA_ISAUTOBATTLE = 2;
    public static final int HOOKDATA_CHAROPTYPE = 3;
    public static final int HOOKDATA_CHAROPID = 4;
    public static final int HOOKDATA_PETOPTYPE = 5;
    public static final int HOOKDATA_PETOPID = 6;
    public static final int HOOKDATA_OFFLINEEXP = 7;

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
            return _o1_ instanceof HookDataUpdateEnum;
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

    public int compareTo(HookDataUpdateEnum _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

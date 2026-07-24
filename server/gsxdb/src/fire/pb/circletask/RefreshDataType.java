//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RefreshDataType implements Marshal, Comparable<RefreshDataType> {
    public static final int STATE = 1;
    public static final int DEST_NPD_KEY = 2;
    public static final int DEST_NPD_ID = 3;
    public static final int DEST_MAP_ID = 4;
    public static final int DEST_XPOS = 5;
    public static final int DEST_YPOS = 6;
    public static final int DEST_ITEM_ID = 7;
    public static final int SUMNUM = 8;
    public static final int DEST_ITEM1_NUM = 9;
    public static final int DEST_ITEM2_ID = 10;
    public static final int DEST_ITEM2_NUM = 11;
    public static final int QUEST_TYPE = 12;

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
            return _o1_ instanceof RefreshDataType;
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

    public int compareTo(RefreshDataType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

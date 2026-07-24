//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.move;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SpriteComponents implements Marshal, Comparable<SpriteComponents> {
    public static final int SPRITE_WEAPON = 1;
    public static final int SPRITE_HEADDRESS = 2;
    public static final int SPRITE_BACKDRESS = 3;
    public static final int SPRITE_FACEDRESS1 = 4;
    public static final int SPRITE_FACEDRESS2 = 5;
    public static final int SPRITE_HORSEDRESS = 6;
    public static final int SPRITE_WEAPONCOLOR = 7;
    public static final int SPRITE_FASHION = 8;
    public static final int ROLE_COLOR1 = 50;
    public static final int ROLE_COLOR2 = 51;
    public static final int SPRITE_EQUIP_EFFECT = 60;

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
            return _o1_ instanceof SpriteComponents;
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

    public int compareTo(SpriteComponents _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

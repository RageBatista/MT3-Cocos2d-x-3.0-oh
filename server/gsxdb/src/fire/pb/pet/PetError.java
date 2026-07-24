//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class PetError implements Marshal, Comparable<PetError> {
    public static final int UnkownError = -1;
    public static final int KeyNotFound = -2;
    public static final int PetcolumnFull = -3;
    public static final int WrongDstCol = -4;
    public static final int ShowPetCantMoveErr = -5;
    public static final int FightPetCantMoveErr = -6;
    public static final int PetNameOverLen = -7;
    public static final int PetNameShotLen = -8;
    public static final int PetNameInvalid = -9;
    public static final int ShowPetCantFree = -10;
    public static final int FightPetCantFree = -11;
    public static final int WrongFreeCode = -12;

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
            return _o1_ instanceof PetError;
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

    public int compareTo(PetError _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

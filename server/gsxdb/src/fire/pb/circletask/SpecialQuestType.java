//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SpecialQuestType implements Marshal, Comparable<SpecialQuestType> {
    public static final int Mail = 801001;
    public static final int Patrol = 801002;
    public static final int BuyItem = 801003;
    public static final int CatchPet = 801004;
    public static final int Demonstrate = 801005;
    public static final int DemonstrateEye = 801006;
    public static final int Rescue = 801007;
    public static final int Tame = 801008;
    public static final int CaiJi = 801010;
    public static final int CaiJiFinish = 801030;
    public static final int ChuanDiXiaoXi = 801011;
    public static final int KillMonster = 801012;
    public static final int KillMonsterFinish = 801032;
    public static final int FindItem = 801013;
    public static final int FindItemFinish = 801033;
    public static final int Answer = 801014;
    public static final int AnswerFinish = 801034;
    public static final int CatchIt_Normal = 1030001;
    public static final int CatchIt_Increase = 1030002;

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
            return _o1_ instanceof SpecialQuestType;
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

    public int compareTo(SpecialQuestType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

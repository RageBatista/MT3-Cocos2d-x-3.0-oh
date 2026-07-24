//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.school;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class ShouXiMsgID implements Marshal, Comparable<ShouXiMsgID> {
    public static final int ChallengeLevelNotEnough = 140245;
    public static final int SchoolContriNotEnough = 140246;
    public static final int InTeam = 140247;
    public static final int MoneyNotEnough = 140248;
    public static final int ChallengeSuccess = 140249;
    public static final int ChallengeLost = 140250;
    public static final int NotSuccess = 140251;
    public static final int AlreadyCandidate = 140252;
    public static final int VoteLevelNotEnough = 140253;
    public static final int TiLiNotEnough = 140254;
    public static final int AlreadyVote = 140255;
    public static final int GiveShouXiTitle = 140256;
    public static final int CancelShouXiTitle = 140257;
    public static final int RefreshAbilityToMuch = 140258;
    public static final int ChallengeAffirm = 140259;
    public static final int Cantvote = 140260;
    public static final int CantChallenge = 140261;

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
            return _o1_ instanceof ShouXiMsgID;
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

    public int compareTo(ShouXiMsgID _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

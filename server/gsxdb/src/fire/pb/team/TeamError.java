//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class TeamError implements Marshal, Comparable<TeamError> {
    public static final int UnkownError = 0;
    public static final int SelfInTeam = 1;
    public static final int SelfNotInTeam = 2;
    public static final int ObjectInTeam = 3;
    public static final int SelfNOtLeader = 4;
    public static final int ObjectNotLeader = 5;
    public static final int ObjectOffline = 6;
    public static final int SelfTeamFunctionClose = 7;
    public static final int ObjectTeamFunctionClose = 8;
    public static final int SelfInUnteamState = 9;
    public static final int ObjectInUnteamState = 10;
    public static final int TeamFull = 11;
    public static final int InvitedInTeam = 12;
    public static final int BeingInvited = 13;
    public static final int InvitedIn30s = 14;
    public static final int InviteingsFull = 15;
    public static final int InviterTeamNotExist = 16;
    public static final int InviterNotLeader = 17;
    public static final int ApplierInTeam = 18;
    public static final int ApplyTimeout = 19;
    public static final int ApplyListFull = 20;
    public static final int ApplierLevelValid = 21;
    public static final int ChangeLeaderUnable = 22;
    public static final int InChangeLeaderStatus = 23;
    public static final int ChangeLeaderInCD = 24;
    public static final int MembersNotNormal = 25;
    public static final int TooFar = 26;
    public static final int NoAbsentMember = 27;
    public static final int RefuseChangeLeader = 28;
    public static final int ObjectNotInTeam = 29;
    public static final int AlreadyApply = 30;
    public static final int AbsentCantBeLeader = 31;
    public static final int LevelSetError = 32;
    public static final int LevelError = 33;
    public static final int NoTarget = 34;
    public static final int TeamEnoughFull = 35;
    public static final int InMatching = 36;
    public static final int ActiveNotOpen = 37;
    public static final int NoFaction = 38;
    public static final int TeamStateError = 39;
    public static final int OneKeyApplyTeamNoTime = 40;
    public static final int NoRollNotInTeam = 50;
    public static final int NoReward = 51;
    public static final int FormBookHalfNotEnough = 55;
    public static final int UnKnuownFormBook = 56;
    public static final int FromLevelMax = 57;
    public static final int FormIdError = 58;
    public static final int FormBookNotEnough = 59;

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
            return _o1_ instanceof TeamError;
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

    public int compareTo(TeamError _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

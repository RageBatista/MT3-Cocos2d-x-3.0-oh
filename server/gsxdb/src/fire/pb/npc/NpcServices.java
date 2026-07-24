//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class NpcServices implements Marshal, Comparable<NpcServices> {
    public static final int FORTUNE_WHEEL = 14;
    public static final int SEND_MAIL = 69;
    public static final int CHECK_CHIEF_ABILITY = 96;
    public static final int CHALLENGE_CHIEF = 97;
    public static final int RUN_FOR_CHIEF = 98;
    public static final int VOTING = 99;
    public static final int REFRESH_CHIEF_ABILITY = 100;
    public static final int ATTEND_IMPEXAM = 136;
    public static final int LEARN_IMPEXAM_RULE = 137;
    public static final int WINNER_START = 166;
    public static final int CHECK_PERSONAL_CREDIT = 167;
    public static final int ADD_PET_LIFE = 168;
    public static final int FIGHT_WINNER = 171;
    public static final int ENTER_BINGFENG = 355;
    public static final int BACK_COPY_SERVICE = 1469;
    public static final int CIRCTASK_SCHOOL1 = 3000;
    public static final int CIRCTASK_SCHOOL2 = 3001;
    public static final int CIRCTASK_SCHOOL3 = 3002;
    public static final int CIRCTASK_SCHOOL4 = 3003;
    public static final int CIRCTASK_SCHOOL5 = 3004;
    public static final int CIRCTASK_SCHOOL6 = 3005;
    public static final int CIRCTASK_SCHOOL_SUBMIT1 = 3010;
    public static final int CIRCTASK_SCHOOL_SUBMIT2 = 3011;
    public static final int CIRCTASK_SCHOOL_SUBMIT3 = 3012;
    public static final int CIRCTASK_SCHOOL_SUBMIT4 = 3013;
    public static final int CIRCTASK_SCHOOL_SUBMIT5 = 3014;
    public static final int CIRCTASK_SCHOOL_SUBMIT6 = 3015;
    public static final int CATCH_IT = 4000;
    public static final int CATCH_IT_SUBMIT = 4001;
    public static final int CATCH_IT_QUERY = 4002;
    public static final int CATCH_IT_BJ = 4003;
    public static final int CATCH_IT_Battle = 4004;
    public static final int TIMER_NPC_Battle = 4005;
    public static final int EVENT_NPC_Battle = 4006;
    public static final int SUBMIT_CIRCTASK = 5000;
    public static final int RENXING_CIRCTASK = 5001;
    public static final int BUY_MEDICINE = 30000;
    public static final int BUY_GOODS = 30001;
    public static final int BUY_EQUIP = 30002;
    public static final int BUY_PET = 30003;
    public static final int OPEN_SHANGHUI = 30004;
    public static final int QUERY_LINEINST = 100049;
    public static final int RESET_LINEINST = 100187;
    public static final int ONE_LIEVEL_TITLE = 900054;
    public static final int TWO_LIEVEL_TITLE = 900055;
    public static final int THREE_LIEVEL_TITLE = 900056;
    public static final int LEADER_SEE_CAMPAIGN_LIST = 900057;
    public static final int LEADER_MY_CAMPAIGN = 900058;
    public static final int LEADER_CHALLENGE = 900059;
    public static final int LEADER_CAMPAIGN = 900060;
    public static final int PET_STORE = 100012;
    public static final int EXCHANGE_CODE = 100600;
    public static final int IMPEXAM_STATE = 100704;
    public static final int LOOK_YAO_QIAN = 200101;
    public static final int ENTER_1V1_PVP = 910000;
    public static final int LEAVE_1V1_PVP = 910004;
    public static final int ENTER_3V3_PVP = 910010;
    public static final int LEAVE_3V3_PVP = 910014;
    public static final int ENTER_5V5_PVP = 910020;
    public static final int LEAVE_5V5_PVP = 910024;
    public static final int WATCH_NPC_BATTLE = 910115;
    public static final int WATCH_EVENTNPC_BATTLE = 910116;
    public static final int WATCH_INST_NPC_BATTLE = 910201;
    public static final int END_INST_NPC_BATTLE = 910202;
    public static final int ENTER_CLAN_FIGHT = 910030;

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
            return _o1_ instanceof NpcServices;
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

    public int compareTo(NpcServices _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

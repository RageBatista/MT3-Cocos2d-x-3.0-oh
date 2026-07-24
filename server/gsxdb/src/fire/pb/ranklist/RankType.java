//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.ranklist;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class RankType implements Marshal, Comparable<RankType> {
    public static final int LEVEL_RANK = 1;
    public static final int PET_GRADE_RANK = 9;
    public static final int FACTION_RANK = 31;
    public static final int ROLE_ZONGHE_RANK = 32;
    public static final int SINGLE_COPY_RANK1 = 21;
    public static final int SINGLE_COPY_RANK2 = 22;
    public static final int SINGLE_COPY_RANK3 = 23;
    public static final int SINGLE_COPY_RANK4 = 24;
    public static final int TEAM_COPY_RANK1 = 27;
    public static final int TEAM_COPY_RANK2 = 28;
    public static final int ROLE_RANK = 38;
    public static final int PROFESSION_WARRIOR_RANK = 43;
    public static final int PROFESSION_MAGIC_RANK = 44;
    public static final int PROFESSION_PRIEST_RANK = 45;
    public static final int PROFESSION_PALADIN_RANK = 46;
    public static final int PROFESSION_HUNTER_RANK = 47;
    public static final int PROFESSION_DRUID_RANK = 48;
    public static final int FACTION_RANK_LEVEL = 49;
    public static final int FACTION_ZONGHE = 50;
    public static final int FACTION_MC = 51;
    public static final int FACTION_NAXX = 52;
    public static final int PROFESSION_ROGUE_RANK = 60;
    public static final int PROFESSION_SAMAN_RANK = 61;
    public static final int PROFESSION_WARLOCK_RANK = 62;
    public static final int PROFESSION_NUERCUN_RANK = 63;
    public static final int PROFESSION_XIAOLEIYIN_RANK = 64;
    public static final int PROFESSION_HUAGUOSHAN_RANK = 65;
    public static final int PROFESSION_XUMIHAI_RANK = 66;
    public static final int PROFESSION_PANSI_RANK = 67;
    public static final int FACTION_COPY = 70;
    public static final int PVP5_LAST_GRADE1 = 81;
    public static final int PVP5_LAST_GRADE2 = 82;
    public static final int PVP5_LAST_GRADE3 = 83;
    public static final int PVP5_HISTORY_GRADE1 = 84;
    public static final int PVP5_HISTORY_GRADE2 = 85;
    public static final int PVP5_HISTORY_GRADE3 = 86;
    public static final int RED_PACK_1 = 101;
    public static final int RED_PACK_2 = 102;
    public static final int FLOWER_RECEIVE = 111;
    public static final int FLOWER_GIVE = 112;
    public static final int CLAN_FIGHT_2 = 120;
    public static final int CLAN_FIGHT_4 = 121;
    public static final int CLAN_FIGHT_WEEK = 122;
    public static final int CLAN_FIGHT_HISTROY = 123;

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
        return _o1_ == this || _o1_ instanceof RankType;
    }

    public int hashCode() {
        return 0;
    }

    public String toString() {
        return "()";
    }

    public int compareTo(RankType _o_) {
        return _o_ == this ? 0 : 0;
    }
}

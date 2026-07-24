//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.attr;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class EffectType implements Marshal, Comparable<EffectType> {
    public static final int CONS_ABL = 11;
    public static final int CONS_PCT = 12;
    public static final int IQ_ABL = 21;
    public static final int IQ_PCT = 22;
    public static final int STR_ABL = 31;
    public static final int STR_PCT = 32;
    public static final int ENDU_ABL = 41;
    public static final int ENDU_PCT = 42;
    public static final int AGI_ABL = 51;
    public static final int AGI_PCT = 52;
    public static final int MAX_HP_ABL = 61;
    public static final int MAX_HP_PCT = 62;
    public static final int UP_LIMITED_HP_ABL = 71;
    public static final int UP_LIMITED_HP_PCT = 72;
    public static final int HP_ABL = 81;
    public static final int HP_PCT = 82;
    public static final int MAX_MP_ABL = 91;
    public static final int MAX_MP_PCT = 92;
    public static final int MP_ABL = 101;
    public static final int MP_PCT = 102;
    public static final int MAX_SP_ABL = 111;
    public static final int MAX_SP_PCT = 112;
    public static final int SP_ABL = 121;
    public static final int SP_PCT = 122;
    public static final int DAMAGE_ABL = 131;
    public static final int DAMAGE_PCT = 132;
    public static final int DEFEND_ABL = 141;
    public static final int DEFEND_PCT = 142;
    public static final int MAGIC_ATTACK_ABL = 151;
    public static final int MAGIC_ATTACK_PCT = 152;
    public static final int MAGIC_DEF_ABL = 161;
    public static final int MAGIC_DEF_PCT = 162;
    public static final int MEDICAL_ABL = 171;
    public static final int SEAL_ABL = 181;
    public static final int UNSEAL_ABL = 191;
    public static final int UNSEAL_PCT = 192;
    public static final int SPEED_ABL = 201;
    public static final int SPEED_PCT = 202;
    public static final int HIT_RATE_ABL = 211;
    public static final int HIT_RATE_PCT = 212;
    public static final int DODGE_RATE_ABL = 221;
    public static final int DODGE_RATE_PCT = 222;
    public static final int PHY_CRITC_LEVEL_ABL = 231;
    public static final int PHY_CRITC_LEVEL_PCT = 232;
    public static final int ANTI_PHY_CRITC_LEVEL_ABL = 241;
    public static final int PHYSIC_CRIT_PCT_ABL = 251;
    public static final int PHYSIC_CRIT_PCT_PCT = 252;
    public static final int MAGIC_CRITC_LEVEL_ABL = 261;
    public static final int MAGIC_CRITC_LEVEL_PCT = 262;
    public static final int ANTI_MAGIC_CRITC_LEVEL_ABL = 271;
    public static final int MAGIC_CRIT_PCT_ABL = 281;
    public static final int MAGIC_CRIT_PCT_PCT = 282;
    public static final int STEAL_HP_PCT_ABL = 361;
    public static final int STEAL_HP_PCT_PCT = 362;
    public static final int STEAL_MP_PCT_ABL = 381;
    public static final int POISON_RATE_ABL = 391;
    public static final int POISON_RATE_PCT = 392;
    public static final int COMBO_ATTACK_RATE_ABL = 451;
    public static final int COMBO_ATTACK_RATE_PCT = 452;
    public static final int COMBO_ATTACK_PCT_ABL = 461;
    public static final int COMBO_ATTACK_PCT_PCT = 462;
    public static final int COMBO_ATTACK_COUNT_ABL = 471;
    public static final int COMBO_ATTACK_COUNT_PCT = 472;
    public static final int MAGIC_COMBO_ATTACK_RATE_ABL = 481;
    public static final int MAGIC_COMBO_ATTACK_RATE_PCT = 482;
    public static final int MAGIC_COMBO_ATTACK_PCT_ABL = 491;
    public static final int MAGIC_COMBO_ATTACK_PCT_PCT = 492;
    public static final int MAGIC_COMBO_ATTACK_COUNT_ABL = 501;
    public static final int MAGIC_COMBO_ATTACK_COUNT_PCT = 502;
    public static final int EXTRA_ATTACK_RATE_ABL = 511;
    public static final int EXTRA_ATTACK_RATE_PCT = 512;
    public static final int EXTRA_ATTACK_DEGREE_ABL = 521;
    public static final int EXTRA_ATTACK_DEGREE_PCT = 522;
    public static final int EXTRA_ATTACK_COUNT_ABL = 531;
    public static final int EXTRA_ATTACK_COUNT_PCT = 532;
    public static final int PARRY_RATE_ABL = 571;
    public static final int PARRY_RATE_PCT = 572;
    public static final int RETURN_HURT_RATE_ABL = 591;
    public static final int RETURN_HURT_RATE_PCT = 592;
    public static final int RETURN_HURT_PCT_ABL = 601;
    public static final int RETURN_HURT_PCT_PCT = 602;
    public static final int RETURN_ATTACK_RATE_ABL = 611;
    public static final int RETURN_ATTACK_RATE_PCT = 612;
    public static final int RETURN_ATTACK_PCT_ABL = 621;
    public static final int RETURN_ATTACK_PCT_PCT = 622;
    public static final int ABSORB_FIRE_ODDS_ABL = 651;
    public static final int ABSORB_WATER_ODDS_ABL = 661;
    public static final int ABSORB_EARTH_ODDS_ABL = 671;
    public static final int ABSORB_THUNDER_ODDS_ABL = 681;
    public static final int ABSORB_OTHER_ODDS_ABL = 691;
    public static final int SEAL_LEVEL_ABL = 811;
    public static final int ANTI_SEAL_LEVEL_ABL = 821;
    public static final int PHYSIC_CRIT_RATE_ABL = 831;
    public static final int PHYSIC_CRIT_RATE_PCT = 832;
    public static final int MAGIC_CRIT_RATE_ABL = 851;
    public static final int MAGIC_CRIT_RATE_PCT = 852;
    public static final int ATTACK_BACK_COUNT_ABL = 931;
    public static final int EFFECT_POINT_ABL = 1011;
    public static final int TEMP_SP_ABL = 1021;
    public static final int AMEND_HIDDEN_WEAPON_ACTIVE_ABL = 1220;
    public static final int PET_LIFE_ABL = 1361;
    public static final int PET_ATTACK_APT_ABL = 1441;
    public static final int PET_DEFEND_APT_ABL = 1451;
    public static final int PET_PHYFORCE_APT_ABL = 1461;
    public static final int PET_MAGIC_APT_ABL = 1471;
    public static final int PET_SPEED_APT_ABL = 1481;
    public static final int PET_DODGE_APT_ABL = 1491;
    public static final int ENLIMIT_ABL = 1521;
    public static final int PFLIMIT_ABL = 1531;
    public static final int OPERATOR = 1581;
    public static final int AIM = 1591;
    public static final int OPERATE_TYPE = 1171;
    public static final int OPERATE_ID = 1181;
    public static final int ATTACK_BACK_LEVEL_ABL = 1751;
    public static final int RETURN_HURT_LEVEL_ABL = 1761;
    public static final int ANTI_ATTACK_BACK_LEVEL_ABL = 1771;
    public static final int ANTI_RETURN_HURT_LEVEL_ABL = 1781;
    public static final int QILIZHI_ABL = 1201;
    public static final int KONGZHI_JIACHENG = 2131;
    public static final int KONGZHI_MIANYI = 2141;
    public static final int SHAPE_ID = 3001;

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
            return _o1_ instanceof EffectType;
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

    public int compareTo(EffectType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

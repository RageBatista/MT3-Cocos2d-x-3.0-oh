//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.attr;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class FightAttrType implements Marshal, Comparable<FightAttrType> {
    public static final int CONS = 10;
    public static final int IQ = 20;
    public static final int STR = 30;
    public static final int ENDU = 40;
    public static final int AGI = 50;
    public static final int MAX_HP = 60;
    public static final int MAX_MP = 90;
    public static final int MAX_SP = 110;
    public static final int ATTACK = 130;
    public static final int DEFEND = 140;
    public static final int MAGIC_ATTACK = 150;
    public static final int MAGIC_DEF = 160;
    public static final int MEDICAL = 170;
    public static final int SEAL = 180;
    public static final int UNSEAL = 190;
    public static final int SPEED = 200;
    public static final int HIT_RATE = 210;
    public static final int DODGE_RATE = 220;
    public static final int PHY_CRITC_LEVEL = 230;
    public static final int ANTI_PHY_CRITC_LEVEL = 240;
    public static final int PHYSIC_CRIT_PCT = 250;
    public static final int MAGIC_CRITC_LEVEL = 260;
    public static final int ANTI_MAGIC_CRITC_LEVEL = 270;
    public static final int MAGIC_CRIT_PCT = 280;
    public static final int HEAL_RATE = 290;
    public static final int HEAL_DEGREE = 300;
    public static final int IGNORE_PHYSIC_DEFEND_RATE = 310;
    public static final int IGNORE_PHYSIC_DEFEND_PCT = 320;
    public static final int IGNORE_MAGIC_DEFEND_RATE = 330;
    public static final int IGNORE_MAGIC_DEFEND_PCT = 340;
    public static final int STEAL_HP_RATE = 350;
    public static final int STEAL_HP_PCT = 360;
    public static final int FIRE_MP_RATE = 370;
    public static final int FIRE_MP_PCT = 380;
    public static final int POISON_RATE = 390;
    public static final int PIOSON_DAMGE_HP = 400;
    public static final int PIOSON_DAMGE_MP = 410;
    public static final int PIOSON_DAMGE_ROUND = 420;
    public static final int DIE_FORBID_RATE = 430;
    public static final int DIE_FORBID_ROUND = 440;
    public static final int PHYSIC_COMBO_ATTACK_RATE = 450;
    public static final int PHYSIC_COMBO_ATTACK_PCT = 460;
    public static final int PHYSIC_COMBO_ATTACK_COUNT = 470;
    public static final int MAGIC_COMBO_ATTACK_RATE = 480;
    public static final int MAGIC_COMBO_ATTACK_PCT = 490;
    public static final int MAGIC_COMBO_ATTACK_COUNT = 500;
    public static final int EXTRA_ATTACK_RATE = 510;
    public static final int EXTRA_ATTACK_PCT = 520;
    public static final int EXTRA_ATTACK_COUNT = 530;
    public static final int DIFFUSE_ATTACK_RATE = 540;
    public static final int DIFFUSE_ATTACK_PCT = 550;
    public static final int DIFFUSE_ATTACK_COUNT = 560;
    public static final int PARRY_RATE = 570;
    public static final int PARRY_PCT = 580;
    public static final int RETURN_HURT_RATE = 590;
    public static final int RETURN_HURT_PCT = 600;
    public static final int ATTACK_BACK_RATE = 610;
    public static final int ATTACK_BACK_PCT = 620;
    public static final int GOD_BLESS_RATE = 630;
    public static final int GOD_BLESS_PCT = 640;
    public static final int ABSORB_FIRE_ODDS = 650;
    public static final int ABSORB_WATER_ODDS = 660;
    public static final int ABSORB_EARTH_ODDS = 670;
    public static final int ABSORB_THUNDER_ODDS = 680;
    public static final int ABSORB_OTHER_ODDS = 690;
    public static final int ABSORB_FIRE_PCT = 700;
    public static final int ABSORB_WATER_PCT = 710;
    public static final int ABSORB_EARTH_PCT = 720;
    public static final int ABSORB_THUNDER_PCT = 730;
    public static final int ABSORB_OTHER_PCT = 740;
    public static final int PHYSIC_DAMGE_RATE = 750;
    public static final int ANTI_PHYSIC_DAMGE_RATE = 760;
    public static final int MAGIC_DAMGE_RATE = 770;
    public static final int ANTI_MAGIC_DAMGE_RATE = 780;
    public static final int HEAL_EFFECT_RATE = 790;
    public static final int ANTI_HEAL_EFFECT_RATE = 800;
    public static final int SEAL_LEVEL = 810;
    public static final int ANTI_SEAL_LEVEL = 820;
    public static final int PHYSIC_CRIT_RATE = 830;
    public static final int ANTI_PHYSIC_CRIT_RATE = 840;
    public static final int MAGIC_CRIT_RATE = 850;
    public static final int ANTI_MAGIC_CRIT_RATE = 860;
    public static final int HEAL_CRIT_LEVEL = 870;
    public static final int ANTI_HEAL_CRIT_LEVEL = 880;
    public static final int ANTI_POISON_RATE = 890;
    public static final int ANTI_DIE_FORBID_RATE = 900;
    public static final int ANTI_PARRY_RATE = 910;
    public static final int ANTI_RETURN_HURT_RATE = 920;
    public static final int ANTI_ATTACK_BACK_RATE = 930;
    public static final int ANTI_GOD_BLESS_RATE = 940;
    public static final int PHYSIC_DAMGE_PIERCE_RATE = 950;
    public static final int ANTI_PHYSIC_DAMGE_PIERCE_RATE = 960;
    public static final int MAGIC_DAMGE_PIERCE_RATE = 970;
    public static final int ANTI_MAGIC_DAMGE_PIERCE_RATE = 980;
    public static final int HEAL_DEEP_RATE = 990;
    public static final int ANTI_HEAL_DEEP_RATE = 1000;
    public static final int EFFECT_POINT = 1010;
    public static final int TEMP_SP = 1020;
    public static final int ENLIMIT = 1520;
    public static final int PFLIMIT = 1530;
    public static final int AMEND_HIDDEN_WEAPON_PASSIVE = 1540;
    public static final int ATTACK_BACK_LEVEL = 1750;
    public static final int RETURN_HURT_LEVEL = 1760;
    public static final int ANTI_ATTACK_BACK_LEVEL = 1770;
    public static final int ANTI_RETURN_HURT_LEVEL = 1780;
    public static final int MAGIC_HIT = 1840;
    public static final int HEALEDREVISE = 800;
    public static final int ANTI_CRITC_LEVEL = 2090;
    public static final int KONGZHI_JIACHENG = 2130;
    public static final int KONGZHI_MIANYI = 2140;
    public static final int PHYSIC_FLOAT_VALUE = 2150;
    public static final int MAGIC_FLOAT_VALUE = 2160;
    public static final int HEAL_FLOAT_VALUE = 2170;
    public static final int DEEP_HEAL_CRITC_LEVEL = 2180;
    public static final int SHAPE_ID = 3000;

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
            return _o1_ instanceof FightAttrType;
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

    public int compareTo(FightAttrType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

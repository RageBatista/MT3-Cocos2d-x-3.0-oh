//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.attr;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class AttrType implements Marshal, Comparable<AttrType> {
    public static final int CONS = 10;
    public static final int IQ = 20;
    public static final int STR = 30;
    public static final int ENDU = 40;
    public static final int AGI = 50;
    public static final int MAX_HP = 60;
    public static final int UP_LIMITED_HP = 70;
    public static final int HP = 80;
    public static final int SPIRIT = 90;
    public static final int MAX_MP = 90;
    public static final int MP = 100;
    public static final int MAX_SP = 110;
    public static final int SP = 120;
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
    public static final int PHY_CRIT_PCT = 250;
    public static final int MAGIC_CRIT_PCT = 280;
    public static final int PHY_CRITC_LEVEL = 230;
    public static final int ANTI_PHY_CRITC_LEVEL = 240;
    public static final int MAGIC_CRITC_LEVEL = 260;
    public static final int ANTI_MAGIC_CRITC_LEVEL = 270;
    public static final int HEAL_CRIT_LEVEL = 290;
    public static final int HEAL_CRIT_PCT = 300;
    public static final int PHFORCE = 450;
    public static final int EXP = 470;
    public static final int NEXP = 480;
    public static final int RENQI = 610;
    public static final int SCHOOLFUND = 850;
    public static final int WULI_CHUANTOU = 950;
    public static final int WULI_DIKANG = 960;
    public static final int FASHU_CHUANTOU = 970;
    public static final int FASHU_DIKANG = 980;
    public static final int ZHILIAO_JIASHEN = 990;
    public static final int EFFECT_POINT = 1010;
    public static final int TEMP_SP = 1020;
    public static final int MASTER_REPUTATION = 1080;
    public static final int PET_XUEMAI_MAX = 1150;
    public static final int PET_LOW_SKILL = 1170;
    public static final int PET_HIGH_SKILL = 1180;
    public static final int PET_SUPER_SKILL = 1190;
    public static final int LEVEL = 1230;
    public static final int PET_LIFE = 1360;
    public static final int ACTIVESTAR = 1380;
    public static final int POINT = 1400;
    public static final int QILIZHI = 1410;
    public static final int QILIZHI_LIMIT = 1420;
    public static final int PET_XUE_MAI_LEVEL = 1430;
    public static final int PET_FIGHT_LEVEL = 1430;
    public static final int PET_ATTACK_APT = 1440;
    public static final int PET_DEFEND_APT = 1450;
    public static final int PET_PHYFORCE_APT = 1460;
    public static final int PET_MAGIC_APT = 1470;
    public static final int PET_SPEED_APT = 1480;
    public static final int PET_DODGE_APT = 1490;
    public static final int PET_GROW_RATE = 1500;
    public static final int ENLIMIT = 1520;
    public static final int PFLIMIT = 1530;
    public static final int PET_SCALE = 1810;
    public static final int ACTIVENESS = 1820;
    public static final int ANTI_CRIT_LEVEL = 2090;
    public static final int KONGZHI_JIACHENG = 2130;
    public static final int KONGZHI_MIANYI = 2140;
    public static final int ENERGY = 3010;

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
            return _o1_ instanceof AttrType;
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

    public int compareTo(AttrType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

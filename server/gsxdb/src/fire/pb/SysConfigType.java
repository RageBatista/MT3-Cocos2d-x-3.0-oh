//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb;

import com.locojoy.base.Marshal.Marshal;
import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;

public class SysConfigType implements Marshal, Comparable<SysConfigType> {
    public static final int Music = 1;
    public static final int Volume = 2;
    public static final int SoundSpecEffect = 3;
    public static final int SceneEffect = 4;
    public static final int MaxScreenShowNum = 5;
    public static final int ScreenRefresh = 6;
    public static final int AutoVoiceGang = 7;
    public static final int AutoVoiceWorld = 8;
    public static final int AutoVoiceTeam = 9;
    public static final int AutoVoiceSchool = 10;
    public static final int RefuseFriend = 11;
    public static final int WorldChannel = 12;
    public static final int GangChannel = 13;
    public static final int SchoolChannel = 14;
    public static final int CurrentChannel = 15;
    public static final int TeamChannel = 16;
    public static final int PVPNotify = 17;
    public static final int friendchatencrypt = 18;
    public static final int friendmessage = 19;
    public static final int rolePointAdd = 20;
    public static final int petPointAdd = 21;
    public static final int skillPointAdd = 22;
    public static final int huoyueduAdd = 23;
    public static final int zhenfaAdd = 24;
    public static final int skillopen = 25;
    public static final int factionopen = 26;
    public static final int petopen = 27;
    public static final int patopen = 28;
    public static final int zuduichannel = 29;
    public static final int guajiopen = 30;
    public static final int zhiyinopen = 31;
    public static final int huodongopen = 32;
    public static final int refuseqiecuo = 33;
    public static final int ts_julonghuwei = 34;
    public static final int ts_julongjuntuan = 35;
    public static final int ts_guanjunshilian = 36;
    public static final int ts_renwentansuo = 37;
    public static final int ts_1v1 = 38;
    public static final int ts_gonghuifuben = 39;
    public static final int ts_3v3 = 40;
    public static final int ts_zhihuishilian = 41;
    public static final int refuseclan = 42;
    public static final int refuseotherseeequip = 43;
    public static final int screenrecord = 44;
    public static final int equipendure = 45;
    public static final int ts_gonghuizhan = 46;
    public static final int rolldianshezhi = 47;
    public static final int framesimplify = 48;

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
            return _o1_ instanceof SysConfigType;
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

    public int compareTo(SysConfigType _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return _c_;
        }
    }
}

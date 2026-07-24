//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.RoleConfigManager;
import fire.pb.fushi.FushiManager;
import fire.pb.team.TeamManager;
import fire.pb.util.BagUtil;
import fire.pb.util.MessageUtil;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.List;
import mkdb.Lockeys;
import mkdb.Procedure;
import org.apache.log4j.Logger;
import xbean.Properties;
import xbean.SchoolWheel;
import xtable.Openschoolwheeltable;

public class CEndSchoolWheel1 extends __CEndSchoolWheel__ {
    public static final int PROTOCOL_TYPE = 800025;
    private static Logger logger = Logger.getLogger("SYSTEM");

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid > 0L) {
            (new Procedure() {
                public boolean returnmoney() {
                    int num = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(509).getValue());
                    Properties prop = xtable.Properties.get(roleid);
                    int userId = prop.getUserid();
                    boolean ok = FushiManager.addFushiToUser(userId, roleid, num, 0, YYLoggerTuJingEnum.tujing_Value_monthcard);
                    return ok;
                }

                protected boolean process() throws Exception {
                    TeamManager.getTeamByRoleId(roleid);
                    List<Long> list = new ArrayList();
                    list.add(roleid);
                    this.lock(Lockeys.get(xtable.Locks.ROLELOCK, list));
                    SchoolWheel schoolWheel = Openschoolwheeltable.get(roleid);
                    if (schoolWheel == null) {
                        this.returnmoney();
                        return true;
                    } else {
                        int type = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(507).getValue());
                        WheelAwardItem awardItem = GameManager.getInstance().getAwardItem(type, schoolWheel.getItemindex());
                        if (awardItem == null) {
                            this.returnmoney();
                            return true;
                        } else {
                            int realAdd = BagUtil.addItem(roleid, awardItem.itemid, awardItem.itemnum, "schoolwheel", YYLoggerTuJingEnum.tujing_Value_rollschoolwheel, awardItem.itemid);
                            if (realAdd == awardItem.itemnum) {
                                MessageUtil.psendAddItemWhileCommit(roleid, awardItem.itemid, realAdd);
                            }

                            int mustAdd = 0;
                            if (awardItem.mustitem > 0) {
                                mustAdd = BagUtil.addItem(roleid, awardItem.mustitem, awardItem.mustnum, "schoolwheel", YYLoggerTuJingEnum.tujing_Value_rollschoolwheel, awardItem.mustitem);
                            }

                            if (mustAdd > 0 && mustAdd == awardItem.mustnum) {
                                MessageUtil.psendAddItemWhileCommit(roleid, awardItem.mustitem, mustAdd);
                            }

                            Openschoolwheeltable.remove(roleid);
                            return true;
                        }
                    }
                }
            }).submit();
        }

    }

    public int getType() {
        return 800025;
    }

    public final boolean _validator_() {
        return true;
    }

    public OctetsStream marshal(OctetsStream _os_) {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public OctetsStream unmarshal(OctetsStream _os_) throws MarshalException {
        if (!this._validator_()) {
            throw new VerifyError("validator failed");
        } else {
            return _os_;
        }
    }

    public boolean equals(Object _o1_) {
        return _o1_ == this || _o1_ instanceof CEndSchoolWheel1;
    }

    public int hashCode() {
        int _h_ = 0;
        return 0;
    }

    public String toString() {
        StringBuilder _sb_ = new StringBuilder();
        _sb_.append("(");
        _sb_.append(")");
        return _sb_.toString();
    }

    public int compareTo(CEndSchoolWheel1 _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return 0;
        }
    }
}

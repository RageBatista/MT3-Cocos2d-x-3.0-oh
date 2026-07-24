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
import fire.pb.item.Pack;
import fire.pb.team.TeamManager;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.List;
import mkdb.Lockeys;
import mkdb.Procedure;
import org.apache.log4j.Logger;
import xbean.Pod;
import xbean.Properties;
import xbean.SchoolWheel;
import xtable.Openschoolwheeltable;

public class CBeginSchoolWheel1 extends __CBeginSchoolWheel__ {
    public static final int PROTOCOL_TYPE = 800024;
    static Logger logger = Logger.getLogger("SHIKONG");

    protected void process() {
        final long roleid = Onlines.getInstance().findRoleid(this);
        if (roleid > 0L) {
            (new Procedure() {
                protected boolean process() throws Exception {
                    TeamManager.getTeamByRoleId(roleid);
                    List<Long> list = new ArrayList();
                    list.add(roleid);
                    this.lock(Lockeys.get(xtable.Locks.ROLELOCK, list));
                    SchoolWheel schoolWheel = Openschoolwheeltable.get(roleid);
                    if (schoolWheel == null) {
                        schoolWheel = Pod.newSchoolWheel();
                        Openschoolwheeltable.insert(roleid, schoolWheel);
                    }

                    int type = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(507).getValue());
                    int itemIndex = GameManager.getInstance().getAwardItemIndex(type);
                    if (itemIndex == -1) {
                        CBeginSchoolWheel1.logger.debug("时空宝盒，没抽中东西");
                        return false;
                    } else {
                        CBeginSchoolWheel1.logger.debug("时空宝盒，抽中了" + itemIndex);
                        schoolWheel.setItemindex(itemIndex);
                        schoolWheel.setAwardid(1);
                        int moneytype = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(508).getValue());
                        int num = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(509).getValue());
                        if (moneytype == 3) {
                            Properties prop = xtable.Properties.get(roleid);
                            int userId = prop.getUserid();
                            boolean ok = FushiManager.subFushiFromUser(userId, roleid, num, 0, 0, 2006, YYLoggerTuJingEnum.tujing_Value_monthcard, true);
                            if (!ok) {
                                System.out.println("货币扣除失败！");
                                return false;
                            }
                        } else {
                            Pack bag = new Pack(roleid, false);
                            long ret = bag.subCurrency((long)(-num), moneytype, "schoolwheel", YYLoggerTuJingEnum.tujing_Value_zhuanpan, 0);
                            if (ret == 0L) {
                                return false;
                            }
                        }

                        SBeginSchoolWheel1 beginWheel = new SBeginSchoolWheel1();
                        beginWheel.wheelindex = itemIndex;
                        Procedure.psendWhileCommit(roleid, beginWheel);
                        return true;
                    }
                }
            }).submit();
        }
    }

    public int getType() {
        return 800024;
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
        return _o1_ == this || _o1_ instanceof CBeginSchoolWheel1;
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

    public int compareTo(CBeginSchoolWheel1 _o_) {
        if (_o_ == this) {
            return 0;
        } else {
            int _c_ = 0;
            return 0;
        }
    }
}

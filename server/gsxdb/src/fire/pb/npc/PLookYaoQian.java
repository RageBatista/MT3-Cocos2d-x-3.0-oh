//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.common.SCommon;
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
import fire.pb.map.SceneNpcManager;
import fire.pb.talk.MessageMgr;
import fire.pb.util.MessageUtil;
import java.util.List;
import mkdb.Procedure;
import xbean.RoleYaoQianShuInfo;
import xbean.RoleYaoQianShuInfoMaps;
import xtable.Roleyaoqianshuinfos;
import xtable.Roleyaoqianshutables;

public class PLookYaoQian extends Procedure {
    private final long roleid;
    private final long npckey;

    public PLookYaoQian(long roleid, long npckey) {
        this.roleid = roleid;
        this.npckey = npckey;
    }

    protected boolean process() throws Exception {
        Long yaoqianRoleid = Roleyaoqianshuinfos.get(this.npckey);
        if (yaoqianRoleid == null) {
            return false;
        } else {
            RoleYaoQianShuInfoMaps yaoqianMap = Roleyaoqianshutables.get(yaoqianRoleid);
            if (yaoqianMap == null) {
                return false;
            } else {
                RoleYaoQianShuInfo yaoqianInfo = (RoleYaoQianShuInfo)yaoqianMap.getYaoqianshumaps().get(this.npckey);
                if (yaoqianInfo == null) {
                    return false;
                } else if (yaoqianInfo.getLookroleids().contains(this.roleid)) {
                    MessageMgr.psendMsgNotifyWhileRollback(this.roleid, 180025, (List)null);
                    return false;
                } else {
                    yaoqianInfo.getLookroleids().add(this.roleid);
                    Pack bag = new Pack(this.roleid, false);
                    bag.addSysMoney(20000L, "摇钱树", YYLoggerTuJingEnum.tujing_Value_yaoqianshu, 0);
                    MessageUtil.psendAddorRemoveMoney(this.roleid, 20000L);
                    SCommon commonMap = (SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(339);
                    if (yaoqianInfo.getLookroleids().size() == Integer.parseInt(commonMap.getValue())) {
                        Pack ownerbag = new Pack(yaoqianRoleid, false);
                        ownerbag.addSysMoney(5000000L, "摇钱树", YYLoggerTuJingEnum.tujing_Value_yaoqianshu, 0);
                        MessageUtil.psendAddorRemoveMoney(yaoqianRoleid, 5000000L);
                        SceneNpcManager.premoveNpcWhileCommit(this.npckey);
                        yaoqianMap.getYaoqianshumaps().remove(this.npckey);
                        Roleyaoqianshuinfos.remove(this.npckey);
                    }

                    return true;
                }
            }
        }
    }
}

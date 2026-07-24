//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.common.SCommon;
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
import fire.pb.util.MessageUtil;
import mkdb.Procedure;
import xbean.RoleYaoQianShuInfo;
import xbean.RoleYaoQianShuInfoMaps;
import xtable.Roleyaoqianshuinfos;
import xtable.Roleyaoqianshutables;

public class PRemoveYaoQian extends Procedure {
    private final long npckey;

    public PRemoveYaoQian(long npckey) {
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
                } else {
                    int lookids = yaoqianInfo.getLookroleids().size();
                    Pack ownerbag = new Pack(yaoqianRoleid, false);
                    SCommon commonMap = (SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(338);
                    if (lookids >= Integer.valueOf(commonMap.getValue())) {
                        ownerbag.addSysMoney(5000000L, "摇钱树", YYLoggerTuJingEnum.tujing_Value_yaoqianshu, 0);
                        MessageUtil.psendAddorRemoveMoney(yaoqianRoleid, 5000000L);
                    } else {
                        long awardmoney = (long)(1000000 + lookids * 10000);
                        ownerbag.addSysMoney(awardmoney, "摇钱树", YYLoggerTuJingEnum.tujing_Value_yaoqianshu, 0);
                        MessageUtil.psendAddorRemoveMoney(yaoqianRoleid, awardmoney);
                    }

                    yaoqianMap.getYaoqianshumaps().remove(this.npckey);
                    Roleyaoqianshuinfos.remove(this.npckey);
                    return true;
                }
            }
        }
    }
}

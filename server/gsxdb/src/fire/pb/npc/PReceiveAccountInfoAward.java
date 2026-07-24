//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.activity.award.RewardMgr;
import java.util.Map;
import mkdb.Procedure;
import xbean.LianyunAwardInfo;
import xbean.Properties;
import xtable.Lianyunaward;

public class PReceiveAccountInfoAward extends Procedure {
    private final long roleid;
    private final int serviceid;

    public PReceiveAccountInfoAward(long roleid, int serviceid) {
        this.roleid = roleid;
        this.serviceid = serviceid;
    }

    protected boolean process() throws Exception {
        Properties prop = xtable.Properties.select(this.roleid);
        if (prop == null) {
            return true;
        } else {
            int awardid = 0;
            int lianyunkey = 0;
            if (this.serviceid == 1078) {
                lianyunkey = 16;
                awardid = 1688;
            }

            if (this.serviceid == 1079) {
                lianyunkey = 32;
                awardid = 1689;
            }

            LianyunAwardInfo lianyunAwardInfo = Lianyunaward.get(prop.getUserid());
            Long awardTime = (Long)lianyunAwardInfo.getAwards().get(lianyunkey);
            if (awardTime != null && awardTime == 0L) {
                RewardMgr.getInstance().distributeAllAward(this.roleid, awardid, (Map)null, YYLoggerTuJingEnum.tujing_Value_npcjiangli, awardid, 4003, "补填账号信息奖励");
                lianyunAwardInfo.getAwards().put(lianyunkey, System.currentTimeMillis());
            }

            return true;
        }
    }
}

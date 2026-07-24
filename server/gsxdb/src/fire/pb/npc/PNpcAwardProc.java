//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.activity.award.RewardMgr;
import fire.pb.game.Snpcjianglifafang;
import fire.pb.main.ConfigManager;
import fire.pb.util.DateValidate;
import java.util.Map;
import mkdb.Procedure;
import xbean.Pod;
import xbean.Properties;
import xbean.npcaward;
import xbean.npcawardrecords;
import xtable.Role2npcawards;

public class PNpcAwardProc extends Procedure {
    private long roleId;
    private int serviceId;

    public PNpcAwardProc(long roleId, int serviceId) {
        this.roleId = roleId;
        this.serviceId = serviceId;
    }

    public boolean process() {
        Properties prop = xtable.Properties.get(this.roleId);
        if (prop == null) {
            return false;
        } else {
            Map<Integer, Snpcjianglifafang> npcawards = ConfigManager.getInstance().getConf(Snpcjianglifafang.class);
            if (npcawards == null) {
                return false;
            } else {
                Snpcjianglifafang cfg = (Snpcjianglifafang)npcawards.get(this.serviceId);
                if (cfg == null) {
                    return false;
                } else if (prop.getLevel() < cfg.lvxianzhi) {
                    return false;
                } else {
                    npcawardrecords records = Role2npcawards.get(this.roleId);
                    if (records == null) {
                        records = Pod.newnpcawardrecords();
                        Role2npcawards.insert(this.roleId, records);
                    }

                    npcaward award = (npcaward)records.getRecords().get(cfg.jiangliid);
                    long now = System.currentTimeMillis();
                    if (award == null) {
                        award = Pod.newnpcaward();
                        award.setLasttime(now);
                        records.getRecords().put(cfg.jiangliid, award);
                    }

                    boolean theSameDay = DateValidate.inTheSameDay(now, award.getLasttime());
                    if (!theSameDay) {
                        award.setCount(0);
                    }

                    if (award.getCount() < cfg.jianglicishu) {
                        award.setCount(award.getCount() + 1);
                        award.setLasttime(now);
                        award.setTotalcount(award.getCount() + 1);
                        RewardMgr.getInstance().distributeAllAward(this.roleId, cfg.jiangliid, (Map)null, YYLoggerTuJingEnum.tujing_Value_npcjiangli, 0, 4003, "NPC奖励", true);
                        return true;
                    } else {
                        return false;
                    }
                }
            }
        }
    }

    public static boolean containedByNpcAward(int serviceId) {
        Map<Integer, Snpcjianglifafang> npcawards = ConfigManager.getInstance().getConf(Snpcjianglifafang.class);
        return npcawards == null ? false : npcawards.containsKey(serviceId);
    }
}

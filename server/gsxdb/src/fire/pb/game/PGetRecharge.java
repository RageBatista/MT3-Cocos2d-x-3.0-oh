//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import fire.pb.main.ConfigManager;
import fire.pb.util.DateValidate;
import java.util.Map;
import mkdb.Procedure;
import xbean.DailyInfo;
import xbean.TotalInfo;
import xtable.Dailyrecharge;
import xtable.Totalrecharge;

public class PGetRecharge extends Procedure {
    private long roleid;
    private Map<Integer, SDayReaward> SDayReawardConf = ConfigManager.getInstance().getConf(SDayReaward.class);
    private Map<Integer, STotalReaward> STotalReawardConf = ConfigManager.getInstance().getConf(STotalReaward.class);

    public PGetRecharge(long roleid) {
        this.roleid = roleid;
    }

    protected boolean process() throws Exception {
        SOutRecharge sOutRecharge = new SOutRecharge();
        long now = System.currentTimeMillis();
        DailyInfo dailyInfo = Dailyrecharge.get(this.roleid);
        if (dailyInfo != null) {
            if (!DateValidate.inTheSameDay(dailyInfo.getTime(), now) && dailyInfo.getTime() < now) {
                dailyInfo.setPaynum(0L);
                dailyInfo.getDayrewardmap().clear();
                dailyInfo.setTime(now);
            }

            for(SDayReaward value : this.SDayReawardConf.values()) {
                if ((long)value.id < dailyInfo.getPaynum() && !dailyInfo.getDayrewardmap().containsKey(value.id)) {
                    dailyInfo.getDayrewardmap().put(value.id, 0L);
                }
            }

            sOutRecharge.pay = dailyInfo.getPaynum();
            sOutRecharge.dayrewardmap.putAll(dailyInfo.getDayrewardmap());
        }

        TotalInfo totalInfo = Totalrecharge.get(this.roleid);
        if (totalInfo != null) {
            for(STotalReaward value : this.STotalReawardConf.values()) {
                if ((long)value.id < totalInfo.getTotal() && !totalInfo.getTotalrewardmap().containsKey(value.id)) {
                    totalInfo.getTotalrewardmap().put(value.id, 0L);
                }
            }

            sOutRecharge.total = totalInfo.getTotal();
            sOutRecharge.totalrewardmap.putAll(totalInfo.getTotalrewardmap());
        }

        Procedure.psendWhileCommit(this.roleid, sOutRecharge);
        return true;
    }
}

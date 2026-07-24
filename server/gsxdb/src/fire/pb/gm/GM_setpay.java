//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import fire.pb.game.SOutReawardResult;
import fire.pb.game.SOutRecharge;
import mkdb.Procedure;
import xbean.DailyInfo;
import xbean.Pod;
import xbean.TotalInfo;
import xtable.Dailyrecharge;
import xtable.Totalrecharge;

public class GM_setpay extends GMCommand {
    boolean exec(String[] strings) {
        final long roleId = Long.parseLong(strings[0]);
        final long paynum = Long.parseLong(strings[1]);
        (new Procedure() {
            public boolean process() {
                DailyInfo dailyInfo = Dailyrecharge.get(roleId);
                long now = System.currentTimeMillis();
                if (dailyInfo == null) {
                    dailyInfo = Pod.newDailyInfo();
                    dailyInfo.setPaynum(paynum);
                    dailyInfo.setTime(now);
                    Dailyrecharge.insert(roleId, dailyInfo);
                } else {
                    long paynum1 = dailyInfo.getPaynum();
                    dailyInfo.setPaynum(paynum1 + paynum);
                    dailyInfo.setTime(now);
                }

                TotalInfo totalInfo = Totalrecharge.get(roleId);
                if (totalInfo == null) {
                    totalInfo = Pod.newTotalInfo();
                    totalInfo.setTotal(paynum);
                    Totalrecharge.insert(roleId, totalInfo);
                } else {
                    long total = totalInfo.getTotal();
                    totalInfo.setTotal(total + paynum);
                }

                SOutRecharge sOutRecharge = new SOutRecharge();
                sOutRecharge.pay = dailyInfo.getPaynum();
                sOutRecharge.dayrewardmap.putAll(dailyInfo.getDayrewardmap());
                sOutRecharge.total = totalInfo.getTotal();
                sOutRecharge.totalrewardmap.putAll(totalInfo.getTotalrewardmap());
                Procedure.psendWhileCommit(roleId, sOutRecharge);
                SOutReawardResult sOutReawardResult = new SOutReawardResult();
                Procedure.psendWhileCommit(roleId, sOutReawardResult);
                return true;
            }
        }).submit();
        return true;
    }

    String usage() {
        return "当前的值";
    }
}

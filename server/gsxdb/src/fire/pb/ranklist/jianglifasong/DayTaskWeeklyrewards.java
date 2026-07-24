//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.ranklist.jianglifasong;

import fire.msp.IGetRolesCallBack;
import fire.pb.RoleConfigManager;
import fire.pb.map.RoleManager;
import java.util.Calendar;
import java.util.List;
import java.util.TimerTask;
import java.util.concurrent.TimeUnit;
import mkdb.Executor;
import mkdb.Procedure;

public class DayTaskWeeklyrewards extends TimerTask {
    public void run() {
        RoleManager.getRolesByConditions(-1, -1, -1, -1L, -1, new IGetRolesCallBack() {
            public void process(List<Long> roleIds) {
                (DayTaskWeeklyrewards.this.new Reward()).call();
            }
        });
    }

    class Reward extends Procedure {
        Reward() {
            System.out.println("周-排行榜发放");
        }

        protected boolean process() throws Exception {
            Calendar cal = Calendar.getInstance();
            int dayInWeek = cal.get(7);
            int paihangbang = Integer.parseInt(RoleConfigManager.getRoleWeeklyrewards(10000).getValue());
            int zhouji = Integer.parseInt(RoleConfigManager.getRoleWeeklyrewards(11001).getValue());
            final int zonghe = Integer.parseInt(RoleConfigManager.getRoleWeeklyrewards(10001).getValue());
            final int renwu = Integer.parseInt(RoleConfigManager.getRoleWeeklyrewards(10002).getValue());
            final int chongwu = Integer.parseInt(RoleConfigManager.getRoleWeeklyrewards(10003).getValue());
            if (paihangbang == 1) {
                if (dayInWeek == zhouji) {
                    System.out.println("开始发榜3");
                    Executor.getInstance().schedule(new Runnable() {
                        public void run() {
                            System.out.println("zonghe:" + zonghe);
                            if (zonghe == 1) {
                                System.out.println("周-综合战力榜发放");
                                ZhouRewardManager.WeeklyReward();
                            }

                            System.out.println("chongwu:" + chongwu);
                            if (chongwu == 1) {
                                System.out.println("周-宠物战力榜发放");
                                ZhouRewardManager.WeeklychongwuReward();
                            }

                            System.out.println("renwu:" + renwu);
                            if (renwu == 1) {
                                System.out.println("周-人物战力榜发放");
                                ZhouRewardManager.WeeklyrenwuReward();
                            }

                        }
                    }, 1L, TimeUnit.MINUTES);
                    return true;
                } else {
                    System.out.println("设定发放时间为：周" + zhouji + "  今天是:周" + dayInWeek);
                    return true;
                }
            } else {
                System.out.println("排行榜未开放");
                return false;
            }
        }
    }
}

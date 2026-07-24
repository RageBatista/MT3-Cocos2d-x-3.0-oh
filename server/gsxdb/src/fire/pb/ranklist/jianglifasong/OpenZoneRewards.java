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

public class OpenZoneRewards extends TimerTask {
    public void run() {
        RoleManager.getRolesByConditions(-1, -1, -1, -1L, -1, new IGetRolesCallBack() {
            public void process(List<Long> roleIds) {
                (OpenZoneRewards.this.new Reward()).call();
            }
        });
    }

    class Reward extends Procedure {
        protected boolean process() throws Exception {
            Calendar cal = Calendar.getInstance();
            int paihangbang = Integer.parseInt(RoleConfigManager.getRoleRFrankingConfig(10000).getValue());
            final int zonghe = Integer.parseInt(RoleConfigManager.getRoleRFrankingConfig(10001).getValue());
            final int renwu = Integer.parseInt(RoleConfigManager.getRoleRFrankingConfig(10002).getValue());
            final int chongwu = Integer.parseInt(RoleConfigManager.getRoleRFrankingConfig(10003).getValue());
            System.out.println("一分钟后开始发榜");
            if (paihangbang == 1) {
                Executor.getInstance().schedule(new Runnable() {
                    public void run() {
                        System.out.println("zonghe:" + zonghe);
                        if (zonghe == 1) {
                            System.out.println("综合战力榜发放");
                            WeeklyRewardManager.WeeklyReward();
                        }

                        System.out.println("chongwu:" + chongwu);
                        if (chongwu == 1) {
                            System.out.println("宠物战力榜发放");
                            WeeklyRewardManager.WeeklychongwuReward();
                        }

                        System.out.println("renwu:" + renwu);
                        if (renwu == 1) {
                            System.out.println("人物战力榜发放");
                            WeeklyRewardManager.WeeklyrenwuReward();
                        }

                    }
                }, 1L, TimeUnit.SECONDS);
                return true;
            } else {
                return false;
            }
        }
    }
}

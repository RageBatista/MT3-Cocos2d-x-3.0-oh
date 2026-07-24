//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.RoleConfigManager;
import fire.pb.fushi.FushiManager;
import fire.pb.talk.MessageMgr;
import java.util.ArrayList;
import java.util.List;
import mkdb.Procedure;
import xbean.Properties;

public class PExtMarketSize extends Procedure {
    private final long roleId;
    private final int packid;

    public PExtMarketSize(long roleId, int packid) {
        this.roleId = roleId;
        this.packid = packid;
    }

    protected boolean process() {
        ItemMaps bag = Module.getInstance().getItemMaps(this.roleId, 6, false);
        int capacity = bag.getCapacity();
        int maxCapacity = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(620).getValue());
        int money = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(621).getValue());
        if (this.packid == 999) {
            SRefreshPackSize send = new SRefreshPackSize();
            send.packid = 999;
            send.cap = bag.getCapacity();
            Procedure.psendWhileCommit(this.roleId, send);
        } else {
            if (capacity >= maxCapacity) {
                List<String> num = new ArrayList();
                num.add(String.valueOf(maxCapacity));
                MessageMgr.sendMsgNotify(this.roleId, 198195, num);
                return false;
            }

            int addcount = 8;
            Properties localProperties = xtable.Properties.get(this.roleId);
            if (!FushiManager.subFushiFromUser(localProperties.getUserid(), this.roleId, money, 0, 0, 1340, YYLoggerTuJingEnum.tujing_Value_changeschoolcost, false)) {
                MessageMgr.psendMsgNotify(this.roleId, 162032, (List)null);
                return false;
            }

            bag.addCapacity(addcount);
            SRefreshPackSize send = new SRefreshPackSize();
            send.packid = 6;
            send.cap = bag.getCapacity();
            Procedure.psendWhileCommit(this.roleId, send);
        }

        return true;
    }
}

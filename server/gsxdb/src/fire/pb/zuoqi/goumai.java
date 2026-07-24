//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.zuoqi;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.fushi.FushiManager;
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
import fire.pb.npc.SRideItem;
import fire.pb.talk.MessageMgr;
import java.util.List;
import mkdb.Procedure;
import xbean.Properties;

public class goumai extends Procedure {
    private long roleId;
    public int zuoqiid;

    public goumai(long roleId, int zuoqiid) {
        this.roleId = roleId;
        this.zuoqiid = zuoqiid;
    }

    protected boolean process() {
        Properties prop = xtable.Properties.get(this.roleId);
        Pack bag = new Pack(this.roleId, false);
        SRideItem SRideItem = (SRideItem)ConfigManager.getInstance().getConf(SRideItem.class).get(this.zuoqiid);
        if (SRideItem.getHuobi() == 3) {
            Properties localProperties = xtable.Properties.get(this.roleId);
            if (!FushiManager.subFushiFromUser(localProperties.getUserid(), this.roleId, SRideItem.getMoney(), 0, 0, 1340, YYLoggerTuJingEnum.tujing_Value_changeschoolcost, false)) {
                MessageMgr.psendMsgNotify(this.roleId, 162032, (List)null);
                return false;
            }
        } else {
            long ret = bag.subCurrency((long)(-SRideItem.getMoney()), SRideItem.getHuobi(), "elector", YYLoggerTuJingEnum.tujing_Value_campaign, 0);
            if (ret == 0L) {
                MessageMgr.sendMsgNotify(this.roleId, 192805, (List)null);
                return false;
            }
        }

        if (prop.getZuoqi().containsKey(this.zuoqiid)) {
            MessageMgr.sendMsgNotify(this.roleId, 198226, (List)null);
            return false;
        } else {
            prop.getZuoqi().put(this.zuoqiid, this.zuoqiid);
            SZuoQiYongYou sshizhuang = new SZuoQiYongYou();
            sshizhuang.zuoqi.putAll(prop.getZuoqi());
            Procedure.psendWhileCommit(this.roleId, sshizhuang);
            return true;
        }
    }
}

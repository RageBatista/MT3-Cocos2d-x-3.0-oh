//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.qiannengguo;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.attr.SRefreshRoleData;
import fire.pb.effect.RoleImpl;
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import mkdb.Mkdb;
import mkdb.Procedure;
import xbean.Properties;

public class PResetPotentialFruit extends Procedure {
    final long roleId;
    final int location;

    public PResetPotentialFruit(long roleId, int location) {
        this.roleId = roleId;
        this.location = location;
    }

    public boolean process() {
        Properties properties = xtable.Properties.get(this.roleId);
        if (properties == null) {
            return false;
        } else if (!properties.getQlgmap().containsKey(this.location)) {
            return false;
        } else {
            SQiannengguoLevelUp levelUp = (SQiannengguoLevelUp)ConfigManager.getInstance().getConf(SQiannengguoLevelUp.class).get(this.location);
            if (levelUp == null) {
                return false;
            } else {
                Pack bag = new Pack(this.roleId, false);
                if (bag.getGold() < (long)levelUp.resetmoney) {
                    MessageMgr.sendMsgNotify(this.roleId, 193453, (List)null);
                    return false;
                } else if ((long)(-levelUp.resetmoney) != bag.subGold((long)(-levelUp.resetmoney), "重置潜灵果属性", YYLoggerTuJingEnum.tujing_Value_itemrecovercost, 0)) {
                    MessageMgr.sendMsgNotify(this.roleId, 193453, (List)null);
                    return false;
                } else {
                    int rand = Mkdb.random().nextInt(100);
                    int temp = 0;
                    int finalId = 0;
                    TreeMap<Integer, SQiannengguo> conf = ConfigManager.getInstance().getConf(SQiannengguo.class);

                    for(Map.Entry<Integer, SQiannengguo> entry : conf.entrySet()) {
                        temp += ((SQiannengguo)entry.getValue()).rate;
                        if (rand < temp) {
                            finalId = (Integer)entry.getKey();
                            break;
                        }
                    }

                    properties.getQlgmap().put(this.location, finalId);
                    RoleImpl role = new RoleImpl(this.roleId);
                    Map<Integer, Float> integerFloatMap = role.updateAllFinalAttrs();
                    role.updateScore();
                    SRefreshRoleData send = new SRefreshRoleData();
                    send.datas.putAll(integerFloatMap);
                    Procedure.psendWhileCommit(this.roleId, send);
                    SyncPotentialFruit fruit = role.getPotentialFruitProtocol();
                    Procedure.psendWhileCommit(this.roleId, fruit);
                    return true;
                }
            }
        }
    }
}

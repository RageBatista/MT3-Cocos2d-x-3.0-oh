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
import mkdb.Mkdb;
import mkdb.Procedure;
import xbean.FunOpenClose;
import xbean.Properties;

public class PResetPotentialFruitExtra extends Procedure {
    final long roleId;

    public PResetPotentialFruitExtra(long roleId) {
        this.roleId = roleId;
    }

    public boolean process() {
        Properties properties = xtable.Properties.get(this.roleId);
        if (properties == null) {
            return false;
        } else {
            SQiannengguoextra qiannengguoextra = PotentialMgr.getExtra(properties);
            if (qiannengguoextra == null) {
                MessageMgr.psendMsgNotify(this.roleId, 193454, (List)null);
                return false;
            } else if (!properties.getQlgextrapromap().containsKey(qiannengguoextra.needcount)) {
                return false;
            } else {
                Pack bag = new Pack(this.roleId, false);
                if (bag.getGold() < (long)qiannengguoextra.costmoney) {
                    MessageMgr.sendMsgNotify(this.roleId, 193453, (List)null);
                    return false;
                } else if ((long)(-qiannengguoextra.costmoney) != bag.subGold((long)(-qiannengguoextra.costmoney), "重置潜灵果组合属性", YYLoggerTuJingEnum.tujing_Value_itemrecovercost, 0)) {
                    MessageMgr.sendMsgNotify(this.roleId, 193453, (List)null);
                    return false;
                } else {
                    FunOpenClose funOpenClose = (FunOpenClose)properties.getQlgextrapromap().get(qiannengguoextra.needcount);
                    if (funOpenClose == null) {
                        return false;
                    } else {
                        funOpenClose.getFunmap().clear();
                        String[] split = qiannengguoextra.proppool.split(",");
                        int randextra = Mkdb.random().nextInt(qiannengguoextra.maxcountvalue - qiannengguoextra.mincountvalue) + qiannengguoextra.mincountvalue;

                        for(int i = 0; i < randextra; ++i) {
                            Integer randId = Integer.valueOf(split[Mkdb.random().nextInt(split.length)]);
                            if (randId != null) {
                                SQiannengguoProp prop = (SQiannengguoProp)ConfigManager.getInstance().getConf(SQiannengguoProp.class).get(randId);
                                if (prop != null) {
                                    int lastValue = Mkdb.random().nextInt(prop.maxvalue - prop.minvalue) + prop.minvalue;
                                    Double finalvalue = (double)lastValue * qiannengguoextra.doublerate;
                                    funOpenClose.getFunmap().put(prop.id, finalvalue.intValue());
                                }
                            }
                        }

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
}

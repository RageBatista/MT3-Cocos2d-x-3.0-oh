//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.qiannengguo;

import fire.pb.SRefreshUserExp;
import fire.pb.attr.SRefreshRoleData;
import fire.pb.effect.RoleImpl;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import mkdb.Mkdb;
import mkdb.Procedure;
import xbean.FunOpenClose;
import xbean.Pod;
import xbean.Properties;

public class POpenPotentialFruit extends Procedure {
    final long roleId;
    final int location;

    public POpenPotentialFruit(long roleId, int location) {
        this.roleId = roleId;
        this.location = location;
    }

    public boolean process() {
        Properties properties = xtable.Properties.get(this.roleId);
        if (properties == null) {
            return false;
        } else {
            int local = 0;

            for(int i = 1; i < 80; ++i) {
                if (!properties.getQlgmap().containsKey(i)) {
                    local = i;
                    break;
                }
            }

            if (local == 0) {
                MessageMgr.psendMsgNotify(this.roleId, 193450, (List)null);
                return false;
            } else {
                SQiannengguoLevelUp levelUp = (SQiannengguoLevelUp)ConfigManager.getInstance().getConf(SQiannengguoLevelUp.class).get(local);
                if (properties.getLevel() < levelUp.openlevel) {
                    MessageMgr.psendMsgNotify(this.roleId, 193451, (List)null);
                    return false;
                } else if (properties.getExp() < (long)levelUp.levelupvalue) {
                    MessageMgr.psendMsgNotify(this.roleId, 193452, (List)null);
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

                    long finalExp = properties.getExp() - (long)levelUp.levelupvalue;
                    properties.setExp(finalExp);
                    Procedure.psendWhileCommit(this.roleId, new SRefreshUserExp(properties.getExp()));
                    properties.getQlgmap().put(this.location, finalId);
                    SQiannengguoextra qiannengguoextra = PotentialMgr.getExtra(properties);
                    if (qiannengguoextra != null) {
                        if (!properties.getQlgextrapromap().containsKey(qiannengguoextra.needcount)) {
                            FunOpenClose map = Pod.newFunOpenClose();
                            properties.getQlgextrapromap().put(qiannengguoextra.needcount, map);
                            String[] split = qiannengguoextra.proppool.split(",");
                            int randextra = Mkdb.random().nextInt(qiannengguoextra.maxcountvalue - qiannengguoextra.mincountvalue) + qiannengguoextra.mincountvalue;
                            map.getFunmap().clear();

                            for(int i = 0; i < randextra; ++i) {
                                Integer randId = Integer.valueOf(split[Mkdb.random().nextInt(split.length)]);
                                if (randId != null) {
                                    SQiannengguoProp prop = (SQiannengguoProp)ConfigManager.getInstance().getConf(SQiannengguoProp.class).get(randId);
                                    if (prop != null) {
                                        int lastValue = Mkdb.random().nextInt(prop.maxvalue - prop.minvalue) + prop.minvalue;
                                        Double finalvalue = (double)lastValue * qiannengguoextra.doublerate;
                                        map.getFunmap().put(prop.id, finalvalue.intValue());
                                    }
                                }
                            }
                        }

                        properties.setQlgcurrextra(qiannengguoextra.needcount);
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

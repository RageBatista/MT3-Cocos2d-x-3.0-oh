//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.school.change;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.item.ItemMaps;
import fire.pb.item.ItemShuXing;
import fire.pb.item.Module;
import fire.pb.item.Pack;
import fire.pb.item.SItemUpgradeConfig;
import fire.pb.main.ConfigManager;
import fire.pb.ranklist.proc.PRoleZongheRankProc;
import fire.pb.talk.MessageMgr;
import fire.pb.util.BagUtil;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import mkdb.Trace;
import org.apache.log4j.Logger;

public class PItemUpgrade extends Procedure {
    public int srcitemkey;
    public long roleid;
    private static Logger logger = Logger.getLogger("ITEM");
    public static final Map<Integer, SItemUpgradeConfig> upgradeMap = ConfigManager.getInstance().getConf(SItemUpgradeConfig.class);

    public PItemUpgrade(long roleid, int srcitemkey) {
        this.srcitemkey = srcitemkey;
        this.roleid = roleid;
    }

    protected boolean process() throws Exception {
        Pack bag = null;
        bag = new Pack(this.roleid, false);
        ItemMaps bagContainer = Module.getInstance().getItemMaps(this.roleid, 1, false);
        int itemID = this.srcitemkey;
        SItemUpgradeConfig conf = (SItemUpgradeConfig)upgradeMap.get(itemID);
        int needitemid = conf.needitemid;
        int needitemcount = conf.needitemcount;
        int havenum = bagContainer.getItemNum(needitemid, 0);
        if (havenum < needitemcount) {
            Trace.log(Trace.DEBUG, "道具*************" + needitemid + "********" + havenum + "********" + conf.needitemcount);
            MessageMgr.sendMsgNotify(this.roleid, 196032, (List)null);
            return false;
        } else {
            int neeweaponid = conf.oldItemID;
            int needweaponcount = conf.needolditemcount;
            int haveweaponnum = bagContainer.getItemNum(neeweaponid, 0);
            if (haveweaponnum < needweaponcount) {
                Trace.log(Trace.DEBUG, "武器*************" + neeweaponid + "********" + haveweaponnum + "********" + needweaponcount);
                MessageMgr.sendMsgNotify(this.roleid, 196048, (List)null);
                return false;
            } else if (!upgradeMap.containsKey(itemID)) {
                logger.error("未找到对应升阶数据");
                return false;
            } else {
                int confWeaponChangeCostMoney = conf.needCold;
                long ret = bag.subGold((long)(-confWeaponChangeCostMoney), "升阶装备消耗", YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0);
                if (ret != (long)(-confWeaponChangeCostMoney)) {
                    return false;
                } else {
                    int delnum = bagContainer.removeItemById(needitemid, needitemcount, YYLoggerTuJingEnum.tujing_Value_ranse, needitemid, "装备升级");
                    if (delnum != needitemcount) {
                        Trace.log(Trace.DEBUG, "99999999" + needitemid + "********" + havenum + "********" + needitemcount);
                        return false;
                    } else {
                        int removenum = bag.removeItemById(neeweaponid, needweaponcount, YYLoggerTuJingEnum.tujing_Value_dazao, 0, "装备相关");
                        if (removenum != needweaponcount) {
                            return false;
                        } else {
                            int newItemID = conf.newItemID;
                            ItemShuXing iAttr = Module.getInstance().getItemManager().getAttr(newItemID);
                            if (iAttr == null) {
                                Module.logger.error("角色:" + this.roleid + "升阶物品的id:" + newItemID + "找不到属性!");
                                return true;
                            } else if (BagUtil.addItem(this.roleid, newItemID, 1, "升阶物品", YYLoggerTuJingEnum.tujing_Value_daozaoget, newItemID) != 1) {
                                MessageMgr.psendMsgNotifyWhileRollback(this.roleid, 142338, (List)null);
                                return false;
                            } else {
                                SItemUpgrade sendResult = new SItemUpgrade();
                                psendWhileCommit(this.roleid, sendResult);
                                Procedure.pexecuteWhileCommit(new PRoleZongheRankProc(this.roleid));
                                return true;
                            }
                        }
                    }
                }
            }
        }
    }
}

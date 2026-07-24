//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.school.change;

import fire.log.beans.ItemBean;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.buff.Module;
import fire.pb.circletask.CircleTaskManager;
import fire.pb.item.EquipItem;
import fire.pb.item.EquipItemShuXing;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMaps;
import fire.pb.item.ItemShuXing;
import fire.pb.item.Pack;
import fire.pb.item.SZuoqiUpgradeConfig;
import fire.pb.main.ConfigManager;
import fire.pb.ranklist.proc.PRoleZongheRankProc;
import fire.pb.talk.MessageMgr;
import fire.pb.util.BagUtil;
import fire.pb.util.Misc;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import mkdb.Trace;
import org.apache.log4j.Logger;
import xbean.Equip;
import xbean.Properties;

public class PZuoqiUpgrade extends Procedure {
    public int srcweaponkey;
    public long roleid;
    private static Logger logger = Logger.getLogger("ITEM");
    public static final Map<Integer, SZuoqiUpgradeConfig> upgradeMap = ConfigManager.getInstance().getConf(SZuoqiUpgradeConfig.class);

    public PZuoqiUpgrade(long roleid, int srcweaponkey) {
        this.srcweaponkey = srcweaponkey;
        this.roleid = roleid;
    }

    protected boolean process() throws Exception {
        Pack bag = null;
        bag = new Pack(this.roleid, false);
        ItemBase oldWeaponIB = bag.getItem(this.srcweaponkey);
        if (oldWeaponIB == null) {
            logger.error("装备升阶旧装备错误!!!----------------" + this.srcweaponkey);
            return false;
        } else if (oldWeaponIB instanceof EquipItem) {
            logger.error("------------------------------装备升阶");
            Map<Integer, EquipItemShuXing> equipItemAttrConfig = ConfigManager.getInstance().getConf(EquipItemShuXing.class);
            if (Module.existState(this.roleid, 507004)) {
                return false;
            } else if (oldWeaponIB != null && oldWeaponIB instanceof EquipItem) {
                int itemID = oldWeaponIB.getItemId();
                EquipItem oldWeapon = (EquipItem)oldWeaponIB;
                EquipItemShuXing itemdata = (EquipItemShuXing)equipItemAttrConfig.get(itemID);
                if (itemdata == null) {
                    MessageMgr.psendMsgNotify(this.roleid, 150163, (List)null);
                    logger.error("升阶功能没有找到该装备数据!!!");
                    return false;
                } else if ((oldWeaponIB.getFlags() & 4) != 0) {
                    logger.error("拍卖的武器无法使用升阶功能");
                    return false;
                } else {
                    SZuoqiUpgradeConfig conf = (SZuoqiUpgradeConfig)upgradeMap.get(itemID);
                    ItemMaps bagContainer = fire.pb.item.Module.getInstance().getItemMaps(this.roleid, 1, false);
                    int needitemid = conf.needitemid;
                    int needitemcount = conf.needitemcount;
                    int havenum = bagContainer.getItemNum(needitemid, 0);
                    if (havenum < needitemcount) {
                        Trace.log(Trace.DEBUG, "道具*************" + needitemid + "********" + havenum + "********" + conf.needitemcount);
                        MessageMgr.sendMsgNotify(this.roleid, 196032, (List)null);
                        return false;
                    } else {
                        int neeweaponid = conf.oldEquipzID;
                        int needweaponcount = conf.needweaponcount;
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
                            Properties prop = xtable.Properties.select(this.roleid);
                            int userid = prop.getUserid();
                            long ok = bag.subGold((long)(-confWeaponChangeCostMoney), "升阶装备消耗", YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0);
                            if (ok != (long)(-confWeaponChangeCostMoney)) {
                                CircleTaskManager.logger.error("角色[" + this.roleid + "]符石不足,不可任性！");
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
                                        List<ItemBean> itemBeanLst = new ArrayList();
                                        if (oldWeaponIB instanceof EquipItem) {
                                            Equip equipAttr = ((EquipItem)oldWeaponIB).getEquipAttr();
                                            List<Integer> diamonds = equipAttr.getDiamonds();
                                            Iterator<Integer> iterator = diamonds.iterator();

                                            while(iterator.hasNext()) {
                                                Integer gemId = (Integer)iterator.next();
                                                ItemBean getGemItem = new ItemBean();
                                                bag.doAddItem(gemId, 1, "装备分解", YYLoggerTuJingEnum.tujing_Value_fenjieget, gemId);
                                                getGemItem.setAmt(1);
                                                getGemItem.setAftAmt(ItemMaps.getItemHasNum(this.roleid, gemId));
                                                getGemItem.setItemId(gemId);
                                                itemBeanLst.add(getGemItem);
                                            }
                                        }

                                        int randomValue = Misc.getProbability(conf.itemsrate);
                                        int itemid = (Integer)conf.items.get(randomValue);
                                        if (itemid == conf.newEquipzID) {
                                            System.out.println("进阶成功");
                                            MessageMgr.sendMsgNotify(this.roleid, conf.cgonggao, (List)null);
                                        } else if (itemid == conf.shibainewEquipzID) {
                                            System.out.println("进阶失败");
                                            MessageMgr.sendMsgNotify(this.roleid, conf.sgonggao, (List)null);
                                        }

                                        int newItemID = conf.newEquipzID;
                                        ItemShuXing iAttr = fire.pb.item.Module.getInstance().getItemManager().getAttr(itemid);
                                        if (iAttr == null) {
                                            fire.pb.item.Module.logger.error("角色:" + this.roleid + "升阶物品的id:" + newItemID + "找不到属性!");
                                            return true;
                                        } else if (BagUtil.addItem(this.roleid, itemid, 1, "升阶物品", YYLoggerTuJingEnum.tujing_Value_daozaoget, itemid) != 1) {
                                            return false;
                                        } else {
                                            SZuoqiUpgrade sendResult = new SZuoqiUpgrade();
                                            Procedure.psendWhileCommit(this.roleid, sendResult);
                                            Procedure.pexecuteWhileCommit(new PRoleZongheRankProc(this.roleid));
                                            return true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                MessageMgr.psendMsgNotify(this.roleid, 150163, (List)null);
                return false;
            }
        } else {
            return false;
        }
    }
}

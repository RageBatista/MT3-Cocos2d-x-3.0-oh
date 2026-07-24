//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import fire.log.YYLogger;
import fire.log.beans.ItemBean;
import fire.log.beans.ResolveItemBean;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.item.equip.diamond.EquipDiamondMgr;
import fire.pb.talk.MessageMgr;
import fire.pb.tel.utils.GoodsSafeLocksUtils;
import fire.pb.util.BagUtil;
import fire.pb.util.Misc;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.Equip;
import xbean.Item;

public class PAllEquipGemFenJie extends Procedure {
    private long roleId;
    private int fenjietype;
    private static int RESOLVE_BASE = 10000;

    public PAllEquipGemFenJie(long roleid, int fenjietype) {
        this.roleId = roleid;
        this.fenjietype = fenjietype;
    }

    public boolean process() {
        Pack bag = new Pack(this.roleId, false);
        ArrayList<Integer> itemkeylist = new ArrayList();
        Map<Integer, Item> allItemKey = bag.getAllItemKey();
        if (this.fenjietype == 1) {
            for(Integer integer : allItemKey.keySet()) {
                ItemBase iteminfo = bag.getItem(integer);
                if (iteminfo instanceof EquipItem) {
                    EquipItemShuXing itemAttr = (EquipItemShuXing)iteminfo.getItemAttr();
                    if (itemAttr.isallfenjie == 1) {
                        itemkeylist.add(integer);
                    }
                }
            }

            for(Integer keyinpack : itemkeylist) {
                ItemBase bi = bag.getItem(keyinpack);
                if (bi == null) {
                    return false;
                }

                ResolveItemData resolveData = (ResolveItemData)Module.resolveItemData.get(bi.getItemId());
                if (resolveData == null) {
                    return false;
                }

                ResolveItemBean resolveItemLog = new ResolveItemBean();
                ItemBean sourceItem = new ItemBean();
                int nMoveNum = bag.removeItemWithKey(keyinpack, 1, YYLoggerTuJingEnum.tujing_Value_fenjie, bi.getItemId(), "宠物背包");
                if (nMoveNum != 1) {
                    return false;
                }

                if (GoodsSafeLocksUtils.checkLockStatus(this.roleId, bi)) {
                    return false;
                }

                int ownItemNum = ItemMaps.getItemHasNum(this.roleId, bi.getItemId());
                sourceItem.setItemId(bi.getItemId());
                sourceItem.setAmt(nMoveNum);
                sourceItem.setAftAmt(ownItemNum);
                resolveItemLog.setSourceitem(sourceItem);
                bag.addMoney((long)resolveData.money, "宠物背包", YYLoggerTuJingEnum.tujing_Value_fenjieget);
                List<String> param = new ArrayList(1);
                param.add(String.valueOf(resolveData.money));
                MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 160163, param);
                resolveItemLog.setMoney(resolveData.money);
                List<ItemBean> itemBeanLst = new ArrayList();
                Equip equipAttr = ((EquipItem)bi).getEquipAttr();

                for(Integer gemId : equipAttr.getDiamonds()) {
                    ItemBean getGemItem = new ItemBean();
                    bag.doAddItem(gemId, 1, "宠物背包", YYLoggerTuJingEnum.tujing_Value_fenjieget, gemId);
                    getGemItem.setAmt(1);
                    getGemItem.setAftAmt(ItemMaps.getItemHasNum(this.roleId, gemId));
                    getGemItem.setItemId(gemId);
                    itemBeanLst.add(getGemItem);
                }

                int item1Index = Misc.getProbabilityByBase(resolveData.retItemid1Rate, RESOLVE_BASE);
                if (item1Index != -1) {
                    int itemid = (Integer)resolveData.retItemid1.get(item1Index);
                    int itemnum = (Integer)resolveData.retItemid1Num.get(item1Index);
                    bag.doAddItem(itemid, itemnum, "宠物背包", YYLoggerTuJingEnum.tujing_Value_fenjieget, itemid);
                    ItemShuXing iAttr = Module.getInstance().getItemManager().getAttr(itemid);
                    if (iAttr == null) {
                        Module.logger.error("角色:" + this.roleId + "分解物品id:" + itemid + "添加物品失败!");
                        return true;
                    }

                    List<String> para = new ArrayList(2);
                    para.add(String.valueOf(iAttr.getName()));
                    para.add(String.valueOf(itemnum));
                    MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 160164, para);
                    ItemBean getItem = new ItemBean();
                    getItem.setAmt(itemnum);
                    getItem.setAftAmt(ItemMaps.getItemHasNum(this.roleId, itemid));
                    getItem.setItemId(itemid);
                    itemBeanLst.add(getItem);
                }

                resolveItemLog.setResultitems(itemBeanLst);
                YYLogger.resolveItemLog(this.roleId, resolveItemLog);
                GoodsSafeLocksUtils.doClearDataWhileCommit(this.roleId);
            }

            return true;
        } else if (this.fenjietype != 2) {
            return true;
        } else {
            for(Integer integer : allItemKey.keySet()) {
                ItemBase iteminfo = bag.getItem(integer);
                if (iteminfo instanceof GemItem) {
                    gemItemShuXing itemAttr = (gemItemShuXing)iteminfo.getItemAttr();
                    if (itemAttr.isallfenjie == 1) {
                        itemkeylist.add(integer);
                    }
                }
            }

            for(Integer gemkey : itemkeylist) {
                ItemBase bi = bag.getItem(gemkey);
                if (bi == null) {
                    return false;
                }

                int fenjienum = bi.getNumber();

                int itemid = ((SBaoShiBiao)EquipDiamondMgr.getDiamondPropMap().get(bi.getItemId())).resolveItem;
                int itemnum = ((SBaoShiBiao)EquipDiamondMgr.getDiamondPropMap().get(bi.getItemId())).resolveNum * fenjienum;
                if (itemid != 0 && itemnum != 0) {
                    int nMoveNum = bag.removeItemWithKey(gemkey, fenjienum, YYLoggerTuJingEnum.tujing_Value_gemfenjie, bi.getItemId(), "宝石分解");
                    if (nMoveNum != fenjienum) {
                        return false;
                    }

                    int realAdd = BagUtil.addItem(this.roleId, itemid, itemnum, "宝石分解", YYLoggerTuJingEnum.tujing_Value_gemfenjieget, itemid);
                    if (realAdd != itemnum) {
                        return false;
                    }

                    ItemShuXing iAttr = Module.getInstance().getItemManager().getAttr(itemid);
                    if (iAttr == null) {
                        Module.logger.error("角色:" + this.roleId + "分解宝石id:" + itemid + "找不到属性!");
                        return false;
                    }

                    List<String> para = new ArrayList(2);
                    para.add(String.valueOf(iAttr.getName()));
                    para.add(String.valueOf(itemnum));
                    MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 160164, para);
                } else {
                    System.out.println("未设置分解奖励跳过此宝石:" + bi.getName());
                }
            }

            return true;
        }
    }
}

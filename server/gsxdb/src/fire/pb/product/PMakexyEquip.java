//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.product;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PropRole;
import fire.pb.event.Poster;
import fire.pb.item.AddItemResult;
import fire.pb.item.EquipItem;
import fire.pb.item.EquipMakeEvent;
import fire.pb.item.ItemBase;
import fire.pb.item.Module;
import fire.pb.item.Pack;
import fire.pb.item.Sxingyindazao;
import fire.pb.item.make.ItemMakeFactory;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import fire.pb.team.TeamManager;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import org.apache.log4j.Logger;

public class PMakexyEquip extends Procedure {
    private long roleId;
    private int equipId;
    private Pack bag = null;
    private static final int PRODUCE_SUCCESS = 140797;
    private static Logger logger = Logger.getLogger("ITEM");

    public PMakexyEquip(long role, int equipid) {
        this.roleId = role;
        this.equipId = equipid;
    }

    public boolean process() {
        this.bag = (Pack)Module.getInstance().getItemMaps(this.roleId, 1, false);
        Map<Integer, Sxingyindazao> petEquipMakeInfoMap = ConfigManager.getInstance().getConf(Sxingyindazao.class);
        Sxingyindazao makeInfo = (Sxingyindazao)petEquipMakeInfoMap.get(this.equipId);
        if (makeInfo == null) {
            return false;
        } else if (!this.checkMaterialIsEnough(makeInfo.item1, makeInfo.item1num) && !this.checkMaterialIsEnough(makeInfo.item2, makeInfo.item2num)) {
            return true;
        } else {
            ItemBase tuzhi = this.getItemKey(makeInfo.item1);
            if (tuzhi == null) {
                MessageMgr.psendMsgNotify(this.roleId, ItemBase.ITEM_LOCK_MSG, (List)null);
                return false;
            } else {
                int removeitemkey = this.bag.removeItemWithKey(tuzhi.getKey(), makeInfo.item1num, YYLoggerTuJingEnum.tujing_Value_dazao, 5, "装备相关");
                if (removeitemkey != makeInfo.item1num) {
                    MessageMgr.psendMsgNotify(this.roleId, ItemBase.ITEM_LOCK_MSG, (List)null);
                    return false;
                } else {
                    logger.debug("Role: " + this.roleId + "背包栏删除道具： " + makeInfo.item1num + "用于" + "装备相关");
                    ItemBase tuzhi2 = this.getItemKey(makeInfo.item2);
                    int removeitemkey2 = this.bag.removeItemWithKey(tuzhi2.getKey(), makeInfo.item2num, YYLoggerTuJingEnum.tujing_Value_dazao, 5, "装备相关");
                    if (removeitemkey2 != makeInfo.item2num) {
                        MessageMgr.psendMsgNotify(this.roleId, ItemBase.ITEM_LOCK_MSG, (List)null);
                        return false;
                    } else {
                        logger.debug("Role: " + this.roleId + "背包栏删除道具： " + makeInfo.item2num + "用于" + "装备相关");
                        PropRole propRole = new PropRole(this.roleId, true);
                        double jilv = (double)makeInfo.jilv / 100.0;
                        if (Math.random() > jilv) {
                            MessageMgr.psendMsgNotify(this.roleId, 196696, (List)null);
                            return true;
                        } else {
                            EquipItem equipItem = this.createEquipItemWithAllAttr(this.equipId, propRole.getName());
                            if (equipItem == null) {
                                logger.error("装备打造出错，检查配置文件");
                                return false;
                            } else if (this.bag.doAddItem(equipItem, -1, "装备相关", YYLoggerTuJingEnum.tujing_Value_daozaoget, 0) != AddItemResult.SUCC) {
                                MessageMgr.psendMsgNotifyWhileRollback(this.roleId, 142338, (List)null);
                                return false;
                            } else {
                                logger.debug("Role: " + this.roleId + "背包栏增加装备： " + this.equipId + "通过" + "装备相关");
                                MessageMgr.psendMsgNotify(this.roleId, 198182, (List)null);
                                Procedure.pexecuteWhileCommit(new Procedure() {
                                    protected boolean process() {
                                        TeamManager.getTeamByRoleId(PMakexyEquip.this.roleId);
                                        Poster.getPoster().dispatchEvent(new EquipMakeEvent(PMakexyEquip.this.roleId));
                                        return true;
                                    }
                                });
                                return true;
                            }
                        }
                    }
                }
            }
        }
    }

    private EquipItem createEquipItemWithAllAttr(int equipid, String producer) {
        return ItemMakeFactory.getFactory().genItemMakeByWay(equipid, producer);
    }

    private ItemBase getItemKey(int itemId) {
        Iterator var3 = this.bag.iterator();

        while(var3.hasNext()) {
            ItemBase item = (ItemBase)var3.next();
            if (itemId == item.getItemId()) {
                return item;
            }
        }

        return null;
    }

    private boolean checkMaterialIsEnough(int materialID, int num) {
        int currentNum = this.bag.getItemNum(materialID, 0);
        return currentNum >= num;
    }
}

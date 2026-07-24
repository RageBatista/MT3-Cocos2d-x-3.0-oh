//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.product;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PropRole;
import fire.pb.event.Poster;
import fire.pb.item.AddItemResult;
import fire.pb.item.EquipMakeEvent;
import fire.pb.item.ItemBase;
import fire.pb.item.Module;
import fire.pb.item.Pack;
import fire.pb.item.PetEquipItem;
import fire.pb.item.SPetEquipMakeInfo;
import fire.pb.item.make.ItemMakeFactory;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import fire.pb.team.TeamManager;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import mkdb.Bean;
import mkdb.Procedure;
import org.apache.log4j.Logger;

public class PMakePetEquip extends Procedure {
    private long roleId;
    private int equipId;
    private Pack bag = null;
    private static final int PRODUCE_SUCCESS = 140797;
    private static Logger logger = Logger.getLogger("ITEM");

    public PMakePetEquip(long role, int equipid) {
        this.roleId = role;
        this.equipId = equipid;
    }

    public boolean process() {
        this.bag = (Pack)Module.getInstance().getItemMaps(this.roleId, 1, false);
        Map<Integer, SPetEquipMakeInfo> petEquipMakeInfoMap = ConfigManager.getInstance().getConf(SPetEquipMakeInfo.class);
        SPetEquipMakeInfo makeInfo = (SPetEquipMakeInfo)petEquipMakeInfoMap.get(this.equipId);
        if (makeInfo == null) {
            return false;
        } else if (!this.checkMaterialIsEnough(makeInfo.item1, makeInfo.item1num) && !this.checkMaterialIsEnough(makeInfo.item2, makeInfo.item2num)) {
            return true;
        } else {
            new PropRole(this.roleId, true);
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
                        double jilv = (double)makeInfo.jilv / 100.0;
                        if (Math.random() > jilv) {
                            MessageMgr.psendMsgNotify(this.roleId, 196696, (List)null);
                            return true;
                        } else {
                            PetEquipItem equipItem = this.createEquipItemWithAllAttr(this.equipId);
                            if (equipItem == null) {
                                logger.error("装备打造出错，检查配置文件");
                                return false;
                            } else if (this.bag.doAddItem(equipItem, -1, "装备相关", YYLoggerTuJingEnum.tujing_Value_daozaoget, 0) != AddItemResult.SUCC) {
                                MessageMgr.psendMsgNotifyWhileRollback(this.roleId, 142338, (List)null);
                                return false;
                            } else {
                                logger.debug("Role: " + this.roleId + "背包栏增加装备： " + this.equipId + "通过" + "装备相关");
                                MessageMgr.psendMsgNotify(this.roleId, 196697, (List)null);
                                Procedure.pexecuteWhileCommit(new Procedure() {
                                    protected boolean process() {
                                        TeamManager.getTeamByRoleId(PMakePetEquip.this.roleId);
                                        Poster.getPoster().dispatchEvent(new EquipMakeEvent(PMakePetEquip.this.roleId));
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

    private PetEquipItem createEquipItemWithAllAttr(int equipid) {
        PetEquipItem equipItem = (PetEquipItem)Module.getInstance().getItemManager().genItemBase(equipid, 1, 0, (Bean)null, false);
        ItemMakeFactory.getFactory().genPetEquip(equipItem);
        return equipItem;
    }

    private ItemBase getItemKey(int itemId) {
        Iterator var2 = this.bag.iterator();

        ItemBase item;
        do {
            if (!var2.hasNext()) {
                return null;
            }

            item = (ItemBase)var2.next();
        } while(itemId != item.getItemId());

        return item;
    }

    private boolean checkMaterialIsEnough(int materialID, int num) {
        int currentNum = this.bag.getItemNum(materialID, 0);
        return currentNum >= num;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet.shenshou;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PropRole;
import fire.pb.RoleConfigManager;
import fire.pb.item.ItemMaps;
import fire.pb.item.ItemShuXing;
import fire.pb.pet.Module;
import fire.pb.pet.Pet;
import fire.pb.pet.PetAttr;
import fire.pb.pet.PetColumn;
import fire.pb.pet.PetManager;
import fire.pb.talk.MessageMgr;
import fire.pb.util.BagUtil;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import org.apache.log4j.Logger;

public class PShenShouChongZhi extends Procedure {
    public static final Logger logger = Logger.getLogger("SYSTEM");
    private final long roleId;
    private final int petKey;
    private final int needPetId;

    public PShenShouChongZhi(long roleId, int petKey, int needPetId) {
        this.roleId = roleId;
        this.petKey = petKey;
        this.needPetId = needPetId;
    }

    protected boolean process() throws Exception {
        PetColumn petCol = new PetColumn(this.roleId, 1, false);
        Pet pet = petCol.getPet(this.petKey);
        if (pet != null && pet.getKind() == 4) {
            PetManager petManager = Module.getInstance().getPetManager();
            if (null == petManager) {
                return false;
            } else {
                PetAttr petAttr = petManager.getAttr(this.needPetId);
                if (null != petAttr && petAttr.getKind() == 4 && petAttr.getId() != pet.getPetAttr().getId()) {
                    PropRole pRole = new PropRole(this.roleId, true);
                    if (pRole.getFightpetkey() == this.petKey) {
                        MessageMgr.sendMsgNotify(this.roleId, 162108, (List)null);
                        logger.error("神兽重置,出战宠物不能重置");
                        return false;
                    } else if (pet.isLocked() != -1L) {
                        MessageMgr.psendMsgNotify(this.roleId, Pet.PET_LOCK_ERROR_MSG, (List)null);
                        return true;
                    } else if (petAttr.takelevel > pRole.getLevel()) {
                        logger.error("神兽重置,兑换的目标神兽携带等级比人物高");
                        return false;
                    } else {
                        int itemId = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(289).getValue());
                        int needItemNum = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(287).getValue());
                        ItemMaps bagContainer = fire.pb.item.Module.getInstance().getItemMaps(this.roleId, 1, false);
                        if (bagContainer == null) {
                            logger.error("角色id " + this.roleId + "神兽重置\t背包错误");
                            return false;
                        } else {
                            ItemShuXing itemShuXing = fire.pb.item.Module.getInstance().getItemManager().getAttr(itemId);
                            if (itemShuXing == null) {
                                logger.error("角色id " + this.roleId + "兑换神兽\t道具错误");
                                return false;
                            } else {
                                int curNum = bagContainer.getItemNum(itemId, 0);
                                if (curNum < needItemNum) {
                                    MessageMgr.sendMsgNotify(this.roleId, 162110,Arrays.<String>asList(itemShuXing.getName()));
                                    return false;
                                } else {
                                    int usedNum = bagContainer.removeItemById(itemId, needItemNum, YYLoggerTuJingEnum.tujing_Value_shenshoucost, itemId, "重置神兽");
                                    if (usedNum != needItemNum) {
                                        return false;
                                    } else {
                                        if (pet.getPetInfo().getShenshouinccount() != 0) {
                                            int ycCostItemNum = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(288).getValue());
                                            int retItemNum = ycCostItemNum * pet.getPetInfo().getShenshouinccount();
                                            if (BagUtil.addItem(this.roleId, itemId, retItemNum, "重置神兽返还物品", YYLoggerTuJingEnum.tujing_Value_shenshou, itemId) != retItemNum) {
                                                logger.error("神兽重置,返还道具数量不正确");
                                                return false;
                                            }

                                            MessageMgr.sendMsgNotify(this.roleId, 162098,Arrays.<String>asList(pet.getPetAttr().getName(), itemShuXing.getName(), Integer.toString(retItemNum)));
                                        }

                                        logger.error("角色id " + this.roleId + "重置神兽\t扣除道具，物品id" + itemId + "数量" + needItemNum);
                                        if (petCol.removePet(pet.getPetkey(), 7) != 0) {
                                            return false;
                                        } else if (petCol.addpet(petAttr.getId(), petAttr.getInitlevel(), petAttr.getKind(), (List)null, 16, -1, false, (Map)null) < 0) {
                                            return false;
                                        } else {
                                            MessageMgr.sendMsgNotify(this.roleId, 162097,Arrays.<String>asList(petAttr.getName()));
                                            MessageMgr.sendMsgNotify(this.roleId, 162109,Arrays.<String>asList(petAttr.getName()));
                                            return true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    MessageMgr.sendMsgNotify(this.roleId, 162104, (List)null);
                    logger.error("神兽重置,needPetId对应的宠物不符合要求或不存在");
                    return false;
                }
            }
        } else {
            MessageMgr.sendMsgNotify(this.roleId, 162104, (List)null);
            logger.error("神兽重置,petkey对应的宠物不符合要求或不存在");
            return false;
        }
    }
}

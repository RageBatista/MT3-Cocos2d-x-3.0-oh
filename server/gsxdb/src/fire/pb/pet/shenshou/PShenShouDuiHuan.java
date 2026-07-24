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
import fire.pb.pet.PetAttr;
import fire.pb.pet.PetColumn;
import fire.pb.pet.PetManager;
import fire.pb.talk.MessageMgr;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import org.apache.log4j.Logger;
import xbean.Properties;

public class PShenShouDuiHuan extends Procedure {
    public static final Logger logger = Logger.getLogger("SYSTEM");
    private final long roleId;

    public PShenShouDuiHuan(long roleId) {
        this.roleId = roleId;
    }

    protected boolean process() throws Exception {
        PetManager petManager = Module.getInstance().getPetManager();
        if (null != petManager) {
            PetAttr petAttr = petManager.randGetOneShenShou();
            if (null == petAttr) {
                return false;
            } else {
                PetColumn petColumn = new PetColumn(this.roleId, 1, false);
                if (petColumn.getRemainSize() < 1) {
                    MessageMgr.sendMsgNotify(this.roleId, 162101, (List)null);
                    logger.error("神兽兑换,宠物栏已满");
                    return false;
                } else {
                    PropRole pRole = new PropRole(this.roleId, true);
                    if (petAttr.takelevel > pRole.getLevel()) {
                        return false;
                    } else {
                        int itemId = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(289).getValue());
                        int needItemNum = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(286).getValue());
                        ItemMaps bagContainer = fire.pb.item.Module.getInstance().getItemMaps(this.roleId, 1, false);
                        if (bagContainer == null) {
                            logger.info("角色id " + this.roleId + "兑换神兽\t背包错误");
                            return false;
                        } else {
                            int curNum = bagContainer.getItemNum(itemId, 0);
                            ItemShuXing attr = fire.pb.item.Module.getInstance().getItemManager().getAttr(itemId);
                            if (attr == null) {
                                logger.info("角色id " + this.roleId + "兑换神兽\t道具错误");
                                return false;
                            } else if (curNum < needItemNum) {
                                MessageMgr.sendMsgNotify(this.roleId, 162093,Arrays.<String>asList(attr.getName()));
                                return false;
                            } else {
                                int usedNum = bagContainer.removeItemById(itemId, needItemNum, YYLoggerTuJingEnum.tujing_Value_shenshoucost, itemId, "兑换神兽");
                                if (usedNum != needItemNum) {
                                    return false;
                                } else {
                                    logger.info("角色id " + this.roleId + "兑换神兽\t扣除道具，物品id" + itemId + "数量" + needItemNum);
                                    if (petColumn.addpet(petAttr.getId(), petAttr.getInitlevel(), petAttr.getKind(), (List)null, 16, -1, false, (Map)null) < 0) {
                                        return false;
                                    } else {
                                        MessageMgr.sendMsgNotify(this.roleId, 162097,Arrays.<String>asList(petAttr.getName()));
                                        MessageMgr.sendMsgNotify(this.roleId, 162109,Arrays.<String>asList(petAttr.getName()));
                                        Properties prop = xtable.Properties.select(this.roleId);
                                        if (prop != null) {
                                            MessageMgr.sendSystemMsg(162142,Arrays.<String>asList(prop.getRolename(), petAttr.getName()));
                                        }

                                        return true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            return false;
        }
    }
}

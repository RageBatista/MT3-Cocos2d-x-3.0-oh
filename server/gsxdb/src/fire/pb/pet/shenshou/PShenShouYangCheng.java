//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet.shenshou;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.RoleConfigManager;
import fire.pb.course.CourseManager;
import fire.pb.item.ItemMaps;
import fire.pb.pet.Module;
import fire.pb.pet.Pet;
import fire.pb.pet.PetColumn;
import fire.pb.pet.PetManager;
import fire.pb.pet.SRefreshPetInfo;
import fire.pb.pet.SShenShouInc;
import fire.pb.talk.MessageMgr;
import java.util.List;
import mkdb.Procedure;
import org.apache.log4j.Logger;
import xbean.PetInfo;

public class PShenShouYangCheng extends Procedure {
    public static final Logger logger = Logger.getLogger("SYSTEM");
    private final long roleId;
    private final int petKey;

    public PShenShouYangCheng(long roleId, int petKey) {
        this.roleId = roleId;
        this.petKey = petKey;
    }

    protected boolean process() throws Exception {
        PetColumn petCol = new PetColumn(this.roleId, 1, false);
        Pet pet = petCol.getPet(this.petKey);
        if (pet != null && pet.getKind() == 4) {
            if (pet.isLocked() != -1L) {
                MessageMgr.psendMsgNotify(this.roleId, Pet.PET_LOCK_ERROR_MSG, (List)null);
                return true;
            } else {
                PetManager petManager = Module.getInstance().getPetManager();
                if (null == petManager) {
                    return false;
                } else {
                    int itemId = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(289).getValue());
                    int needItemNum = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(288).getValue());
                    ItemMaps bagContainer = fire.pb.item.Module.getInstance().getItemMaps(this.roleId, 1, false);
                    if (bagContainer == null) {
                        logger.error("角色id " + this.roleId + "神兽养成\t背包错误");
                        return false;
                    } else {
                        int curNum = bagContainer.getItemNum(itemId, 0);
                        if (curNum < needItemNum) {
                            MessageMgr.sendMsgNotify(this.roleId, 162094, (List)null);
                            return false;
                        } else {
                            PetInfo petInfo = petCol.getPetInfo(this.petKey);
                            if (petInfo == null) {
                                return false;
                            } else {
                                int shenshouinccount = petInfo.getShenshouinccount();
                                if (pet.getPetAttr().iszhenshou == 0 && shenshouinccount >= 3) {
                                    MessageMgr.sendMsgNotify(this.roleId, 162096, (List)null);
                                    return false;
                                } else {
                                    int maxcount = Integer.valueOf(RoleConfigManager.getRoleCommonConfig(907).value);
                                    if (pet.getPetAttr().iszhenshou == 1 && shenshouinccount >= maxcount) {
                                        MessageMgr.sendMsgNotify(this.roleId, 201067, (List)null);
                                        return false;
                                    } else {
                                        SShenShouInc attConf = petManager.getShenShouIncConfig(petInfo.getId(), shenshouinccount);
                                        if (attConf == null) {
                                            MessageMgr.sendMsgNotify(this.roleId, 162107, (List)null);
                                            logger.error("角色id " + this.roleId + "错误:神兽养成次数为" + shenshouinccount);
                                            return false;
                                        } else if (petInfo.getLevel() < attConf.getInclv()) {
                                            return false;
                                        } else {
                                            int chengzhang = petInfo.getGrowrate() + attConf.getAttinc();
                                            int gongji = petInfo.getBornattackapt();
                                            int fangyu = petInfo.getBorndefendapt();
                                            int hp = petInfo.getBornphyforceapt();
                                            int mp = petInfo.getBornmagicapt();
                                            int sudu = petInfo.getBornspeedapt();
                                            petInfo.setGrowrate(chengzhang);
                                            petInfo.setBornattackapt(gongji + attConf.getAtkinc());
                                            petInfo.setBorndefendapt(fangyu + attConf.getDefinc());
                                            petInfo.setBornphyforceapt(hp + attConf.getHpinc());
                                            petInfo.setBornmagicapt(mp + attConf.getMpinc());
                                            petInfo.setBornspeedapt(sudu + attConf.getSpdinc());
                                            int maxchengzhang = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(825).getValue());
                                            if (chengzhang > maxchengzhang) {
                                                petInfo.setGrowrate(maxchengzhang);
                                                petInfo.setBornattackapt(gongji);
                                                petInfo.setBorndefendapt(fangyu);
                                                petInfo.setBornphyforceapt(hp);
                                                petInfo.setBornmagicapt(mp);
                                                petInfo.setBornspeedapt(sudu);
                                                MessageMgr.sendMsgNotify(this.roleId, 202227, (List)null);
                                            }

                                            petInfo.setShenshouinccount(shenshouinccount + 1);
                                            pet.updatePetScoreWhileChange();
                                            CourseManager.checkAchieveCourse(this.roleId, 31, pet.getPetInfo().getPetscore());
                                            int usedNum = bagContainer.removeItemById(itemId, needItemNum, YYLoggerTuJingEnum.tujing_Value_shenshou, itemId, "重置神兽");
                                            if (usedNum != needItemNum) {
                                                return false;
                                            } else {
                                                SRefreshPetInfo refresh = new SRefreshPetInfo(pet.getProtocolPet());
                                                psendWhileCommit(this.roleId, refresh);
                                                MessageMgr.sendMsgNotify(this.roleId, 162095, (List)null);
                                                logger.error("角色id " + this.roleId + "养成神兽\t扣除道具，物品id" + itemId + "数量" + needItemNum);
                                                return true;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            MessageMgr.sendMsgNotify(this.roleId, 162105, (List)null);
            logger.error("神兽养成,petkey对应的宠物不符合要求或不存在");
            return false;
        }
    }
}

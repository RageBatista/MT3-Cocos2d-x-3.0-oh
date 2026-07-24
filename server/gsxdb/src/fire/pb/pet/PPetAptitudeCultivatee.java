//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.log.YYLogger;
import fire.log.beans.OpPetTraBean;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.common.SCommon;
import fire.pb.course.CourseManager;
import fire.pb.item.ItemBase;
import fire.pb.item.Pack;
import fire.pb.item.pet.PetAptItemItem;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import fire.pb.talk.STransChatMessageNotify2Client;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;

public class PPetAptitudeCultivatee extends Procedure {
    private final long roleId;
    private final int petKey;
    private final int aptId;
    private final int itemKey;

    public PPetAptitudeCultivatee(long roleId, int petKey, int aptId, int itemKey) {
        this.roleId = roleId;
        this.petKey = petKey;
        this.aptId = aptId;
        this.itemKey = itemKey;
    }

    public boolean process() {
        if (Helper.isPetInBattle(this.roleId, this.petKey)) {
            return false;
        } else {
            PetColumn petCol = new PetColumn(this.roleId, 1, false);
            Pet pet = petCol.getPet(this.petKey);
            if (null == pet) {
                System.out.println("加宠物资质3");
                return false;
            } else if (pet.isLocked() != -1L) {
                MessageMgr.psendMsgNotify(this.roleId, Pet.PET_LOCK_ERROR_MSG, (List)null);
                System.out.println("加宠物资质4");
                return true;
            } else {
                int countLimit = this.getCountLimit() + 10;
                if (pet.getPetInfo().getAptaddcount() >= countLimit) {
                    return true;
                } else {
                    System.out.println("加宠物资质2");
                    Pack bag = new Pack(this.roleId, false);
                    ItemBase bi = bag.getItem(this.itemKey);
                    if (bi == null) {
                        System.out.println("加宠物资质cuowu2");
                        return false;
                    } else if (!(bi instanceof PetAptItemItem)) {
                        System.out.println("加宠物资质cuowu1");
                        return false;
                    } else {
                        int curValue = 0;
                        int maxValue = 0;
                        int addValue = 0;
                        int finalValue = 0;
                        switch (this.aptId) {
                            case 1440:
                                curValue = pet.getPetInfo().getBornattackapt();
                                maxValue = pet.getPetAttr().getAttackaptmax();
                                addValue = 100;
                                break;
                            case 1450:
                                curValue = pet.getPetInfo().getBorndefendapt();
                                maxValue = pet.getPetAttr().getDefendaptmax();
                                addValue = 100;
                                break;
                            case 1460:
                                curValue = pet.getPetInfo().getBornphyforceapt();
                                maxValue = pet.getPetAttr().getPhyforceaptmax();
                                addValue = 500;
                                break;
                            case 1470:
                                curValue = pet.getPetInfo().getBornmagicapt();
                                maxValue = pet.getPetAttr().getMagicaptmax();
                                addValue = 100;
                                break;
                            case 1480:
                                curValue = pet.getPetInfo().getBornspeedapt();
                                maxValue = pet.getPetAttr().getSpeedaptmax();
                                addValue = 100;
                                break;
                            default:
                                return false;
                        }

                        System.out.println("加宠物资质1");
                        switch (this.aptId) {
                            case 1440:
                                pet.getPetInfo().setBornattackapt(curValue + 100);
                                break;
                            case 1450:
                                pet.getPetInfo().setBorndefendapt(curValue + 100);
                                break;
                            case 1460:
                                pet.getPetInfo().setBornphyforceapt(curValue + 500);
                                break;
                            case 1470:
                                pet.getPetInfo().setBornmagicapt(curValue + 100);
                                break;
                            case 1480:
                                pet.getPetInfo().setBornspeedapt(curValue + 100);
                                break;
                            default:
                                return false;
                        }

                        pet.getPetInfo().setAptaddcount(pet.getPetInfo().getAptaddcount() + 1);
                        pet.updatePetScoreWhileChange();
                        CourseManager.checkAchieveCourse(this.roleId, 31, pet.getPetInfo().getPetscore());
                        System.out.println("加宠物资质11");
                        int itemNum = 1;
                        int num = bag.removeItemWithKey(this.itemKey, itemNum, YYLoggerTuJingEnum.tujing_Value_peiyang, bi.getItemId(), "Pet aptitude cultivate cost");
                        if (num != itemNum) {
                            return false;
                        } else {
                            SRefreshPetInfo refresh = new SRefreshPetInfo(pet.getProtocolPet());
                            psendWhileCommit(this.roleId, refresh);
                            psendWhileCommit(this.roleId, new SPetAptitudeCultivatee(this.petKey, this.aptId, curValue));
                            List<String> params = new ArrayList();
                            params.add(pet.getName());
                            params.add(pet.getAptitudeStringByAttrType(this.aptId, false));
                            params.add(Integer.valueOf(addValue).toString());
                            STransChatMessageNotify2Client msg = MessageMgr.getMsgNotify(150074, 0, params);
                            psendWhileCommit(this.roleId, msg);
                            if (Module.logger.isInfoEnabled()) {
                                Module.logger.info("[PPetAptitudeCultivatee] roleId:" + this.roleId + " itemKey:" + this.itemKey + " itemId:" + bi.getItemId() + " itemName:" + bi.getName() + " aptId:" + this.aptId + " curValue:" + curValue + " maxValue:" + maxValue + " addValue:" + addValue + " finalValue:" + curValue + " petInfo:" + Helper.toString(pet.getPetInfo()));
                            }

                            this.writeYYLogger(bi);
                            return true;
                        }
                    }
                }
            }
        }
    }

    private void writeYYLogger(ItemBase bi) {
        if (bi != null) {
            YYLogger.petTraLog(this.roleId, new OpPetTraBean(bi.getItemId(), 1, this.aptId));
        }
    }

    int getAddAptValue(int curValue, int maxValue) {
        return maxValue;
    }

    int getCountLimit() {
        Map<Integer, SCommon> confs = ConfigManager.getInstance().getConf(SCommon.class);
        if (confs != null) {
            SCommon conf = (SCommon)confs.get(120);
            if (conf != null) {
                return Integer.parseInt(conf.getValue());
            }
        }

        return 0;
    }
}

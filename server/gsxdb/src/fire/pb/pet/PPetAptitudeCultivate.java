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
import fire.pb.item.pet.PetAptItem;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import fire.pb.talk.STransChatMessageNotify2Client;
import fire.pb.util.Misc;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;

public class PPetAptitudeCultivate extends Procedure {
    private final long roleId;
    private final int petKey;
    private final int aptId;
    private final int itemKey;

    public PPetAptitudeCultivate(long roleId, int petKey, int aptId, int itemKey) {
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
                return false;
            } else if (pet.isLocked() != -1L) {
                MessageMgr.psendMsgNotify(this.roleId, Pet.PET_LOCK_ERROR_MSG, (List)null);
                return true;
            } else {
                int countLimit = this.getCountLimit();
                if (pet.getPetInfo().getAptaddcount() >= countLimit) {
                    return true;
                } else {
                    Pack bag = new Pack(this.roleId, false);
                    ItemBase bi = bag.getItem(this.itemKey);
                    if (bi == null) {
                        return false;
                    } else if (!(bi instanceof PetAptItem)) {
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
                                break;
                            case 1450:
                                curValue = pet.getPetInfo().getBorndefendapt();
                                maxValue = pet.getPetAttr().getDefendaptmax();
                                break;
                            case 1460:
                                curValue = pet.getPetInfo().getBornphyforceapt();
                                maxValue = pet.getPetAttr().getPhyforceaptmax();
                                break;
                            case 1470:
                                curValue = pet.getPetInfo().getBornmagicapt();
                                maxValue = pet.getPetAttr().getMagicaptmax();
                                break;
                            case 1480:
                                curValue = pet.getPetInfo().getBornspeedapt();
                                maxValue = pet.getPetAttr().getSpeedaptmax();
                                break;
                            default:
                                return false;
                        }

                        addValue = this.getAddAptValue(curValue, maxValue);
                        finalValue = curValue + addValue;
                        if (finalValue > maxValue) {
                            finalValue = maxValue;
                        }

                        if (curValue >= finalValue) {
                            return true;
                        } else {
                            switch (this.aptId) {
                                case 1440:
                                    pet.getPetInfo().setBornattackapt(finalValue);
                                    break;
                                case 1450:
                                    pet.getPetInfo().setBorndefendapt(finalValue);
                                    break;
                                case 1460:
                                    pet.getPetInfo().setBornphyforceapt(finalValue);
                                    break;
                                case 1470:
                                    pet.getPetInfo().setBornmagicapt(finalValue);
                                    break;
                                case 1480:
                                    pet.getPetInfo().setBornspeedapt(finalValue);
                                    break;
                                default:
                                    return false;
                            }

                            pet.getPetInfo().setAptaddcount(pet.getPetInfo().getAptaddcount() + 1);
                            pet.updatePetScoreWhileChange();
                            CourseManager.checkAchieveCourse(this.roleId, 31, pet.getPetInfo().getPetscore());
                            int itemNum = 1;
                            int num = bag.removeItemWithKey(this.itemKey, itemNum, YYLoggerTuJingEnum.tujing_Value_peiyang, bi.getItemId(), "Pet aptitude cultivate cost");
                            if (num != itemNum) {
                                return false;
                            } else {
                                SRefreshPetInfo refresh = new SRefreshPetInfo(pet.getProtocolPet());
                                psendWhileCommit(this.roleId, refresh);
                                psendWhileCommit(this.roleId, new SPetAptitudeCultivate(this.petKey, this.aptId, finalValue));
                                List<String> params = new ArrayList();
                                params.add(pet.getName());
                                params.add(pet.getAptitudeStringByAttrType(this.aptId, false));
                                params.add(Integer.valueOf(addValue).toString());
                                STransChatMessageNotify2Client msg = MessageMgr.getMsgNotify(150074, 0, params);
                                psendWhileCommit(this.roleId, msg);
                                if (Module.logger.isInfoEnabled()) {
                                    Module.logger.info("[PPetAptitudeCultivate] roleId:" + this.roleId + " itemKey:" + this.itemKey + " itemId:" + bi.getItemId() + " itemName:" + bi.getName() + " aptId:" + this.aptId + " curValue:" + curValue + " maxValue:" + maxValue + " addValue:" + addValue + " finalValue:" + finalValue + " petInfo:" + Helper.toString(pet.getPetInfo()));
                                }

                                this.writeYYLogger(bi);
                                return true;
                            }
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
        int v1 = (int)((double)(maxValue - curValue) * 0.04 + (double)0.5F);
        int v2 = (int)((double)(maxValue - curValue) * 0.06 + (double)0.5F);
        int r = Misc.getRandomBetween(v1, v2);
        return r > 0 ? r : 1;
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

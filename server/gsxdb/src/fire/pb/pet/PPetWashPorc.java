//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.log.YYLogger;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.common.SCommon;
import fire.pb.course.CourseManager;
import fire.pb.event.PetColumnChange;
import fire.pb.event.Poster;
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
import fire.pb.role.RoleDayCounter;
import fire.pb.talk.MessageMgr;
import fire.pb.util.Misc;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.PetInfo;
import xtable.Properties;

public class PPetWashPorc extends Procedure {
    private final long roleId;
    private final int petKey;

    public PPetWashPorc(long roleId, int petKey) {
        this.roleId = roleId;
        this.petKey = petKey;
    }

    public boolean process() {
        Integer fightPetKey = Properties.selectFightpetkey(this.roleId);
        PetColumn petCol;
        Pet pet;
        if (fightPetKey != this.petKey && null != (pet = (petCol = new PetColumn(this.roleId, 1, false)).getPet(this.petKey))) {
            if (pet.isLocked() != -1L) {
                MessageMgr.psendMsgNotify(this.roleId, Pet.PET_LOCK_ERROR_MSG, (List)null);
                return true;
            } else {
                PetAttr attr = pet.getPetInfo().getPetid() > 0 ? (PetAttr)ConfigManager.getInstance().getConf(PetAttr.class).get(pet.getPetInfo().getPetid()) : pet.getPetAttr();
                if (attr.daywashcount > 0 && RoleDayCounter.getInstance().getDayCounter(this.roleId, (int)pet.getUniqueId()) >= attr.daywashcount) {
                    List<String> params = new ArrayList();
                    params.add(String.valueOf(attr.daywashcount));
                    MessageMgr.psendMsgNotify(this.roleId, 193456, params);
                    return false;
                } else {
                    int newPetId = this.randomWashPetId(attr);
                    PetAttr newPetAttr;
                    if (newPetId > 0 && (newPetAttr = PetManager.getInstance().getAttr(newPetId)) != null) {
                        int itemId = pet.getPetAttr().getWashitemid();
                        int itemNum = pet.getPetAttr().getWashitemnum();
                        if (itemId > 0 && itemNum > 0) {
                            Pack bag = new Pack(this.roleId, false);
                            if (bag.getBagItemNum(itemId) < itemNum) {
                                return false;
                            }

                            int num = bag.removeItemById(itemId, itemNum, YYLoggerTuJingEnum.tujing_Value_xilian, 0, "Pet wash cost");
                            if (num != itemNum) {
                                return false;
                            }
                        }

                        Map<Integer, Object> initAttrs = new HashMap();
                        if (pet.getPetInfo().getName() != pet.getPetAttr().getName()) {
                            initAttrs.put(CalcPetAttr.PET_NAME, pet.getPetInfo().getName());
                        } else {
                            initAttrs.put(CalcPetAttr.PET_NAME, newPetAttr.getName());
                        }

                        int oldKind = pet.getPetAttr().getKind();
                        int newKind = newPetAttr.getKind();
                        PetInfo newPetInfo = PetColumn.createPet(this.roleId, newPetId, 0, (List)null, newKind, 1, pet.isBind(), initAttrs, pet.getUniqueId());
                        newPetInfo.setKey(pet.getPetInfo().getKey());
                        petCol.getPetsMap().put(newPetInfo.getKey(), newPetInfo);
                        Pet newPet = petCol.getPet(newPetInfo.getKey());
                        if (newPet == null) {
                            return false;
                        } else {
                            CalcPetAttr cattr = new CalcPetAttr(newPetInfo);
                            cattr.setBornAttackApt(this.randomAptitude(cattr.getPetAttr().getAttackaptmin(), cattr.getPetAttr().getAttackaptmax()));
                            cattr.setBornDefendApt(this.randomAptitude(cattr.getPetAttr().getDefendaptmin(), cattr.getPetAttr().getDefendaptmax()));
                            cattr.setBornMagicApt(this.randomAptitude(cattr.getPetAttr().getMagicaptmin(), cattr.getPetAttr().getMagicaptmax()));
                            cattr.setBornPhyforceApt(this.randomAptitude(cattr.getPetAttr().getPhyforceaptmin(), cattr.getPetAttr().getPhyforceaptmax()));
                            cattr.setBornDodgeApt(this.randomAptitude(0, 0));
                            cattr.setBornSpeedApt(this.randomAptitude(cattr.getPetAttr().getSpeedaptmin(), cattr.getPetAttr().getSpeedaptmax()));
                            newPetInfo.setAutoaddcons(0);
                            newPetInfo.setAutoaddiq(0);
                            newPetInfo.setAutoaddstr(0);
                            newPetInfo.setAutoaddendu(0);
                            newPetInfo.setAutoaddagi(0);
                            if (pet.getPetInfo().getPetdye1() > 0) {
                                newPet.getPetInfo().setPetdye1(pet.getPetInfo().getPetdye1());
                                newPet.getPetInfo().setPetdye2(pet.getPetInfo().getPetdye2());
                            }

                            if (oldKind == 2 || oldKind == 3) {
                                if (oldKind == newKind) {
                                    newPetInfo.setWashcount(pet.getPetInfo().getWashcount() + 1);
                                }

                                int maxWashCount = newPet.getPetAttr().getWashcount();
                                if (maxWashCount > 0 && newPetInfo.getWashcount() >= maxWashCount) {
                                    newPetInfo.getSkills().clear();

                                    for(SkillRate sr : newPet.getPetAttr().getSkills()) {
                                        if (sr.skillid > 0) {
                                            newPet.addSkill(sr.skillid, -1L, 0, 0);
                                        }
                                    }

                                    newPetInfo.setWashcount(0);
                                }
                            }

                            newPet.updatePetScoreWhileChange();
                            if (newPet.getPetInfo().getTreasure() == 1) {
                                CourseManager.achieveUpdate(this.roleId, 30);
                            }

                            CourseManager.checkAchieveCourse(this.roleId, 31, newPet.getPetInfo().getPetscore());
                            SRefreshPetInfo send = new SRefreshPetInfo(newPet.getProtocolPet());
                            Procedure.psendWhileCommit(this.roleId, send);
                            Procedure.psendWhileCommit(this.roleId, new SPetWash(newPet.getPetkey()));
                            if (oldKind != newKind && newKind == 3) {
                                String roleName = Properties.selectRolename(this.roleId);
                                MessageMgr.sendSystemMsg(160484, MessageMgr.getStringList(new Object[]{roleName, newPetAttr.getName()}));
                                CourseManager.achieveUpdate(this.roleId, 35);
                            }

                            Poster.getPoster().dispatchEvent(new PetColumnChange(this.roleId, newPetInfo.getId()));
                            this.onLog(this.roleId, newPetInfo, newPetAttr, pet, itemId);
                            if (attr.daywashcount > 0) {
                                RoleDayCounter.getInstance().setDayCounter(this.roleId, Integer.valueOf((int)newPet.getUniqueId()));
                            }

                            return true;
                        }
                    } else {
                        return false;
                    }
                }
            }
        } else {
            return false;
        }
    }

    public int randomWashPetId(PetAttr petAttr) {
        String[] petList = petAttr.getWashnewpetid().split(";");
        if (petList.length <= 0) {
            return 0;
        } else {
            List<Integer> idList = new ArrayList();
            List<Integer> rateList = new ArrayList();
            int sumValue = 0;

            for(String str : petList) {
                String[] pet = str.split("@");
                if (pet.length != 2) {
                    return 0;
                }

                int id = Integer.parseInt(pet[0]);
                int rate = Integer.parseInt(pet[1]);
                idList.add(id);
                rateList.add(rate);
                sumValue += rate;
            }

            int r = Misc.getRandomBetween(1, sumValue);
            int v = 0;

            for(int i = 0; i < idList.size() && i < rateList.size(); ++i) {
                v += (Integer)rateList.get(i);
                if (v >= r) {
                    return (Integer)idList.get(i);
                }
            }

            return 0;
        }
    }

    static Double getCommonConf(int id) {
        Map<Integer, SCommon> confs = ConfigManager.getInstance().getConf(SCommon.class);
        SCommon conf;
        return confs != null && (conf = (SCommon)confs.get(id)) != null ? Double.parseDouble(conf.getValue()) : null;
    }

    public int randomAptitude(int minValue, int maxValue) {
        if (minValue > maxValue) {
            return 0;
        } else {
            Double p1 = getCommonConf(268);
            if (p1 == null) {
                p1 = 0.4;
            }

            int value = (int)((double)minValue + (double)(maxValue - minValue) * p1);
            return Misc.getRandomBetween(value, maxValue);
        }
    }

    public void onLog(long roleId, PetInfo petInfo, PetAttr petAttr, Pet pet, int itemId) {
        if (Module.logger.isInfoEnabled()) {
            Module.logger.info("[PPetWashPorc] roleId:" + roleId + " petInfo:" + Helper.toString(petInfo));
        }

        this.writeYYLogger(roleId, petInfo, petAttr, pet, itemId);
    }

    private void writeYYLogger(long roleId, PetInfo petInfo, PetAttr petAttr, Pet pet, int itemId) {
        if (petInfo != null && petAttr != null && pet != null) {
            int isTrea = petAttr.getTreasureScore() > petInfo.getPetscore() ? 0 : 1;
            YYLogger.petRefLog(roleId, petAttr.getId(), isTrea, pet.getUniqueId(), itemId);
        }
    }
}

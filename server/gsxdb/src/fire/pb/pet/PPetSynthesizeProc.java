//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.log.YYLogger;
import fire.log.beans.OpPetMixBean;
import fire.pb.RoleConfigManager;
import fire.pb.common.SCommon;
import fire.pb.course.CourseManager;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import fire.pb.tel.utils.GoodsSafeLocksUtils;
import fire.pb.util.Misc;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.PetEquipItem;
import xbean.PetInfo;
import xbean.PetSkill;
import xtable.Properties;

public class PPetSynthesizeProc extends Procedure {
    private final long roleId;
    private final int petKey1;
    private final int petKey2;

    public PPetSynthesizeProc(long roleId, int petKey1, int petKey2) {
        this.roleId = roleId;
        this.petKey1 = petKey1;
        this.petKey2 = petKey2;
    }

    public boolean process() {
        Integer curLevel = Properties.selectLevel(this.roleId);
        if (curLevel == null) {
            return false;
        } else if (curLevel < 55) {
            return false;
        } else {
            Integer fightPetKey = Properties.selectFightpetkey(this.roleId);
            if (fightPetKey != this.petKey1 && fightPetKey != this.petKey2) {
                PetColumn petCol = new PetColumn(this.roleId, 1, false);
                Pet pet1 = petCol.getPet(this.petKey1);
                Pet pet2 = petCol.getPet(this.petKey2);
                if (pet1 != null && pet2 != null) {
                    if (GoodsSafeLocksUtils.checkLockStatus(this.roleId, pet1.getPetInfo())) {
                        return false;
                    } else if (GoodsSafeLocksUtils.checkLockStatus(this.roleId, pet2.getPetInfo())) {
                        return false;
                    } else if (!pet1.isBind() && !pet2.isBind()) {
                        if (pet1.isLocked() == -1L && pet2.isLocked() == -1L) {
                            if (pet1.getKind() != 1 && pet2.getKind() != 1) {
                                if (pet1.getPetAttr().iszhenshou == 1 && pet2.getPetAttr().iszhenshou == 1) {
                                    Integer iszhenshou = Integer.valueOf(RoleConfigManager.getRoleCommonConfig(905).value);
                                    if (iszhenshou == 0) {
                                        MessageMgr.sendMsgNotify(this.roleId, 201065, (List)null);
                                        return false;
                                    }
                                } else if (pet1.getPetAttr().iszhenshou == 1 && pet2.getKind() != 3 || pet2.getPetAttr().iszhenshou == 1 && pet1.getKind() != 3) {
                                    MessageMgr.sendMsgNotify(this.roleId, 193455, (List)null);
                                    return false;
                                }

                                if (!this.isHaveSkillCertification(pet1) && !this.isHaveSkillCertification(pet2)) {
                                    if ((pet1.getKind() != 4 || pet1.getPetAttr().iszhenshou != 0) && (pet1.getKind() != 4 || pet1.getPetAttr().iszhenshou != 0)) {
                                        PetInfo petInfo = pet1.getPetInfo();

                                        for(PetEquipItem localPetEquipItem2 : petInfo.getPetequipbag()) {
                                            if (localPetEquipItem2.getPos() == 1 || localPetEquipItem2.getPos() == 2 || localPetEquipItem2.getPos() == 3) {
                                                MessageMgr.psendMsgNotify(this.roleId, 192301, (List)null);
                                                return false;
                                            }
                                        }

                                        PetInfo petInfo1 = pet2.getPetInfo();

                                        for(PetEquipItem localPetEquipItem2 : petInfo1.getPetequipbag()) {
                                            if (localPetEquipItem2.getPos() == 1 || localPetEquipItem2.getPos() == 2 || localPetEquipItem2.getPos() == 3) {
                                                MessageMgr.psendMsgNotify(this.roleId, 192301, (List)null);
                                                return false;
                                            }
                                        }

                                        PetInfo newPetInfo = this.newPetInfoBySynthesize(pet1, pet2);
                                        if (newPetInfo != null) {
                                            if (petCol.removePet(pet1.getPetkey(), 5) != 0) {
                                                return false;
                                            }

                                            if (petCol.removePet(pet2.getPetkey(), 5) != 0) {
                                                return false;
                                            }

                                            if (petCol.add(newPetInfo, 8) <= 0) {
                                                return false;
                                            }

                                            Procedure.psendWhileCommit(this.roleId, new SPetSynthesize(newPetInfo.getKey()));
                                            Pet newpet = Pet.getPet(newPetInfo);
                                            newpet.updatePetScoreWhileChange();
                                            CourseManager.achieveUpdate(this.roleId, 41);
                                            CourseManager.checkAchieveCourse(this.roleId, 44, newpet.getBattleskillIds().size());
                                            CourseManager.checkAchieveCourse(this.roleId, 31, newpet.getPetInfo().getPetscore());
                                            if (Module.logger.isInfoEnabled()) {
                                                Module.logger.info("[PPetSynthesizeProc] roleId:" + this.roleId + " petInfo1:" + Helper.toString(pet1.getPetInfo()) + " petInfo2:" + Helper.toString(pet2.getPetInfo()) + " newPetInfo:" + Helper.toString(newPetInfo));
                                            }

                                            this.writeYYLogger(pet1, pet2, newPetInfo, newpet);
                                            GoodsSafeLocksUtils.doClearDataWhileCommit(this.roleId);
                                        }

                                        return true;
                                    } else {
                                        MessageMgr.sendMsgNotify(this.roleId, 201066, (List)null);
                                        return false;
                                    }
                                } else {
                                    return false;
                                }
                            } else {
                                return false;
                            }
                        } else {
                            return true;
                        }
                    } else {
                        return true;
                    }
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }
    }

    private void writeYYLogger(Pet pet1, Pet pet2, PetInfo newPetInfo, Pet newpet) {
        if (pet1 != null && pet2 != null && newPetInfo != null && newpet != null) {
            OpPetMixBean opPetMixBean = new OpPetMixBean(pet1.getPetAttr().getId(), pet1.getPetAttr().getTreasureScore() > pet1.getPetInfo().getPetscore() ? 0 : 1, pet2.getPetAttr().getId(), pet2.getPetAttr().getTreasureScore() > pet2.getPetInfo().getPetscore() ? 0 : 1, newPetInfo.getId(), newpet.getPetAttr().getTreasureScore() > newPetInfo.getPetscore() ? 0 : 1);
            YYLogger.petMixLog(this.roleId, opPetMixBean);
        }
    }

    public boolean isHaveSkillCertification(Pet pet) {
        for(PetSkill s : pet.getBattleskills()) {
            if (s.getCertification() == 1) {
                return true;
            }
        }

        return false;
    }

    public List<Integer> getSkillList(int newID, Pet pet1, Pet pet2) {
        List<Integer> skillIds = new ArrayList();
        if (newID == pet1.getBaseId()) {
            PetAttr attr = Module.getInstance().getPetManager().getAttr(pet1.getBaseId());

            for(SkillRate sr : attr.getSkills()) {
                if (sr.rate >= 1001) {
                    skillIds.add(sr.getSkillid());
                }
            }
        } else {
            PetAttr attr = Module.getInstance().getPetManager().getAttr(pet2.getBaseId());

            for(SkillRate sr : attr.getSkills()) {
                if (sr.rate >= 1001) {
                    skillIds.add(sr.getSkillid());
                }
            }
        }

        List<Integer> randomSkillIds = pet1.getBattleskillIds();

        for(Integer id : pet2.getBattleskillIds()) {
            if (!randomSkillIds.contains(id)) {
                randomSkillIds.add(id);
            }
        }

        for(Integer id : skillIds) {
            while(randomSkillIds.contains(id)) {
                randomSkillIds.remove(id);
            }
        }

        Object confs = ConfigManager.getInstance().getConf(PetSynthesizeSkillRateConfig.class);
        if (confs != null) {
            int sumValue = 0;

            for(int i = 0; i <= randomSkillIds.size(); ++i) {
                PetSynthesizeSkillRateConfig conf = (PetSynthesizeSkillRateConfig)((Map)confs).get(i);
                if (conf != null) {
                    sumValue += conf.getValue();
                }
            }

            int r = Misc.getRandomBetween(1, sumValue);
            int curValue = 0;
            Integer maxskill = Integer.valueOf(RoleConfigManager.getRoleCommonConfig(906).value);

            for(int num = 0; num <= randomSkillIds.size(); ++num) {
                PetSynthesizeSkillRateConfig conf = (PetSynthesizeSkillRateConfig)((Map)confs).get(num);
                if (conf != null) {
                    curValue += conf.getValue();
                    if (curValue >= r) {
                        for(int n = 0; n < num; ++n) {
                            int index = Misc.getRandomBetween(0, randomSkillIds.size() - 1);
                            int id = (Integer)randomSkillIds.get(index);
                            if (skillIds.size() < maxskill) {
                                skillIds.add(id);
                            }

                            randomSkillIds.remove(index);
                        }
                        break;
                    }
                }
            }
        }

        return skillIds;
    }

    static Double getCommonConf(int id) {
        Map<Integer, SCommon> confs = ConfigManager.getInstance().getConf(SCommon.class);
        if (confs != null) {
            SCommon conf = (SCommon)confs.get(id);
            if (conf != null) {
                return Double.parseDouble(conf.getValue());
            }
        }

        return null;
    }

    public double getAptFactorMinConf() {
        Double p = getCommonConf(102);
        if (p == null) {
            p = 0.9;
        }

        return p;
    }

    public double getAptFactorMaxConf() {
        Double p = getCommonConf(103);
        if (p == null) {
            p = 1.08;
        }

        return p;
    }

    public int randomAptitude(int v1, int v2) {
        double p1 = this.getAptFactorMinConf();
        double p2 = this.getAptFactorMaxConf();
        int min = (int)((double)(v1 + v2) / (double)2.0F * p1);
        int max = (int)((double)(v1 + v2) / (double)2.0F * p2);
        return Misc.getRandomBetween(min, max);
    }

    public int getAptitudeMax(Pet pet1, Pet pet2, int maxValue1, int maxValue2) {
        if (pet1.getKind() == 3 || pet2.getKind() == 3) {
            double aptFactorMax = this.getAptFactorMaxConf();
            if (pet1.getKind() == 2) {
                maxValue1 = (int)((double)maxValue1 * aptFactorMax);
            } else if (pet2.getKind() == 2) {
                maxValue2 = (int)((double)maxValue2 * aptFactorMax);
            }
        }

        return Math.max(maxValue1, maxValue2);
    }

    public int fixAptitudeValue(Pet pet1, Pet pet2, int value, int aptId) {
        if (pet1.getKind() == 3 || pet2.getKind() == 3) {
            int maxValue = -1;
            switch (aptId) {
                case 1440:
                    maxValue = this.getAptitudeMax(pet1, pet2, pet1.getPetAttr().getAttackaptmax(), pet2.getPetAttr().getAttackaptmax());
                    break;
                case 1450:
                    maxValue = this.getAptitudeMax(pet1, pet2, pet1.getPetAttr().getDefendaptmax(), pet2.getPetAttr().getDefendaptmax());
                    break;
                case 1460:
                    maxValue = this.getAptitudeMax(pet1, pet2, pet1.getPetAttr().getPhyforceaptmax(), pet2.getPetAttr().getPhyforceaptmax());
                    break;
                case 1470:
                    maxValue = this.getAptitudeMax(pet1, pet2, pet1.getPetAttr().getMagicaptmax(), pet2.getPetAttr().getMagicaptmax());
                    break;
                case 1480:
                    maxValue = this.getAptitudeMax(pet1, pet2, pet1.getPetAttr().getSpeedaptmax(), pet2.getPetAttr().getSpeedaptmax());
                    break;
                case 1490:
                    maxValue = this.getAptitudeMax(pet1, pet2, 0, 0);
                    break;
                default:
                    Module.logger.error("[PPetSynthesizeProc.fixAptitudeValue] roleId:" + this.roleId + " apt:" + aptId);
                    return 0;
            }

            value = Math.min(value, maxValue);
        }

        return value;
    }

    public int randomGrowrate(int v1, int v2) {
        Double p1 = getCommonConf(104);
        Double p2 = getCommonConf(105);
        if (p1 == null) {
            p1 = (double)48.0F;
        }

        if (p2 == null) {
            p2 = (double)24.0F;
        }

        int min = (int)((double)(v1 + v2) / (double)2.0F - p1);
        int max = (int)((double)(v1 + v2) / (double)2.0F + p2);
        return Misc.getRandomBetween(min, max);
    }

    public PetInfo newPetInfoBySynthesize(Pet pet1, Pet pet2) {
        int newID = Misc.getRatePercent() <= 50 ? pet1.getBaseId() : pet2.getBaseId();
        if (pet1.getPetAttr().iszhenshou == 1) {
            newID = pet1.getBaseId();
        }

        if (pet2.getPetAttr().iszhenshou == 1) {
            newID = pet2.getBaseId();
        }

        if (pet1.getPetAttr().iszhenshou == 1 && pet2.getPetAttr().iszhenshou == 1) {
            String huanlan = RoleConfigManager.getRoleCommonConfig(909).value;
            Integer jilv = Integer.valueOf(RoleConfigManager.getRoleCommonConfig(910).value);
            List<Integer> ids = new ArrayList();
            String[] idss = huanlan.split(",");

            for(String id : idss) {
                ids.add(Integer.valueOf(id));
            }

            if (ids.contains(pet1.getPetAttr().id) && !ids.contains(pet2.getPetAttr().id)) {
                newID = Misc.getRatePercent() <= jilv ? pet1.getBaseId() : pet2.getBaseId();
            } else if (ids.contains(pet2.getPetAttr().id) && !ids.contains(pet1.getPetAttr().id)) {
                newID = Misc.getRatePercent() <= jilv ? pet2.getBaseId() : pet1.getBaseId();
            } else {
                newID = Misc.getRatePercent() <= 50 ? pet1.getBaseId() : pet2.getBaseId();
            }
        }

        int kind = newID == pet1.getBaseId() ? pet1.getKind() : pet2.getKind();
        int newLevel = Misc.getRandomBetween(pet1.getLevel(), pet2.getLevel());
        List<Integer> skillIds = this.getSkillList(newID, pet1, pet2);
        PetInfo newPetInfo = PetColumn.createPet(this.roleId, newID, newLevel, skillIds, kind, 1, false);
        int attackApt = this.randomAptitude(pet1.getAttackapt(), pet2.getAttackapt());
        attackApt = this.fixAptitudeValue(pet1, pet2, attackApt, 1440);
        int defendApt = this.randomAptitude(pet1.getDefendapt(), pet2.getDefendapt());
        defendApt = this.fixAptitudeValue(pet1, pet2, defendApt, 1450);
        int magicApt = this.randomAptitude(pet1.getMagicapt(), pet2.getMagicapt());
        magicApt = this.fixAptitudeValue(pet1, pet2, magicApt, 1470);
        int phyforceApt = this.randomAptitude(pet1.getPhyforceapt(), pet2.getPhyforceapt());
        phyforceApt = this.fixAptitudeValue(pet1, pet2, phyforceApt, 1460);
        int dodgeApt = this.randomAptitude(pet1.getDodgeapt(), pet2.getDodgeapt());
        dodgeApt = this.fixAptitudeValue(pet1, pet2, dodgeApt, 1490);
        int speedApt = this.randomAptitude(pet1.getSpeedapt(), pet2.getSpeedapt());
        speedApt = this.fixAptitudeValue(pet1, pet2, speedApt, 1480);
        CalcPetAttr cattr = new CalcPetAttr(newPetInfo);
        cattr.setBornAttackApt(attackApt);
        cattr.setBornDefendApt(defendApt);
        cattr.setBornMagicApt(magicApt);
        cattr.setBornPhyforceApt(phyforceApt);
        cattr.setBornDodgeApt(dodgeApt);
        cattr.setBornSpeedApt(speedApt);
        int growrate = this.randomGrowrate(pet1.getGrowrate(), pet2.getGrowrate());
        newPetInfo.setGrowrate(growrate);
        newPetInfo.setAutoaddcons(0);
        newPetInfo.setAutoaddiq(0);
        newPetInfo.setAutoaddstr(0);
        newPetInfo.setAutoaddendu(0);
        newPetInfo.setAutoaddagi(0);
        return newPetInfo;
    }
}

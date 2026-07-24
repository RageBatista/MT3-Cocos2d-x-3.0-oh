//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.log.YYLogger;
import fire.log.beans.OpPetSkiBean;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.RoleConfigManager;
import fire.pb.buff.BuffPetImpl;
import fire.pb.common.SCommon;
import fire.pb.course.CourseManager;
import fire.pb.item.ItemBase;
import fire.pb.item.Pack;
import fire.pb.item.PetItemShuXing;
import fire.pb.item.SPetEquiptaozhuang;
import fire.pb.item.pet.PetSkillItem;
import fire.pb.main.ConfigManager;
import fire.pb.skill.BuffUnit;
import fire.pb.skill.Result;
import fire.pb.skill.SSkillConfig;
import fire.pb.skill.SkillPet;
import fire.pb.skill.SubSkillConfig;
import fire.pb.skill.fight.FightSkillConfig;
import fire.pb.talk.MessageMgr;
import fire.pb.util.Misc;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import mkdb.Procedure;
import xbean.BattleInfo;
import xbean.PetInfo;
import xbean.PetSkill;

public class PPetLearnSkillByBook extends Procedure {
    private long roleId;
    private int petKey;
    private int bookKey;
    public static final int RESULT_INVALID = -3;
    public static final int RESULT_NULL = -2;
    public static final int RESULT_ADD = -1;
    public static final int RESULT_REPLACE = 0;

    public PPetLearnSkillByBook(long roleId, int petKey, int bookKey) {
        this.roleId = roleId;
        this.petKey = petKey;
        this.bookKey = bookKey;
    }

    public boolean process() {
        if (Helper.isPetInBattle(this.roleId, this.petKey)) {
            return false;
        } else {
            PetColumn petCol = new PetColumn(this.roleId, 1, false);
            Pet pet = petCol.getPet(this.petKey);
            if (pet == null) {
                Module.logger.error("[PPetLearnSkillByBook] petKey=" + this.petKey + " non-existent.");
                return true;
            } else {
                PetInfo petInfo = pet.getPetInfo();
                if (pet.isLocked() != -1L) {
                    MessageMgr.psendMsgNotify(this.roleId, Pet.PET_LOCK_ERROR_MSG, (List)null);
                    return true;
                } else {
                    Pack bag = (Pack)fire.pb.item.Module.getInstance().getItemMaps(this.roleId, 1, false);
                    ItemBase item = bag.getItem(this.bookKey);
                    if (item == null) {
                        return false;
                    } else if (!(item instanceof PetSkillItem)) {
                        Module.logger.error("[PPetLearnSkillByBook] use item type != PetSkillItem.");
                        return true;
                    } else {
                        int itemid = item.getItemId();
                        int shenshou = Integer.parseInt(((SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(911)).getValue());
                        if (itemid == shenshou) {
                            if (4 != pet.getKind()) {
                                MessageMgr.psendMsgNotify(this.roleId, 202223, (List)null);
                                return false;
                            } else {
                                int maxskill = Integer.parseInt(((SCommon)ConfigManager.getInstance().getConf(SCommon.class).get(913)).getValue());
                                List<PetSkill> skills = pet.getBattleskills();
                                if (skills.size() >= maxskill) {
                                    MessageMgr.psendMsgNotify(this.roleId, 202225, (List)null);
                                    return false;
                                } else {
                                    int currentSkillCount = pet.getBattleskillIds().size();
                                    int learnProbability;
                                    if (currentSkillCount < 8) {
                                        learnProbability = 100;
                                    } else if (currentSkillCount < 9) {
                                        learnProbability = 70;
                                    } else if (currentSkillCount < 10) {
                                        learnProbability = 50;
                                    } else if (currentSkillCount < 11) {
                                        learnProbability = 25;
                                    } else if (currentSkillCount < 12) {
                                        learnProbability = 10;
                                    } else {
                                        learnProbability = 5;
                                    }

                                    Random random = new Random();
                                    int randomNum = random.nextInt(100);
                                    if (bag.removeItemWithKey(this.bookKey, 1, YYLoggerTuJingEnum.tujing_Value_peiyang, item.getItemId(), "PetLearnSkill") != 1) {
                                        return false;
                                    } else if (randomNum >= learnProbability) {
                                        MessageMgr.psendMsgNotify(this.roleId, 202226, (List)null);
                                        return true;
                                    } else {
                                        PetSkillItem skillItem = (PetSkillItem)item;
                                        SCommon common = RoleConfigManager.getRoleCommonConfig(912);
                                        String[] commonValues = common.getValue().split(";");
                                        int maxAttempts = commonValues.length;
                                        int attempts = 0;

                                        do {
                                            int randomIndex = random.nextInt(commonValues.length);
                                            String randomValue = commonValues[randomIndex];
                                            int skillId = Integer.parseInt(randomValue);
                                            if (!pet.hasAnySkill(skillId)) {
                                                pet.addSkill(skillId, -1L, 1, 1);
                                                BuffPetImpl buffPetImpl = new BuffPetImpl(this.roleId, this.petKey);
                                                int isConfirm = 0;
                                                if (isConfirm == 0) {
                                                    FightSkillConfig sconf = fire.pb.skill.Module.getInstance().getFightSkillConfig(skillId);
                                                    if (sconf != null && !sconf.isActiveSkill() && sconf.getType() == 10 && sconf.getSubSkills()[0] != null && sconf.getSubSkills()[0].getBuffUnits()[0] != null) {
                                                        for(SubSkillConfig subSkill : sconf.getSubSkills()) {
                                                            for(BuffUnit buffArg : subSkill.getBuffUnits()) {
                                                                if (buffArg != null && buffArg.buffIndex > 0) {
                                                                    buffPetImpl.removeCBuffWithSP(buffArg.buffIndex);
                                                                }
                                                            }
                                                        }
                                                    }
                                                }

                                                SkillPet spet = new SkillPet(petInfo, this.roleId);
                                                Result result = spet.addSkillBuffWhileOnline((BattleInfo)null);
                                                buffPetImpl.psendSBuffChangeResult(result);
                                                spet.updateSkillBuffWhileOut((BattleInfo)null);
                                                SRefreshPetSkill send = new SRefreshPetSkill();
                                                send.petkey = this.petKey;
                                                pet.fillSRefreshPetSkill(send);
                                                Procedure.psendWhileCommit(this.roleId, send);
                                                pet.updatePetScoreWhileChange();
                                                CourseManager.checkAchieveCourse(this.roleId, 31, pet.getPetInfo().getPetscore());
                                                CourseManager.achieveUpdate(this.roleId, 37);
                                                if (Module.logger.isInfoEnabled()) {
                                                    Module.logger.info("[PPetSkillCertificationLingWu] roleId:" + this.roleId + " skillId:" + skillId + " isConfirm:" + isConfirm + " petInfo:" + Helper.toString(pet.getPetInfo()));
                                                }

                                                return true;
                                            }

                                            ++attempts;
                                        } while(attempts < maxAttempts);

                                        MessageMgr.psendMsgNotify(this.roleId, 202224, (List)null);
                                        return false;
                                    }
                                }
                            }
                        } else {
                            PetSkillItem skillItem = (PetSkillItem)item;
                            int skillId = ((PetItemShuXing)skillItem.getItemAttr()).getSkillid();
                            if (PetManager.getInstance().getSkillUpGrade(skillId) == null) {
                                return false;
                            } else {
                                if (PetManager.getInstance().isActiveSkill(skillId)) {
                                    int count = 0;

                                    for(int tempId : pet.getBattleskillIds()) {
                                        if (PetManager.getInstance().isActiveSkill(tempId)) {
                                            ++count;
                                        }
                                    }

                                    if (count >= 6) {
                                        MessageMgr.psendMsgNotify(this.roleId, 145221, (List)null);
                                        return false;
                                    }
                                }

                                if (pet.hasAnySkill(skillId)) {
                                    MessageMgr.psendMsgNotify(this.roleId, 141700, (List)null);
                                    return true;
                                } else {
                                    int oldSkillId = -4;
                                    int learnResult = this.getLearnSkillResult(pet);
                                    if (learnResult == -2) {
                                        return true;
                                    } else {
                                        if (learnResult == -1) {
                                            if (!pet.addSkill(skillId, -1L, (int)skillItem.getDataItem().getExtid(), 1)) {
                                                return false;
                                            }
                                        } else {
                                            if (learnResult < 0) {
                                                return true;
                                            }

                                            oldSkillId = pet.insertSkill(learnResult, skillId, -1L, 1);
                                            List<String> p1 = new ArrayList();
                                            p1.add(pet.getName());
                                            SSkillConfig localObject2 = (SSkillConfig)ConfigManager.getInstance().getConf(SSkillConfig.class).get(oldSkillId);
                                            SSkillConfig localSSkillConfig = (SSkillConfig)ConfigManager.getInstance().getConf(SSkillConfig.class).get(skillId);
                                            p1.add(localSSkillConfig.getName());
                                            p1.add(localObject2.getName());
                                            MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 202222, p1);
                                            if (oldSkillId < 0) {
                                                return false;
                                            }
                                        }

                                        if (pet.getBattleskillIds().size() > pet.petSkillsGrid()) {
                                            return false;
                                        } else if (bag.removeItemWithKey(this.bookKey, 1, YYLoggerTuJingEnum.tujing_Value_peiyang, skillItem.getItemId(), "PetLearnSkill") != 1) {
                                            return false;
                                        } else {
                                            BuffPetImpl buffPetImpl = new BuffPetImpl(this.roleId, this.petKey);
                                            if (oldSkillId > 0) {
                                                FightSkillConfig sconf = fire.pb.skill.Module.getInstance().getFightSkillConfig(oldSkillId);
                                                if (sconf != null && !sconf.isActiveSkill() && sconf.getType() == 10 && sconf.getSubSkills()[0] != null && sconf.getSubSkills()[0].getBuffUnits()[0] != null) {
                                                    for(SubSkillConfig subSkill : sconf.getSubSkills()) {
                                                        for(BuffUnit buffArg : subSkill.getBuffUnits()) {
                                                            if (buffArg != null && buffArg.buffIndex > 0) {
                                                                buffPetImpl.removeCBuffWithSP(buffArg.buffIndex);
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            SkillPet spet = new SkillPet(petInfo, this.roleId);
                                            Result result = spet.addSkillBuffWhileOnline((BattleInfo)null);
                                            buffPetImpl.psendSBuffChangeResult(result);
                                            spet.updateSkillBuffWhileOut((BattleInfo)null);
                                            SRefreshPetSkill send = new SRefreshPetSkill();
                                            send.petkey = this.petKey;
                                            pet.fillSRefreshPetSkill(send);
                                            Procedure.psendWhileCommit(this.roleId, send);
                                            pet.updatePetScoreWhileChange();
                                            CourseManager.checkAchieveCourse(this.roleId, 31, pet.getPetInfo().getPetscore());
                                            CourseManager.achieveUpdate(this.roleId, 36);
                                            this.onLog(this.roleId, pet, skillId);
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
    }

    public int getLearnSkillResult(Pet pet) {
        Map<Integer, PetLearnSkillRateConfig> confs = ConfigManager.getInstance().getConf(PetLearnSkillRateConfig.class);
        if (confs == null) {
            return -3;
        } else {
            List<PetSkill> skills = pet.getBattleskills();
            int num = skills.size();
            boolean isReplace = true;
            PetLearnSkillRateConfig conf = (PetLearnSkillRateConfig)confs.get(num);
            if (conf != null && conf.getRate() > (double)0.0F) {
                int r = Misc.getRandomBetween(0, 9999);
                int v = (int)(conf.getRate() * (double)10000.0F);
                if (v >= r) {
                    isReplace = false;
                }
            }

            if (num < pet.getSkillMaxNum() && !isReplace) {
                return -1;
            } else {
                List<Integer> replaceIndexList = new ArrayList();
                Map<Integer, SPetEquiptaozhuang> taozhuangConf = ConfigManager.getInstance().getConf(SPetEquiptaozhuang.class);
                Set<Integer> taozhuangSkillIds = new HashSet();
                if (taozhuangConf != null) {
                    for(SPetEquiptaozhuang config : taozhuangConf.values()) {
                        if (config.getSkill() > 0) {
                            taozhuangSkillIds.add(config.getSkill());
                        }
                    }
                }

                for(int i = 0; i < skills.size(); ++i) {
                    PetSkill skill = (PetSkill)skills.get(i);
                    if (skill.getCertification() == 0 && this.isCanBeReplace(pet, i) && !taozhuangSkillIds.contains(skill.getSkillid()) && !this.isProtectedSkill(pet, skill.getSkillid())) {
                        replaceIndexList.add(i);
                    }
                }

                if (replaceIndexList.size() > 0) {
                    int index = Misc.getRandomBetween(0, replaceIndexList.size() - 1);
                    return (Integer)replaceIndexList.get(index);
                } else {
                    return -2;
                }
            }
        }
    }

    private boolean isProtectedSkill(Pet pet, int skillId) {
        return false;
    }

    private boolean isCanBeReplace(Pet pet, int index) {
        if (4 != pet.getKind()) {
            return true;
        } else {
            boolean isCanBeReplace = true;
            switch (index) {
                case 0:
                    if (pet.getPetAttr().getIsbindskill1() != 0) {
                        isCanBeReplace = false;
                    }
                    break;
                case 1:
                    if (pet.getPetAttr().getIsbindskill2() != 0) {
                        isCanBeReplace = false;
                    }
                    break;
                case 2:
                    if (pet.getPetAttr().getIsbindskill3() != 0) {
                        isCanBeReplace = false;
                    }
                    break;
                case 3:
                    if (pet.getPetAttr().getIsbindskill4() != 0) {
                        isCanBeReplace = false;
                    }
                    break;
                case 4:
                    if (pet.getPetAttr().getIsbindskill5() != 0) {
                        isCanBeReplace = false;
                    }
            }

            return isCanBeReplace;
        }
    }

    public void onLog(long roleId, Pet pet, int SkiId) {
        if (Module.logger.isInfoEnabled()) {
            List<Integer> skillIds = new ArrayList();
            List<Integer> skillTypes = new ArrayList();
            List<Integer> skillCertifys = new ArrayList();

            for(PetSkill skill : pet.getPetInfo().getSkills()) {
                skillIds.add(skill.getSkillid());
                skillTypes.add(skill.getSkilltype());
                skillCertifys.add(skill.getCertification());
            }

            Module.logger.info("[PPetLearnSkillByBook] roleId:" + roleId + " petKey:" + pet.getPetInfo().getKey() + " uniqId:" + pet.getPetInfo().getUniqid() + " petId:" + pet.getPetInfo().getId() + " skillIds:" + Arrays.toString(skillIds.toArray()) + " skillTypes:" + Arrays.toString(skillTypes.toArray()) + " skillCertifys:" + Arrays.toString(skillCertifys.toArray()));
        }

        this.writeYYLogger(roleId, pet, SkiId);
    }

    private void writeYYLogger(long roleId, Pet pet, int SkiId) {
        if (pet != null) {
            int isTrea = pet.getPetInfo().getPetscore() > pet.getPetAttr().getTreasureScore() ? 1 : 0;
            OpPetSkiBean opPetSkiBean = new OpPetSkiBean(pet.getPetInfo().getId(), isTrea, pet.getPetInfo().getUniqid(), SkiId, OpPetSkiBean.Op_PetSkiBean_Operate_Add);
            YYLogger.petSkiLog(roleId, opPetSkiBean);
        }
    }
}

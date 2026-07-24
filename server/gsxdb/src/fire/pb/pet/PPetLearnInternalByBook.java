//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.log.YYLogger;
import fire.log.beans.OpPetSkiBean;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffPetImpl;
import fire.pb.course.CourseManager;
import fire.pb.item.ItemBase;
import fire.pb.item.Pack;
import fire.pb.item.PetItemShuXing;
import fire.pb.item.pet.PetInternalItem;
import fire.pb.main.ConfigManager;
import fire.pb.skill.BuffUnit;
import fire.pb.skill.Result;
import fire.pb.skill.SkillPet;
import fire.pb.skill.SubSkillConfig;
import fire.pb.skill.fight.FightSkillConfig;
import fire.pb.talk.MessageMgr;
import fire.pb.util.Misc;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.BattleInfo;
import xbean.PetInfo;
import xbean.PetSkill;

public class PPetLearnInternalByBook extends Procedure {
    private long roleId;
    private int petKey;
    private int bookKey;
    public static final int RESULT_INVALID = -3;
    public static final int RESULT_NULL = -2;
    public static final int RESULT_ADD = -1;
    public static final int RESULT_REPLACE = 0;
    public static final int RESULT_LEVELLIMIT = -4;

    public PPetLearnInternalByBook(long roleId, int petKey, int bookKey) {
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
                Module.logger.error("[PPetLearnInternalByBook] petKey=" + this.petKey + " non-existent.");
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
                    } else if (!(item instanceof PetInternalItem)) {
                        Module.logger.error("[PPetLearnInternalByBook] use item type != PetInternalItem.");
                        return true;
                    } else {
                        PetInternalItem skillItem = (PetInternalItem)item;
                        int skillId = ((PetItemShuXing)skillItem.getItemAttr()).getSkillid();
                        if (PetManager.getInstance().getSkillUpGrade(skillId) == null) {
                            return false;
                        } else if (pet.hasAnyInternal(skillId)) {
                            MessageMgr.psendMsgNotify(this.roleId, 141700, (List)null);
                            return true;
                        } else {
                            int oldSkillId = -4;
                            int learnResult = this.getLearnResult(pet);
                            if (learnResult == -2) {
                                return true;
                            } else {
                                if (learnResult == -1) {
                                    if (!pet.addInternal(skillId, -1L, (int)skillItem.getDataItem().getExtid(), 1)) {
                                        return false;
                                    }
                                } else {
                                    if (learnResult == -4) {
                                        MessageMgr.psendMsgNotify(this.roleId, 191160, (List)null);
                                        return false;
                                    }

                                    if (learnResult < 0) {
                                        return true;
                                    }

                                    oldSkillId = pet.insertInternal(learnResult, skillId, -1L, 1);
                                    if (oldSkillId < 0) {
                                        return false;
                                    }
                                }

                                if (pet.getBattleInternalIds().size() > pet.petInternalsGrid()) {
                                    return false;
                                } else if (bag.removeItemWithKey(this.bookKey, 1, YYLoggerTuJingEnum.tujing_Value_peiyang, skillItem.getItemId(), "PetLearnSkill") != 1) {
                                    return false;
                                } else {
                                    BuffAgent buffAgent = new BuffPetImpl(this.roleId, this.petKey);
                                    if (oldSkillId > 0) {
                                        FightSkillConfig sconf = fire.pb.skill.Module.getInstance().getFightSkillConfig(oldSkillId);
                                        if (sconf != null && !sconf.isActiveSkill() && sconf.getType() == 10 && sconf.getSubSkills()[0] != null && sconf.getSubSkills()[0].getBuffUnits()[0] != null) {
                                            SubSkillConfig[] var15;
                                            for(SubSkillConfig subSkill : var15 = sconf.getSubSkills()) {
                                                BuffUnit[] var19;
                                                for(BuffUnit buffArg : var19 = subSkill.getBuffUnits()) {
                                                    if (buffArg != null && buffArg.buffIndex > 0) {
                                                        buffAgent.removeCBuffWithSP(buffArg.buffIndex);
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    SkillPet spet = new SkillPet(petInfo, this.roleId);
                                    Result result = spet.addSkillBuffWhileOnline((BattleInfo)null);
                                    buffAgent.psendSBuffChangeResult(result);
                                    spet.updateSkillBuffWhileOut((BattleInfo)null);
                                    SRefreshPetInternal send = new SRefreshPetInternal();
                                    send.petkey = this.petKey;
                                    pet.fillSRefreshPetInternal(send);
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

    public int getLearnResult(Pet pet) {
        List<PetSkill> internals = pet.getBattleInternals();
        int num = internals.size();
        Map<Integer, PetLearnInternalCountConfig> confs = ConfigManager.getInstance().getConf(PetLearnInternalCountConfig.class);
        if (confs == null) {
            return -3;
        } else {
            PetLearnInternalCountConfig conf = (PetLearnInternalCountConfig)confs.get(num);
            boolean isReplace = true;
            if (conf.getRate() > (double)0.0F) {
                int r = Misc.getRandomBetween(0, 9999);
                int v = (int)(conf.getRate() * (double)10000.0F);
                if (v >= r) {
                    isReplace = false;
                }
            }

            if (num < pet.getInternalMaxNum() && !isReplace) {
                return -1;
            } else {
                List<Integer> replaceIndexList = new ArrayList();

                for(int i = 0; i < num; ++i) {
                    replaceIndexList.add(i);
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

    public void onLog(long roleId, Pet pet, int SkiId) {
        if (Module.logger.isInfoEnabled()) {
            List<Integer> skillIds = new ArrayList();
            List<Integer> skillTypes = new ArrayList();
            List<Integer> skillCertifys = new ArrayList();

            for(PetSkill skill : pet.getPetInfo().getInternals()) {
                skillIds.add(skill.getSkillid());
                skillTypes.add(skill.getSkilltype());
                skillCertifys.add(skill.getCertification());
            }

            Module.logger.info("[PPetLearnInternalByBook] roleId:" + roleId + " petKey:" + pet.getPetInfo().getKey() + " uniqId:" + pet.getPetInfo().getUniqid() + " petId:" + pet.getPetInfo().getId() + " skillIds:" + Arrays.toString(skillIds.toArray()) + " skillTypes:" + Arrays.toString(skillTypes.toArray()) + " skillCertifys:" + Arrays.toString(skillCertifys.toArray()));
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

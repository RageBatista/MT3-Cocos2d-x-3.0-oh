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
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
import fire.pb.skill.BuffUnit;
import fire.pb.skill.Result;
import fire.pb.skill.SPetSkillupgrade;
import fire.pb.skill.SkillPet;
import fire.pb.skill.SubSkillConfig;
import fire.pb.skill.fight.FightSkillConfig;
import fire.pb.talk.MessageMgr;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.BattleInfo;
import xbean.PetInfo;
import xbean.PetSkill;

public class PPetLevelUpInternal extends Procedure {
    private long roleId;
    private int petKey;
    private int internalid;

    public PPetLevelUpInternal(long roleId, int petKey, int internalid) {
        this.roleId = roleId;
        this.petKey = petKey;
        this.internalid = internalid;
    }

    public boolean process() {
        if (Helper.isPetInBattle(this.roleId, this.petKey)) {
            return false;
        } else {
            PetColumn petCol = new PetColumn(this.roleId, 1, false);
            Pet pet = petCol.getPet(this.petKey);
            if (pet == null) {
                Module.logger.error("[PPetLevelUpInternal] petKey=" + this.petKey + " non-existent.");
                return true;
            } else {
                PetInfo petInfo = pet.getPetInfo();
                if (pet.isLocked() != -1L) {
                    MessageMgr.psendMsgNotify(this.roleId, Pet.PET_LOCK_ERROR_MSG, (List)null);
                    return true;
                } else if (!pet.hasAnyInternal(this.internalid)) {
                    MessageMgr.psendMsgNotify(this.roleId, 141710, (List)null);
                    return true;
                } else {
                    int nMatItemid;
                    int nMatItemCount;
                    Map<Integer, SPetLevelUpInternalConfig> confs = ConfigManager.getInstance().getConf(SPetLevelUpInternalConfig.class);
                    if (confs == null) {
                        return true;
                    } else {
                        SPetLevelUpInternalConfig conf = (SPetLevelUpInternalConfig)confs.get(this.internalid);
                        if (conf == null) {
                            MessageMgr.psendMsgNotify(this.roleId, 191154, (List)null);
                            return true;
                        } else {
                            nMatItemid = conf.getItemid();
                            nMatItemCount = conf.getItemcount();
                            Pack bag = (Pack)fire.pb.item.Module.getInstance().getItemMaps(this.roleId, 1, false);
                            if (bag.getBagItemNum(nMatItemid) < nMatItemCount) {
                                MessageMgr.psendMsgNotify(this.roleId, 191153, (List)null);
                                Module.logger.error("[PPetLearnSkillByBook] ======== 2");
                                return true;
                            } else {
                                SPetSkillupgrade petupgrade = PetManager.getInstance().getSkillUpGrade(this.internalid);
                                if (petupgrade == null) {
                                    MessageMgr.psendMsgNotify(this.roleId, 191154, (List)null);
                                    return false;
                                } else if (petupgrade.nextid == 0) {
                                    MessageMgr.psendMsgNotify(this.roleId, 191154, (List)null);
                                    return true;
                                } else {
                                    int oldSkillId = this.internalid;
                                    int newSkillId = petupgrade.nextid;
                                    oldSkillId = pet.LevelUpInternal(this.internalid, newSkillId);
                                    if (oldSkillId < 0) {
                                        return false;
                                    } else {
                                        int nremovemum = bag.removeItemById(nMatItemid, nMatItemCount, YYLoggerTuJingEnum.tujing_Value_peiyang, 0, "PetLeveUpInternal");
                                        if (nremovemum != nMatItemCount) {
                                            Module.logger.error("[PPetLevelUpInternal] remove matitem:" + nMatItemid + "   neednum:" + nMatItemCount + "   removenum:" + nremovemum);
                                            return false;
                                        } else {
                                            BuffAgent buffAgent = new BuffPetImpl(this.roleId, this.petKey);
                                            if (oldSkillId > 0) {
                                                FightSkillConfig sconf = fire.pb.skill.Module.getInstance().getFightSkillConfig(oldSkillId);
                                                if (sconf != null && !sconf.isActiveSkill() && sconf.getType() == 10 && sconf.getSubSkills()[0] != null && sconf.getSubSkills()[0].getBuffUnits()[0] != null) {
                                                    SubSkillConfig[] var17;
                                                    int var16 = (var17 = sconf.getSubSkills()).length;

                                                    for(int var15 = 0; var15 < var16; ++var15) {
                                                        SubSkillConfig subSkill = var17[var15];
                                                        BuffUnit[] var21;
                                                        int var20 = (var21 = subSkill.getBuffUnits()).length;

                                                        for(int var19 = 0; var19 < var20; ++var19) {
                                                            BuffUnit buffArg = var21[var19];
                                                            if (buffArg != null && buffArg.buffIndex > 0) {
                                                                buffAgent.removeCBuffWithSP(buffArg.buffIndex);
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            MessageMgr.psendMsgNotify(this.roleId, 191155, (List)null);
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
                                            this.onLog(this.roleId, pet, this.internalid);
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

    public void onLog(long roleId, Pet pet, int SkiId) {
        if (Module.logger.isInfoEnabled()) {
            List<Integer> skillIds = new ArrayList();
            List<Integer> skillTypes = new ArrayList();
            List<Integer> skillCertifys = new ArrayList();
            Iterator var9 = pet.getPetInfo().getInternals().iterator();

            while(var9.hasNext()) {
                PetSkill skill = (PetSkill)var9.next();
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

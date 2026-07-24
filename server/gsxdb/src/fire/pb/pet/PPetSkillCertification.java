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
import fire.pb.skill.Module;
import fire.pb.skill.Result;
import fire.pb.skill.SPetSkillupgrade;
import fire.pb.skill.SkillPet;
import fire.pb.skill.SubSkillConfig;
import fire.pb.skill.fight.FightSkillConfig;
import fire.pb.talk.MessageMgr;
import fire.pb.util.Misc;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeMap;
import mkdb.Procedure;
import xbean.BattleInfo;
import xbean.PetSkill;

public class PPetSkillCertification extends Procedure {
    private final long roleId;
    private final int petKey;
    private final int skillId;
    private final int isConfirm;

    public PPetSkillCertification(long var1, int var3, int var4, int var5) {
        this.roleId = var1;
        this.petKey = var3;
        this.skillId = var4;
        this.isConfirm = var5;
    }

    public boolean process() {
        if (Helper.isPetInBattle(this.roleId, this.petKey)) {
            return false;
        } else {
            PetColumn var1 = new PetColumn(this.roleId, 1, false);
            Pet var2 = var1.getPet(this.petKey);
            if (null == var2) {
                return false;
            } else if (var2.isLocked() != -1L) {
                MessageMgr.psendMsgNotify(this.roleId, Pet.PET_LOCK_ERROR_MSG, (List)null);
                return true;
            } else {
                if (this.isConfirm == 1) {
                    if (!this.confirm(var2, this.skillId)) {
                        return false;
                    }
                } else if (!this.cancel(var2, this.skillId)) {
                    return false;
                }

                BuffPetImpl var3 = new BuffPetImpl(this.roleId, this.petKey);
                if (this.isConfirm == 0) {
                    FightSkillConfig var4 = Module.getInstance().getFightSkillConfig(this.skillId);
                    if (var4 != null && !var4.isActiveSkill() && var4.getType() == 10 && var4.getSubSkills()[0] != null && var4.getSubSkills()[0].getBuffUnits()[0] != null) {
                        for(SubSkillConfig var8 : var4.getSubSkills()) {
                            for(BuffUnit var12 : var8.getBuffUnits()) {
                                if (var12 != null && var12.buffIndex > 0) {
                                    ((BuffAgent)var3).removeCBuffWithSP(var12.buffIndex);
                                }
                            }
                        }
                    }
                }

                SkillPet var13 = new SkillPet(var2.getPetInfo(), this.roleId);
                Result var14 = var13.addSkillBuffWhileOnline((BattleInfo)null);
                ((BuffAgent)var3).psendSBuffChangeResult(var14);
                var13.updateSkillBuffWhileOut((BattleInfo)null);
                SRefreshPetSkill var15 = new SRefreshPetSkill();
                var15.petkey = this.petKey;
                var2.fillSRefreshPetSkill(var15);
                Procedure.psendWhileCommit(this.roleId, var15);
                Procedure.psendWhileCommit(this.roleId, new SPetSkillCertification(this.petKey, this.skillId, this.isConfirm));
                var2.updatePetScoreWhileChange();
                CourseManager.checkAchieveCourse(this.roleId, 31, var2.getPetInfo().getPetscore());
                CourseManager.achieveUpdate(this.roleId, 37);
                if (fire.pb.pet.Module.logger.isInfoEnabled()) {
                    fire.pb.pet.Module.logger.info("[PPetSkillCertification] roleId:" + this.roleId + " skillId:" + this.skillId + " isConfirm:" + this.isConfirm + " petInfo:" + Helper.toString(var2.getPetInfo()));
                }

                return true;
            }
        }
    }

    public boolean confirm(Pet var1, int var2) {
        List<PetSkill> var3 = var1.getBattleskills();
        PetSkill var4 = null;

        for(PetSkill var6 : var3) {
            if (var6.getCertification() == 1) {
                return false;
            }

            if (var6.getSkillid() == var2) {
                var4 = var6;
            }
        }

        if (var4 == null) {
            return false;
        } else {
            SPetSkillupgrade var8 = PetManager.getInstance().getSkillUpGrade(var2);
            if (var8 == null) {
                return false;
            } else if (var8.getIscancertification() == 0) {
                return false;
            } else {
                int var9 = var1.getPetAttr().getCertificationcost();
                if (var9 > 0) {
                    Pack var7 = new Pack(this.roleId, false);
                    if (var7.subMoney((long)(-var9), "Pet skill certification", YYLoggerTuJingEnum.tujing_Value_peiyang, 0) != (long)(-var9)) {
                        return false;
                    }
                }

                var4.setCertification(1);
                int var10 = this.getAppendSkillId(var1);
                if (var10 > 0) {
                    var1.addSkill(var10, -1L, 0, 2);
                }

                this.writeLogger(var1, var2, OpPetSkiBean.Op_PetSkiBean_Operate_CerMagi);
                return true;
            }
        }
    }

    public boolean cancel(Pet var1, int var2) {
        boolean var3 = false;
        List<PetSkill> var4 = var1.getBattleskills();
        PetSkill var5 = null;

        for(PetSkill var7 : var4) {
            if (var7.getCertification() == 1) {
                var5 = var7;
            }

            if (var7.getSkillid() == var2) {
                var3 = true;
            }
        }

        if (var5 == null) {
            return false;
        } else if (!var3) {
            return false;
        } else {
            int var8 = var1.getPetAttr().getCancelcertificationcost();
            if (var8 > 0) {
                Pack var9 = new Pack(this.roleId, false);
                if (var9.subMoney((long)(-var8), "Pet skill cancel certification", YYLoggerTuJingEnum.tujing_Value_peiyang, 0) != (long)(-var8)) {
                    return false;
                }
            }

            if (var1.removeSkillById(var2)) {
                var5.setCertification(0);
            }

            this.writeLogger(var1, var2, OpPetSkiBean.Op_PetSkiBean_Operate_CancelCerMagi);
            return true;
        }
    }

    private List<Integer> getAppendSkillIdList(Pet var1, int var2) {
        ArrayList<Integer> var3 = new ArrayList<Integer>();
        TreeMap<Integer, SPetSkillupgrade> var4 = ConfigManager.getInstance().getConf(SPetSkillupgrade.class);
        if (var4 != null) {
            for(SPetSkillupgrade var6 : var4.values()) {
                if (var6.getIscertificationappend() == var2) {
                    int var7 = var6.getId();
                    if (!var1.hasAnySkill(var7)) {
                        var3.add(var6.getId());
                    }
                }
            }
        }

        return var3;
    }

    private int getAppendSkillId(Pet var1) {
        List var2 = this.getAppendSkillIdList(var1, 1);
        if (var2.size() == 0) {
            var2 = this.getAppendSkillIdList(var1, 2);
        }

        if (var2.size() > 0) {
            int var3 = Misc.getRandomBetween(0, var2.size() - 1);
            return (Integer)var2.get(var3);
        } else {
            return 0;
        }
    }

    private void writeLogger(Pet var1, int var2, int var3) {
        if (var1 != null) {
            int var4 = var1.getPetInfo().getPetscore() > var1.getPetAttr().getTreasureScore() ? 1 : 0;
            OpPetSkiBean var5 = new OpPetSkiBean(var1.getPetInfo().getId(), var4, var1.getUniqueId(), var2, var3);
            YYLogger.petSkiLog(this.roleId, var5);
        }
    }
}

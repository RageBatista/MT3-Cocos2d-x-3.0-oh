//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffPetImpl;
import fire.pb.course.CourseManager;
import fire.pb.item.ItemMaps;
import fire.pb.item.Module;
import fire.pb.main.ConfigManager;
import fire.pb.skill.BuffUnit;
import fire.pb.skill.Result;
import fire.pb.skill.SPetSkilllw;
import fire.pb.skill.SkillPet;
import fire.pb.skill.SubSkillConfig;
import fire.pb.skill.fight.FightSkillConfig;
import fire.pb.talk.MessageMgr;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.BattleInfo;

public class PPetSkillCertificationYiWang extends Procedure {
    private final long roleId;
    private final int petKey;
    private final int skillId;
    private final int isConfirm;

    public PPetSkillCertificationYiWang(long roleId, int petKey, int skillId, int isConfirm) {
        this.roleId = roleId;
        this.petKey = petKey;
        this.skillId = skillId;
        this.isConfirm = isConfirm;
    }

    public boolean process() {
        if (Helper.isPetInBattle(this.roleId, this.petKey)) {
            System.out.println("55555");
            return false;
        } else {
            PetColumn petCol = new PetColumn(this.roleId, 1, false);
            Pet pet = petCol.getPet(this.petKey);
            if (null == pet) {
                System.out.println("666666");
                return false;
            } else {
                ItemMaps bagContainer = Module.getInstance().getItemMaps(this.roleId, 1, false);
                if (!pet.hasSkill(this.skillId)) {
                    System.out.println("777777");
                    MessageMgr.psendMsgNotify(this.roleId, 191239, (List)null);
                    return false;
                } else {
                    Map<Integer, SPetSkilllw> skilllingwu = ConfigManager.getInstance().getConf(SPetSkilllw.class);
                    if (skilllingwu == null) {
                        System.out.println("表格不存在");
                        return false;
                    } else {
                        SPetSkilllw conf = (SPetSkilllw)skilllingwu.get(this.skillId);
                        int havenum = bagContainer.getItemNum(conf.removeneeditem, 0);
                        if (havenum < conf.removeneeditemnum) {
                            System.out.println("3333***" + conf.removeneeditem + "****" + havenum + "***" + conf.removeneeditemnum);
                            MessageMgr.sendMsgNotify(this.roleId, 191237, (List)null);
                        }

                        int delnum = bagContainer.removeItemById(conf.removeneeditem, conf.removeneeditemnum, YYLoggerTuJingEnum.tujing_Value_ranse, conf.removeneeditem, "装备升级");
                        if (delnum != conf.removeneeditemnum) {
                            System.out.println("44444***********" + delnum + "*********" + conf.addneeditemnum);
                            return false;
                        } else {
                            pet.removeSkillById(this.skillId);
                            MessageMgr.sendMsgNotify(this.roleId, 191240, (List)null);
                            BuffAgent buffAgent = new BuffPetImpl(this.roleId, this.petKey);
                            if (this.isConfirm == 0) {
                                FightSkillConfig sconf = fire.pb.skill.Module.getInstance().getFightSkillConfig(this.skillId);
                                if (sconf != null && !sconf.isActiveSkill() && sconf.getType() == 10 && sconf.getSubSkills()[0] != null && sconf.getSubSkills()[0].getBuffUnits()[0] != null) {
                                    for(SubSkillConfig subSkill : sconf.getSubSkills()) {
                                        for(BuffUnit buffArg : subSkill.getBuffUnits()) {
                                            if (buffArg != null && buffArg.buffIndex > 0) {
                                                buffAgent.removeCBuffWithSP(buffArg.buffIndex);
                                            }
                                        }
                                    }
                                }
                            }

                            SkillPet spet = new SkillPet(pet.getPetInfo(), this.roleId);
                            Result result = spet.addSkillBuffWhileOnline((BattleInfo)null);
                            buffAgent.psendSBuffChangeResult(result);
                            spet.updateSkillBuffWhileOut((BattleInfo)null);
                            System.out.println("88888888");
                            SRefreshPetSkill send = new SRefreshPetSkill();
                            send.petkey = this.petKey;
                            pet.fillSRefreshPetSkill(send);
                            Procedure.psendWhileCommit(this.roleId, send);
                            System.out.println("99999999");
                            pet.updatePetScoreWhileChange();
                            CourseManager.checkAchieveCourse(this.roleId, 31, pet.getPetInfo().getPetscore());
                            CourseManager.achieveUpdate(this.roleId, 37);
                            if (fire.pb.skill.Module.logger.isInfoEnabled()) {
                                fire.pb.skill.Module.logger.info("[PPetSkillCertificationLingWu] roleId:" + this.roleId + " skillId:" + this.skillId + " isConfirm:" + this.isConfirm + " petInfo:" + Helper.toString(pet.getPetInfo()));
                            }

                            return true;
                        }
                    }
                }
            }
        }
    }
}

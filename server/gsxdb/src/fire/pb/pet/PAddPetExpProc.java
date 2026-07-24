//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffPetImpl;
import fire.pb.course.CourseManager;
import fire.pb.effect.PetImpl;
import fire.pb.effect.Role;
import fire.pb.skill.Result;
import fire.pb.skill.SkillPet;
import fire.pb.talk.MessageMgr;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import mkdb.Transaction;
import xbean.BattleInfo;
import xbean.PetInfo;
import xbean.PetSkill;
import xtable.Properties;

public class PAddPetExpProc extends Procedure {
    public static final int ADD_REASON_DEFAULT = 0;
    public static final int ADD_REASON_EXPCULTIVATE = 1;
    private final long roleId;
    private final int petKey;
    private final long addExp;
    private boolean showMsg;
    private int reason;

    public PAddPetExpProc(long roleId, int petKey, long addExp) {
        this.showMsg = true;
        this.reason = 0;
        this.roleId = roleId;
        this.petKey = petKey;
        this.addExp = addExp;
    }

    public PAddPetExpProc(long roleId, int petKey, long addExp, boolean show) {
        this.showMsg = true;
        this.reason = 0;
        this.roleId = roleId;
        this.petKey = petKey;
        this.addExp = addExp;
        this.showMsg = show;
    }

    public PAddPetExpProc(long roleId, int petKey, long addExp, boolean show, int reason) {
        this(roleId, petKey, addExp, show);
        this.reason = reason;
    }

    public boolean process() {
        if (this.addExp == 0L) {
            return false;
        } else if (Helper.isPetInBattle(this.roleId, this.petKey)) {
            return false;
        } else {
            PetColumn petCol = new PetColumn(this.roleId, 1, false);
            Pet pet = petCol.getPet(this.petKey);
            if (pet == null) {
                return false;
            } else {
                PetInfo petInfo = pet.getPetInfo();
                int oldLevel = petInfo.getLevel();
                int levelSpace = 6;
                if (this.reason == 1) {
                    levelSpace = 10;
                }

                int roleLevel = Properties.selectLevel(this.roleId);
                if (petInfo.getLevel() >= roleLevel + levelSpace && this.addExp > 0L) {
                    if (this.reason == 0) {
                        MessageMgr.psendMsgNotify(this.roleId, 141794, (List)null);
                    }

                    return false;
                } else {
                    long curExp = petInfo.getExp();
                    Role epet = new PetImpl(this.roleId, this.petKey);
                    long nextExp = epet.getNextExp();
                    if (curExp + this.addExp <= 0L) {
                        petInfo.setExp(0L);
                    } else if (curExp + this.addExp >= nextExp) {
                        petInfo.setExp(curExp + this.addExp);
                        Map<Integer, Float> changeAttrs = new HashMap();
                        int i = 1;

                        while(petInfo.getExp() >= epet.getNextExp()) {
                            Map<Integer, Float> res = epet.levelUp();
                            if (res == null) {
                                break;
                            }

                            changeAttrs.putAll(res);
                            CalcPetAttr.graspPekSkillWhileUplevel(this.roleId, this.petKey);
                            ++i;
                            if (i > 155) {
                                Module.logger.error("宠物一次升级次数过多 PetExp = " + petInfo.getExp() + "NextExp = " + epet.getNextExp());
                                break;
                            }
                        }

                        if (!changeAttrs.isEmpty()) {
                            SkillPet skillPet = new SkillPet(petInfo, this.roleId);
                            Result result = skillPet.addSkillBuffWhileOnline((BattleInfo)null);

                            for(Map.Entry<Integer, Float> entry : changeAttrs.entrySet()) {
                                if (!result.getChangedAttrs().containsKey(entry.getKey())) {
                                    result.getChangedAttrs().put(entry.getKey(), entry.getValue());
                                }
                            }

                            BuffAgent buffAgent = new BuffPetImpl(this.roleId, this.petKey);
                            buffAgent.psendSBuffChangeResult(result);
                        }
                    } else {
                        petInfo.setExp(curExp + this.addExp);
                    }

                    if (this.addExp > 0L && this.showMsg) {
                        ArrayList<String> params = new ArrayList();
                        params.add(petInfo.getName());
                        PetAttr petAttr = Module.getInstance().getPetManager().getAttr(petInfo.getId());
                        if (petAttr != null) {
                            params.add(petAttr.getColour());
                        } else {
                            params.add("ffff0000");
                        }

                        params.add(Long.toString(this.addExp));
                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 141157, params);
                    }

                    if (petInfo.getLevel() > oldLevel) {
                        List<String> param = new ArrayList();
                        param.add(pet.getName());
                        param.add(Module.getInstance().getPetColorRGB(pet.getColor()));
                        if (Transaction.current() == null) {
                            MessageMgr.sendMsgNotify(this.roleId, 141404, param);
                        } else {
                            MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 141404, param);
                        }
                    }

                    int newLevel = petInfo.getLevel();
                    if (newLevel - oldLevel > 0) {
                        pet.updatePetScoreWhileChange();
                        CourseManager.checkAchieveCourse(this.roleId, 31, pet.getPetInfo().getPetscore());
                        if (newLevel >= 60) {
                            for(PetSkill skill : pet.getBattleskills()) {
                                CourseManager.achieveCourse(this.roleId, 21, skill.getSkillid(), 0);
                            }
                        }
                    }

                    Procedure.psendWhileCommit(this.roleId, new SRefreshPetExp(this.petKey, petInfo.getExp()));
                    this.onLog(this.roleId, petInfo.getKey(), petInfo.getUniqid(), petInfo.getId(), curExp, this.addExp, oldLevel, newLevel, this.reason);
                    return true;
                }
            }
        }
    }

    private void onLog(long roleId, int petKey, long uniqId, int petId, long curExp, long addExp, int oldLevel, int newLevel, int reason) {
        if (Module.logger.isInfoEnabled()) {
            Module.logger.info("[PAddPetExpProc] roleId:" + roleId + " petKey:" + petKey + " uniqId:" + uniqId + " petId:" + petId + " curExp:" + curExp + " addExp:" + addExp + " oldLevel:" + oldLevel + " newLevel:" + newLevel + " reason:" + reason);
        }

    }
}

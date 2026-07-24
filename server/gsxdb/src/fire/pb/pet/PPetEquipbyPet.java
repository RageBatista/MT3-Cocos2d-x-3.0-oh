//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.buff.BuffPetImpl;
import fire.pb.course.CourseManager;
import fire.pb.effect.PetImpl;
import fire.pb.item.AddItemResult;
import fire.pb.item.ItemBase;
import fire.pb.item.Pack;
import fire.pb.main.ModuleManager;
import fire.pb.skill.BuffUnit;
import fire.pb.skill.Result;
import fire.pb.skill.SkillPet;
import fire.pb.skill.SubSkillConfig;
import fire.pb.skill.fight.FightSkillConfig;
import fire.pb.talk.MessageMgr;
import java.util.List;
import mkdb.Procedure;
import xbean.BattleInfo;
import xbean.PetEquipItem;
import xbean.PetInfo;
import xbean.PetSkill;

public class PPetEquipbyPet extends Procedure {
    private long roleId;
    private int petKey;
    private int itemKey;

    public PPetEquipbyPet(long roleId, int petKey, int itemKey) {
        this.roleId = roleId;
        this.petKey = petKey;
        this.itemKey = itemKey;
    }

    public boolean process() {
        if (Helper.isPetInBattle(this.roleId, this.petKey)) {
            return false;
        } else {
            PetColumn petCol = new PetColumn(this.roleId, 1, false);
            Pet pet = petCol.getPet(this.petKey);
            if (pet == null) {
                Module.logger.error("[PPetEquipbyPet] petKey=" + this.petKey + " non-existent.");
                return true;
            } else {
                PetInfo petInfo = pet.getPetInfo();
                if (pet.isLocked() != -1L) {
                    MessageMgr.psendMsgNotify(this.roleId, Pet.PET_LOCK_ERROR_MSG, (List)null);
                    return true;
                } else {
                    Pack bag = (Pack)fire.pb.item.Module.getInstance().getItemMaps(this.roleId, 1, false);
                    ItemBase item = bag.getItem(this.itemKey);
                    if (item == null) {
                        return false;
                    } else if (!(item instanceof fire.pb.item.PetEquipItem)) {
                        Module.logger.error("[PPetEquipbyPet] use item type != PetEquipItem.");
                        return true;
                    } else {
                        fire.pb.item.PetEquipItem EquipItem = (fire.pb.item.PetEquipItem)item;
                        PetImpl petequip = new PetImpl(this.roleId, this.petKey);
                        int pos = EquipItem.getEquipAttr().getPos();
                        PetEquipItem oldpetEquipItem = null;
                        switch (pos) {
                            case 1:
                            case 2:
                            case 3:
                                oldpetEquipItem = pet.addPetEquipHuFu(EquipItem);
                            default:
                                if (bag.removeItemWithKey(this.itemKey, 1, YYLoggerTuJingEnum.tujing_Value_peiyang, EquipItem.getItemId(), "PetEquip") != 1) {
                                    return false;
                                } else {
                                    fire.pb.item.Module itemmodule = (fire.pb.item.Module)ModuleManager.getInstance().getModuleByName("item");
                                    if (itemmodule != null && oldpetEquipItem != null) {
                                        ItemBase givepetequip = itemmodule.getItemManager().genItemBase(oldpetEquipItem.getItemid(), 1);
                                        fire.pb.item.PetEquipItem petequipitem = (fire.pb.item.PetEquipItem)givepetequip;
                                        petequipitem.getEquipAttr().setPos(oldpetEquipItem.getPos());
                                        petequipitem.getEquipAttr().getPro().putAll(oldpetEquipItem.getPro());
                                        petequipitem.settaozhuangid(oldpetEquipItem.getTaozhuangid());
                                        AddItemResult petaddequip = bag.doAddItem(givepetequip, -1, "宠物装备装入背包", YYLoggerTuJingEnum.tujing_Value_itemuseget, 0);
                                        if (petaddequip != AddItemResult.SUCC) {
                                            return false;
                                        }
                                    }

                                    List<PetEquipItem> equips = petInfo.getPetequipbag();
                                    int tz1 = 0;
                                    int tz2 = 0;
                                    int tz3 = 0;

                                    for(PetEquipItem equip : equips) {
                                        switch (equip.getPos()) {
                                            case 1:
                                                tz1 = equip.getTaozhuangid();
                                                break;
                                            case 2:
                                                tz2 = equip.getTaozhuangid();
                                                break;
                                            case 3:
                                                tz3 = equip.getTaozhuangid();
                                        }
                                    }

                                    if (tz1 != 0 && tz2 != 0 && tz3 != 0) {
                                        if (tz1 == tz2 && tz2 == tz3) {
                                            addtaozhuang(this.roleId, this.petKey, tz1, false, petInfo);
                                        } else {
                                            deltaozhuang(this.roleId, this.petKey, tz1, tz2, tz3, false, petInfo);
                                        }
                                    }

                                    petequip.updateAllFinalAttrs();
                                    SRefreshPetInfo send = new SRefreshPetInfo(pet.getProtocolPet());
                                    Procedure.psendWhileCommit(this.roleId, send);
                                    pet.updatePetScoreWhileChange();
                                    CourseManager.checkAchieveCourse(this.roleId, 31, pet.getPetInfo().getPetscore());
                                    return true;
                                }
                        }
                    }
                }
            }
        }
    }

    public static boolean addtaozhuang(long roleId, int petkey, int tz1, boolean bind, PetInfo petInfo) {
        System.out.println("[DEBUG] Attempting to add suit tz1: " + tz1 + " to pet: " + petkey);
        PetColumn petCol = new PetColumn(roleId, 1, false);
        PetImpl petequip = new PetImpl(roleId, petkey);
        Pet pet = petCol.getPet(petkey);
        System.out.println("[DEBUG] Current pet skills: " + pet.getBattleskills());
        int maxSkillNum = 24;
        List<PetSkill> skills = pet.getBattleskills();
        if (skills.size() >= maxSkillNum) {
            System.out.println("[ERROR] Max skill limit reached for pet: " + petkey);
            return false;
        } else {
            for(PetSkill skill : skills) {
                if (skill.getSkillid() == tz1) {
                    System.out.println("[ERROR] Skill " + tz1 + " already exists on pet: " + petkey);
                    return false;
                }
            }

            pet.addSkill(tz1, -1L, 0, 1);
            System.out.println("[DEBUG] Added skill " + tz1 + " to pet: " + petkey);
            BuffPetImpl buffPetImpl = new BuffPetImpl(roleId, petkey);
            FightSkillConfig sconf = fire.pb.skill.Module.getInstance().getFightSkillConfig(tz1);
            if (sconf != null && !sconf.isActiveSkill() && sconf.getType() == 10 && sconf.getSubSkills()[0] != null && sconf.getSubSkills()[0].getBuffUnits()[0] != null) {
                for(SubSkillConfig subSkill : sconf.getSubSkills()) {
                    for(BuffUnit buffArg : subSkill.getBuffUnits()) {
                        if (buffArg != null && buffArg.buffIndex > 0) {
                            buffPetImpl.removeCBuffWithSP(buffArg.buffIndex);
                        }
                    }
                }
            }

            petInfo.setPettaozhuang(1);
            System.out.println("[DEBUG] Suit flag set to 1 for pet: " + petkey);
            petequip.updateAllFinalAttrs();
            SRefreshPetInfo send = new SRefreshPetInfo(pet.getProtocolPet());
            pet.updatePetScoreWhileChange();
            CourseManager.checkAchieveCourse(roleId, 31, pet.getPetInfo().getPetscore());
            Procedure.psendWhileCommit(roleId, send);
            SkillPet spet = new SkillPet(petInfo, roleId);
            Result result = spet.addSkillBuffWhileOnline((BattleInfo)null);
            buffPetImpl.psendSBuffChangeResult(result);
            System.out.println("[DEBUG] Final pet info after suit addition: " + petInfo);
            return true;
        }
    }

    public static PetInfo deltaozhuang(long roleId, int petkey, int tz1, int tz2, int tz3, boolean bind, PetInfo petInfo) {
        PetImpl petequip = new PetImpl(roleId, petkey);
        PetColumn petCol = new PetColumn(roleId, 1, false);
        Pet pet = petCol.getPet(petkey);
        if (petInfo.getPettaozhuang() == 1) {
            pet.removeSkillById(tz1);
            pet.removeSkillById(tz2);
            pet.removeSkillById(tz3);
            petInfo.setPettaozhuang(0);
            BuffPetImpl buffPetImpl = new BuffPetImpl(roleId, petkey);
            FightSkillConfig sconf = fire.pb.skill.Module.getInstance().getFightSkillConfig(tz1);
            if (sconf != null && !sconf.isActiveSkill() && sconf.getType() == 10 && sconf.getSubSkills()[0] != null && sconf.getSubSkills()[0].getBuffUnits()[0] != null) {
                SubSkillConfig[] arrayOfSubSkillConfig;
                for(SubSkillConfig subSkill : arrayOfSubSkillConfig = sconf.getSubSkills()) {
                    BuffUnit[] arrayOfBuffUnit;
                    for(BuffUnit buffArg : arrayOfBuffUnit = subSkill.getBuffUnits()) {
                        if (buffArg != null && buffArg.buffIndex > 0) {
                            buffPetImpl.removeCBuffWithSP(buffArg.buffIndex);
                        }
                    }
                }
            }

            petequip.updateAllFinalAttrs();
            SRefreshPetInfo send = new SRefreshPetInfo(pet.getProtocolPet());
            pet.updatePetScoreWhileChange();
            CourseManager.checkAchieveCourse(roleId, 31, pet.getPetInfo().getPetscore());
            Procedure.psendWhileCommit(roleId, send);
            SkillPet spet = new SkillPet(petInfo, roleId);
            Result result = spet.addSkillBuffWhileOnline((BattleInfo)null);
            buffPetImpl.psendSBuffChangeResult(result);
        }

        return petInfo;
    }
}

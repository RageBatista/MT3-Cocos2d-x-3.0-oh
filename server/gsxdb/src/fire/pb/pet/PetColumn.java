//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.MarshalException;
import com.locojoy.base.Marshal.OctetsStream;
import fire.log.YYLogger;
import fire.log.beans.OpPetBean;
import fire.msp.move.GNotifyMapPetInfo;
import fire.pb.GsClient;
import fire.pb.PetBean;
import fire.pb.PropRole;
import fire.pb.buff.BuffAgent;
import fire.pb.buff.BuffRoleImpl;
import fire.pb.buff.continual.ConstantlyBuff;
import fire.pb.course.CourseManager;
import fire.pb.course.CourseType;
import fire.pb.effect.PetImpl;
import fire.pb.event.PetColumnChange;
import fire.pb.event.Poster;
import fire.pb.item.SItemToItem;
import fire.pb.main.ConfigManager;
import fire.pb.ranklist.RankType;
import fire.pb.ranklist.proc.PRankInsertPet;
import fire.pb.ranklist.proc.PRankInsertPetChangeName;
import fire.pb.ranklist.proc.PRoleZongheRankProc;
import fire.pb.ranklist.proc.RankListManager;
import fire.pb.skill.Result;
import fire.pb.talk.MessageMgr;
import fire.pb.tel.utils.GoodsSafeLocksUtils;
import fire.pb.util.DateValidate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import mkdb.Mkdb;
import mkdb.Procedure;
import mkdb.TTable;
import mkdb.util.AutoKey;
import xbean.BasicFightProperties;
import xbean.DiscardPet;
import xbean.PetInfo;
import xbean.PetScoreListRecord;
import xbean.PetScoreRankList;
import xbean.Petrecoverlist;
import xbean.Pets;
import xbean.Pod;
import xbean.Properties;
import xbean.RoleRankNotifyTimeInfo;
import xbean.UniquePet;
import xtable.Petrecover;
import xtable.Petrecyclebin;
import xtable.Petscorelist;
import xtable.Roleranknotifytime;
import xtable.Uniquepets;

public class PetColumn {
    public static final int ADD_REASON_MOVE_BETWEEN_ROLES = -1;
    public static final int ADD_REASON_MOVE_BETWEEN_BAGS = 0;
    public static final int ADD_REASON_CATCH = 1;
    public static final int ADD_REASON_PACKAGE = 2;
    public static final int ADD_REASON_GM = 6;
    public static final int ADD_REASON_SYNTHESIZE = 8;
    public static final int ADD_REASON_SHOP_BUY = 9;
    public static final int ADD_REASON_TASK = 10;
    public static final int ADD_REASON_CHARGE = 12;
    public static final int ADD_REASON_ITEM = 13;
    public static final int ADD_REASON_ACHIEVE = 14;
    public static final int ADD_REASON_LEIJILOGIN = 15;
    public static final int ADD_REASON_SHENSHOUDUIHUAN = 16;
    public static final int ADD_REASON_SHENSHOUCHONGZHI = 17;

    public static final int REMOVE_REASON_MOVE_BETWEEN_ROLES = -1;
    public static final int REMOVE_REASON_MOVE_BETWEEN_BAGS = 0;
    public static final int REMOVE_REASON_RELEASE = 1;
    public static final int REMOVE_REASON_TASK = 2;
    public static final int REMOVE_REASON_SYNTHESIZE = 5;
    public static final int REMOVE_REASON_SELL = 6;
    public static final int REMOVE_REASON_SHENSHOUCHONGZHI = 7;

    public final long roleId;
    public final int petColumnId;
    private final boolean readOnly;
    private final Pets pets;
    private final PetColumnConfig config;

    public PetColumn(long roleId, int petColumnId, boolean readOnly) {
        if (roleId <= 0L) {
            throw new IllegalArgumentException("Error roleId:" + roleId);
        } else {
            this.readOnly = readOnly;
            this.roleId = roleId;
            this.petColumnId = petColumnId;
            this.config = getPetColumnConfig(petColumnId);
            if (null == this.config) {
                throw new IllegalArgumentException("Error petColumnId:" + petColumnId);
            } else {
                TTable<Long, Pets> table = (TTable<Long, Pets>)Mkdb.getInstance().getTables().getTable(this.config.tablename);
                Pets petColumn;
                if (readOnly) {
                    petColumn = table.select(roleId, v -> v.toData());
                } else {
                    petColumn = table.get(roleId);
                }

                if (null == petColumn) {
                    if (readOnly) {
                        this.pets = Pod.newPetsData();
                    } else {
                        this.pets = Pod.newPets();
                    }

                    this.pets.setCapacity(this.config.initsize);
                    if (!readOnly) {
                        table.insert(roleId, this.pets);
                    }
                } else {
                    this.pets = petColumn;
                }

            }
        }
    }

    public Map<Integer, PetInfo> getPetsMap() {
        return this.pets != null ? this.pets.getPetmap() : null;
    }

    private int incNextId() {
        if (this.readOnly) {
            return 0;
        } else {
            int id = this.pets.getNextid() + 1;
            if (id < 0) {
                throw new RuntimeException("");
            } else {
                this.pets.setNextid(id);
                return id;
            }
        }
    }

    public int getPetNum(int petId) {
        int count = 0;

        for(PetInfo petinfo : this.getPetsMap().values()) {
            if (petinfo.getId() == petId && this.petNotFightPet(petId)) {
                ++count;
            }
        }

        return count;
    }

    public int getPetNumByMapping(int petId) {
        int firstpetnum = this.getPetNum(petId);
        int otherpetnum = 0;
        SItemToItem item2item = ConfigManager.getInstance().getConf(SItemToItem.class).get(petId);
        if (item2item != null) {
            for(Integer curitem : item2item.getItemsid()) {
                int curitemnum = this.getPetNum(curitem);
                otherpetnum += curitemnum;
            }
        }

        return firstpetnum + otherpetnum;
    }

    public int countPet(int petId, int... types) {
        int count = 0;

        for(PetInfo pinfo : this.getPetsMap().values()) {
            if (pinfo.getId() == petId) {
                if (types.length > 0) {
                    for(int type : types) {
                        if (pinfo.getKind() == type) {
                            ++count;
                            break;
                        }
                    }
                } else {
                    ++count;
                }
            }
        }

        return count;
    }

    public int getCapacity() {
        return this.pets.getCapacity();
    }

    public void incCapacity() {
        if (this.readOnly) {
            throw new RuntimeException("Invoke must in procedure");
        } else {
            this.pets.setCapacity(this.pets.getCapacity() + 1);
        }
    }

    public void incCapacity(int addsize) {
        if (this.readOnly) {
            throw new RuntimeException("Invoke must in procedure");
        } else {
            this.pets.setCapacity(this.pets.getCapacity() + addsize);
        }
    }

    public int getPetColumnMaxCapacity() {
        return this.config.maxsize;
    }

    public void refreshCapacity() {
        SRefreshPetColumnCapacity send = new SRefreshPetColumnCapacity(this.petColumnId, this.getCapacity());
        Procedure.psendWhileCommit(this.roleId, send);
    }

    public int size() {
        return this.pets.getPetmap().size();
    }

    public int getRemainSize() {
        return this.getCapacity() - this.size();
    }

    public static PetInfo createPet(long roleid, int id, int level, List<Integer> skillIds, int type, int colour, boolean bind) {
        return createPet(roleid, id, level, skillIds, type, colour, bind, null, -1L);
    }

    public static PetInfo createPet(long roleId, int id, int level, List<Integer> skillIds, int type, int starId, boolean bind, Map<Integer, Object> initAttrs, Long uId) {
        if (level >= 0 && level <= 200) {
            PetInfo petInfo = Pod.newPetInfo();
            petInfo.setId(id);
            petInfo.setKind(type);
            petInfo.setIsbinded(bind);
            petInfo.setLevel(level);
            if (uId <= 0L) {
                AutoKey<Long> autoKey = Mkdb.getInstance().getTables().getTableSys().getAutoKeys().getAutoKeyLong(Module.PET_AUTOKEY_NAME);
                uId = autoKey.next();
                if (uId == null) {
                    throw new IllegalArgumentException("Get pet uid equal null");
                }
            }

            petInfo.setUniqid(uId);
            petInfo.setOwnerid(roleId);
            CalcPetAttr calcAttr = new CalcPetAttr(petInfo);
            calcAttr.setInitAttrPoint();
            petInfo.getBfp().setStr(petInfo.getBfp().getStr() + level);
            petInfo.getBfp().setCons(petInfo.getBfp().getCons() + level);
            petInfo.getBfp().setEndu(petInfo.getBfp().getEndu() + level);
            petInfo.getBfp().setIq(petInfo.getBfp().getIq() + level);
            petInfo.getBfp().setAgi(petInfo.getBfp().getAgi() + level);
            calcAttr.setBornAttackApt(-1);
            calcAttr.setBornDefendApt(-1);
            calcAttr.setBornMagicApt(-1);
            calcAttr.setBornPhyforceApt(-1);
            calcAttr.setBornDodgeApt(-1);
            calcAttr.setBornSpeedApt(-1);
            calcAttr.setPetAttrByInitAttrs(initAttrs, id);
            fire.pb.pet.Pet pet = fire.pb.pet.Pet.getPet(petInfo);
            if (skillIds != null) {
                pet.getBattleskills().clear();

                for(int skillId : skillIds) {
                    if (fire.pb.skill.Module.isPetSkill(skillId)) {
                        pet.addSkill(skillId, -1L, 0, 0);
                    }
                }
            } else {
                calcAttr.genPetSkill(petInfo);
            }

            pet.getPetInfo().setAutoaddcons(pet.getPetAttr().addpoint.get(0));
            pet.getPetInfo().setAutoaddiq(pet.getPetAttr().addpoint.get(1));
            pet.getPetInfo().setAutoaddstr(pet.getPetAttr().addpoint.get(2));
            pet.getPetInfo().setAutoaddendu(pet.getPetAttr().addpoint.get(3));
            pet.getPetInfo().setAutoaddagi(pet.getPetAttr().addpoint.get(4));
            BasicFightProperties bfp = pet.getPetInfo().getBfp();
            bfp.setCons(bfp.getCons() + level * pet.getPetAttr().addpoint.get(0));
            bfp.setIq(bfp.getIq() + level * pet.getPetAttr().addpoint.get(1));
            bfp.setStr(bfp.getStr() + level * pet.getPetAttr().addpoint.get(2));
            bfp.setEndu(bfp.getEndu() + level * pet.getPetAttr().addpoint.get(3));
            bfp.setAgi(bfp.getAgi() + level * pet.getPetAttr().addpoint.get(4));
            int point = level * 5;
            point -= level * pet.getPetAttr().addpoint.get(0);
            point -= level * pet.getPetAttr().addpoint.get(1);
            point -= level * pet.getPetAttr().addpoint.get(2);
            point -= level * pet.getPetAttr().addpoint.get(3);
            point -= level * pet.getPetAttr().addpoint.get(4);
            pet.setPoint(point);
            if (point < 0) {
                int sum = pet.getPetAttr().addpoint.get(0) + pet.getPetAttr().addpoint.get(1) + pet.getPetAttr().addpoint.get(2) + pet.getPetAttr().addpoint.get(3) + pet.getPetAttr().addpoint.get(4);
                String err = String.format("createPet id:%d level:%d setPoint:%d autoadd:%d", id, level, point, sum);
                throw new RuntimeException(err);
            } else {
                if (petInfo.getKind() != pet.getPetAttr().getKind()) {
                    Module.logger.warn("[createPet] roleId:" + roleId + " uniqId:" + petInfo.getUniqid() + " id:" + petInfo.getId() + " name:" + petInfo.getName() + " kind:" + petInfo.getKind() + " fixKind = PetAttr.kind:" + pet.getPetAttr().getKind());
                    petInfo.setKind(pet.getPetAttr().getKind());
                }

                pet.online();
                PetImpl epet = new PetImpl(petInfo);
                epet.fullHp();
                epet.fullMp();
                return petInfo;
            }
        } else {
            return null;
        }
    }

    public int add(PetInfo petInfo, int reason) {
        if (this.readOnly) {
            return -1;
        } else if (this.size() >= this.getCapacity()) {
            return -1;
        } else {
            boolean bSetFight = false;
            if (this.size() == 0) {
                bSetFight = true;
            }
            if (fire.pb.buff.Module.existState(this.roleId, 507004)) {
                switch (reason) {
                    case ADD_REASON_MOVE_BETWEEN_ROLES:
                    case ADD_REASON_MOVE_BETWEEN_BAGS:
                    case ADD_REASON_CATCH:
                    case ADD_REASON_SYNTHESIZE:
                    case ADD_REASON_SHOP_BUY:
                    case ADD_REASON_CHARGE:
                    case ADD_REASON_ITEM:
                    case ADD_REASON_ACHIEVE:
                    case ADD_REASON_LEIJILOGIN:
                        bSetFight = false;
                        break;
                    default:
                        return -1;
                }
            }

            int nextId;
            do {
                nextId = this.incNextId();
                if (nextId == 0) {
                    nextId = this.incNextId();
                }
            } while(null != this.pets.getPetmap().get(nextId));

            petInfo.setKey(nextId);
            this.pets.getPetmap().put(nextId, petInfo);
            Poster.getPoster().dispatchEvent(new PetColumnChange(this.roleId, petInfo.getId()));
            fire.pb.pet.Pet pet = fire.pb.pet.Pet.getPet(petInfo);
            SAddPetToColumn sendAdd = new SAddPetToColumn();
            sendAdd.columnid = this.petColumnId;
            sendAdd.petdata = pet.getProtocolPet();
            Procedure.psendWhileCommit(this.roleId, sendAdd);
            if (reason == ADD_REASON_MOVE_BETWEEN_BAGS) {
                return petInfo.getKey();
            } else {
                boolean isMsg = reason > 0;
                this.changeOwner(petInfo, isMsg);
                if (reason == ADD_REASON_MOVE_BETWEEN_ROLES) {
                    CourseManager.achieveCourse(this.roleId, CourseType.HAVE_PAT, pet.getPetAttr().quality, pet.getPetAttr().unusualid);
                    return petInfo.getKey();
                } else {
                    pet.updatePetScoreWhileChange();
                    CourseManager.achieveCourse(this.roleId, CourseType.PET_COURSE, petInfo.getId(), 0);
                    CourseManager.achieveCourse(this.roleId, CourseType.HAVE_PAT, pet.getPetAttr().quality, pet.getPetAttr().unusualid);
                    CourseManager.checkAchieveCourse(this.roleId, CourseType.PET_SCORE, pet.getPetInfo().getPetscore());
                    this.writeYYLogger(petInfo);
                    if (bSetFight) {
                        (new PSetFightPetProc(this.roleId, petInfo.getKey(), true)).call();
                    }

                    return petInfo.getKey();
                }
            }
        }
    }

    private void writeYYLogger(PetInfo petInfo) {
        if (petInfo != null) {
            PropRole pRole = new PropRole(this.roleId, true);
            OpPetBean opPetBean = new OpPetBean(petInfo.getId(), petInfo.getLevel(), petInfo.getIsbinded() ? 1 : 0, pRole.getFightpetkey() == petInfo.getKey() ? 1 : 0, petInfo.getPetscore(), petInfo.getHp(), petInfo.getMp(), petInfo.getTreasure(), petInfo.getUniqid(), petInfo.getBfp().getCons(), petInfo.getBfp().getIq(), petInfo.getBfp().getStr(), petInfo.getBfp().getEndu(), petInfo.getBfp().getAgi(), petInfo.getBornphyforceapt(), petInfo.getBornmagicapt(), petInfo.getId(), petInfo.getBorndefendapt(), petInfo.getBornspeedapt(), petInfo.getSkills());
            YYLogger.petLog(this.roleId, opPetBean);
        }
    }

    private void changeOwner(PetInfo petInfo, boolean isMsg) {
        UniquePet uniquePet = Uniquepets.get(petInfo.getUniqid());
        if (uniquePet == null) {
            uniquePet = Pod.newUniquePet();
            Uniquepets.insert(petInfo.getUniqid(), uniquePet);
        }

        uniquePet.setRoleid(this.roleId);
        petInfo.setOwnerid(this.roleId);
        Procedure.pexecuteWhileCommit(new PRankInsertPet(petInfo.getUniqid(), isMsg));
    }

    public int removePet(int petKey, int reason, int param) {
        if (this.readOnly) {
            throw new RuntimeException("readOnly!!");
        } else {
            if (fire.pb.buff.Module.existState(this.roleId, 507004)) {
                if (reason != REMOVE_REASON_MOVE_BETWEEN_ROLES
                        && reason != REMOVE_REASON_MOVE_BETWEEN_BAGS
                        && reason != REMOVE_REASON_SYNTHESIZE) {
                    return PetError.KeyNotFound;
                }
            }

            PetInfo petInfo = this.getPetInfo(petKey);
            if (null == petInfo) {
                return PetError.KeyNotFound;
            } else {
                fire.pb.pet.Pet pet = fire.pb.pet.Pet.getPet(petInfo);
                Map<Integer, PetInfo> petMap = this.pets.getPetmap();
                PetInfo removed = petMap.remove(petKey);
                if (removed == null) {
                    return PetError.KeyNotFound;
                } else if (removed != petInfo) {
                    return PetError.KeyNotFound;
                } else {
                    Poster.getPoster().dispatchEvent(new PetColumnChange(this.roleId, removed.getId()));
                    SRemovePetFromCol sendRemove = new SRemovePetFromCol(this.petColumnId, petKey);
                    Procedure.psendWhileCommit(this.roleId, sendRemove);
                    if (reason != REMOVE_REASON_MOVE_BETWEEN_BAGS
                            && reason != REMOVE_REASON_MOVE_BETWEEN_ROLES) {
                        this.onRealRemove(pet, reason, param, new HashMap<>());
                    }

                    return 0;
                }
            }
        }
    }

    public int removePet(int petKey, int reason) {
        if (this.readOnly) {
            throw new RuntimeException("readOnly!!");
        } else {
            if (fire.pb.buff.Module.existState(this.roleId, 507004)) {
                if (reason != REMOVE_REASON_MOVE_BETWEEN_ROLES
                        && reason != REMOVE_REASON_MOVE_BETWEEN_BAGS
                        && reason != REMOVE_REASON_SYNTHESIZE) {
                    return PetError.KeyNotFound;
                }
            }

            PetInfo petInfo = this.getPetInfo(petKey);
            if (null == petInfo) {
                return PetError.KeyNotFound;
            } else {
                fire.pb.pet.Pet pet = fire.pb.pet.Pet.getPet(petInfo);
                Map<Integer, PetInfo> petMap = this.pets.getPetmap();
                PetInfo removed = petMap.remove(petKey);
                if (removed == null) {
                    return PetError.KeyNotFound;
                } else if (removed != petInfo) {
                    return PetError.KeyNotFound;
                } else {
                    Poster.getPoster().dispatchEvent(new PetColumnChange(this.roleId, removed.getId()));
                    SRemovePetFromCol sendRemove = new SRemovePetFromCol(this.petColumnId, petKey);
                    Procedure.psendWhileCommit(this.roleId, sendRemove);
                    if (reason != REMOVE_REASON_MOVE_BETWEEN_BAGS
                            && reason != REMOVE_REASON_MOVE_BETWEEN_ROLES) {
                        this.onRealRemove(pet, reason, 0, new HashMap<>());
                    }

                    return 0;
                }
            }
        }
    }

    private void onRealRemove(fire.pb.pet.Pet pet, int reason, int param, Map<String, Object> params) {
        final long uniquePetId = pet.getUniqueId();
        boolean ret = Uniquepets.remove(uniquePetId);
        if (!ret) {
            Module.logger.error("[onRealRemove] roleId:" + this.roleId + " petKey:" + pet.getPetInfo().getKey() + " uniqId:" + uniquePetId + " Pet not exist in Uniquepets.");
        }

        boolean isRecycle = false;
        if (pet.getKind() != PetTypeEnum.WILD) {
            if (pet.getKind() == PetTypeEnum.BABY && pet.getTreasure() == 0) {
                isRecycle = false;
            } else {
                isRecycle = true;
            }

            if (isRecycle) {
                this.enterRecyclebin(pet, reason);
            }
        }

        if (Module.logger.isInfoEnabled()) {
            Module.logger.info("[onRealRemove] roleId:" + this.roleId + " petKey:" + pet.getPetkey() + " uniqId:" + pet.getUniqueId() + " petId:" + pet.getBaseId() + " name:" + pet.getName() + " petScore:" + pet.getPetInfo().getPetscore() + " isTreasure:" + pet.getTreasure() + " reason:" + reason + " isRecycle:" + isRecycle);
        }

        Procedure.pexecuteWhileCommit(new Procedure() {
            public boolean process() {
                PetColumn.this.removeFromPetscoreRankList(uniquePetId);
                return true;
            }
        });
        Procedure.pexecuteWhileCommit(new PRoleZongheRankProc(pet.getPetInfo().getOwnerid()));
    }

    private void enterRecyclebin(fire.pb.pet.Pet pet, int reason) {
        DiscardPet dpet = Pod.newDiscardPet();
        dpet.setRoleid(this.roleId);
        dpet.setDeletedate(System.currentTimeMillis());
        dpet.setReason(reason);
        OctetsStream os = pet.getPetInfo().marshal(new OctetsStream());

        try {
            dpet.getPet().unmarshal(os);
        } catch (MarshalException e) {
            Module.logger.error(e);
        }

        if (pet.getUniqueId() > 0L) {
            Petrecyclebin.insert(pet.getUniqueId(), dpet);
            if (reason == REMOVE_REASON_RELEASE) {
                Petrecoverlist petRecoverList = Petrecover.get(this.roleId);
                if (petRecoverList == null) {
                    petRecoverList = Pod.newPetrecoverlist();
                    Petrecover.insert(this.roleId, petRecoverList);
                }

                if (!petRecoverList.getUniqids().contains(pet.getUniqueId())) {
                    petRecoverList.getUniqids().add(pet.getUniqueId());
                    if (petRecoverList.getUniqids().size() > 50) {
                        petRecoverList.getUniqids().remove(0);
                    }
                }
            }
        }

    }

    protected void removeFromPetscoreRankList(long uniqPetid) {
        PetScoreRankList list = Petscorelist.get(1);
        if (null != list) {
            int index = 0;
            boolean isRemove = false;

            for(PetScoreListRecord record : list.getRecords()) {
                if (record.getMarshaldata().getUniquepetid() == uniqPetid) {
                    isRemove = true;
                    break;
                }

                ++index;
            }

            if (isRemove) {
                list.getRecords().remove(index);
                RoleRankNotifyTimeInfo roleInfo = Roleranknotifytime.get(this.roleId);
                if (roleInfo == null) {
                    roleInfo = Pod.newRoleRankNotifyTimeInfo();
                    roleInfo.getLasttime().put(RankType.ROLE_ZONGHE_RANK, 0L);
                    roleInfo.getLasttime().put(RankType.PET_GRADE_RANK, 0L);
                }

                if (roleInfo.getLasttime().get(RankType.PET_GRADE_RANK) == null) {
                    roleInfo.getLasttime().put(RankType.PET_GRADE_RANK, 0L);
                }

                List<String> param = new ArrayList<>();
                param.add(RankListManager.getInstance().getNameByType(RankType.PET_GRADE_RANK));
                if (!DateValidate.inTheSameDay(System.currentTimeMillis(), roleInfo.getLasttime().get(RankType.PET_GRADE_RANK))) {
                    roleInfo.getLasttime().put(RankType.PET_GRADE_RANK, System.currentTimeMillis());
                }
            }

        }
    }

    public boolean petIsFightPet(int petKey) {
        if (this.petColumnId != PetColumnTypes.PET) {
            return false;
        } else {
            PetInfo petInfo = this.getPetInfo(petKey);
            if (null == petInfo) {
                return false;
            } else {
                Properties prop = xtable.Properties.select(this.roleId);
                return prop != null && prop.getFightpetkey() == petInfo.getKey();
            }
        }
    }

    public boolean petNotFightPet(int petId) {
        Properties prop = xtable.Properties.select(this.roleId);
        if (null == prop) {
            return false;
        } else {
            int fightPetKey = prop.getFightpetkey();

            for(PetInfo petInfo : this.getPetsMap().values()) {
                if (null != petInfo && petInfo.getId() == petId && petInfo.getKey() != fightPetKey) {
                    return true;
                }
            }

            return false;
        }
    }

    public boolean petIsShowPet(int petKey) {
        if (this.petColumnId != PetColumnTypes.PET) {
            return false;
        } else {
            PetInfo info = this.getPetInfo(petKey);
            if (null == info) {
                return false;
            } else {
                Properties prop = xtable.Properties.select(this.roleId);
                return prop != null && prop.getShowpetkey() == petKey;
            }
        }
    }

    public static int doMovePet(PetColumn srcCol, int srcKey, PetColumn dstCol) {
        if (!srcCol.readOnly && !dstCol.readOnly) {
            if (srcCol.roleId != dstCol.roleId) {
                throw new RuntimeException("Error argument!!");
            } else if (srcCol.petColumnId == dstCol.petColumnId) {
                return PetError.WrongDstCol;
            } else if (srcCol.petIsShowPet(srcKey)) {
                return PetError.ShowPetCantMoveErr;
            } else if (srcCol.petIsFightPet(srcKey)) {
                return PetError.FightPetCantMoveErr;
            } else {
                PetInfo srcPetInfo = srcCol.getPetInfo(srcKey);
                if (null == srcPetInfo) {
                    return PetError.KeyNotFound;
                } else if (dstCol.size() >= dstCol.getCapacity()) {
                    return PetError.PetcolumnFull;
                } else {
                    int ret = srcCol.removePet(srcKey, REMOVE_REASON_MOVE_BETWEEN_BAGS, 0);
                    if (ret == 0) {
                        ret = dstCol.add(srcPetInfo, ADD_REASON_MOVE_BETWEEN_BAGS);
                    }

                    return ret > 0 ? ret : PetError.UnkownError;
                }
            }
        } else {
            throw new RuntimeException("Error argument!!");
        }
    }

    public int addPetByID(int id, boolean bind, int reason) {
        PetAttr petAttr = Module.getInstance().getPetManager().getAttr(id);
        return petAttr != null
                ? this.addpet(id, petAttr.getInitlevel(), petAttr.getKind(), null, reason, PetColour.WHITE, bind, null)
                : -1;
    }

    public int addpet(int id, int level, int type, List<Integer> skills, int reason, int starId, boolean bind, Map<Integer, Object> initAttrs) {
        PetInfo petInfo = createPet(this.roleId, id, level, skills, type, starId, bind, initAttrs, -1L);
        return null == petInfo ? -1 : this.add(petInfo, reason);
    }

    public ArrayList<PetBean> getAllProtocolPets() {
        if (null != this.pets && null != this.pets.getPetmap()) {
            ArrayList<PetBean> vecs = new ArrayList<>();

            for(PetInfo petInfo : this.pets.getPetmap().values()) {
                fire.pb.pet.Pet pet = fire.pb.pet.Pet.getPet(petInfo);
                if (pet != null) {
                    vecs.add(pet.getProtocolPet());
                }
            }

            return vecs;
        } else {
            return null;
        }
    }

    public PetInfo getPetInfo(int key) {
        Map<Integer, PetInfo> petMap = this.pets.getPetmap();
        if (null == petMap) {
            return null;
        } else {
            PetInfo petInfo = petMap.get(key);
            return petInfo;
        }
    }

    public boolean addShowSkillBuff() {
        if (this.readOnly) {
            return false;
        } else if (this.petColumnId != 1) {
            return false;
        } else {
            Properties prop = xtable.Properties.select(this.roleId);
            int petKey = prop.getShowpetkey();
            return petKey >= 0 && this.addShowSkillBuff(this.getPet(petKey));
        }
    }

    private boolean addShowSkillBuff(fire.pb.pet.Pet pet) {
        if (pet == null) {
            return false;
        } else {
            ConstantlyBuff buff = pet.getShowSkillBuff(pet.getBattleskills());
            if (buff == null) {
                return false;
            } else {
                BuffAgent buffAgent = new BuffRoleImpl(this.roleId);
                buffAgent.addCBuff(buff);
                return true;
            }
        }
    }

    public boolean removeShowSkillBuff() {
        if (this.readOnly) {
            return false;
        } else {
            BuffAgent buffAgent = new BuffRoleImpl(this.roleId);
            Result result = buffAgent.removeCBuff(500214);
            return result != null && result.isSuccess();
        }
    }

    public boolean addSkill(int petkey, int skillid, int skillExp, int skillType) {
        if (this.readOnly) {
            return false;
        } else {
            fire.pb.pet.Pet pet = this.getPet(petkey);
            if (pet == null) {
                return false;
            } else if (pet.hasAnySkill(skillid)) {
                return false;
            } else {
                return pet.addSkill(skillid, -1L, skillExp, skillType);
            }
        }
    }

    public boolean modPetName(int petKey, String name) {
        if (this.readOnly) {
            return false;
        } else if (null != name && this.petColumnId == 1) {
            PetInfo petInfo = this.getPetInfo(petKey);
            if (null == petInfo) {
                return false;
            } else if (petInfo.getName().equals(name)) {
                return false;
            } else {
                String oldName = petInfo.getName();
                petInfo.setName(name);
                SModPetName sendName = new SModPetName(this.roleId, petKey, name);
                Procedure.psendWhileCommit(this.roleId, sendName);
                Properties prop = xtable.Properties.get(this.roleId);
                if (prop == null) {
                    return false;
                } else {
                    if (prop.getShowpetkey() == petKey) {
                        GNotifyMapPetInfo send = new GNotifyMapPetInfo(this.roleId, fire.pb.pet.Pet.getPet(petInfo).getShowPetInfo());
                        GsClient.pSendWhileCommit(send);
                    }

                    Procedure.pexecuteWhileCommit(new PRankInsertPetChangeName(petInfo.getUniqid(), true));
                    Procedure.pexecuteWhileCommit(new PRoleZongheRankProc(petInfo.getOwnerid()));
                    if (Module.logger.isDebugEnabled()) {
                        Module.logger.debug("[PModPetName] roleId:" + this.roleId + " petKey:" + petKey + " uniqId:" + petInfo.getUniqid() + " petId:" + petInfo.getId() + " oldName:" + oldName + " newName:" + name);
                    }

                    return true;
                }
            }
        } else {
            return false;
        }
    }

    public boolean checkCanFreePet(int petKey) {
        if (this.readOnly) {
            return false;
        } else if (this.petColumnId != PetColumnTypes.PET) {
            return false;
        } else {
            fire.pb.pet.Pet pet = this.getPet(petKey);
            if (null == pet) {
                return false;
            } else if (pet.isLocked() != -1L) {
                return false;
            } else if (pet.getKind() == PetTypeEnum.SACREDANIMAL) {
                return false;
            } else {
                SPetError sendErr = new SPetError();
                if (this.petIsShowPet(petKey)) {
                    sendErr.peterror = PetError.ShowPetCantFree;
                    Procedure.psendWhileRollback(this.roleId, sendErr);
                    return false;
                } else if (this.petIsFightPet(petKey)) {
                    sendErr.peterror = PetError.FightPetCantFree;
                    Procedure.psendWhileRollback(this.roleId, sendErr);
                    return false;
                } else {
                    return true;
                }
            }
        }
    }

    public boolean freePet(int petKey) {
        fire.pb.pet.Pet pet = this.getPet(petKey);
        if (pet == null) {
            return false;
        } else if (!this.checkCanFreePet(petKey)) {
            return false;
        } else if (GoodsSafeLocksUtils.checkLockStatus(this.roleId, pet.getPetInfo())) {
            return false;
        } else {
            int removedPetTScore = pet.getPetAttr().getTreasureScore();
            int removedPetScore = pet.getPetInfo().getPetscore();
            long uniqid = pet.getPetInfo().getUniqid();
            if (this.removePet(petKey, REMOVE_REASON_RELEASE, 0) == 0) {
                MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 142258, null);
                this.writeYYLogger(pet.getPetAttr().getId(), removedPetTScore, removedPetScore, uniqid);
                GoodsSafeLocksUtils.doClearDataWhileCommit(this.roleId);
                return true;
            } else {
                return false;
            }
        }
    }

    private void writeYYLogger(int petId, int removedPetTScore, int removedPetScore, long uniqid) {
        int isTrea = removedPetTScore > removedPetScore ? 0 : 1;
        YYLogger.petFreeLog(this.roleId, petId, isTrea, uniqid);
    }

    public static int moveBetweenRolePetColumn(PetColumn srcCol, PetColumn dstCol, int petKey) {
        fire.pb.pet.Pet pet = srcCol.getPet(petKey);
        if (pet == null) {
            return -1;
        } else {
            PropRole prop = new PropRole(dstCol.roleId, false);
            if (prop.getLevel() < pet.getTakeLevel()) {
                return -1;
            } else if (srcCol.petIsFightPet(petKey)) {
                return -1;
            } else {
                PetInfo petInfo = pet.copyPetInfoBean();
                if (null == petInfo) {
                    return -1;
                } else {
                    return srcCol.removePet(petKey, REMOVE_REASON_MOVE_BETWEEN_ROLES) == 0
                            && dstCol.add(petInfo, ADD_REASON_MOVE_BETWEEN_ROLES) > 0 ? 0 : -1;
                }
            }
        }
    }

    public static PetColumnConfig getPetColumnConfig(int petColumnId) {
        return ConfigManager.getInstance().getConf(PetColumnConfig.class).get(petColumnId);
    }

    public int getPetColumnType() {
        return this.petColumnId;
    }

    public fire.pb.pet.Pet getPet(int petkey) {
        return fire.pb.pet.Pet.getPet(this.roleId, this, petkey, this.readOnly);
    }

    public List<fire.pb.pet.Pet> getPets() {
        List<fire.pb.pet.Pet> list = new LinkedList<>();

        for(int petKey : this.pets.getPetmap().keySet()) {
            list.add(fire.pb.pet.Pet.getPet(this.roleId, this, petKey, this.readOnly));
        }

        return list;
    }

    public static List<fire.pb.pet.Pet> getPetsByColumnType(long roleId, int columnType, boolean readOnly) {
        try {
            List<fire.pb.pet.Pet> pets = new LinkedList<>();
            switch (columnType) {
                case -1:
                case 0:
                    int column = columnType == -1 ? PetColumnTypes.PET : PetColumnTypes.DEPOT;
                    PetColumn petCol = new PetColumn(roleId, column, readOnly);
                    pets.addAll(petCol.getPets());
                default:
                    return pets;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.buff.Module;
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import fire.pb.tel.utils.GoodsSafeLocksUtils;
import fire.pb.util.DateValidate;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.PetSellCount;
import xbean.Pod;
import xtable.Properties;
import xtable.Rolepetsellcount;

public class PPetSell extends Procedure {
    private final long roleId;
    private final int petKey;

    public PPetSell(long roleId, int petKey) {
        this.roleId = roleId;
        this.petKey = petKey;
    }

    public boolean process() {
        if (Module.existState(this.roleId, 507004)) {
            return false;
        } else {
            Integer fightPetKey = Properties.selectFightpetkey(this.roleId);
            if (fightPetKey == this.petKey) {
                return false;
            } else {
                PetColumn petCol = new PetColumn(this.roleId, 1, false);
                Pet pet = petCol.getPet(this.petKey);
                if (null == pet) {
                    return false;
                } else if (GoodsSafeLocksUtils.checkLockStatus(this.roleId, pet.getPetInfo())) {
                    return false;
                } else if (pet.isLocked() != -1L) {
                    MessageMgr.psendMsgNotify(this.roleId, Pet.PET_LOCK_ERROR_MSG, (List)null);
                    return true;
                } else if (pet.getKind() != 1) {
                    return false;
                } else {
                    PetSellCount petSellCount = Rolepetsellcount.get(this.roleId);
                    if (petSellCount == null) {
                        petSellCount = Pod.newPetSellCount();
                        Rolepetsellcount.insert(this.roleId, petSellCount);
                    }

                    if (!this.checkCount(petSellCount)) {
                        MessageMgr.psendMsgNotify(this.roleId, 160405, (List)null);
                        return false;
                    } else if (!this.award(pet.getBaseId())) {
                        return false;
                    } else {
                        this.addCount(petSellCount);
                        if (petCol.removePet(pet.getPetkey(), 6) != 0) {
                            return false;
                        } else {
                            if (fire.pb.pet.Module.logger.isInfoEnabled()) {
                                long resetTime = petSellCount.getResettime();
                                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                                String strTime = resetTime > 0L ? dateFormat.format(resetTime) : "0";
                                fire.pb.pet.Module.logger.info("[PPetSell] roleId:" + this.roleId + " petKey:" + this.petKey + " uniqId:" + pet.getUniqueId() + " petId:" + pet.getBaseId() + " petSellCount:" + petSellCount.getCount() + " resetTime:" + strTime);
                            }

                            GoodsSafeLocksUtils.doClearDataWhileCommit(this.roleId);
                            return true;
                        }
                    }
                }
            }
        }
    }

    private boolean checkCount(PetSellCount petSellCount) {
        long now = System.currentTimeMillis();
        if (!DateValidate.inTheSameDay(now, petSellCount.getResettime())) {
            petSellCount.setCount(0);
            petSellCount.setResettime(now);
        }

        return petSellCount.getCount() < 10;
    }

    private void addCount(PetSellCount petSellCount) {
        petSellCount.setCount(petSellCount.getCount() + 1);
    }

    private boolean award(int petId) {
        int money = 0;
        Map<Integer, PetAttr> mapConfig = ConfigManager.getInstance().getConf(PetAttr.class);
        if (mapConfig != null) {
            for(PetAttr conf : mapConfig.values()) {
                if (conf.getId() == petId) {
                    if (conf.getSellPrice() > 0) {
                        money = conf.getSellPrice();
                    }
                    break;
                }
            }
        }

        if (money != 0) {
            Pack bag = new Pack(this.roleId, false);
            if (bag.addSysMoney((long)money, "Pet sell", YYLoggerTuJingEnum.tujing_Value_peiyang, 0) != (long)money) {
                return false;
            }
        }

        MessageMgr.psendMsgNotify(this.roleId, 160049, MessageMgr.getStringList(new Object[]{money}));
        return true;
    }
}

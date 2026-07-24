//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.effect.PetImpl;
import fire.pb.effect.Role;
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;

public class PPetResetPoint extends Procedure {
    private final long roleId;
    private final int petKey;

    public PPetResetPoint(long roleId, int petKey) {
        this.roleId = roleId;
        this.petKey = petKey;
    }

    public boolean process() {
        if (Helper.isPetInBattle(this.roleId, this.petKey)) {
            return false;
        } else {
            PetColumn petCol = new PetColumn(this.roleId, 1, false);
            Pet pet = petCol.getPet(this.petKey);
            if (null == pet) {
                return false;
            } else if (pet.isLocked() != -1L) {
                MessageMgr.psendMsgNotify(this.roleId, Pet.PET_LOCK_ERROR_MSG, (List)null);
                return true;
            } else if (!this.cost(pet.getPetInfo().getPointresetcount() + 1)) {
                return false;
            } else {
                pet.getPetInfo().setPointresetcount(pet.getPetInfo().getPointresetcount() + 1);
                Role epet = new PetImpl(this.roleId, this.petKey);
                Map<Integer, Float> res = epet.resetPoints();
                if (res != null) {
                    SRefreshPetInfo refresh = new SRefreshPetInfo(pet.getProtocolPet());
                    psendWhileCommit(this.roleId, refresh);
                    MessageMgr.psendMsgNotify(this.roleId, 150044, (List)null);
                }

                if (Module.logger.isInfoEnabled()) {
                    Module.logger.info("[PPetResetPoint] roleId:" + this.roleId + " petKey:" + this.petKey + " uniqId:" + pet.getUniqueId() + " petId:" + pet.getBaseId() + " pointResetCount:" + pet.getPetInfo().getPointresetcount());
                }

                return true;
            }
        }
    }

    private boolean cost(int count) {
        int money = 0;
        Map<Integer, PetResetPointConfig> mapConfig = ConfigManager.getInstance().getConf(PetResetPointConfig.class);
        if (mapConfig != null) {
            for(PetResetPointConfig conf : mapConfig.values()) {
                money = conf.getCost();
                if (conf.getId() == count) {
                    break;
                }
            }
        }

        if (money != 0) {
            Pack bag = new Pack(this.roleId, false);
            if (bag.subMoney((long)(-money), "Pet reset point", YYLoggerTuJingEnum.tujing_Value_peiyang, 0) != (long)(-money)) {
                return false;
            }
        }

        return true;
    }
}

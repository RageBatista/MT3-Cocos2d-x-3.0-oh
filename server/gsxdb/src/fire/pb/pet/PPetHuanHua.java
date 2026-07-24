//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import java.util.List;
import mkdb.Procedure;
import xbean.PetInfo;
import xtable.Properties;

public class PPetHuanHua extends Procedure {
    private final long roleId;
    private final int petKey;
    private final int resultkey;

    public PPetHuanHua(long roleId, int petKey, int resultkey) {
        this.roleId = roleId;
        this.petKey = petKey;
        this.resultkey = resultkey;
    }

    public boolean process() {
        Integer fightPetKey = Properties.selectFightpetkey(this.roleId);
        if (fightPetKey == this.petKey) {
            return false;
        } else {
            PetColumn petCol = new PetColumn(this.roleId, 1, false);
            Pet pet = petCol.getPet(this.petKey);
            if (null == pet) {
                return false;
            } else if (pet.isLocked() != -1L) {
                MessageMgr.psendMsgNotify(this.roleId, Pet.PET_LOCK_ERROR_MSG, (List)null);
                return true;
            } else {
                PetAttr petAttr1 = (PetAttr)ConfigManager.getInstance().getConf(PetAttr.class).get(this.resultkey);
                if (petAttr1.needitemid > 0 && petAttr1.needitemnum > 0) {
                    Pack bag = new Pack(this.roleId, false);
                    if (bag.getBagItemNum(petAttr1.needitemid) < petAttr1.needitemnum) {
                        return false;
                    }

                    int num = bag.removeItemById(petAttr1.needitemid, petAttr1.needitemnum, YYLoggerTuJingEnum.tujing_Value_xilian, 0, "Pet wash cost");
                    if (num != petAttr1.needitemnum) {
                        return false;
                    }
                }

                PetColumn petColumn = new PetColumn(this.roleId, 1, false);
                PetInfo petInfo = petColumn.getPetInfo(this.petKey);
                if (petInfo.getPetid() <= 0) {
                    petInfo.setPetid(petInfo.getId());
                }

                petInfo.setId(this.resultkey);
                petInfo.setKind(petAttr1.getKind());
                if (petAttr1.getKind() == 4) {
                    petInfo.setLife(99999);
                } else {
                    petInfo.setLife(99999);
                }

                SRefreshPetInfo refresh = new SRefreshPetInfo(pet.getProtocolPet());
                psendWhileCommit(this.roleId, refresh);
                return true;
            }
        }
    }
}

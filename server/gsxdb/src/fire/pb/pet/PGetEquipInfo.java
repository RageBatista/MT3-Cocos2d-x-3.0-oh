//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.pb.talk.MessageMgr;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.PetEquipItem;
import xbean.PetInfo;

public class PGetEquipInfo extends Procedure {
    private long roleId;
    private int petKey;
    private int pos;

    public PGetEquipInfo(long roleId, int petKey, int pos) {
        this.roleId = roleId;
        this.petKey = petKey;
        this.pos = pos;
    }

    public boolean process() {
        PetColumn petCol = new PetColumn(this.roleId, 1, false);
        Pet pet = petCol.getPet(this.petKey);
        if (pet == null) {
            Module.logger.error("[PGetEquipInfo] petKey=" + this.petKey + " non-existent.");
            return true;
        } else {
            PetInfo petInfo = pet.getPetInfo();
            if (pet.isLocked() != -1L) {
                MessageMgr.psendMsgNotify(this.roleId, Pet.PET_LOCK_ERROR_MSG, (List)null);
                return true;
            } else {
                Map<Integer, Integer> pro = null;
                int itemid = 0;
                int itemid1 = 0;

                for(PetEquipItem petEquipItem : petInfo.getPetequipbag()) {
                    if (petEquipItem.getPos() == this.pos) {
                        itemid = petEquipItem.getItemid();
                        itemid1 = petEquipItem.getTaozhuangid();
                        pro = petEquipItem.getPro();
                    }
                }

                SSetPetEquipInfo sSetPetEquipInfo = new SSetPetEquipInfo();
                sSetPetEquipInfo.petkey = this.petKey;
                sSetPetEquipInfo.itemid = itemid;
                sSetPetEquipInfo.taozhuangid = itemid1;
                sSetPetEquipInfo.petequipinfo.putAll(pro);
                Procedure.psendWhileCommit(this.roleId, sSetPetEquipInfo);
                return true;
            }
        }
    }
}

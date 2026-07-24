//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.pb.skill.Module;
import fire.pb.talk.MessageMgr;
import java.util.List;
import mkdb.Procedure;
import xbean.PetEquipItem;
import xbean.PetInfo;

public class PGetPetEquipList extends Procedure {
    private long roleId;
    private int petKey;

    public PGetPetEquipList(long roleId, int petKey) {
        this.roleId = roleId;
        this.petKey = petKey;
    }

    public boolean process() {
        PetColumn petCol = new PetColumn(this.roleId, 1, false);
        Pet pet = petCol.getPet(this.petKey);
        if (pet == null) {
            Module.logger.error("[PGetPetEquipList] petKey=" + this.petKey + " non-existent.");
            return true;
        } else {
            PetInfo petInfo = pet.getPetInfo();
            if (pet.isLocked() != -1L) {
                MessageMgr.psendMsgNotify(this.roleId, Pet.PET_LOCK_ERROR_MSG, (List)null);
                return true;
            } else {
                int xiangquanid = 0;
                int hujiaid = 0;
                int hufuid = 0;
                int tz1 = 0;
                int tz2 = 0;
                int tz3 = 0;

                for(PetEquipItem petEquipItem : petInfo.getPetequipbag()) {
                    if (petEquipItem.getPos() == 1) {
                        xiangquanid = petEquipItem.getItemid();
                        tz1 = petEquipItem.getTaozhuangid();
                    }

                    if (petEquipItem.getPos() == 2) {
                        hujiaid = petEquipItem.getItemid();
                        tz2 = petEquipItem.getTaozhuangid();
                    }

                    if (petEquipItem.getPos() == 3) {
                        hufuid = petEquipItem.getItemid();
                        tz3 = petEquipItem.getTaozhuangid();
                    }
                }

                if (xiangquanid != 0 && hujiaid != 0 && hufuid != 0) {
                    if (tz1 == tz2 && tz2 == tz3 && tz1 == tz3) {
                        PPetEquipbyPet.addtaozhuang(this.roleId, this.petKey, tz1, false, petInfo);
                    }

                    if (tz1 != tz2 || tz2 != tz3 || tz1 != tz3) {
                        PPetEquipbyPet.deltaozhuang(this.roleId, this.petKey, tz1, tz2, tz3, false, petInfo);
                    }
                }

                SSetPetEquipList sSetPetEquipList = new SSetPetEquipList();
                sSetPetEquipList.petkey = this.petKey;
                sSetPetEquipList.xiangquanid = xiangquanid;
                sSetPetEquipList.hujiaid = hujiaid;
                sSetPetEquipList.hufuid = hufuid;
                Procedure.psendWhileCommit(this.roleId, sSetPetEquipList);
                return true;
            }
        }
    }
}

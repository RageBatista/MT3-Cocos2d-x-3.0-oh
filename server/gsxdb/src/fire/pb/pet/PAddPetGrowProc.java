//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import mkdb.Procedure;
import xbean.PetInfo;
import xbean.Properties;

public class PAddPetGrowProc extends Procedure {
    private final long roleId;
    private final int petKey;
    private final int addGrow;

    public PAddPetGrowProc(long roleId, int petKey, int addGrow) {
        this.roleId = roleId;
        this.petKey = petKey;
        this.addGrow = addGrow;
    }

    public boolean process() {
        if (this.addGrow == 0) {
            return false;
        } else {
            Properties prop = xtable.Properties.get(this.roleId);
            if (null == prop) {
                return false;
            } else {
                PetColumn petColumn = new PetColumn(this.roleId, 1, false);
                PetInfo petInfo = petColumn.getPetInfo(this.petKey);
                if (null == petInfo) {
                    return false;
                } else {
                    petInfo.setGrowrate(this.addGrow);
                    Pet pet = petColumn.getPet(this.petKey);
                    SRefreshPetInfo refreshMsg = new SRefreshPetInfo(pet.getProtocolPet());
                    Procedure.psendWhileCommit(this.roleId, refreshMsg);
                    return true;
                }
            }
        }
    }
}

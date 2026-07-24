//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.pb.attr.SRefreshPetData;
import fire.pb.effect.PetImpl;
import fire.pb.effect.Role;
import java.util.HashMap;
import mkdb.Procedure;
import xbean.PetInfo;
import xbean.Properties;

public class PAddPetMPProc extends Procedure {
    private final long roleId;
    private final int petKey;
    private final long addMp;

    public PAddPetMPProc(long roleId, int petKey, long addMp) {
        this.roleId = roleId;
        this.petKey = petKey;
        this.addMp = addMp;
    }

    public boolean process() {
        if (this.addMp == 0L) {
            return false;
        } else {
            Properties prop = xtable.Properties.get(this.roleId);
            if (null == prop) {
                return false;
            } else {
                PetColumn petCol = new PetColumn(this.roleId, 1, false);
                PetInfo petInfo = petCol.getPetInfo(this.petKey);
                if (null == petInfo) {
                    return false;
                } else {
                    HashMap<Integer, Float> petAttr = new HashMap();
                    Role petImpl = new PetImpl(this.roleId, this.petKey);
                    int tmp = petImpl.addMp((int)this.addMp);
                    if (tmp != 0) {
                        petAttr.put(100, (float)petImpl.getMp());
                        SRefreshPetData refrenshData = new SRefreshPetData(1, this.petKey, petAttr);
                        psendWhileCommit(this.roleId, refrenshData);
                        return true;
                    } else {
                        return false;
                    }
                }
            }
        }
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.msp.move.GNotifyMapPetInfo;
import fire.pb.GsClient;
import mkdb.Procedure;
import xbean.Properties;

public class PShowPetProc extends Procedure {
    private final long roleId;
    private final int petKey;

    PShowPetProc(long roleId, int petKey) {
        this.roleId = roleId;
        this.petKey = petKey;
    }

    public boolean process() {
        Properties prop = xtable.Properties.get(this.roleId);
        if (null == prop) {
            return false;
        } else if (prop.getShowpetkey() == this.petKey) {
            return false;
        } else {
            PetColumn petCol = new PetColumn(this.roleId, 1, false);
            Pet pet = petCol.getPet(this.petKey);
            if (pet == null) {
                return false;
            } else {
                petCol.removeShowSkillBuff();
                prop.setShowpetkey(this.petKey);
                petCol.addShowSkillBuff();
                GNotifyMapPetInfo send = new GNotifyMapPetInfo(this.roleId, pet.getShowPetInfo());
                GsClient.pSendWhileCommit(send);
                return true;
            }
        }
    }
}

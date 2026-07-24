//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.msp.move.GNotifyMapPetInfo;
import fire.pb.GsClient;
import mkdb.Procedure;
import xbean.Properties;

public class PShowPetOffProc extends Procedure {
    private final long roleId;

    public PShowPetOffProc(long roleId) {
        this.roleId = roleId;
    }

    public boolean process() {
        Properties prop = xtable.Properties.get(this.roleId);
        if (null != prop && prop.getShowpetkey() >= 0) {
            prop.setShowpetkey(-1);
            PetColumn petCol = new PetColumn(this.roleId, 1, false);
            petCol.removeShowSkillBuff();
            GNotifyMapPetInfo send = new GNotifyMapPetInfo();
            send.roleid = this.roleId;
            GsClient.pSendWhileCommit(send);
            return true;
        } else {
            return false;
        }
    }
}

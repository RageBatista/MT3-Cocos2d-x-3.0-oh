//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import mkdb.Procedure;
import xbean.PetInfo;

public class PPetSetAutoAddPointProc extends Procedure {
    private final long roleId;
    private final int petKey;
    private int cons;
    private int iq;
    private int str;
    private int endu;
    private int agi;

    public PPetSetAutoAddPointProc(long roleId, int petKey, int str, int iq, int cons, int endu, int agi) {
        this.roleId = roleId;
        this.petKey = petKey;
        this.cons = cons;
        this.iq = iq;
        this.str = str;
        this.endu = endu;
        this.agi = agi;
    }

    public boolean process() {
        int sum = this.cons + this.iq + this.str + this.endu + this.agi;
        if (sum >= 0 && sum <= 5 && this.cons >= 0 && this.cons <= 5 && this.iq >= 0 && this.iq <= 5 && this.str >= 0 && this.str <= 5 && this.endu >= 0 && this.endu <= 5 && this.agi >= 0 && this.agi <= 5) {
            PetColumn petCol = new PetColumn(this.roleId, 1, false);
            PetInfo petInfo = petCol.getPetInfo(this.petKey);
            if (petInfo == null) {
                return false;
            } else {
                petInfo.setAutoaddcons(this.cons);
                petInfo.setAutoaddiq(this.iq);
                petInfo.setAutoaddstr(this.str);
                petInfo.setAutoaddendu(this.endu);
                petInfo.setAutoaddagi(this.agi);
                SPetSetAutoAddPoint send = new SPetSetAutoAddPoint(this.petKey, this.str, this.iq, this.cons, this.endu, this.agi);
                psendWhileCommit(this.roleId, send);
                if (Module.logger.isDebugEnabled()) {
                    Module.logger.debug("[PPetSetAutoAddPointProc] roleId:" + this.roleId + " petKey:" + this.petKey + " uniqId:" + petInfo.getUniqid() + " petId:" + petInfo.getId() + " cons:" + this.cons + " iq:" + this.iq + " str:" + this.str + " endu:" + this.endu + " agi:" + this.agi + " sum:" + sum);
                }

                return true;
            }
        } else {
            return false;
        }
    }
}

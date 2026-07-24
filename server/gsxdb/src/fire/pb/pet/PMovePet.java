//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import mkdb.Procedure;

public class PMovePet extends Procedure {
    private final int srcCol;
    private final int srcKey;
    private final int dstCol;
    private final long roleId;

    PMovePet(int srcCol, int srcKey, int dstCol, long npcKey, long roleId) {
        this.srcCol = srcCol;
        this.srcKey = srcKey;
        this.dstCol = dstCol;
        this.roleId = roleId;
    }

    public boolean process() {
        PetColumn srcPetCol = new PetColumn(this.roleId, this.srcCol, false);
        if (this.srcCol == this.dstCol) {
            return false;
        } else {
            PetColumn dstPetCol = new PetColumn(this.roleId, this.dstCol, false);
            int ret = PetColumn.doMovePet(srcPetCol, this.srcKey, dstPetCol);
            if (ret < 0) {
                SPetError errosend = new SPetError(ret);
                psendWhileRollback(this.roleId, errosend);
            }

            return ret >= 0;
        }
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import java.util.List;
import mkdb.Procedure;

public class PFreePet extends Procedure {
    private long roleId;
    private List<Integer> petKeys;

    public PFreePet(long roleId, List<Integer> petKeys) {
        this.roleId = roleId;
        this.petKeys = petKeys;
    }

    public boolean process() {
        PetColumn petCol = new PetColumn(this.roleId, 1, false);
        boolean allFree = true;

        for(int petKey : this.petKeys) {
            if (!Pet.isInBattle(this.roleId, petKey)) {
                return false;
            }

            if (!petCol.freePet(petKey)) {
                allFree = false;
                break;
            }
        }

        return allFree;
    }
}

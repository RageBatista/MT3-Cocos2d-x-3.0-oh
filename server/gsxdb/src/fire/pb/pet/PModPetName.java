//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import mkdb.Procedure;

public class PModPetName extends Procedure {
    private long roleId;
    private int petKey;
    private String name;

    public PModPetName(long roleId, int petKey, String name) {
        this.roleId = roleId;
        this.petKey = petKey;
        this.name = name;
    }

    public boolean process() {
        if (this.roleId >= 0L && this.petKey >= 1 && this.name != null) {
            PetColumn petcol = new PetColumn(this.roleId, 1, false);
            return petcol.modPetName(this.petKey, this.name);
        } else {
            return false;
        }
    }
}

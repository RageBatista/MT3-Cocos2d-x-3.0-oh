//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import java.util.List;
import java.util.Map;
import mkdb.Procedure;

public class PAddPetByPetID extends Procedure {
    private final long roleId;
    private final int petColumnId;
    private final int petId;
    private final int level;
    private int type;
    private int reason;
    private List<Integer> skills = null;
    private int starId = 1;
    private final boolean isBind;

    public PAddPetByPetID(long roleId, int petId, int level, int petColumnId, int type, List<Integer> skills, int reason, int starId, boolean isBind) {
        this.roleId = roleId;
        this.petColumnId = petColumnId;
        this.petId = petId;
        this.level = level;
        this.type = type;
        this.reason = reason;
        this.starId = starId;
        this.skills = skills;
        this.isBind = isBind;
    }

    public PAddPetByPetID(long roleId, int petId, int level, int petColumnId, int type, int reason, int starId, boolean isBind) {
        this.roleId = roleId;
        this.petColumnId = petColumnId;
        this.petId = petId;
        this.level = level;
        this.type = type;
        this.reason = reason;
        this.starId = starId;
        this.isBind = isBind;
    }

    public boolean process() {
        PetColumn petCol = new PetColumn(this.roleId, this.petColumnId, false);
        int petkey = petCol.addpet(this.petId, this.level, this.type, this.skills, this.reason, this.starId, this.isBind, (Map)null);
        return petkey >= 0;
    }
}

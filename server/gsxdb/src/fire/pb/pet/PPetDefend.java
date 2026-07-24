//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.pb.course.CourseManager;
import fire.pb.talk.MessageMgr;
import java.util.List;
import mkdb.Procedure;

public class PPetDefend extends Procedure {
    private final long roleId;
    private final int petKey;
    private final int petDefend;

    public PPetDefend(long roleId, int petKey, int petDefend) {
        this.roleId = roleId;
        this.petKey = petKey;
        this.petDefend = petDefend;
    }

    public boolean process() {
        if (Helper.isPetInBattle(this.roleId, this.petKey)) {
            return false;
        } else {
            PetColumn petColumn = new PetColumn(this.roleId, 1, false);
            Pet pet = petColumn.getPet(this.petKey);
            if (null == pet) {
                return false;
            } else if (pet.isLocked() != -1L) {
                MessageMgr.psendMsgNotify(this.roleId, Pet.PET_LOCK_ERROR_MSG, (List)null);
                return true;
            } else {
                pet.getPetInfo().setBorndefendapt(this.petDefend);
                pet.updatePetScoreWhileChange();
                CourseManager.checkAchieveCourse(this.roleId, 31, pet.getPetInfo().getPetscore());
                SRefreshPetInfo refreshMsg = new SRefreshPetInfo(pet.getProtocolPet());
                psendWhileCommit(this.roleId, refreshMsg);
                return true;
            }
        }
    }
}

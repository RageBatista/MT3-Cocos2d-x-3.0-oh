//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.pb.course.CourseManager;
import fire.pb.talk.MessageMgr;
import java.util.List;
import mkdb.Procedure;

public class PPetSpeed extends Procedure {
    private final long roleId;
    private final int petKey;
    private final int petSpeed;

    public PPetSpeed(long var1, int var3, int var4) {
        this.roleId = var1;
        this.petKey = var3;
        this.petSpeed = var4;
    }

    public boolean process() {
        if (Helper.isPetInBattle(this.roleId, this.petKey)) {
            return false;
        } else {
            PetColumn var1 = new PetColumn(this.roleId, 1, false);
            Pet var2 = var1.getPet(this.petKey);
            if (null == var2) {
                return false;
            } else if (var2.isLocked() != -1L) {
                MessageMgr.psendMsgNotify(this.roleId, Pet.PET_LOCK_ERROR_MSG, (List)null);
                return true;
            } else {
                var2.getPetInfo().setBornspeedapt(this.petSpeed);
                var2.updatePetScoreWhileChange();
                CourseManager.checkAchieveCourse(this.roleId, 31, var2.getPetInfo().getPetscore());
                SRefreshPetInfo var3 = new SRefreshPetInfo(var2.getProtocolPet());
                psendWhileCommit(this.roleId, var3);
                return true;
            }
        }
    }
}

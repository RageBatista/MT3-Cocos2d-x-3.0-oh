//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.pb.course.CourseManager;
import fire.pb.talk.MessageMgr;
import java.util.List;
import mkdb.Procedure;

public class PPetFull extends Procedure {
    private final long roleId;
    private final int petKey;

    public PPetFull(long roleId, int petKey) {
        this.roleId = roleId;
        this.petKey = petKey;
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
                int maxAttack = pet.getPetAttr().getAttackaptmax();
                int maxDefend = pet.getPetAttr().getDefendaptmax();
                int maxMagic = pet.getPetAttr().getMagicaptmax();
                int maxPhyForce = pet.getPetAttr().getPhyforceaptmax();
                int maxSpeed = pet.getPetAttr().getSpeedaptmax();
                pet.getPetInfo().setBornattackapt(maxAttack);
                pet.getPetInfo().setBorndefendapt(maxDefend);
                pet.getPetInfo().setBornmagicapt(maxMagic);
                pet.getPetInfo().setBornphyforceapt(maxPhyForce);
                pet.getPetInfo().setBornspeedapt(maxSpeed);
                pet.updatePetScoreWhileChange();
                CourseManager.checkAchieveCourse(this.roleId, 31, pet.getPetInfo().getPetscore());
                SRefreshPetInfo refreshMsg = new SRefreshPetInfo(pet.getProtocolPet());
                psendWhileCommit(this.roleId, refreshMsg);
                return true;
            }
        }
    }
}

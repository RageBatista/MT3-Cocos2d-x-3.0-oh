//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.pb.attr.SRefreshPetData;
import fire.pb.course.CourseManager;
import fire.pb.effect.PetImpl;
import fire.pb.effect.Role;
import java.util.Map;
import mkdb.Procedure;
import xbean.PetInfo;

public class PPetAddPointProc extends Procedure {
    private final long roleId;
    private final int petKey;
    private int cons;
    private int iq;
    private int str;
    private int endu;
    private int agi;

    public PPetAddPointProc(long roleId, int petKey, int cons, int iq, int str, int endu, int agi) {
        this.roleId = roleId;
        this.petKey = petKey;
        this.cons = cons;
        this.iq = iq;
        this.str = str;
        this.endu = endu;
        this.agi = agi;
    }

    public boolean process() {
        int addPoint = this.str + this.iq + this.cons + this.endu + this.agi;
        if (Integer.MAX_VALUE <= addPoint) {
            return false;
        } else if (this.cons >= 0 && this.cons < 1000000 && this.iq >= 0 && this.iq < 1000000 && this.str >= 0 && this.str < 1000000 && this.endu >= 0 && this.endu < 1000000 && this.agi >= 0 && this.agi < 1000000) {
            if (Helper.isPetInBattle(this.roleId, this.petKey)) {
                return false;
            } else {
                PetColumn petCol = new PetColumn(this.roleId, 1, false);
                PetInfo petInfo = petCol.getPetInfo(this.petKey);
                if (petInfo == null) {
                    return false;
                } else {
                    int curPoint = petInfo.getPoint();
                    if (addPoint > curPoint) {
                        return false;
                    } else {
                        Role epet = new PetImpl(this.roleId, this.petKey);
                        Map<Integer, Float> res = epet.addPoints(this.cons, this.str, this.agi, this.endu, this.iq);
                        if (res != null) {
                            SRefreshPetData refresh = new SRefreshPetData();
                            refresh.columnid = 1;
                            refresh.petkey = this.petKey;
                            refresh.datas.putAll(res);
                            psendWhileCommit(this.roleId, refresh);
                            Pet pet = Pet.getPet(petInfo);
                            pet.updatePetScoreWhileChange();
                            CourseManager.checkAchieveCourse(this.roleId, 31, pet.getPetInfo().getPetscore());
                            if (Module.logger.isInfoEnabled()) {
                                Module.logger.info("[PPetAddPointProc] roleId:" + this.roleId + " petKey:" + this.petKey + " uniqId:" + petInfo.getUniqid() + " petId:" + petInfo.getId() + " addStr:" + this.str + " addIq:" + this.iq + " addCons:" + this.cons + " addEndu:" + this.endu + " addAgi:" + this.agi + " newStr:" + pet.getBfp().getStr() + " newIq:" + pet.getBfp().getIq() + " newCons:" + pet.getBfp().getCons() + " newEndu:" + pet.getBfp().getEndu() + " newAgi:" + pet.getBfp().getAgi() + " addPoint:" + addPoint + " oldPoint:" + curPoint + " newPoint:" + petInfo.getPoint());
                            }
                        }

                        return true;
                    }
                }
            }
        } else {
            return false;
        }
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.OctetsStream;
import java.util.HashSet;
import java.util.Set;
import mkdb.Lockeys;
import mkdb.Procedure;
import xbean.DiscardPet;
import xbean.PetInfo;
import xbean.Petrecoverlist;
import xbean.Pod;
import xbean.Properties;
import xbean.UniquePet;
import xtable.Locks;
import xtable.Petrecover;
import xtable.Petrecyclebin;
import xtable.Uniquepets;

public class PRecoverPet extends Procedure {
    private long roleId;
    private final long uniqueId;
    public String resultInfo;

    public PRecoverPet(long roleId, long uniqueId) {
        this.roleId = roleId;
        this.uniqueId = uniqueId;
    }

    protected boolean process() throws Exception {
        long oldOwnerId = Petrecyclebin.selectRoleid(this.uniqueId);
        if (this.roleId <= 0L) {
            this.roleId = oldOwnerId;
        }

        Set<Long> roleIds = new HashSet();
        roleIds.add(this.roleId);
        if (this.roleId != oldOwnerId) {
            roleIds.add(oldOwnerId);
        }

        this.lock(Lockeys.get(Locks.ROLELOCK, roleIds));
        Petrecoverlist petRecoverList = Petrecover.get(oldOwnerId);
        if (petRecoverList == null) {
            this.resultInfo = "roleId:" + this.roleId + " Pet recover not found!";
            return false;
        } else {
            Properties prop = xtable.Properties.select(this.roleId);
            if (prop == null) {
                this.resultInfo = "roleId:" + this.roleId + " Properties not found!";
                return false;
            } else {
                PetColumn petCol = new PetColumn(this.roleId, 1, false);
                UniquePet upet = Pod.newUniquePet();
                upet.setRoleid(this.roleId);
                Uniquepets.add(this.uniqueId, upet);
                DiscardPet discardPet = Petrecyclebin.get(this.uniqueId);
                if (discardPet == null) {
                    this.resultInfo = "uniqueId:" + this.uniqueId + " Recycle bin not found!";
                    return false;
                } else {
                    PetInfo petInfo = Pod.newPetInfo();
                    petInfo.unmarshal(discardPet.getPet().marshal(new OctetsStream()));
                    petInfo.setOwnerid(this.roleId);
                    String petInfoString = "petId:" + petInfo.getId() + " uniqId:" + petInfo.getUniqid() + " petName:" + petInfo.getName() + " petLevel:" + petInfo.getLevel();
                    int petKey = petCol.add(petInfo, 0);
                    if (petKey == -1) {
                        this.resultInfo = petInfoString + " revert to roleId:" + this.roleId + " faild.";
                        return false;
                    } else {
                        Petrecyclebin.remove(this.uniqueId);
                        petRecoverList.getUniqids().remove(this.uniqueId);
                        this.resultInfo = petInfoString + " old roleId:" + discardPet.getRoleid() + " revert to new roleId:" + this.roleId + " success.";
                        if (Module.logger.isInfoEnabled()) {
                            Module.logger.info("[PRecoverPet] roleId:" + this.roleId + " petInfo:" + Helper.toString(petInfo));
                        }

                        return true;
                    }
                }
            }
        }
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import com.locojoy.base.Marshal.OctetsStream;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.item.Pack;
import mkdb.Procedure;
import xbean.DiscardPet;
import xbean.PetInfo;
import xbean.Petrecoverlist;
import xbean.Pod;
import xbean.UniquePet;
import xtable.Petrecover;
import xtable.Petrecyclebin;
import xtable.Uniquepets;

public class PPetRecover extends Procedure {
    public final long roleId;
    public final long uniqId;

    public PPetRecover(long roleId, long uniqId) {
        this.roleId = roleId;
        this.uniqId = uniqId;
    }

    protected boolean process() throws Exception {
        Petrecoverlist petRecoverList = Petrecover.get(this.roleId);
        if (petRecoverList == null) {
            return false;
        } else if (!petRecoverList.getUniqids().contains(this.uniqId)) {
            return false;
        } else {
            PetColumn petCol = new PetColumn(this.roleId, 1, false);
            UniquePet upet = Pod.newUniquePet();
            upet.setRoleid(this.roleId);
            Uniquepets.add(this.uniqId, upet);
            DiscardPet discardPet = Petrecyclebin.get(this.uniqId);
            if (discardPet == null) {
                return false;
            } else {
                PetAttr petAttrConf = Module.getInstance().getPetManager().getAttr(discardPet.getPet().getId());
                if (petAttrConf == null) {
                    return false;
                } else {
                    int cost = petAttrConf.getRecovercost() * -1;
                    Pack bag = new Pack(this.roleId, false);
                    if ((long)cost != bag.subGold((long)cost, "宠物找回", YYLoggerTuJingEnum.tujing_Value_petrecovercost, 0)) {
                        return false;
                    } else {
                        PetInfo petInfo = Pod.newPetInfo();
                        petInfo.unmarshal(discardPet.getPet().marshal(new OctetsStream()));
                        petInfo.setOwnerid(this.roleId);
                        int petKey = petCol.add(petInfo, 0);
                        if (petKey == -1) {
                            return false;
                        } else {
                            Petrecyclebin.remove(this.uniqId);
                            petRecoverList.getUniqids().remove(this.uniqId);
                            SPetRecover send = new SPetRecover();
                            send.petid = petInfo.getId();
                            send.uniqid = this.uniqId;
                            Procedure.psendWhileCommit(this.roleId, send);
                            if (Module.logger.isInfoEnabled()) {
                                Module.logger.info("[PPetRecover] roleId:" + this.roleId + " petInfo:" + Helper.toString(petInfo));
                            }

                            return true;
                        }
                    }
                }
            }
        }
    }
}

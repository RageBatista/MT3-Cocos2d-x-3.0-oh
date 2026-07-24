//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.pb.PropRole;
import fire.pb.event.Poster;
import fire.pb.event.SetFightPetEvent;
import fire.pb.skill.SkillPet;
import mkdb.Procedure;
import xbean.BattleInfo;
import xbean.PetInfo;

public class PSetFightPetProc extends Procedure {
    private final long roleId;
    private final int petKey;
    private final boolean on;
    private boolean isInBattle;

    public PSetFightPetProc(long roleId, int petKey, boolean on) {
        this.isInBattle = false;
        this.roleId = roleId;
        this.petKey = petKey;
        this.on = on;
    }

    public PSetFightPetProc(long roleId, int petKey, boolean on, boolean isInBattle) {
        this(roleId, petKey, on);
        this.isInBattle = isInBattle;
    }

    public boolean process() {
        PropRole prop = new PropRole(this.roleId, false);
        PetColumn petCol = new PetColumn(this.roleId, 1, false);
        if (this.on) {
            PetInfo petInfo = petCol.getPetInfo(this.petKey);
            if (null == petInfo) {
                return false;
            }

            boolean isLifeForever = Module.getInstance().getPetManager().isPetLifeForever(petInfo.getId());
            if (petInfo.getLife() < 50 && !isLifeForever) {
                return false;
            }

            prop.setFightpetkey(this.petKey);
            SSetFightPet send = new SSetFightPet(this.petKey, (byte)(this.isInBattle ? 1 : 0));
            psendWhileCommit(this.roleId, send);
            SkillPet skillAgent = new SkillPet(petInfo, this.roleId);
            skillAgent.updateSkillBuffWhileOut((BattleInfo)null);
            Poster.getPoster().dispatchEvent(new SetFightPetEvent(this.roleId, petInfo.getKey(), petInfo.getId(), Pet.getClour(1)));
        } else {
            if (prop.getFightpetkey() <= 0) {
                return false;
            }

            prop.setFightpetkey(-1);
            SSetFightPetRest send = new SSetFightPetRest((byte)(this.isInBattle ? 1 : 0));
            psendWhileCommit(this.roleId, send);
            Poster.getPoster().dispatchEvent(new SetFightPetEvent(this.roleId, -1, -1, -1));
        }

        if (Module.logger.isDebugEnabled()) {
            Module.logger.debug("[PSetFightPetProc] roleId:" + this.roleId + " petKey:" + this.petKey + " on:" + this.on + " isInBattle:" + this.isInBattle);
        }

        return true;
    }
}

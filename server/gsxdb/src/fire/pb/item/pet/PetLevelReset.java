//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.pet;

import fire.pb.effect.PetImpl;
import fire.pb.effect.Role;
import fire.pb.item.Commontext;
import fire.pb.item.ItemMgr;
import fire.pb.item.PetItem;
import fire.pb.item.Commontext.UseResult;
import fire.pb.pet.Pet;
import fire.pb.pet.PetColumn;
import fire.pb.pet.SRefreshPetExp;
import fire.pb.pet.SRefreshPetInfo;
import fire.pb.talk.MessageMgr;
import fire.pb.talk.STransChatMessageNotify2Client;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.Item;
import xbean.PetInfo;

public class PetLevelReset extends PetItem {
    public PetLevelReset(ItemMgr im, int itemid) {
        super(im, itemid);
    }

    public PetLevelReset(ItemMgr im, Item item) {
        super(im, item);
    }

    public Commontext.UseResult appendToPet(int petkey, int usednum) {
        PetColumn petColumn = new PetColumn(this.getOwnerid(), 1, false);
        Pet pet = petColumn.getPet(petkey);
        if (pet == null) {
            return UseResult.FAIL;
        } else {
            PetInfo petInfo = petColumn.getPetInfo(petkey);
            int level = petInfo.getLevel();
            petInfo.setLevel(0);
            Role epet = new PetImpl(this.roleid, petkey);
            Map<Integer, Float> res = epet.resetPoints();
            if (res != null) {
                int newpoint = petInfo.getPoint() - level * 5 * 2;
                petInfo.setPoint(newpoint);
                SRefreshPetInfo refresh = new SRefreshPetInfo(pet.getProtocolPet());
                Procedure.psendWhileCommit(this.roleid, refresh);
            }

            pet.updatePetScoreWhileChange();
            Procedure.psendWhileCommit(this.roleid, new SRefreshPetExp(petkey, petInfo.getExp()));
            SRefreshPetInfo sRefreshPetInfo = new SRefreshPetInfo(pet.getProtocolPet());
            Procedure.psendWhileCommit(this.roleid, sRefreshPetInfo);
            List<String> params = new ArrayList();
            params.add(pet.getName());
            STransChatMessageNotify2Client msg = MessageMgr.getMsgNotify(191218, 0, params);
            Procedure.psendWhileCommit(this.roleid, msg);
            return UseResult.SUCC;
        }
    }
}

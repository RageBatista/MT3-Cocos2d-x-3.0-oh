//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.pet;

import fire.pb.common.SCommon;
import fire.pb.item.Commontext;
import fire.pb.item.ItemMgr;
import fire.pb.item.PetItem;
import fire.pb.item.Commontext.UseResult;
import fire.pb.main.ConfigManager;
import fire.pb.pet.Pet;
import fire.pb.pet.PetColumn;
import fire.pb.pet.SRefreshPetExp;
import fire.pb.pet.SRefreshPetInfo;
import fire.pb.talk.MessageMgr;
import java.util.Collections;
import java.util.TreeMap;
import mkdb.Procedure;
import mkdb.Transaction;
import xbean.Item;
import xbean.PetInfo;
import xtable.Properties;

public class PetQianYeItem extends PetItem {
    public PetQianYeItem(ItemMgr paramItemMgr, int paramInt) {
        super(paramItemMgr, paramInt);
    }

    public PetQianYeItem(ItemMgr paramItemMgr, Item paramItem) {
        super(paramItemMgr, paramItem);
    }

    public Commontext.UseResult appendToPet(int paramInt1, int paramInt2) {
        PetColumn localPetColumn = new PetColumn(this.getOwnerid(), 1, false);
        Pet localPet = localPetColumn.getPet(paramInt1);
        if (localPet == null) {
            return UseResult.FAIL;
        } else {
            Properties.select(this.roleid);
            PetInfo localPetInfo = localPetColumn.getPetInfo(paramInt1);
            if (localPetInfo.getLevel() <= 0) {
                MessageMgr.sendMsgNotify(this.roleid, 191157, Collections.singletonList(""));
                return UseResult.FAIL;
            } else {
                int i = getGrowrateAddCountLimit();
                if (localPetInfo.getUseqianyecount() >= i) {
                    MessageMgr.sendMsgNotify(this.roleid, 191158, Collections.singletonList(""));
                    return UseResult.FAIL;
                } else {
                    localPetInfo.setLevel(localPetInfo.getLevel() - 20);
                    localPet.updatePetScoreWhileChange();
                    Procedure.psendWhileCommit(this.roleid, new SRefreshPetExp(paramInt1, localPetInfo.getExp()));
                    localPetInfo.setUseqianyecount(localPetInfo.getUseqianyecount() + 1);
                    SRefreshPetInfo localSRefreshPetInfo = new SRefreshPetInfo(localPet.getProtocolPet());
                    Procedure.psendWhileCommit(this.roleid, localSRefreshPetInfo);
                    if (Transaction.current() == null) {
                        MessageMgr.sendMsgNotify(this.roleid, 162199, Collections.singletonList(""));
                    } else {
                        MessageMgr.psendMsgNotifyWhileCommit(this.roleid, 162199, Collections.singletonList(""));
                    }

                    return UseResult.SUCC;
                }
            }
        }
    }

    private static int getGrowrateAddCountLimit() {
        TreeMap localTreeMap = ConfigManager.getInstance().getConf(SCommon.class);
        if (localTreeMap != null) {
            SCommon localSCommon = (SCommon)localTreeMap.get(121);
            if (localSCommon != null) {
                return Integer.parseInt(localSCommon.getValue());
            }
        }

        return 0;
    }
}

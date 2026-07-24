//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.pet;

import fire.pb.attr.SRefreshPetData;
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
import java.util.Arrays;
import java.util.List;
import java.util.TreeMap;
import mkdb.Procedure;
import mkdb.Transaction;
import xbean.Item;
import xbean.PetInfo;
import xtable.Properties;

public class PetResetLevelItem extends PetItem {
    public PetResetLevelItem(ItemMgr paramItemMgr, int paramInt) {
        super(paramItemMgr, paramInt);
    }

    public PetResetLevelItem(ItemMgr paramItemMgr, Item paramItem) {
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
            boolean isFightPet = localPetColumn.petIsFightPet(paramInt1);
            int i = 69;
            int j = 0;
            if (localPetInfo.getLevel() < i) {
                MessageMgr.sendMsgNotify(this.roleid, 191157,Arrays.<String>asList(""));
                return UseResult.FAIL;
            } else {
                int k = getGrowrateAddCountLimit();
                if (localPetInfo.getGrowrateaddcount() >= k) {
                    MessageMgr.sendMsgNotify(this.roleid, 191158,Arrays.<String>asList(""));
                    return UseResult.FAIL;
                } else {
                    localPetInfo.setLevel(localPetInfo.getLevel() - j);
                    localPet.updatePetScoreWhileChange();
                    Procedure.psendWhileCommit(this.roleid, new SRefreshPetExp(paramInt1, localPetInfo.getExp()));
                    localPetInfo.setGrowrateaddcount(localPetInfo.getGrowrateaddcount() + 1);
                    int qianye = localPetInfo.getQianye() + 1;
                    localPetInfo.setQianye(qianye);
                    SRefreshPetInfo localSRefreshPetInfo = new SRefreshPetInfo(localPet.getProtocolPet());
                    Procedure.psendWhileCommit(this.roleid, localSRefreshPetInfo);
                    if (isFightPet) {
                        SRefreshPetData petsend = new SRefreshPetData();
                        petsend.columnid = 1;
                        petsend.petkey = paramInt1;
                        petsend.datas.put(1240, (float)qianye);
                        Procedure.psendWhileCommit(this.roleid, petsend);
                    }

                    List localList = Arrays.asList("");
                    if (Transaction.current() == null) {
                        MessageMgr.sendMsgNotify(this.roleid, 162199,Arrays.<String>asList(""));
                    } else {
                        MessageMgr.psendMsgNotifyWhileCommit(this.roleid, 162199,Arrays.<String>asList(""));
                    }

                    return UseResult.SUCC;
                }
            }
        }
    }

    static int getGrowrateAddCountLimit() {
        TreeMap localTreeMap = ConfigManager.getInstance().getConf(SCommon.class);
        if (localTreeMap != null) {
            SCommon localSCommon = (SCommon)localTreeMap.get(371);
            if (localSCommon != null) {
                return Integer.parseInt(localSCommon.getValue());
            }
        }

        return 0;
    }
}

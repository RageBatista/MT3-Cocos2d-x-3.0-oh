//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.pet;

import fire.log.YYLogger;
import fire.log.beans.OpPetTraBean;
import fire.pb.common.SCommon;
import fire.pb.course.CourseManager;
import fire.pb.item.Commontext;
import fire.pb.item.ItemMgr;
import fire.pb.item.PetItem;
import fire.pb.item.Commontext.UseResult;
import fire.pb.main.ConfigManager;
import fire.pb.pet.Helper;
import fire.pb.pet.Module;
import fire.pb.pet.Pet;
import fire.pb.pet.PetAttr;
import fire.pb.pet.PetColumn;
import fire.pb.pet.SRefreshPetInfo;
import fire.pb.util.Misc;
import java.util.Map;
import mkdb.Procedure;
import xbean.Item;

public class PetGrowrateItemItem extends PetItem {
    public PetGrowrateItemItem(ItemMgr im, int itemid) {
        super(im, itemid);
    }

    public PetGrowrateItemItem(ItemMgr im, Item item) {
        super(im, item);
    }

    public Commontext.UseResult appendToPet(int petkey, int num) {
        if (Helper.isPetInBattle(this.getOwnerid(), petkey)) {
            return UseResult.FAIL;
        } else {
            PetColumn petcol = new PetColumn(this.getOwnerid(), 1, false);
            Pet pet = petcol.getPet(petkey);
            if (pet == null) {
                return UseResult.FAIL;
            } else {
                int countLimit = getGrowrateAddCountLimit() + 10;
                if (pet.getPetInfo().getGrowrateaddcount() >= countLimit) {
                    return UseResult.FAIL;
                } else {
                    int curValue = pet.getPetInfo().getGrowrate();
                    int maxValue = getGrowrateMaxValue(pet.getBaseId());
                    int addValue = 500;
                    int finalValue = curValue + addValue;
                    pet.getPetInfo().setGrowrate(finalValue);
                    pet.getPetInfo().setGrowrateaddcount(pet.getPetInfo().getGrowrateaddcount() + 1);
                    SRefreshPetInfo send = new SRefreshPetInfo(pet.getProtocolPet());
                    Procedure.psendWhileCommit(this.roleid, send);
                    pet.updatePetScoreWhileChange();
                    CourseManager.checkAchieveCourse(this.roleid, 31, pet.getPetInfo().getPetscore());
                    if (Module.logger.isInfoEnabled()) {
                        Module.logger.info("[PetGrowrateItem] roleId:" + this.roleid + " petKey:" + petkey + " uniqId:" + pet.getUniqueId() + " petId:" + pet.getBaseId() + " itemId:" + this.getItemId() + " ItemName:" + this.getName() + " itemNum:" + num + " curValue:" + curValue + " maxValue:" + maxValue + " addValue:" + addValue + " finalValue:" + finalValue + " petInfo:" + Helper.toString(pet.getPetInfo()));
                    }

                    this.writeYYLogger(num);
                    return UseResult.SUCC;
                }
            }
        }
    }

    private void writeYYLogger(int num) {
        YYLogger.petTraLog(this.roleid, new OpPetTraBean(this.getItemId(), num, 1500));
    }

    static int getAddGrowrateValue(int curValue, int maxValue) {
        int v1 = (int)((double)(maxValue - curValue) * 0.05 + (double)0.5F);
        int v2 = (int)((double)(maxValue - curValue) * 0.1 + (double)0.5F);
        int r = Misc.getRandomBetween(v1, v2);
        return r > 0 ? r : 1;
    }

    static int getGrowrateMaxValue(int petId) {
        int maxValue = 0;
        Map<Integer, PetAttr> confs = ConfigManager.getInstance().getConf(PetAttr.class);
        if (confs != null) {
            PetAttr conf = (PetAttr)confs.get(petId);
            if (conf != null) {
                for(Integer v : conf.getGrowrate()) {
                    if (v > maxValue) {
                        maxValue = v;
                    }
                }
            }
        }

        return maxValue;
    }

    static int getGrowrateAddCountLimit() {
        Map<Integer, SCommon> confs = ConfigManager.getInstance().getConf(SCommon.class);
        if (confs != null) {
            SCommon conf = (SCommon)confs.get(370);
            if (conf != null) {
                return Integer.parseInt(conf.getValue());
            }
        }

        return 0;
    }
}

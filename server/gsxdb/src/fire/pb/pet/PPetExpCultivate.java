//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.log.YYLogger;
import fire.log.beans.OpPetTraBean;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.item.ItemIdToClassString;
import fire.pb.item.Pack;
import fire.pb.item.PetItemShuXing;
import fire.pb.item.pet.PetExpItem;
import mkdb.Procedure;

public class PPetExpCultivate extends Procedure {
    private final long roleId;
    private final int petKey;
    private final int itemId;
    private final int itemNum;

    public PPetExpCultivate(long roleId, int petKey, int itemId, int itemNum) {
        this.roleId = roleId;
        this.petKey = petKey;
        this.itemId = itemId;
        this.itemNum = itemNum;
    }

    public boolean process() {
        if (Helper.isPetInBattle(this.roleId, this.petKey)) {
            return false;
        } else {
            PetColumn petCol = new PetColumn(this.roleId, 1, false);
            Pet pet = petCol.getPet(this.petKey);
            if (null == pet) {
                return false;
            } else {
                String itemClassName = ItemIdToClassString.getInstance().getItemClass(this.itemId);
                if (!PetExpItem.class.getName().equals(itemClassName)) {
                    return false;
                } else {
                    int addExp = getItemAddExp(this.itemId) * this.itemNum;
                    if (addExp <= 0) {
                        return true;
                    } else {
                        Pack bag = new Pack(this.roleId, false);
                        if (bag.getBagItemNum(this.itemId) < this.itemNum) {
                            return false;
                        } else {
                            PAddPetExpProc addExpProc = new PAddPetExpProc(this.roleId, this.petKey, (long)addExp, false, 1);
                            if (!addExpProc.call()) {
                                return false;
                            } else {
                                int num = bag.removeItemById(this.itemId, this.itemNum, YYLoggerTuJingEnum.tujing_Value_peiyang, 0, "Pet exp cultivate cost");
                                if (num != this.itemNum) {
                                    return false;
                                } else {
                                    if (Module.logger.isInfoEnabled()) {
                                        Module.logger.info("[PPetExpCultivate] roleId:" + this.roleId + " itemId:" + this.itemId + " itemNum:" + this.itemNum + " addExp:" + addExp + " petInfo:" + Helper.toString(pet.getPetInfo()));
                                    }

                                    this.writeYYLogger();
                                    return true;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private void writeYYLogger() {
        YYLogger.petTraLog(this.roleId, new OpPetTraBean(this.itemId, this.itemNum, 470));
    }

    public static int getItemAddExp(int itemId) {
        PetItemShuXing conf = (PetItemShuXing)fire.pb.item.Module.getInstance().getItemManager().getAttr(itemId);
        return conf != null ? conf.getAddExp() : 0;
    }
}

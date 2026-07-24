//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.item.Pack;
import fire.pb.main.ConfigManager;
import java.util.Map;
import mkdb.Procedure;

public class PPetDepotColumnAddCapacity extends Procedure {
    private final long roleId;

    public PPetDepotColumnAddCapacity(long roleId) {
        this.roleId = roleId;
    }

    public boolean process() {
        PetColumn petCol = new PetColumn(this.roleId, 2, false);
        if (petCol.getCapacity() >= petCol.getPetColumnMaxCapacity()) {
            return false;
        } else if (!this.cost(petCol)) {
            return false;
        } else {
            petCol.incCapacity();
            petCol.refreshCapacity();
            if (Module.logger.isInfoEnabled()) {
                Module.logger.info("[PPetDepotColumnAddCapacity] roleId:" + this.roleId + " petColumnCapacity:" + petCol.getCapacity() + " petColumnMaxCapacity:" + petCol.getPetColumnMaxCapacity());
            }

            return true;
        }
    }

    boolean cost(PetColumn petCol) {
        int money = this.getAddCapacityNeedMoney(petCol.getCapacity());
        if (money < 0) {
            return false;
        } else {
            if (money > 0) {
                Pack bag = new Pack(this.roleId, false);
                if (bag.subMoney((long)(-money), "Pet depot add capacity", YYLoggerTuJingEnum.tujing_Value_peiyang, 0) != (long)(-money)) {
                    return false;
                }
            }

            return true;
        }
    }

    int getAddCapacityNeedMoney(int curCapacity) {
        Map<Integer, SPetDepotPrice> confs = ConfigManager.getInstance().getConf(SPetDepotPrice.class);
        if (confs != null) {
            for(SPetDepotPrice conf : confs.values()) {
                if (conf.getNum() == curCapacity) {
                    return conf.getNextneedmoney();
                }
            }
        }

        return -1;
    }
}

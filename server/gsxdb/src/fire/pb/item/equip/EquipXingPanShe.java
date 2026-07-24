//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.equip;

import fire.pb.item.EquipItem;
import fire.pb.item.ItemMgr;
import xbean.Item;

public class EquipXingPanShe extends EquipItem implements IEquipType {
    public EquipXingPanShe(ItemMgr im, int itemid) {
        super(im, itemid);
    }

    public EquipXingPanShe(ItemMgr im, Item item) {
        super(im, item);
    }

    public void setUnfixedAttribute(int genWay) {
    }

    public int getEquipType() {
        return 31;
    }
}

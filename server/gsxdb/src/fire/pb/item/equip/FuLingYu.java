//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.equip;

import fire.pb.item.EquipItem;
import fire.pb.item.ItemMgr;
import xbean.Item;

public class FuLingYu extends EquipItem implements IEquipType {
    public FuLingYu(ItemMgr im, int itemid) {
        super(im, itemid);
    }

    public FuLingYu(ItemMgr im, Item item) {
        super(im, item);
    }

    public void setUnfixedAttribute(int genWay) {
    }

    public int getEquipType() {
        return 38;
    }
}

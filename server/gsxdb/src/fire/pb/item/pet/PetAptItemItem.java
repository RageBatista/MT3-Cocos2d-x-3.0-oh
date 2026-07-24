//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.pet;

import fire.pb.item.Commontext;
import fire.pb.item.ItemMgr;
import fire.pb.item.PetItem;
import fire.pb.item.Commontext.UseResult;
import xbean.Item;

public class PetAptItemItem extends PetItem {
    public PetAptItemItem(ItemMgr im, int itemid) {
        super(im, itemid);
    }

    public PetAptItemItem(ItemMgr im, Item item) {
        super(im, item);
    }

    public Commontext.UseResult appendToPet(int petkey, int num) {
        return UseResult.SUCC;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.pet;

import fire.pb.item.Commontext;
import fire.pb.item.ItemMgr;
import fire.pb.item.PetItem;
import fire.pb.item.PetItemShuXing;
import fire.pb.item.Commontext.UseResult;
import xbean.Item;

public class PetInternalItem extends PetItem {
    public PetInternalItem(ItemMgr im, int itemid) {
        super(im, itemid);
    }

    public PetInternalItem(ItemMgr im, Item item) {
        super(im, item);
    }

    public Commontext.UseResult appendToPet(int petkey, int num) {
        if (num != 1) {
            return UseResult.FAIL;
        } else {
            PetItemShuXing ia = (PetItemShuXing)this.itemAttr;
            return this.useSkillBook(this.roleid, petkey, ia, (int)this.itemData.getExtid()) ? UseResult.SUCC : UseResult.FAIL;
        }
    }

    public boolean useSkillBook(long roleId, int petkey, PetItemShuXing attr, int skillexp) {
        return false;
    }
}

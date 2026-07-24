//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.pet;

import fire.pb.item.Commontext;
import fire.pb.item.ItemMgr;
import fire.pb.item.Commontext.UseResult;
import fire.pb.pet.Pet;
import fire.pb.pet.PetColumn;
import mkdb.Bean;
import xbean.Item;

public class PetEquipItem extends fire.pb.item.PetEquipItem {
    public PetEquipItem(ItemMgr im, int itemid) {
        super(im, itemid);
    }

    public PetEquipItem(ItemMgr im, int itemid, Bean extinfo) {
        super(im, itemid, extinfo);
    }

    public PetEquipItem(ItemMgr im, Item item) {
        super(im, item);
    }

    public Commontext.UseResult appendToPet(int petkey, int num) {
        PetColumn petcol = new PetColumn(this.getOwnerid(), 1, false);
        Pet pet = petcol.getPet(petkey);
        return pet == null ? UseResult.FAIL : UseResult.SUCC;
    }
}

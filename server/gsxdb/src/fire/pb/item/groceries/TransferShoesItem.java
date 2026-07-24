//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.groceries;

import fire.pb.item.Commontext;
import fire.pb.item.GroceryItem;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMgr;
import fire.pb.item.STransferShoesItem;
import fire.pb.item.UseItemHandler;
import fire.pb.item.Commontext.UseResult;
import fire.pb.main.ConfigManager;
import fire.pb.map.Transfer;
import xbean.Item;
import xbean.Properties;

public class TransferShoesItem extends GroceryItem {
    public TransferShoesItem(ItemMgr im, int itemid) {
        super(im, itemid);
    }

    public TransferShoesItem(ItemMgr im, Item item) {
        super(im, item);
    }

    protected UseItemHandler getUseItemHandler() {
        int itemid = this.getItemId();
        return new UseTransferItemHandler(itemid);
    }

    private class UseTransferItemHandler implements UseItemHandler {
        private int itemid;

        public UseTransferItemHandler(int itemid) {
            this.itemid = itemid;
        }

        public Commontext.UseResult onUse(long roleId, ItemBase bi, int usednum) {
            Properties prop = xtable.Properties.get(roleId);
            if (prop == null) {
                throw new IllegalArgumentException("错误的roleId:" + roleId);
            } else {
                STransferShoesItem cnf = (STransferShoesItem)ConfigManager.getInstance().getConf(STransferShoesItem.class).get(this.itemid);
                if (cnf == null) {
                    return UseResult.FAIL;
                } else {
                    Transfer.justGoto(TransferShoesItem.this.roleid, (long)cnf.getSceneid(), cnf.getPosX(), cnf.getPosY(), 516013);
                    return UseResult.SUCC;
                }
            }
        }
    }
}

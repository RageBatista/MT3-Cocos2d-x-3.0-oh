//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.groceries;

import fire.pb.item.Commontext;
import fire.pb.item.GroceryItem;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMgr;
import fire.pb.item.UseItemHandler;
import fire.pb.item.feixingqi;
import fire.pb.item.Commontext.UseResult;
import fire.pb.main.ConfigManager;
import fire.pb.map.Transfer;
import xbean.Item;
import xbean.Properties;

public class FeiXingQiItem extends GroceryItem {
    public FeiXingQiItem(ItemMgr im, int itemid) {
        super(im, itemid);
    }

    public FeiXingQiItem(ItemMgr im, Item item) {
        super(im, item);
    }

    protected UseItemHandler getUseItemHandler() {
        int itemid = this.getItemId();
        return new UseReincarnateItemHandler(itemid);
    }

    private class UseReincarnateItemHandler implements UseItemHandler {
        private int itemid;

        public UseReincarnateItemHandler(int itemid) {
            this.itemid = itemid;
        }

        public Commontext.UseResult onUse(long roleId, ItemBase bi, int usednum) {
            Properties prop = xtable.Properties.get(roleId);
            if (prop == null) {
                throw new IllegalArgumentException("错误的roleId:" + roleId);
            } else {
                feixingqi cnf = (feixingqi)ConfigManager.getInstance().getConf(feixingqi.class).get(this.itemid);
                if (cnf.map != 0) {
                    Transfer.justGoto(FeiXingQiItem.this.roleid, (long)cnf.map, cnf.mapx, cnf.mapy, 516022);
                }

                return UseResult.SUCC;
            }
        }
    }
}

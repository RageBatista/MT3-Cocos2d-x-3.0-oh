//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.groceries;

import fire.pb.item.Commontext;
import fire.pb.item.GroceryItem;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMgr;
import fire.pb.item.PExpExchange;
import fire.pb.item.UseItemHandler;
import fire.pb.item.Commontext.UseResult;
import fire.pb.talk.MessageMgr;
import java.util.Arrays;
import xbean.Item;

public class ExpExchangeItem extends GroceryItem {
    private static long exp = 500000000L;
    private static int itemid = 400156;
    private static int itemnum = 1;

    public ExpExchangeItem(ItemMgr im, int itemid) {
        super(im, itemid);
    }

    public ExpExchangeItem(ItemMgr im, Item item) {
        super(im, item);
    }

    protected UseItemHandler getUseItemHandler() {
        return new UseExpExchangeItemHandler(this.getItemId());
    }

    private class UseExpExchangeItemHandler implements UseItemHandler {
        private int itemidd;

        public UseExpExchangeItemHandler(int itemidd) {
            this.itemidd = itemidd;
        }

        public Commontext.UseResult onUse(long n, ItemBase itemBase, int n2) {
            if ((new PExpExchange(ExpExchangeItem.this.roleid, ExpExchangeItem.exp, ExpExchangeItem.itemid, ExpExchangeItem.itemnum)).call()) {
                MessageMgr.sendMsgNotify(n, 14510,Arrays.<String>asList("消耗5亿经验兑换成功"));
                return UseResult.SUCC_NODEL;
            } else {
                MessageMgr.sendMsgNotify(n, 14510,Arrays.<String>asList("当前经验不足5亿兑换失败"));
                return UseResult.FAIL;
            }
        }
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.groceries;

import fire.pb.attr.SRefreshPointType;
import fire.pb.attr.SRefreshRoleData;
import fire.pb.effect.RoleImpl;
import fire.pb.event.Poster;
import fire.pb.item.Commontext;
import fire.pb.item.GroceryItem;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMgr;
import fire.pb.item.RoleAddPointEvent;
import fire.pb.item.UseItemHandler;
import fire.pb.item.Commontext.UseResult;
import java.util.Map;
import mkdb.Procedure;
import xbean.BasicFightProperties;
import xbean.Item;
import xbean.Properties;
import xbean.RoleAddPointProperties;

public class AddAgiItem extends GroceryItem {
    private static int addvalue = 2;

    public AddAgiItem(ItemMgr var1, int var2) {
        super(var1, var2);
    }

    public AddAgiItem(ItemMgr var1, Item var2) {
        super(var1, var2);
    }

    protected UseItemHandler getUseItemHandler() {
        int var1 = this.getItemId();
        return new UseAddPointHandler(var1);
    }

    private class UseAddPointHandler implements UseItemHandler {
        private int itemid;

        public UseAddPointHandler(int var2) {
            this.itemid = var2;
        }

        public Commontext.UseResult onUse(long var1, ItemBase var3, int var4) {
            Properties var5 = xtable.Properties.get(var1);
            if (var5 == null) {
                throw new IllegalArgumentException("错误的roleId:" + var1);
            } else {
                RoleImpl var6 = new RoleImpl(var1);
                RoleAddPointProperties var7 = var5.getAddpointfp();
                int var8 = var5.getScheme();
                Map var9 = var6.gmAddPoints(AddAgiItem.addvalue, 0, 0, 0, 0);
                if (var9 != null) {
                    SRefreshRoleData var10 = new SRefreshRoleData();
                    var10.datas.putAll(var9);
                    Procedure.psendWhileCommit(var1, var10);
                    SRefreshPointType var11 = new SRefreshPointType();
                    BasicFightProperties var12 = var5.getBfp();
                    var11.bfp.agi = (short)var12.getAgi();
                    var11.bfp.cons = (short)var12.getCons();
                    var11.bfp.endu = (short)var12.getEndu();
                    var11.bfp.iq = (short)var12.getIq();
                    var11.bfp.str = (short)var12.getStr();
                    var11.bfp.agi_save.putAll(var5.getAddpointfp().getAgi_save());
                    var11.bfp.cons_save.putAll(var5.getAddpointfp().getCons_save());
                    var11.bfp.endu_save.putAll(var5.getAddpointfp().getEndu_save());
                    var11.bfp.iq_save.putAll(var5.getAddpointfp().getIq_save());
                    var11.bfp.str_save.putAll(var5.getAddpointfp().getStr_save());
                    var11.point.putAll(var5.getPoint());
                    var11.pointscheme = var5.getScheme();
                    var11.schemechanges = var5.getSchemechanges();
                    Procedure.psendWhileCommit(var1, var11);
                    Poster.getPoster().dispatchEvent(new RoleAddPointEvent(var1));
                    return UseResult.SUCC;
                } else {
                    return UseResult.FAIL;
                }
            }
        }
    }
}

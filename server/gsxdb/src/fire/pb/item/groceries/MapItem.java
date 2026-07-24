//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.groceries;

import fire.pb.buff.Module;
import fire.pb.item.Commontext;
import fire.pb.item.GroceryItem;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMgr;
import fire.pb.item.UseItemHandler;
import fire.pb.item.Commontext.UseResult;
import fire.pb.main.ConfigManager;
import fire.pb.map.DuplicateHelper;
import fire.pb.map.MapConfig;
import fire.pb.map.Transfer;
import xbean.BuffRole;
import xbean.Item;
import xbean.StoredBuffRole;
import xtable.Buffroles;
import xtable.Buffrolestodisk;

public class MapItem extends GroceryItem {
    public MapItem(ItemMgr var1, int var2) {
        super(var1, var2);
    }

    public MapItem(ItemMgr var1, Item var2) {
        super(var1, var2);
    }

    protected UseItemHandler getUseItemHandler() {
        return new UseMapItemHandler();
    }

    private static class UseMapItemHandler implements UseItemHandler {
        private UseMapItemHandler() {
        }

        public Commontext.UseResult onUse(long var1, ItemBase var3, int var4) {
            if (var4 != 1) {
                return UseResult.FAIL;
            } else if (Module.existState(var1, 507006)) {
                return UseResult.FAIL;
            } else {
                Integer var5 = 9013;
                MapConfig var6 = (MapConfig)ConfigManager.getInstance().getConf(MapConfig.class).get(var5);
                if (var6 == null) {
                    return UseResult.FAIL;
                } else {
                    boolean var7 = var6.dynamic == 0;
                    if (var7) {
                        BuffRole var8 = Buffroles.select(var1);
                        StoredBuffRole var9 = Buffrolestodisk.select(var1);
                        if (var8 == null || var9 == null) {
                            return UseResult.FAIL;
                        }

                        Transfer.justGotoRandom(var1, var5, 516022);
                    } else {
                        DuplicateHelper.enterDynamicMap(var1, var5, 50, 50, var1, var6.mapName, false, 0, 516022);
                    }

                    return UseResult.SUCC;
                }
            }
        }
    }
}

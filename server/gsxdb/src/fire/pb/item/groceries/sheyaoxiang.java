//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.groceries;

import fire.pb.buff.BuffRoleImpl;
import fire.pb.item.Commontext;
import fire.pb.item.GroceryItem;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMgr;
import fire.pb.item.UseItemHandler;
import fire.pb.item.Commontext.UseResult;
import fire.pb.main.ConfigManager;
import fire.pb.map.DuplicateHelper;
import fire.pb.map.MapConfig;
import fire.pb.talk.MessageMgr;
import java.util.List;
import xbean.BuffRole;
import xbean.Item;
import xbean.StoredBuffRole;
import xtable.Buffroles;
import xtable.Buffrolestodisk;

public class sheyaoxiang extends GroceryItem {
    public sheyaoxiang(ItemMgr paramItemMgr, int paramInt) {
        super(paramItemMgr, paramInt);
    }

    public sheyaoxiang(ItemMgr paramItemMgr, Item paramItem) {
        super(paramItemMgr, paramItem);
    }

    protected UseItemHandler getUseItemHandler() {
        return new UsesheyaoxiangHandler();
    }

    private static class UsesheyaoxiangHandler implements UseItemHandler {
        private UsesheyaoxiangHandler() {
        }

        public Commontext.UseResult onUse(long roleId, ItemBase ItemBase, int paramInt) {
            if (paramInt != 1) {
                return UseResult.FAIL;
            } else {
                Integer localInteger = 9013;
                MapConfig localMapConfig = (MapConfig)ConfigManager.getInstance().getConf(MapConfig.class).get(localInteger);
                if (localMapConfig == null) {
                    return UseResult.FAIL;
                } else {
                    boolean isDynamic = (localMapConfig.dynamic == 0);
                    if (isDynamic) {
                        BuffRole localBuffRole = Buffroles.select(roleId);
                        StoredBuffRole localStoredBuffRole = Buffrolestodisk.select(roleId);
                        if (localBuffRole == null || localStoredBuffRole == null) {
                            return UseResult.FAIL;
                        }

                        BuffRoleImpl brole = new BuffRoleImpl(roleId);
                        brole.addCBuff(500008);
                        MessageMgr.psendMsgNotify(roleId, 192812, (List)null);
                    } else {
                        DuplicateHelper.enterDynamicMap(roleId, localInteger, 50, 50, roleId, localMapConfig.mapName, false, 0, 516022);
                    }

                    return UseResult.SUCC;
                }
            }
        }
    }
}

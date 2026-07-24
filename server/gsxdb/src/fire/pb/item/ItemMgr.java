//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.Bag;
import java.util.HashMap;
import java.util.NavigableMap;
import java.util.Set;
import mkdb.Bean;
import xbean.Item;

public interface ItemMgr {
    ItemBase genItemBase(int var1, int var2, int var3, Bean var4, boolean var5) throws IllegalArgumentException;

    ItemBase genItemBase(int var1, int var2, Bean var3) throws IllegalArgumentException;

    ItemBase genItemBase(int var1, int var2) throws IllegalArgumentException;

    ItemBase genItemBase(int var1, int var2, int var3) throws IllegalArgumentException;

    ItemShuXing getAttr(int var1);

    NavigableMap<Integer, ItemShuXing> getAttrMap();

    HashMap<Integer, Bag> getLoginPackInfo(long var1);

    int addItemToPack(long var1, int var3, int var4, int var5, int var6, YYLoggerTuJingEnum var7, int var8, String var9);

    SItemBuff getItemBuff(int var1);

    BagConfig getPackCfg(int var1);

    ItemBase toItemBase(Item var1);

    ItemBase toItemBase(Item var1, long var2, int var4, int var5);

    SEquipNaiJiuXiaoHao getLoseNaiJiu(int var1);

    ItemMgrImp.LiBao getLiBao(int var1, int var2, int var3, int var4);

    Set<Integer> getItemByCard(int var1);

    int getBuyDepotMoney(int var1);
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.school.change;

import com.locojoy.base.Octets;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.buff.Module;
import fire.pb.item.EquipItem;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMaps;
import fire.pb.item.Pack;
import fire.pb.item.SAddItem;
import fire.pb.item.SEquipToEquipex;
import fire.pb.item.SGetItemTips;
import fire.pb.main.ConfigManager;
import fire.pb.ranklist.proc.PRoleZongheRankProc;
import fire.pb.talk.MessageMgr;
import java.util.List;
import java.util.TreeMap;
import mkdb.Procedure;
import org.apache.log4j.Logger;
import xbean.Properties;

public class PChangeEquipEx extends Procedure {
    private static Logger logger = Logger.getLogger("ITEM");
    private final long roleId;
    private final int equipKey;
    private final int newitemid;

    public PChangeEquipEx(long var1, int var3, int var4) {
        this.roleId = var1;
        this.equipKey = var3;
        this.newitemid = var4;
    }

    protected boolean process() throws Exception {
        Properties var1 = xtable.Properties.get(this.roleId);
        if (var1 == null) {
            return false;
        } else if (Module.existState(this.roleId, 507004)) {
            MessageMgr.psendMsgNotify(this.roleId, 150163, (List)null);
            logger.error("战斗状态下无法使用转换武器功能");
            return false;
        } else {
            Pack var2 = new Pack(this.roleId, false);
            ItemBase var3 = var2.getItem(this.equipKey);
            if (var3 != null && var3 instanceof EquipItem) {
                EquipItem var4 = (EquipItem)var3;
                int var5 = 0;
                int var6 = 0;
                boolean var7 = false;
                TreeMap var8 = ConfigManager.getInstance().getConf(SEquipToEquipex.class);
                if (var8 != null) {
                    SEquipToEquipex var9 = (SEquipToEquipex)var8.get(var4.getItemId());
                    if (var9 == null) {
                        logger.error("表不存在!!!");
                        return true;
                    }

                    if (var9.getToitemlist().size() == 0) {
                        logger.error("列表为空!!!");
                        return true;
                    }

                    var5 = var9.getNeeditemid();
                    var6 = var9.getNeeditemcount();

                    for(int var10 = 0; var10 < var9.toitemlist.size(); ++var10) {
                        if ((Integer)var9.toitemlist.get(var10) == this.newitemid) {
                            var7 = true;
                            break;
                        }
                    }
                }

                if (!var7) {
                    logger.error("找不到对应的目标");
                    return true;
                } else if ((long)var6 > var2.getGold()) {
                    MessageMgr.psendMsgNotify(this.roleId, 160118, (List)null);
                    return true;
                } else if ((var3.getFlags() & 4) != 0) {
                    logger.error("拍卖的武器无法使用转换武器功能备");
                    return false;
                } else {
                    long var17 = var2.subGold((long)(-var6), "changeweaponex", YYLoggerTuJingEnum.tujing_Value_peiyang, 0);
                    if (var17 != (long)(-var6)) {
                        return false;
                    } else {
                        var4.changeEquipID(fire.pb.item.Module.getInstance().getItemManager(), this.newitemid);
                        int var11 = fire.pb.item.Module.getInstance().getEquipScore(var4);
                        var4.getEquipAttr().setEquipscore(var11);
                        if (var11 >= var4.getItemAttr().getTreasureScore()) {
                            var4.getEquipAttr().setTreasure(1);
                        } else {
                            var4.getEquipAttr().setTreasure(0);
                        }

                        SAddItem var12 = new SAddItem();
                        var12.packid = var2.getPackid();
                        var12.data.add(ItemMaps.transItemData2SendData(var4.getDataItem(), this.equipKey, 0));
                        psendWhileCommit(this.roleId, var12);
                        Octets var13 = var4.getTips();
                        SGetItemTips var14 = new SGetItemTips(1, var4.getKey(), var13);
                        psendWhileCommit(this.roleId, var14);
                        SChangeWeapon var15 = new SChangeWeapon();
                        psendWhileCommit(this.roleId, var15);
                        Procedure.pexecuteWhileCommit(new PRoleZongheRankProc(this.roleId));
                        return true;
                    }
                }
            } else {
                MessageMgr.psendMsgNotify(this.roleId, 150163, (List)null);
                logger.error("转换武器功能旧武器错误!!!");
                return false;
            }
        }
    }
}

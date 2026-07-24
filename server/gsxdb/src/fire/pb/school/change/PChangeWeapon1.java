//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.school.change;

import com.locojoy.base.Octets;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.RoleConfigManager;
import fire.pb.buff.Module;
import fire.pb.item.EquipItem;
import fire.pb.item.ItemBase;
import fire.pb.item.Pack;
import fire.pb.item.SEquipczEquip;
import fire.pb.item.SGetItemTips;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import org.apache.log4j.Logger;
import xbean.Properties;

public class PChangeWeapon1 extends Procedure {
    static Map<Integer, SEquipczEquip> produceConfs = ConfigManager.getInstance().getConf(SEquipczEquip.class);
    private static Logger logger = Logger.getLogger("ITEM");
    private final long roleId;
    private final int equipKey;
    private final int newWeaponTypeId;

    public PChangeWeapon1(long roleId, int equipKey, int newWeaponTypeId) {
        this.roleId = roleId;
        this.equipKey = equipKey;
        this.newWeaponTypeId = newWeaponTypeId;
    }

    protected boolean process() throws Exception {
        Properties prop = xtable.Properties.get(this.roleId);
        if (prop == null) {
            return false;
        } else if (Module.existState(this.roleId, 507004)) {
            MessageMgr.psendMsgNotify(this.roleId, 150163, (List)null);
            logger.error("战斗状态下无法使用转换武器功能");
            return false;
        } else {
            Pack bag = new Pack(this.roleId, false);
            ItemBase oldWeaponIB = bag.getItem(this.equipKey);
            if (produceConfs != null) {
                Iterator var5 = produceConfs.values().iterator();

                while(var5.hasNext()) {
                    SEquipczEquip pc = (SEquipczEquip)var5.next();
                    if (pc != null && pc.getNeedid() != null) {
                        if (this.equipKey == pc.getNextid2()) {
                            bag.removeItemById((Integer)pc.getNeedid().get(0), (Integer)pc.getNeedid2num().get(0), YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0, "Treasuremap used success");
                            bag.removeItemWithKey(this.equipKey, 1, YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0, "Treasuremap used success");
                            bag.addItem(this.equipKey, 1, "Treasuremap used success", YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0, false);
                            break;
                        }

                        if (this.newWeaponTypeId == pc.getNextid1()) {
                            bag.removeItemById((Integer)pc.getNeedid().get(0), (Integer)pc.getNeedid1num().get(0), YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0, "Treasuremap used success");
                            bag.removeItemWithKey(this.equipKey, 1, YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0, "Treasuremap used success");
                            bag.addItem(this.newWeaponTypeId, 1, "Treasuremap used success", YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0, false);
                            break;
                        }
                    }
                }
            }

            EquipItem oldWeapon = (EquipItem)oldWeaponIB;
            if ((oldWeaponIB.getFlags() & 4) != 0) {
                logger.error("拍卖的武器无法使用转换武器功能备");
                return false;
            } else {
                int confWeaponChangeCostGold = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(476).getValue());
                long ret = bag.subGold((long)(-confWeaponChangeCostGold), "转职转武器消耗", YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0);
                if (ret != (long)(-confWeaponChangeCostGold)) {
                    return false;
                } else {
                    int score = fire.pb.item.Module.getInstance().getEquipScore(oldWeapon);
                    oldWeapon.getEquipAttr().setEquipscore(score);
                    if (score >= oldWeapon.getItemAttr().getTreasureScore()) {
                        oldWeapon.getEquipAttr().setTreasure(1);
                    } else {
                        oldWeapon.getEquipAttr().setTreasure(0);
                    }

                    Octets tips = oldWeapon.getTips();
                    SGetItemTips send = new SGetItemTips(1, oldWeapon.getKey(), tips);
                    psendWhileCommit(this.roleId, send);
                    return true;
                }
            }
        }
    }
}

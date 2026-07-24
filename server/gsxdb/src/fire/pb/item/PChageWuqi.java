//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Octets;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.RoleConfigManager;
import fire.pb.buff.Module;
import fire.pb.ranklist.proc.PRoleZongheRankProc;
import fire.pb.talk.MessageMgr;
import fire.pb.util.BagUtil;
import java.util.List;
import mkdb.Procedure;
import org.apache.log4j.Logger;
import xbean.Properties;

public class PChageWuqi extends Procedure {
    private static Logger logger = Logger.getLogger("ITEM");
    private final long roleId;
    private final int equipKey;
    private final int newWeaponTypeId;

    public PChageWuqi(long roleId, int equipKey, int newWeaponTypeId) {
        this.roleId = roleId;
        this.equipKey = equipKey;
        this.newWeaponTypeId = newWeaponTypeId;
    }

    protected boolean process() throws Exception {
        Properties prop = xtable.Properties.get(this.roleId);
        if (null == prop) {
            return false;
        } else if (Module.existState(this.roleId, 507004)) {
            MessageMgr.psendMsgNotify(this.roleId, 150163, (List)null);
            logger.error("战斗状态下无法使用转换武器功能");
            return false;
        } else {
            ItemShuXing newEquipAttr = fire.pb.item.Module.getInstance().getItemManager().getAttr(this.newWeaponTypeId);
            if (newEquipAttr == null) {
                logger.error("转换武器功能新武器类型不存在");
                return false;
            } else {
                Pack bag = new Pack(this.roleId, false);
                ItemBase oldWeaponIB = bag.getItem(this.equipKey);
                if (oldWeaponIB != null && oldWeaponIB instanceof EquipItem) {
                    EquipItem oldWeapon = (EquipItem)oldWeaponIB;
                    if ((oldWeaponIB.getFlags() & 4) != 0) {
                        logger.error("拍卖的武器无法使用转换武器功能备");
                        return false;
                    } else {
                        int itemid = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(492).getValue());
                        int itemnum = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(493).getValue());
                        if (BagUtil.removeItem(this.roleId, itemid, itemnum, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "????????????") != itemnum) {
                            return false;
                        } else {
                            int confWeaponChangeCostMoney = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(491).getValue());
                            long ret = bag.subGold((long)(-confWeaponChangeCostMoney), "转职转武器消耗", YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0);
                            if (ret != (long)(-confWeaponChangeCostMoney)) {
                                return false;
                            } else {
                                oldWeapon.changeEquipID(fire.pb.item.Module.getInstance().getItemManager(), this.newWeaponTypeId);
                                int score = fire.pb.item.Module.getInstance().getEquipScore(oldWeapon);
                                oldWeapon.getEquipAttr().setEquipscore(score);
                                if (score >= oldWeapon.getItemAttr().getTreasureScore()) {
                                    oldWeapon.getEquipAttr().setTreasure(1);
                                } else {
                                    oldWeapon.getEquipAttr().setTreasure(0);
                                }

                                SAddItem sAddItem = new SAddItem();
                                sAddItem.packid = bag.getPackid();
                                sAddItem.data.add(ItemMaps.transItemData2SendData(oldWeapon.getDataItem(), this.equipKey, 0));
                                psendWhileCommit(this.roleId, sAddItem);
                                Octets tips = oldWeapon.getTips();
                                SGetItemTips send = new SGetItemTips(1, oldWeapon.getKey(), tips);
                                psendWhileCommit(this.roleId, send);
                                SRepairResult sRepairResult = new SRepairResult();
                                sRepairResult.ret = 1;
                                Procedure.psendWhileCommit(this.roleId, sRepairResult);
                                Procedure.pexecuteWhileCommit(new PRoleZongheRankProc(this.roleId));
                                return true;
                            }
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
}

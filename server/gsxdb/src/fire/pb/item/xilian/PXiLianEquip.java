//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.xilian;

import com.locojoy.base.Octets;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.RoleConfigManager;
import fire.pb.buff.Module;
import fire.pb.item.EquipItem;
import fire.pb.item.EquipItemShuXing;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemShuXing;
import fire.pb.item.Pack;
import fire.pb.item.SGetItemTips;
import fire.pb.item.SRepairResult;
import fire.pb.item.make.ItemMakeFactory;
import fire.pb.product.SErrorCode;
import fire.pb.skill.SceneSkillRole;
import fire.pb.skill.SkillManager;
import fire.pb.talk.MessageMgr;
import fire.pb.team.TeamManager;
import fire.pb.util.BagUtil;
import java.util.List;
import mkdb.Procedure;

public class PXiLianEquip extends Procedure {
    private final long roleId;
    private Pack beibao = null;
    private final int equipKey;
    protected ItemShuXing attr;
    private int bagId = 1;

    public PXiLianEquip(long roleId, int equipKey) {
        this.roleId = roleId;
        this.equipKey = equipKey;
    }

    private boolean checkMaterialIsOk(int materialId, int requiredNum) {
        int currentNum = this.beibao.getItemNum(materialId, 0);
        return currentNum >= requiredNum;
    }

    private int getEquipItemNum(int equipLevel) {
        int baseLevel = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(473).getValue());
        int baseNum = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(606).getValue());
        int increasePerLevel = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(607).getValue());
        int result;
        if (equipLevel <= baseLevel) {
            result = baseNum;
        } else {
            int levelDiff = (equipLevel - baseLevel) / 10;
            result = baseNum + levelDiff * increasePerLevel;
        }

        return result;
    }

    private int getNeedNum(int equipLevel, int baseLevel) {
        int baseGold = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(474).getValue());
        int increasePerLevel = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(475).getValue());
        int result;
        if (equipLevel <= baseLevel) {
            result = baseGold;
        } else {
            int levelDiff = (equipLevel - baseLevel) / 10;
            result = increasePerLevel * levelDiff + baseGold;
        }

        return result;
    }

    protected boolean process() throws Exception {
        int materialItemId = 403004;
        if (Module.existState(this.roleId, 507004)) {
            return false;
        } else {
            TeamManager.getTeamByRoleId(this.roleId);
            this.beibao = (Pack)fire.pb.item.Module.getInstance().getItemMaps(this.roleId, this.bagId, false);
            SErrorCode errorCode = new SErrorCode();
            ItemBase itemBase = this.beibao.getItem(this.equipKey);
            if (!(itemBase instanceof EquipItem)) {
                Module.logger.debug("重铸的物品不是装备");
                return false;
            } else {
                this.attr = fire.pb.item.Module.getInstance().getItemManager().getAttr(itemBase.getItemId());
                if (!(this.attr instanceof EquipItemShuXing)) {
                    Module.logger.debug("重铸的物品不是装备");
                    return false;
                } else {
                    EquipItemShuXing equipAttr = (EquipItemShuXing)this.attr;
                    EquipItem equipItem = (EquipItem)itemBase;
                    int equipLevel = equipAttr.getLevel();
                    int requiredMaterialNum = this.getEquipItemNum(equipLevel);
                    if (!this.checkMaterialIsOk(materialItemId, requiredMaterialNum)) {
                        return false;
                    } else if (this.roleId < 0L) {
                        return false;
                    } else {
                        int baseLevel = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(473).getValue());
                        long requiredGold = (long)this.getNeedNum(equipLevel, baseLevel);
                        if (requiredGold > this.beibao.getGold()) {
                            errorCode.errorcode = -5;
                            Procedure.psendWhileCommit(this.roleId, errorCode);
                            return false;
                        } else if (this.beibao.subGold(-requiredGold, "装备相关", YYLoggerTuJingEnum.tujing_Value_xiuli, 0) != -requiredGold) {
                            return false;
                        } else {
                            int removedCount = BagUtil.removeItem(this.roleId, materialItemId, requiredMaterialNum, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "熔炼消耗道具");
                            System.out.println("扣除数量过程");
                            if (removedCount < 1) {
                                return false;
                            } else {
                                ItemMakeFactory.getFactory().genItemWithSkillAndShuangJia2(equipItem);
                                int equipScore = fire.pb.item.Module.getInstance().getEquipScore(itemBase);
                                equipItem.getEquipAttr().setEquipscore(equipScore);
                                if (equipScore >= equipItem.getItemAttr().getTreasureScore()) {
                                    equipItem.getEquipAttr().setTreasure(1);
                                } else {
                                    equipItem.getEquipAttr().setTreasure(0);
                                }

                                Octets tips = equipItem.getTips();
                                SGetItemTips itemTipsResponse = new SGetItemTips(this.bagId, this.equipKey, tips);
                                Procedure.psendWhileCommit(this.roleId, itemTipsResponse);
                                MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 196026, (List)null);
                                if (this.bagId == 3) {
                                    SceneSkillRole sceneSkillRole = SkillManager.getSceneSkillRole(this.roleId);
                                    sceneSkillRole.addEquipEffectAndSkillWithSP(equipItem);
                                }

                                SRepairResult repairResult = new SRepairResult();
                                repairResult.ret = 1;
                                Procedure.psendWhileCommit(this.roleId, repairResult);
                                return repairResult.ret == 1;
                            }
                        }
                    }
                }
            }
        }
    }
}

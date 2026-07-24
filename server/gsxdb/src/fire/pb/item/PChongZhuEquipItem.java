//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Octets;
import fire.log.YYLogger;
import fire.log.beans.OpEquiRepBean;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.item.make.ItemMakeFactory;
import fire.pb.skill.SceneSkillRole;
import fire.pb.skill.SkillManager;
import fire.pb.talk.MessageMgr;
import fire.pb.team.TeamManager;
import fire.pb.util.BagUtil;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import org.apache.log4j.Logger;

public class PChongZhuEquipItem extends Procedure {
    private long roleId;
    private int equipKey;
    private int bagId;
    private int repairType;
    private ItemMaps bag = null;
    private Pack beibao = null;
    protected ItemShuXing attr;
    private static Logger logger = Logger.getLogger("ITEM");

    public PChongZhuEquipItem(long roleId, int keyinpack, int packid, int repairtype) {
        this.roleId = roleId;
        this.equipKey = keyinpack;
        this.bagId = packid;
        this.repairType = repairtype;
    }

    public boolean process() {
        if (this.bagId != 1 && this.bagId != 3) {
            Module.logger.debug("背包类型不正确");
            return false;
        } else if (this.bagId == 3 && fire.pb.buff.Module.existState(this.roleId, 507004)) {
            return false;
        } else {
            TeamManager.getTeamByRoleId(this.roleId);
            switch (this.bagId) {
                case 1:
                    this.bag = Module.getInstance().getItemMaps(this.roleId, this.bagId, false);
                    break;
                case 3:
                    this.bag = Module.getInstance().getItemMaps(this.roleId, this.bagId, false);
                    break;
                default:
                    Module.logger.debug("背包类型不正确");
                    return false;
            }

            this.beibao = (Pack)Module.getInstance().getItemMaps(this.roleId, 1, false);
            ItemBase bi = this.bag.getItem(this.equipKey);
            if (!(bi instanceof EquipItem)) {
                Module.logger.debug("重铸的物品不是装备");
                return false;
            } else {
                this.attr = Module.getInstance().getItemManager().getAttr(bi.getItemId());
                if (!(this.attr instanceof EquipItemShuXing)) {
                    Module.logger.debug("重铸的物品不是装备");
                    return false;
                } else {
                    EquipItemShuXing equipattr = (EquipItemShuXing)this.attr;
                    EquipItem ei = (EquipItem)bi;
                    int itemId = ei.getItemAttr().chongzhuitemid;
                    if (this.repairType == 1) {
                        if (this.roleId < 0L) {
                            return false;
                        }

                        int equipItemNum = ei.getItemAttr().chongzhuitemnum;
                        if (itemId > 0 && equipItemNum > 0) {
                            Pack bag = new Pack(this.roleId, false);
                            if (bag.getBagItemNum(itemId) < equipItemNum) {
                                return false;
                            }

                            int ret = BagUtil.removeItem(this.roleId, itemId, equipItemNum, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "熔炼消耗道具");
                            if (ret != equipItemNum) {
                                return false;
                            }
                        }

                        Map<Integer, Integer> addattr = ei.getEquipAttr().getAddattr();
                        if (addattr != null) {
                            addattr.clear();
                        }

                        ItemMakeFactory.getFactory().genItem(ei);
                        int i4 = Module.getInstance().getEquipScore(bi);
                        ei.getEquipAttr().setEquipscore(i4);
                        if (i4 >= ei.getItemAttr().getTreasureScore()) {
                            ei.getEquipAttr().setTreasure(1);
                        } else {
                            ei.getEquipAttr().setTreasure(0);
                        }

                        Octets octets = ei.getTips();
                        SGetItemTips sGetItemTips = new SGetItemTips(this.bagId, this.equipKey, octets);
                        Procedure.psendWhileCommit(this.roleId, sGetItemTips);
                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 196026, (List)null);
                        if (this.bagId == 3) {
                            SceneSkillRole sceneSkillRole = SkillManager.getSceneSkillRole(this.roleId);
                            sceneSkillRole.addEquipEffectAndSkillWithSP(ei);
                        }

                        SRepairResult sRepairResult = new SRepairResult();
                        sRepairResult.ret = 1;
                        Procedure.psendWhileCommit(this.roleId, sRepairResult);
                        if (sRepairResult.ret != 1) {
                            return false;
                        }
                    }

                    this.writeYYLogger(equipattr, ei);
                    return true;
                }
            }
        }
    }

    private void writeYYLogger(EquipItemShuXing equipattr, EquipItem ei) {
        if (equipattr != null && ei != null) {
            OpEquiRepBean opEquiRepBean = new OpEquiRepBean(equipattr.getId(), equipattr.getLevel(), equipattr.getRare(), ei.getItemId(), ei.getEndure(), this.repairType);
            YYLogger.equiRepLog(this.roleId, opEquiRepBean);
        }
    }
}

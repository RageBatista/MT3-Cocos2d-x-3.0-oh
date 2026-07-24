//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Octets;
import fire.log.YYLogger;
import fire.log.beans.OpEquiRepBean;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.main.ConfigManager;
import fire.pb.product.SErrorCode;
import fire.pb.skill.SkillRole;
import fire.pb.talk.MessageMgr;
import fire.pb.talk.STransChatMessageNotify2Client;
import fire.pb.team.TeamManager;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.TreeMap;
import mkdb.Procedure;
import org.apache.log4j.Logger;

public class PAttunement extends Procedure {
    private long roleId;
    private int equipKey;
    private int bagId;
    private int repairType;
    private ItemMaps bag = null;
    private Pack beibao = null;
    protected ItemShuXing attr;
    private static Logger logger = Logger.getLogger("ITEM");

    public PAttunement(long roleId, int equipId, int bagId, int repairType) {
        this.roleId = roleId;
        this.equipKey = equipId;
        this.bagId = bagId;
        this.repairType = repairType;
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
                    this.bag = (Pack)Module.getInstance().getItemMaps(this.roleId, this.bagId, false);
                    break;
                case 3:
                    this.bag = (Equip)Module.getInstance().getItemMaps(this.roleId, this.bagId, false);
                    break;
                default:
                    Module.logger.debug("背包类型不正确");
                    return false;
            }

            this.beibao = (Pack)Module.getInstance().getItemMaps(this.roleId, 1, false);
            new SErrorCode();
            ItemBase bi = this.bag.getItem(this.equipKey);
            if (!(bi instanceof EquipItem)) {
                Module.logger.debug("修理的物品不是装备");
                return false;
            } else {
                this.attr = Module.getInstance().getItemManager().getAttr(bi.getItemId());
                if (!(this.attr instanceof EquipItemShuXing)) {
                    Module.logger.debug("修理的物品不是装备");
                    return false;
                } else {
                    EquipItemShuXing equipattr = (EquipItemShuXing)this.attr;
                    EquipItem ei = (EquipItem)bi;
                    xbean.Equip equipAttr = ei.getEquipAttr();
                    int needmaney = equipattr.ptxlmoneynum;
                    if ((long)needmaney > this.beibao.getMoney()) {
                        STransChatMessageNotify2Client msg = MessageMgr.getMsgNotify(192805, 0, (List)null);
                        psendWhileCommit(this.roleId, msg);
                        return true;
                    } else if (!this.checkMaterialIsOk(400017, 1)) {
                        STransChatMessageNotify2Client msg = MessageMgr.getMsgNotify(192808, 0, (List)null);
                        psendWhileCommit(this.roleId, msg);
                        return true;
                    } else {
                        ItemBase itemBase = this.getItemKey(400017);
                        if (itemBase == null) {
                            MessageMgr.psendMsgNotify(this.roleId, ItemBase.ITEM_LOCK_MSG, (List)null);
                            return false;
                        } else {
                            this.beibao.removeItemWithKey(itemBase.getKey(), 1, YYLoggerTuJingEnum.tujing_Value_xiuli, 5, "装备相关");
                            if (this.beibao.subMoney((long)(-needmaney), "装备相关", YYLoggerTuJingEnum.tujing_Value_xiuli, 0) != (long)(-needmaney)) {
                                return false;
                            } else {
                                logger.debug("Role: " + this.roleId + "delete item");
                                TreeMap<Integer, SEquipsit> conf = ConfigManager.getInstance().getConf(SEquipsit.class);
                                ArrayList<Integer> Equipsitidlist = new ArrayList();

                                for(Integer integer : conf.keySet()) {
                                    SEquipsit sEquipsit = (SEquipsit)conf.get(integer);
                                    if (sEquipsit != null) {
                                        Equipsitidlist.add(sEquipsit.id);
                                    }
                                }

                                Random random = new Random();
                                int i = random.nextInt(Equipsitidlist.size() + 1);
                                if (i == 0) {
                                    i = 1;
                                }

                                SEquipsit sEquipsit = (SEquipsit)conf.get(i);
                                ei.getEquipAttr().setEquipsit(sEquipsit.id);
                                Octets octets = ei.getTips();
                                SGetItemTips sGetItemTips = new SGetItemTips(this.bagId, this.equipKey, octets);
                                Procedure.psendWhileCommit(this.roleId, sGetItemTips);
                                SkillRole srole = new SkillRole(this.roleId);
                                srole.addEquipments(this.roleId);
                                srole.sendSpecialSkills();
                                SRepairResult sRepairResult = new SRepairResult();
                                sRepairResult.ret = 1;
                                Procedure.psendWhileCommit(this.roleId, sRepairResult);
                                MessageMgr.psendMsgNotify(this.roleId, 192807, (List)null);
                                this.writeYYLogger(equipattr, ei);
                                return true;
                            }
                        }
                    }
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

    private boolean checkMaterialIsOk(int materialID, int num) {
        int currentNum = this.beibao.getItemNum(materialID, 0);
        return currentNum >= num;
    }

    private ItemBase getItemKey(int itemId) {
        for(ItemBase item : this.beibao) {
            if (itemId == item.getItemId()) {
                return item;
            }
        }

        return null;
    }
}

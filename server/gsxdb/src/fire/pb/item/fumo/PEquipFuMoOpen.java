//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.fumo;

import com.locojoy.base.Octets;
import fire.log.YYLogger;
import fire.log.beans.OpEquiRepBean;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PropRole;
import fire.pb.item.EquipItem;
import fire.pb.item.EquipItemShuXing;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMaps;
import fire.pb.item.ItemShuXing;
import fire.pb.item.Module;
import fire.pb.item.Pack;
import fire.pb.item.SFumoInfo;
import fire.pb.item.SGetItemTips;
import fire.pb.item.SRepairResult;
import fire.pb.main.ConfigManager;
import fire.pb.map.SceneManager;
import fire.pb.skill.SceneSkillRole;
import fire.pb.skill.SkillManager;
import fire.pb.talk.MessageMgr;
import fire.pb.talk.STransChatMessageNotify2Client;
import fire.pb.team.TeamManager;
import fire.pb.util.BagUtil;
import fire.pb.util.Misc;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.TreeMap;
import mkdb.Procedure;
import org.apache.log4j.Logger;
import xbean.Equip;

public class PEquipFuMoOpen extends Procedure {
    private long roleId;
    private int equipKey;
    private int bagId;
    private int repairType;
    private ItemMaps bag = null;
    private Pack beibao = null;
    protected ItemShuXing attr;
    private final TreeMap<Integer, SFumoInfo> conf = ConfigManager.getInstance().getConf(SFumoInfo.class);
    private static Logger logger = Logger.getLogger("ITEM");

    public PEquipFuMoOpen(long roleId, int keyinpack, int packid, int repairtype) {
        this.roleId = roleId;
        this.equipKey = keyinpack;
        this.bagId = packid;
        this.repairType = repairtype;
    }

    private boolean checkMaterialIsOk(int paramInt1, int paramInt2) {
        int i = this.beibao.getItemNum(paramInt1, 0);
        return i >= paramInt2;
    }

    private int RandomSkill() {
        int randomBetween = Misc.getRandomBetween(0, 9999);
        Random random = new Random();
        ArrayList<Integer> skilllist = new ArrayList();
        ArrayList<Integer> effectlist = new ArrayList();

        for(Integer integer : this.conf.keySet()) {
            if (((SFumoInfo)this.conf.get(integer)).skilltype == 1) {
                int probability = (int)((SFumoInfo)this.conf.get(integer)).probability * 10000;
                if (((SFumoInfo)this.conf.get(integer)).probability > 0.7) {
                    effectlist.add(integer);
                }

                if (probability >= randomBetween) {
                    skilllist.add(integer);
                }
            }
        }

        if (skilllist.size() < 1) {
            skilllist.addAll(effectlist);
        }

        int rannum = random.nextInt(skilllist.size());
        return (Integer)skilllist.get(rannum);
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
                case 2:
                default:
                    Module.logger.debug("背包类型不正确");
                    return false;
                case 3:
                    this.bag = Module.getInstance().getItemMaps(this.roleId, this.bagId, false);
            }

            this.beibao = (Pack)Module.getInstance().getItemMaps(this.roleId, 1, false);
            ItemBase bi = this.bag.getItem(this.equipKey);
            if (!(bi instanceof EquipItem)) {
                Module.logger.debug("附魔的物品不是装备");
                return false;
            } else {
                this.attr = Module.getInstance().getItemManager().getAttr(bi.getItemId());
                if (!(this.attr instanceof EquipItemShuXing)) {
                    Module.logger.debug("附魔的物品不是装备");
                    return false;
                } else {
                    EquipItemShuXing equipItemShuXing = (EquipItemShuXing)this.attr;
                    EquipItem ei = (EquipItem)bi;
                    if (this.repairType == 0) {
                        if (this.roleId < 0L) {
                            return false;
                        }

                        EquipItemShuXing equipattr = (EquipItemShuXing)Module.getInstance().getItemManager().getAttr(bi.getItemId());
                        int itemid = equipattr.fumoitemid;
                        if (itemid == 0) {
                            System.out.println("未设置装备附魔需求道具");
                            return false;
                        }

                        int fumoNum = equipattr.fumoitemnum;
                        if (fumoNum == 0) {
                            System.out.println("未设置装备附魔需求道具数量");
                            return false;
                        }

                        int needmoney = equipattr.fumomoney;
                        if (needmoney == 0) {
                            System.out.println("未设置装备附魔需求货币数量");
                            return false;
                        }

                        if ((long)needmoney > this.beibao.getGold()) {
                            System.out.println("货币不足！");
                            return true;
                        }

                        if (!this.checkMaterialIsOk(itemid, fumoNum)) {
                            MessageMgr.psendMsgNotify(this.roleId, 193109, (List)null);
                            return true;
                        }

                        if (ei.getEquipAttr().getNeweffect() != 0) {
                            MessageMgr.psendMsgNotify(this.roleId, 193110, (List)null);
                            return true;
                        }

                        if (this.beibao.subGold((long)(-needmoney), "装备附魔消耗", YYLoggerTuJingEnum.tujing_Value_xiuli, 0) != (long)(-needmoney)) {
                            return false;
                        }

                        if (BagUtil.removeItem(this.roleId, itemid, fumoNum, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "附魔消耗道具") != fumoNum) {
                            return false;
                        }

                        Equip equipAttr = ei.getEquipAttr();
                        int neweffect = equipAttr.getNeweffect();
                        int newskill = equipAttr.getNewskill();
                        int skillid = this.RandomSkill();
                        String msg = "";
                        if (neweffect == 0) {
                            equipAttr.setNeweffect(skillid);
                            msg = "第三条";
                        } else {
                            equipAttr.setNewskill(skillid);
                            msg = "第四条";
                        }

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
                        if (this.bagId == 3) {
                            SceneSkillRole sceneSkillRole = SkillManager.getSceneSkillRole(this.roleId);
                            sceneSkillRole.addEquipEffectAndSkillWithSP(ei);
                        }

                        SRepairResult sRepairResult = new SRepairResult();
                        sRepairResult.ret = 1;
                        ArrayList<String> strings = new ArrayList();
                        String name = (new PropRole(this.roleId, false)).getName();
                        strings.add(name);
                        strings.add(ei.getName());
                        strings.add(msg);
                        Procedure.psendWhileCommit(this.roleId, sRepairResult);
                        STransChatMessageNotify2Client ssmn = MessageMgr.getMsgNotify(191228, 0, strings);
                        SceneManager.sendAll(ssmn);
                    }

                    this.writeYYLogger(equipItemShuXing, ei);
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

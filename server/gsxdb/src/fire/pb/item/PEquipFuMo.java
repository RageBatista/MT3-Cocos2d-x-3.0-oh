//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Octets;
import fire.log.YYLogger;
import fire.log.beans.OpEquiRepBean;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PropRole;
import fire.pb.main.ConfigManager;
import fire.pb.map.SceneManager;
import fire.pb.skill.SSkillConfig;
import fire.pb.skill.SceneSkillRole;
import fire.pb.skill.SkillManager;
import fire.pb.talk.MessageMgr;
import fire.pb.talk.STransChatMessageNotify2Client;
import fire.pb.util.BagUtil;
import java.util.ArrayList;
import java.util.Map;
import mkdb.Procedure;
import org.apache.log4j.Logger;
import xbean.Equip;

public class PEquipFuMo extends Procedure {
    private long roleId;
    private int equipKey;
    private int bagId;
    private int skillid;
    private int effectid;
    private int newskillid;
    private int neweffectid;
    private ItemMaps bag = null;
    private Pack beibao = null;
    protected ItemShuXing attr;
    public static final Map<Integer, SSetFumoInfo> SSetFumoInfo = ConfigManager.getInstance().getConf(SSetFumoInfo.class);
    public static final Map<Integer, SSkillConfig> SSkillConfig = ConfigManager.getInstance().getConf(SSkillConfig.class);
    private static Logger logger = Logger.getLogger("ITEM");

    public PEquipFuMo(long roleId, int keyinpack, int packid, int skillid, int effectid, int newskillid, int neweffectid) {
        this.roleId = roleId;
        this.equipKey = keyinpack;
        this.bagId = packid;
        this.skillid = skillid;
        this.effectid = effectid;
        this.newskillid = newskillid;
        this.neweffectid = neweffectid;
    }

    private boolean checkMaterialIsOk(int materialID, int num) {
        int currentNum = this.beibao.getItemNum(materialID, 0);
        return currentNum >= num;
    }

    public boolean process() {
        if (this.bagId != 1 && this.bagId != 3) {
            Module.logger.debug("背包类型不正确");
            return false;
        } else if (this.bagId == 3 && fire.pb.buff.Module.existState(this.roleId, 507004)) {
            return false;
        } else {
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
                Module.logger.debug("附魔的物品不是装备");
                return false;
            } else {
                this.attr = Module.getInstance().getItemManager().getAttr(bi.getItemId());
                if (!(this.attr instanceof EquipItemShuXing)) {
                    Module.logger.debug("附魔的物品不是装备");
                    return false;
                } else {
                    EquipItemShuXing equipattr = (EquipItemShuXing)this.attr;
                    EquipItem ei = (EquipItem)bi;
                    int newskill = ei.getEquipAttr().getNewskill();
                    int neweffect = ei.getEquipAttr().getNeweffect();
                    if (newskill == 0) {
                        this.newskillid = 0;
                    }

                    if (neweffect == 0) {
                        this.neweffectid = 0;
                    }

                    int itemid = 0;
                    int itemnum = 0;
                    int itemnum1 = 0;
                    int itemnum2 = 0;
                    int itemnum3 = 0;
                    String skillname = "";
                    String effectname = "";
                    String newskillname = "";
                    String neweffectname = "";
                    if (this.skillid != 0) {
                        SSetFumoInfo sskillid = (SSetFumoInfo)SSetFumoInfo.get(this.skillid);
                        skillname = ((SSkillConfig)SSkillConfig.get(this.skillid)).name;
                        itemid = sskillid.itemid;
                        itemnum = sskillid.itemnum;
                    }

                    if (this.effectid != 0) {
                        SSetFumoInfo seffectid = (SSetFumoInfo)SSetFumoInfo.get(this.effectid);
                        effectname = ((SSkillConfig)SSkillConfig.get(this.effectid)).name;
                        itemid = seffectid.itemid;
                        itemnum1 = seffectid.itemnum;
                    }

                    if (this.newskillid != 0) {
                        SSetFumoInfo snewskillid = (SSetFumoInfo)SSetFumoInfo.get(this.newskillid);
                        newskillname = ((SSkillConfig)SSkillConfig.get(this.newskillid)).name;
                        itemid = snewskillid.itemid;
                        itemnum2 = snewskillid.itemnum;
                    }

                    if (this.neweffectid != 0) {
                        SSetFumoInfo sneweffectid = (SSetFumoInfo)SSetFumoInfo.get(this.neweffectid);
                        neweffectname = ((SSkillConfig)SSkillConfig.get(this.neweffectid)).name;
                        itemid = sneweffectid.itemid;
                        itemnum3 = sneweffectid.itemnum;
                    }

                    int cout = itemnum + itemnum1 + itemnum2 + itemnum3;
                    if (!this.checkMaterialIsOk(itemid, cout)) {
                        return false;
                    } else if (this.roleId < 0L) {
                        return false;
                    } else if (BagUtil.removeItem(this.roleId, itemid, cout, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "附魔消耗道具") != cout) {
                        return false;
                    } else {
                        this.equipfumo(ei, this.skillid, this.effectid, this.newskillid, this.neweffectid);
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
                        ArrayList<String> strings = new ArrayList();
                        String name = (new PropRole(this.roleId, false)).getName();
                        strings.add(name);
                        strings.add(ei.getName());
                        String msg = "";
                        String msg1 = "";
                        String msg2 = "";
                        String msg3 = "";
                        if (!skillname.equals("")) {
                            String replace = skillname.replace("%", "百分比");
                            msg = "特技:" + replace + " ";
                        }

                        if (!effectname.equals("")) {
                            String replace = effectname.replace("%", "百分比");
                            msg1 = "特效:" + replace + " ";
                        }

                        if (!newskillname.equals("")) {
                            String replace = newskillname.replace("%", "百分比");
                            msg2 = "附加:" + replace + " ";
                        }

                        if (!neweffectname.equals("")) {
                            String replace = neweffectname.replace("%", "百分比");
                            msg3 = "附加:" + replace;
                        }

                        strings.add(msg + msg1 + msg2 + msg3);
                        STransChatMessageNotify2Client ssmn = MessageMgr.getMsgNotify(191231, 0, strings);
                        SceneManager.sendAll(ssmn);
                        if (this.bagId == 3) {
                            SceneSkillRole sceneSkillRole = SkillManager.getSceneSkillRole(this.roleId);
                            sceneSkillRole.addEquipEffectAndSkillWithSP(ei);
                        }

                        SRepairResult sRepairResult = new SRepairResult();
                        sRepairResult.ret = 1;
                        Procedure.psendWhileCommit(this.roleId, sRepairResult);
                        if (sRepairResult.ret != 1) {
                            return false;
                        } else {
                            this.writeYYLogger(equipattr, ei);
                            return true;
                        }
                    }
                }
            }
        }
    }

    private void equipfumo(EquipItem ei, int skillid, int effectid, int newskillid, int neweffectid) {
        Equip equipAttr = ei.getEquipAttr();
        if (skillid != 0) {
            equipAttr.setSkill(skillid);
        }

        if (effectid != 0) {
            equipAttr.setEffect(effectid);
        }

        if (newskillid != 0) {
            equipAttr.setNewskill(newskillid);
        }

        if (neweffectid != 0) {
            equipAttr.setNeweffect(neweffectid);
        }

    }

    private void writeYYLogger(EquipItemShuXing equipattr, EquipItem ei) {
        if (equipattr != null && ei != null) {
            OpEquiRepBean opEquiRepBean = new OpEquiRepBean(equipattr.getId(), equipattr.getLevel(), equipattr.getRare(), ei.getItemId(), ei.getEndure(), this.effectid);
            YYLogger.equiRepLog(this.roleId, opEquiRepBean);
        }
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Octets;
import fire.log.YYLogger;
import fire.log.beans.OpEquiRepBean;
import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.RoleConfigManager;
import fire.pb.buff.Module;
import fire.pb.item.make.BoDongDuan;
import fire.pb.item.make.ItemMakeFactory;
import fire.pb.item.make.ItemMakeUtil;
import fire.pb.item.make.ShuXing;
import fire.pb.item.make.ZhuangBeiShuXing;
import fire.pb.main.ConfigManager;
import fire.pb.product.SErrorCode;
import fire.pb.skill.SceneSkillRole;
import fire.pb.skill.SkillManager;
import fire.pb.talk.MessageMgr;
import fire.pb.team.TeamManager;
import fire.pb.util.BagUtil;
import fire.pb.util.Misc;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import mkdb.Procedure;
import org.apache.log4j.Logger;
import xbean.Equip;

public class PQiangHuaEquipItemAttr extends Procedure {
    private long roleId;
    private int equipKey;
    private int bagId;
    private int repairType;
    private ItemMaps bag = null;
    private Pack beibao = null;
    protected ItemShuXing attr;
    private static Logger logger = Logger.getLogger("ITEM");

    public PQiangHuaEquipItemAttr(long roleId, int keyinpack, int packid, int repairtype) {
        this.roleId = roleId;
        this.equipKey = keyinpack;
        this.bagId = packid;
        this.repairType = repairtype;
    }

    private int getBaseEffectByConfig(Map<Integer, BoDongDuan> paramMap) {
        ArrayList<Integer> arrayList = new ArrayList();

        for(Map.Entry<Integer, BoDongDuan> entry : paramMap.entrySet()) {
            arrayList.add(((BoDongDuan)entry.getValue()).bodongduanbase);
        }

        paramMap.get(0);
        BoDongDuan boDongDuan2 = (BoDongDuan)paramMap.get(paramMap.size() - 1);
        return boDongDuan2.max;
    }

    private ItemBase getItemKey(int itemId) {
        for(ItemBase item : this.beibao) {
            if (itemId == item.getItemId()) {
                return item;
            }
        }

        return null;
    }

    private boolean checkMaterialIsOk(int materialID, int num) {
        int currentNum = this.beibao.getItemNum(materialID, 0);
        return currentNum >= num;
    }

    public boolean process() {
        if (this.bagId != 1 && this.bagId != 3) {
            Module.logger.debug("背包类型不正确");
            return false;
        } else if (this.bagId == 3 && Module.existState(this.roleId, 507004)) {
            return false;
        } else {
            TeamManager.getTeamByRoleId(this.roleId);
            switch (this.bagId) {
                case 1:
                    this.bag = fire.pb.item.Module.getInstance().getItemMaps(this.roleId, this.bagId, false);
                    break;
                case 3:
                    this.bag = fire.pb.item.Module.getInstance().getItemMaps(this.roleId, this.bagId, false);
                    break;
                default:
                    Module.logger.debug("背包类型不正确");
                    return false;
            }

            this.beibao = (Pack)fire.pb.item.Module.getInstance().getItemMaps(this.roleId, 1, false);
            SErrorCode sErrorCode = new SErrorCode();
            ItemBase bi = this.bag.getItem(this.equipKey);
            if (!(bi instanceof EquipItem)) {
                Module.logger.debug("重铸的物品不是装备");
                return false;
            } else {
                this.attr = fire.pb.item.Module.getInstance().getItemManager().getAttr(bi.getItemId());
                if (!(this.attr instanceof EquipItemShuXing)) {
                    Module.logger.debug("重铸的物品不是装备");
                    return false;
                } else {
                    EquipItem ei = (EquipItem)bi;
                    if (this.repairType != 5 && this.repairType != 6) {
                        EquipItemShuXing equipattr = (EquipItemShuXing)this.attr;
                        int itemid = ei.getItemAttr().ronglianitem;
                        int num = ei.getItemAttr().rongliannum;
                        if (!this.checkMaterialIsOk(itemid, num)) {
                            return false;
                        } else {
                            if (this.repairType == 1) {
                                if (this.roleId < 0L) {
                                    return false;
                                }

                                equipattr.getLevel();
                                long needmoney = (long)ei.getItemAttr().ronglianmoney;
                                if (needmoney > this.beibao.getGold()) {
                                    sErrorCode.errorcode = -5;
                                    Procedure.psendWhileCommit(this.roleId, sErrorCode);
                                    return false;
                                }

                                if (this.beibao.subGold(-needmoney, "装备相关", YYLoggerTuJingEnum.tujing_Value_xiuli, 0) != -needmoney) {
                                    return false;
                                }

                                int ret = BagUtil.removeItem(this.roleId, itemid, num, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "熔炼消耗道具");
                                if (ret < 1) {
                                    return false;
                                }

                                EquipItemShuXing equipItemShuXing1 = ei.getItemAttr();
                                int n = equipItemShuXing1.getBaseAttrId();
                                ZhuangBeiShuXing zhuangBeiShuXing = (ZhuangBeiShuXing)ItemMakeUtil.effectConfigs.get(n);
                                if (zhuangBeiShuXing == null) {
                                    return false;
                                }

                                HashMap<Integer, Integer> hashMap = new HashMap();
                                Map<Integer, ShuXing> map = zhuangBeiShuXing.GetERandom();
                                Random random = new Random();
                                int i1 = map.size();
                                int i2 = random.nextInt(i1);
                                int i3 = 0;

                                for(Map.Entry<Integer, ShuXing> entry : map.entrySet()) {
                                    ShuXing shuXing = (ShuXing)entry.getValue();
                                    int i6 = fire.pb.effect.Module.getInstance().getIdByName(shuXing.GetEffectName().trim());
                                    if (i2 == i3) {
                                        int i7 = this.getBaseEffectByConfig(shuXing.GetBodongMap());
                                        hashMap.put(i6, i7);
                                        i2 = random.nextInt(i1);
                                    }

                                    ++i3;
                                }

                                if (((EquipItem)bi).getEquipPos() != 0 && ((EquipItem)bi).getEquipPos() != 3) {
                                    this.SetExtraBaseAttr(hashMap);
                                    if (((EquipItem)bi).getEquipPos() == 0 || ((EquipItem)bi).getEquipPos() == 3) {
                                        ItemMakeFactory.getFactory().setEquipNewShuangJia(this.roleId, (EquipItem)bi);
                                    }
                                } else {
                                    NewShuangJiaInfo equipDoubleInfo = EquipDoubleInfo.getEquipDoubleInfo(this.roleId, bi.getUniqId());
                                    if (equipDoubleInfo != null && equipDoubleInfo.lockstate) {
                                        int maxcount = 0;

                                        for(Integer id : equipDoubleInfo.lockedProp) {
                                            SRonglianAttrLimit sRonglianAttrLimit = (SRonglianAttrLimit)ConfigManager.getInstance().getConf(SRonglianAttrLimit.class).get(id);
                                            if (sRonglianAttrLimit != null && equipDoubleInfo.doubleadd.containsKey(sRonglianAttrLimit.proptype)) {
                                                int value = (Integer)equipDoubleInfo.doubleadd.get(sRonglianAttrLimit.proptype);
                                                if (value == sRonglianAttrLimit.maxvalue) {
                                                    ++maxcount;
                                                }
                                            }
                                        }

                                        if (maxcount == equipDoubleInfo.lockedProp.size()) {
                                            this.SetExtraBaseAttr(hashMap);
                                        } else {
                                            ItemMakeFactory.getFactory().setEquipNewShuangJia(this.roleId, (EquipItem)bi);
                                        }
                                    } else {
                                        this.SetExtraBaseAttr(hashMap);
                                        ItemMakeFactory.getFactory().setEquipNewShuangJia(this.roleId, (EquipItem)bi);
                                    }
                                }

                                int i4 = fire.pb.item.Module.getInstance().getEquipScore(bi);
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
                                Procedure.psendWhileCommit(this.roleId, sRepairResult);
                                if (sRepairResult.ret != 1) {
                                    return false;
                                }
                            } else if (this.repairType == 2) {
                                if (this.roleId < 0L) {
                                    return false;
                                }

                                equipattr.getLevel();
                                long needmoney2 = (long)ei.getItemAttr().ronglianmoney;
                                if (needmoney2 > this.beibao.getGold()) {
                                    sErrorCode.errorcode = -5;
                                    Procedure.psendWhileCommit(this.roleId, sErrorCode);
                                    return false;
                                }

                                if (this.beibao.subGold(-needmoney2, "装备相关", YYLoggerTuJingEnum.tujing_Value_xiuli, 0) != -needmoney2) {
                                    return false;
                                }

                                int ret2 = BagUtil.removeItem(this.roleId, itemid, num, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "熔炼消耗道具");
                                if (ret2 < 1) {
                                    return false;
                                }

                                this.SetExtraAddAttr();
                                int i42 = fire.pb.item.Module.getInstance().getEquipScore(bi);
                                ei.getEquipAttr().setEquipscore(i42);
                                if (i42 >= ei.getItemAttr().getTreasureScore()) {
                                    ei.getEquipAttr().setTreasure(1);
                                } else {
                                    ei.getEquipAttr().setTreasure(0);
                                }

                                Octets octets2 = ei.getTips();
                                SGetItemTips sGetItemTips2 = new SGetItemTips(this.bagId, this.equipKey, octets2);
                                Procedure.psendWhileCommit(this.roleId, sGetItemTips2);
                                if (this.bagId == 3) {
                                    SceneSkillRole sceneSkillRole2 = SkillManager.getSceneSkillRole(this.roleId);
                                    sceneSkillRole2.addEquipEffectAndSkillWithSP(ei);
                                }

                                SRepairResult sRepairResult2 = new SRepairResult();
                                sRepairResult2.ret = 1;
                                Procedure.psendWhileCommit(this.roleId, sRepairResult2);
                                if (sRepairResult2.ret != 1) {
                                    return false;
                                }
                            } else if (this.repairType == 3) {
                                if (this.roleId < 0L) {
                                    return false;
                                }

                                long needmoney3 = (long)Integer.parseInt(RoleConfigManager.getRoleCommonConfig(603).getValue());
                                int item = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(604).getValue());
                                int itemnum = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(605).getValue());
                                if (needmoney3 > this.beibao.getGold()) {
                                    sErrorCode.errorcode = -5;
                                    Procedure.psendWhileCommit(this.roleId, sErrorCode);
                                    return false;
                                }

                                if (this.beibao.subGold(-needmoney3, "装备相关", YYLoggerTuJingEnum.tujing_Value_xiuli, 0) != -needmoney3) {
                                    MessageMgr.psendMsgNotify(this.roleId, 160118, (List)null);
                                    return false;
                                }

                                int ret3 = BagUtil.removeItem(this.roleId, item, itemnum, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "熔炼消耗道具");
                                if (ret3 < 1) {
                                    return false;
                                }

                                Equip equipAttrOne = ((EquipItem)bi).getEquipAttr();
                                int skillid = (int)((double)420001.0F + Math.random() * (double)33.0F);
                                int skillid1 = (int)((double)430001.0F + Math.random() * (double)63.0F);
                                equipAttrOne.setNeweffect(skillid1);
                                equipAttrOne.setNewskill(skillid);
                                int i43 = fire.pb.item.Module.getInstance().getEquipScore(bi);
                                ei.getEquipAttr().setEquipscore(i43);
                                if (i43 >= ei.getItemAttr().getTreasureScore()) {
                                    ei.getEquipAttr().setTreasure(1);
                                } else {
                                    ei.getEquipAttr().setTreasure(0);
                                }

                                Octets octets3 = ei.getTips();
                                SGetItemTips sGetItemTips3 = new SGetItemTips(this.bagId, this.equipKey, octets3);
                                Procedure.psendWhileCommit(this.roleId, sGetItemTips3);
                                SRepairResult sRepairResult3 = new SRepairResult();
                                sRepairResult3.ret = 1;
                                Procedure.psendWhileCommit(this.roleId, sRepairResult3);
                                if (sRepairResult3.ret != 1) {
                                    return false;
                                }
                            } else if (this.repairType == 4) {
                                if (this.roleId < 0L) {
                                    return false;
                                }

                                long needmoney4 = (long)Integer.parseInt(RoleConfigManager.getRoleCommonConfig(603).getValue());
                                int item2 = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(604).getValue());
                                int itemnum2 = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(605).getValue());
                                if (needmoney4 > this.beibao.getGold()) {
                                    sErrorCode.errorcode = -5;
                                    Procedure.psendWhileCommit(this.roleId, sErrorCode);
                                    return false;
                                }

                                if (this.beibao.subGold(-needmoney4, "装备相关", YYLoggerTuJingEnum.tujing_Value_xiuli, 0) != -needmoney4) {
                                    return false;
                                }

                                int ret4 = BagUtil.removeItem(this.roleId, item2, itemnum2, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "熔炼消耗道具");
                                if (ret4 < 1) {
                                    return false;
                                }

                                Equip equipAttrOne2 = ((EquipItem)bi).getEquipAttr();
                                int skillid2 = (int)((double)430001.0F + Math.random() * (double)63.0F);
                                equipAttrOne2.setNeweffect(skillid2);
                                System.out.println(equipAttrOne2.getNeweffect());
                                int i44 = fire.pb.item.Module.getInstance().getEquipScore(bi);
                                ei.getEquipAttr().setEquipscore(i44);
                                if (i44 >= ei.getItemAttr().getTreasureScore()) {
                                    ei.getEquipAttr().setTreasure(1);
                                } else {
                                    ei.getEquipAttr().setTreasure(0);
                                }

                                Octets octets4 = ei.getTips();
                                SGetItemTips sGetItemTips4 = new SGetItemTips(this.bagId, this.equipKey, octets4);
                                Procedure.psendWhileCommit(this.roleId, sGetItemTips4);
                                SRepairResult sRepairResult4 = new SRepairResult();
                                sRepairResult4.ret = 1;
                                Procedure.psendWhileCommit(this.roleId, sRepairResult4);
                                if (sRepairResult4.ret != 1) {
                                    return false;
                                }
                            }

                            this.writeYYLogger(equipattr, ei);
                            return true;
                        }
                    } else {
                        NewShuangJiaInfo equipDoubleInfo = EquipDoubleInfo.getEquipDoubleInfo(this.roleId, ei.getUniqId());
                        if (equipDoubleInfo == null) {
                            return false;
                        } else {
                            if (this.repairType == 5) {
                                equipDoubleInfo.lockstate = true;
                            } else {
                                equipDoubleInfo.lockstate = false;
                            }

                            HashMap<Long, NewShuangJiaInfo> equipAllInfo = EquipDoubleInfo.getEquipAllInfo(this.roleId);
                            equipAllInfo.put(ei.getUniqId(), equipDoubleInfo);
                            EquipDoubleInfo.UpdateEquipInfo(this.roleId, equipAllInfo);
                            Octets octets = ei.getTips();
                            SGetItemTips sGetItemTips = new SGetItemTips(this.bagId, this.equipKey, octets);
                            Procedure.psendWhileCommit(this.roleId, sGetItemTips);
                            return true;
                        }
                    }
                }
            }
        }
    }

    public int getNewBaseAddValue() {
        int rnd = Misc.getRandomBetween(1, 2);
        Integer ronglian = Integer.valueOf(RoleConfigManager.getRoleCommonConfig(608).value);
        if (Misc.getRandomBetween(1, 100) < ronglian) {
            rnd = -1;
        }

        return rnd;
    }

    public void SetExtraBaseAttr(Map<Integer, Integer> paramMap) {
        ItemBase bi = this.bag.getItem(this.equipKey);
        EquipItem ei = (EquipItem)bi;
        Map<Integer, Integer> extraattr = ei.getEquipAttr().getExtraattr();
        Map<Integer, Integer> extraattr1 = ei.getEquipAttr().getAttr();

        for(Map.Entry<Integer, Integer> entry : paramMap.entrySet()) {
            for(Map.Entry<Integer, Integer> entry1 : paramMap.entrySet()) {
                int key = (Integer)entry.getKey();
                int key1 = (Integer)entry1.getKey();
                int extraattrvalue = 0;
                int extraattrvalue1 = 0;
                int i = this.getNewBaseAddValue();
                if (extraattr.get(key) != null) {
                    extraattrvalue = (Integer)extraattr.get(key);
                }

                if (extraattr1.get(key1) != null) {
                    extraattrvalue1 = (Integer)extraattr1.get(key1);
                }

                int newaddvalue = extraattrvalue + i;
                SRongLianAttr attr = (SRongLianAttr)ConfigManager.getInstance().getConf(SRongLianAttr.class).get(key - 1);
                if (attr != null) {
                    if (extraattrvalue >= attr.maxvalue) {
                        continue;
                    }

                    if (newaddvalue < attr.minvalue) {
                        newaddvalue = attr.minvalue;
                    }

                    if (newaddvalue > attr.maxvalue) {
                        newaddvalue = attr.maxvalue;
                    }
                }

                extraattr.put(key, newaddvalue);
            }
        }

    }

    public void SetExtraAddAttr() {
        int cishu = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(602).getValue());
        int max = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(603).getValue());
        ItemBase bi = this.bag.getItem(this.equipKey);
        EquipItem ei = (EquipItem)bi;
        Map<Integer, Integer> addattr = ei.getEquipAttr().getAddattr();
        Map<Integer, Integer> extraaddattr = ei.getEquipAttr().getExtraaddattr();

        for(Integer integer : addattr.keySet()) {
            int curvalue = 0;
            if (extraaddattr.get(integer) != null) {
                curvalue = (Integer)extraaddattr.get(integer);
            }

            int extraddattrvalue = curvalue + cishu;
            if (extraddattrvalue > max) {
                extraddattrvalue = max;
            }

            extraaddattr.put(integer, extraddattrvalue);
        }

    }

    private void writeYYLogger(EquipItemShuXing equipattr, EquipItem ei) {
        if (equipattr != null && ei != null) {
            OpEquiRepBean opEquiRepBean = new OpEquiRepBean(equipattr.getId(), equipattr.getLevel(), equipattr.getRare(), ei.getItemId(), ei.getEndure(), this.repairType);
            YYLogger.equiRepLog(this.roleId, opEquiRepBean);
        }
    }
}

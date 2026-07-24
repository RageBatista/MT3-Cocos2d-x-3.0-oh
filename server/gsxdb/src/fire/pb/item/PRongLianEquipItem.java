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
import fire.pb.item.make.BoDongDuan;
import fire.pb.item.make.ItemMakeUtil;
import fire.pb.item.make.ShuXing;
import fire.pb.item.make.ZhuangBeiShuXing;
import fire.pb.skill.SceneSkillRole;
import fire.pb.skill.SkillManager;
import fire.pb.talk.MessageMgr;
import fire.pb.team.TeamManager;
import fire.pb.util.BagUtil;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import mkdb.Procedure;
import org.apache.log4j.Logger;
import xbean.Equip;

public class PRongLianEquipItem extends Procedure {
    private long roleId;
    private int equipKey;
    private int bagId;
    private int repairType;
    private ItemMaps bag = null;
    private Pack beibao = null;
    protected ItemShuXing attr;
    private static Logger logger = Logger.getLogger("ITEM");

    public PRongLianEquipItem(long roleId, int keyinpack, int packid, int repairtype) {
        this.roleId = roleId;
        this.equipKey = keyinpack;
        this.bagId = packid;
        this.repairType = repairtype;
    }

    private boolean checkMaterialIsOk(int paramInt1, int paramInt2) {
        int i = this.beibao.getItemNum(paramInt1, 0);
        return i >= paramInt2;
    }

    private int getBaseEffectByConfig(Map<Integer, BoDongDuan> paramMap) {
        ArrayList<Integer> arrayList = new ArrayList();

        for(Map.Entry<Integer, BoDongDuan> entry : paramMap.entrySet()) {
            arrayList.add(((BoDongDuan)entry.getValue()).bodongduanbase);
        }

        BoDongDuan boDongDuan2 = (BoDongDuan)paramMap.get(paramMap.size() - 1);
        return boDongDuan2.max;
    }

    private int checkRonglian(EquipItem ei, HashMap<Integer, Integer> hashMap) {
        Map<Integer, Integer> addattr = ei.getEquipAttr().getAddattr();
        if (addattr == null) {
            return 1;
        } else {
            int maxnum = 0;

            for(Integer integer : addattr.keySet()) {
                Integer integer1 = (Integer)addattr.get(integer);
                if (integer1 >= 9999) {
                    ++maxnum;
                }
            }

            if (addattr.size() == maxnum && addattr.size() != 0) {
                return 0;
            } else {
                int max = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(566).getValue());
                Equip equipAttr = ei.getEquipAttr();
                Map<Integer, Integer> map = equipAttr.getAttr();
                maxnum = 0;

                for(Map.Entry<Integer, Integer> effectmap : hashMap.entrySet()) {
                    int current = (Integer)map.get(effectmap.getKey());
                    int maxvalue = (Integer)effectmap.getValue() + max;
                    if (current == maxvalue) {
                        ++maxnum;
                    }
                }

                if (map.size() == maxnum && map.size() != 0) {
                    return 0;
                } else {
                    return 1;
                }
            }
        }
    }

    public void ronglian(EquipItem equipItem, Map<Integer, Integer> paramMap) {
        Random random = new Random();
        int max = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(566).getValue());
        Equip equipAttr = equipItem.getEquipAttr();
        Map<Integer, Integer> addattr = equipAttr.getAddattr();

        for(Integer integer : addattr.keySet()) {
            int i = random.nextInt(7) - 2;
            int addnum = (Integer)addattr.get(integer) + i;
            if (addnum >= 9999) {
                addnum = 9999;
            }

            addattr.put(integer, addnum);
        }

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
                Module.logger.debug("重铸的物品不是装备");
                return false;
            } else {
                this.attr = Module.getInstance().getItemManager().getAttr(bi.getItemId());
                if (!(this.attr instanceof EquipItemShuXing)) {
                    Module.logger.debug("重铸的物品不是装备");
                    return false;
                } else {
                    EquipItemShuXing equipItemShuXing = (EquipItemShuXing)this.attr;
                    EquipItem ei = (EquipItem)bi;
                    int itemId = ei.getItemAttr().chongzhuitemid;
                    if (this.repairType == 1) {
                        if (this.roleId < 0L) {
                            return false;
                        }

                        EquipItemShuXing equipattr = (EquipItemShuXing)Module.getInstance().getItemManager().getAttr(bi.getItemId());
                        int itemid = equipattr.equipitemid > 0 ? equipattr.equipitemid : 0;
                        if (itemid == 0) {
                            System.out.println("未设置装备点化需求道具");
                            return false;
                        }

                        int rongLianNum = equipattr.equipnum > 0 ? equipattr.equipnum : 0;
                        if (rongLianNum == 0) {
                            System.out.println("未设置装备点化需求道具数量");
                            return false;
                        }

                        int needmoney = equipattr.equipmoney > 0 ? equipattr.equipmoney : 0;
                        if (needmoney == 0) {
                            System.out.println("未设置装备点化需求货币数量");
                            return false;
                        }

                        if ((long)needmoney > this.beibao.getGold()) {
                            System.out.println("货币不足！");
                            return true;
                        }

                        if (!this.checkMaterialIsOk(itemid, rongLianNum)) {
                            MessageMgr.psendMsgNotify(this.roleId, 191224, (List)null);
                            return true;
                        }

                        if (this.beibao.subGold((long)(-needmoney), "装备相关", YYLoggerTuJingEnum.tujing_Value_xiuli, 0) != (long)(-needmoney)) {
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

                        for(Map.Entry entry : map.entrySet()) {
                            ShuXing shuXing = (ShuXing)entry.getValue();
                            int i6 = fire.pb.effect.Module.getInstance().getIdByName(shuXing.GetEffectName().trim());
                            if (i2 == i3) {
                                int i7 = this.getBaseEffectByConfig(shuXing.GetBodongMap());
                                hashMap.put(i6, i7);
                                i2 = random.nextInt(i1);
                            }

                            ++i3;
                        }

                        if (this.checkRonglian(ei, hashMap) == 0) {
                            MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 192817, (List)null);
                            return true;
                        }

                        if (BagUtil.removeItem(this.roleId, itemid, rongLianNum, YYLoggerTuJingEnum.tujing_Value_xiuli, 0, "熔炼消耗道具") != rongLianNum) {
                            return false;
                        }

                        this.ronglian(ei, hashMap);
                        int i4 = Module.getInstance().getEquipScore(bi);
                        ei.getEquipAttr().setEquipscore(i4);
                        if (i4 >= ei.getItemAttr().getTreasureScore()) {
                            ei.getEquipAttr().setTreasure(1);
                        } else {
                            ei.getEquipAttr().setTreasure(0);
                        }

                        Octets octets = ei.getTips();
                        boolean bool = this.bagId == 0 ? true : true;
                        SGetItemTips sGetItemTips = new SGetItemTips(this.bagId, this.equipKey, octets);
                        Procedure.psendWhileCommit(this.roleId, sGetItemTips);
                        MessageMgr.psendMsgNotifyWhileCommit(this.roleId, 141443, (List)null);
                        if (this.bagId == 3) {
                            SceneSkillRole sceneSkillRole = SkillManager.getSceneSkillRole(this.roleId);
                            sceneSkillRole.addEquipEffectAndSkillWithSP(ei);
                        }

                        SRepairResult sRepairResult = new SRepairResult();
                        sRepairResult.ret = 1;
                        Procedure.psendWhileCommit(this.roleId, sRepairResult);
                        int i5 = 192811;
                        if (sRepairResult.ret != 1) {
                            return false;
                        }

                        MessageMgr.psendMsgNotify(this.roleId, i5, (List)null);
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

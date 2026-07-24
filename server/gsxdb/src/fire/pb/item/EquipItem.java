//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import com.locojoy.base.Octets;
import com.locojoy.base.Marshal.OctetsStream;
import fire.msp.move.GRoleEquipChange;
import fire.pb.GsClient;
import fire.pb.attr.SRefreshRoleData;
import fire.pb.buff.continual.ConstantlyBuffConfig;
import fire.pb.item.equip.WeaponItem;
import fire.pb.item.make.BoDongDuan;
import fire.pb.item.make.ItemMakeUtil;
import fire.pb.item.make.ShuXing;
import fire.pb.item.make.ZhuangBeiShuXing;
import fire.pb.skill.Result;
import fire.pb.skill.SceneSkillRole;
import fire.pb.skill.SkillManager;
import fire.pb.team.Team;
import fire.pb.team.TeamManager;
import fire.pb.util.Misc;
import fire.pb.util.RolePropConf;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Random;
import mkdb.Bean;
import mkdb.Procedure;
import xbean.EnhancementData;
import xbean.Equip;
import xbean.Item;
import xbean.Pod;
import xbean.Properties;
import xtable.Equips;

public abstract class EquipItem extends ItemBase {
    private Equip equipAttr;

    public EquipItem(ItemMgr im, int itemid) {
        super(im, itemid);
        this.equipAttr = Pod.newEquip();
        this.equipAttr.setEquiplevel(this.itemAttr.getLevel());
        Long nextkey = Equips.insert(this.equipAttr);
        this.itemData.setExtid(nextkey);
    }

    public EquipItem(ItemMgr im, int itemid, Bean extinfo) {
        super(im, itemid);
        this.equipAttr = Pod.newEquip();
        this.equipAttr.setEquiplevel(this.itemAttr.getLevel());
        Long nextkey = Equips.insert(this.equipAttr);
        this.itemData.setExtid(nextkey);
        this.setExtinfo(extinfo);
    }

    public EquipItem(ItemMgr im, Item item) {
        super(im, item);
        if (!item.isData()) {
            this.equipAttr = Equips.get(item.getExtid());
        } else {
            this.equipAttr = Equips.select(item.getExtid());
        }

        if (this.equipAttr == null) {
            throw new RuntimeException("Equip data missing: extid=" + item.getExtid()
                + ", itemId=" + item.getId() + ", isData=" + item.isData());
        }

    }

    public boolean isEquipmentBroken() {
        return this.equipAttr != null && this.equipAttr.getEndure() <= 0;
    }

    public boolean isCurrentlyEquipped() {
        return itemData.getPosition() > 0 && itemData.getPosition() < 20;
    }

    public EquipError canEquipment(int pos, int roleLevel, int rolesex, int shape, int school) {
        if (pos != 12 && pos != 13 && pos != 14 && pos != 15 && pos != 9 && pos != this.getEquipPos()) {
            return EquipItem.EquipError.POS_NOT_SUIT;
        } else if (this.equipAttr.getEndure() <= 0) {
            return EquipItem.EquipError.ZERO_ENDURE;
        } else {
            int requirelevel = this.itemAttr.needlevel;
            if (this.equipAttr.getEffect() != 430034 && this.equipAttr.getNewskill() != 430034) {
                if (this.equipAttr.getEffect() == 430035 || this.equipAttr.getNewskill() == 430035) {
                    requirelevel = 1;
                }
            } else {
                requirelevel = Math.max(1, requirelevel - 5);
            }

            ArrayList<Integer> shapes = ((EquipItemShuXing)this.itemAttr).roleNeed;
            if (shapes != null && !shapes.isEmpty() && !shapes.contains(RolePropConf.getShapeidByXshapeid(shape))) {
                return EquipItem.EquipError.SHAPE_NOT_SUIT;
            } else if (roleLevel < requirelevel) {
                return EquipItem.EquipError.LEVEL_NOT_SUIT;
            } else if (!this.isNeedSex(rolesex)) {
                return EquipItem.EquipError.SEX_NOT_SUIT;
            } else {
                return !this.isNeedSchool(school) ? EquipItem.EquipError.SCHOOL_NOT_SUIT : EquipItem.EquipError.NO_ERROR;
            }
        }
    }

    public Map<Integer, Integer> getBaseAttr() {
        Map<Integer, Integer> baseAttr = new HashMap();
        baseAttr.putAll(this.equipAttr.getAttr());
        return baseAttr;
    }

    public Map<Integer, Integer> getAddAttr() {
        Map<Integer, Integer> addAttr = new HashMap();
        addAttr.putAll(this.equipAttr.getAddattr());
        return addAttr;
    }

    public int getCurMaxEndure() {
        return this.equipAttr.getCurmaxendure();
    }

    protected void getEffects(Map<Integer, Float> effects) {
        Map<Integer, Integer> baseAttr = this.getBaseAttr();

        for(Map.Entry<Integer, Integer> attr : baseAttr.entrySet()) {
            int key = (Integer)attr.getKey();
            int value = (Integer)attr.getValue();
            effects.put(key, (float)value);
        }

        Map<Integer, Integer> addAttr = this.getAddAttr();
        for(Map.Entry<Integer, Integer> attr : addAttr.entrySet()) {
            int key = (Integer)attr.getKey();
            int value = (Integer)attr.getValue();
            effects.put(key, (float)value);
        }

        for(Map.Entry<Integer, Integer> extraattr : this.equipAttr.getExtraattr().entrySet()) {
            int key = (Integer)extraattr.getKey();
            float value = (float)(Integer)extraattr.getValue();
            Float v = (Float)effects.get(key);
            if (v == null) {
                effects.put(key, value);
            } else {
                effects.put(key, v + value);
            }
        }

        for(Map.Entry<Integer, Integer> extraaddattr : this.equipAttr.getExtraaddattr().entrySet()) {
            int key = (Integer)extraaddattr.getKey();
            float value = (float)(Integer)extraaddattr.getValue();
            Float v = (Float)effects.get(key);
            if (v == null) {
                effects.put(key, value);
            } else {
                effects.put(key, v + value);
            }
        }

        for(Map.Entry<Integer, EnhancementData> e : this.equipAttr.getEnhancement().entrySet()) {
            for(Map.Entry<Integer, Integer> attr : ((EnhancementData)e.getValue()).getEnhancementattr().entrySet()) {
                int key = (Integer)attr.getKey();
                float value = (float)(Integer)attr.getValue();
                Float v = (Float)effects.get(key);
                if (v == null) {
                    effects.put(key, value);
                } else {
                    effects.put(key, v + value);
                }
            }
        }

        NewShuangJiaInfo dinfo = EquipDoubleInfo.getEquipDoubleInfo(this.roleid, this.getUniqId());
        if (dinfo != null) {
            for(Map.Entry<Integer, Integer> entry : dinfo.doubleadd.entrySet()) {
                if (effects.containsKey(entry.getKey())) {
                    effects.put(entry.getKey(), (Float)effects.get(entry.getKey()) + ((Integer)entry.getValue()).floatValue());
                } else {
                    effects.put(entry.getKey(), ((Integer)entry.getValue()).floatValue());
                }
            }
        }

        if (this.equipAttr.getDiamonds().size() > 0) {
            for(Integer gemID : this.equipAttr.getDiamonds()) {
                GemItem.addGemProp(gemID, effects, false);
            }
        }

    }

    public void getEffectsAndBuffs(Map<Integer, Float> effects, List<ConstantlyBuffConfig> buffs) {
        this.getEffects(effects);
    }

    public Octets getEmptyTips() {
        if (this.os == null) {
            this.os = new OctetsStream();
            // 1. lockstate (char) (2字节)
            this.os.marshal((byte)0);
            // 2. shuangjia (空 map)
            this.os.marshal(0);
            // 3. baseEffect (空 map)
            this.os.marshal(0);
            // 4. extrabaseEffect (空 map)
            this.os.marshal(0);
            // 5. plusEffect (空 map)
            this.os.marshal(0);
            // 6. extraplusEffect (空 map)
            this.os.marshal(0);
            // 7. 离婚
            this.os.marshal(0);
            // 8.技能效果
            this.os.marshal(0);
            // 9.装备
            this.os.marshal(0);
            // 10.新闻技能
            this.os.marshal(0);
            // 11.新闻技能效果
            this.os.marshal(0);
            // 12. gemlist (空列表)
            this.os.marshal(0);
            // 13. 忍受
            this.os.marshal(this.equipAttr != null ? this.equipAttr.getEndure() : 0);
            // 14.耐力
            this.os.marshal(this.equipAttr != null ? this.equipAttr.getMaxendure() : 0);
            // 15. 修复时间
            this.os.marshal(0);
            // 16. 装备评分
            this.os.marshal(0);
            // 17. maker (空字符串)
            try {
                String producer = (this.equipAttr != null) ? this.equipAttr.getProducer() : "";
                if (producer == null) producer = "";
                this.os.marshal(new Octets(producer.getBytes("UTF-16LE")));
            } catch (UnsupportedEncodingException var2) {
                var2.printStackTrace();
            }
            // 18. vFumo (空列表)
            this.os.marshal(0);
            // 19. crystalnum (水晶数量)
            // 功能未实现，硬编码为0
            this.os.marshal(0);
            // 20. crystalprogress (水晶进度)
            // 功能未实现，硬编码为0
            this.os.marshal(0);
            // 21. blesslv (祝福等级)
            // 功能未实现，硬编码为0
            this.os.marshal(0);
        }

        return this.os;
    }

    public int getEndure() {
        return this.equipAttr.getEndure();
    }

    public Equip getEquipAttr() {
        return this.equipAttr;
    }

    public int getEquipPos() {
        return this.getEquipType();
    }

    public Equip getExtInfo() {
        return this.equipAttr;
    }

    protected int getGrowattr(int type) {
        Map<Integer, Integer> baseAttr = this.getBaseAttr();
        Map<Integer, Integer> addAttr = this.getAddAttr();
        Integer value = (Integer)baseAttr.get(type);
        if (value == null) {
            value = (Integer)addAttr.get(type);
        }
        return value == null ? 0 : value;
    }

    public EquipItemShuXing getItemAttr() {
        return (EquipItemShuXing)this.itemAttr;
    }

    public String getName() {
        return this.itemAttr.name;
    }

    protected int getFailTimes() {
        return this.equipAttr.getRepairtimes();
    }

    public Octets getTips() {
        // 添加空值检查，防止 equipAttr 为 null 时抛出异常
        if (this.equipAttr == null) {
            Module.logger.error("EquipItem.getTips: equipAttr is null, itemId=" + this.itemData.getId() + ", extid=" + this.itemData.getExtid());
            return getEmptyTips();
        }
        return this.getTipsAgain();
    }

    public Octets getTipsAgain() {
        // 临时强制重新生成Tips，确保新序列化逻辑生效
        this.os = null;
        if (this.os == null) {
            if (this.equipAttr == null) {
                Module.logger.error("EquipItem.getTipsAgain: equipAttr is null, returning empty tips");
                return getEmptyTips();
            }

            // ========== 装备属性诊断日志 ==========
            Map<Integer, Integer> diagBaseMap = this.equipAttr.getAttr();
            Map<Integer, Integer> diagAddMap = this.equipAttr.getAddattr();
            Map<Integer, Integer> diagExtraBaseMap = this.equipAttr.getExtraattr();
            Map<Integer, Integer> diagExtraAddMap = this.equipAttr.getExtraaddattr();
            int diagScore = this.equipAttr.getEquipscore();

            Module.logger.info("[装备诊断] itemId=" + this.itemData.getId()
                + ", extid=" + this.itemData.getExtid()
                + ", 基础属性数量=" + (diagBaseMap != null ? diagBaseMap.size() : "null")
                + ", 熔炼属性数量=" + (diagAddMap != null ? diagAddMap.size() : "null")
                + ", 额外基础属性数量=" + (diagExtraBaseMap != null ? diagExtraBaseMap.size() : "null")
                + ", 额外附加属性数量=" + (diagExtraAddMap != null ? diagExtraAddMap.size() : "null")
                + ", 评分=" + diagScore);

            if (diagBaseMap != null && !diagBaseMap.isEmpty()) {
                for (Map.Entry<Integer, Integer> e : diagBaseMap.entrySet()) {
                    Module.logger.info("[基础属性] attrType=" + e.getKey() + ", value=" + e.getValue());
                }
            } else {
                Module.logger.warn("[装备诊断] 基础属性为空! itemId=" + this.itemData.getId());
            }

            if (diagAddMap != null && !diagAddMap.isEmpty()) {
                for (Map.Entry<Integer, Integer> e : diagAddMap.entrySet()) {
                    Module.logger.info("[熔炼属性] attrType=" + e.getKey() + ", value=" + e.getValue());
                }
            } else {
                Module.logger.info("[装备诊断] 熔炼属性为空(未熔炼), itemId=" + this.itemData.getId());
            }

            if (diagScore == 0) {
                Module.logger.warn("[装备诊断] 评分为0! itemId=" + this.itemData.getId()
                    + ", equipPos=" + this.getEquipPos());
            }
            // ========== 诊断日志结束 ==========

            this.os = new OctetsStream();

            try {
                // 1-2. shuangjia (双加属性) - 从EquipDoubleInfo获取
                // 注意：这里lockstate和shuangjia合并处理，参考反编译代码逻辑
                NewShuangJiaInfo dinfo = EquipDoubleInfo.getEquipDoubleInfo(this.roleid, this.getUniqId());
                if (dinfo != null && dinfo.doubleadd != null) {
                    this.os.marshal(dinfo.lockstate);  // 使用实际的lockstate值
                    this.os.marshal(dinfo.doubleadd.size());
                    for (Map.Entry<Integer, Integer> entry : dinfo.doubleadd.entrySet()) {
                        // 属性键值取整：去掉个位数（如 61 -> 60, 141 -> 140）
                        this.os.marshal(entry.getKey() - entry.getKey() % 10);
                        this.os.marshal(entry.getValue());
                    }
                } else {
                    this.os.marshal(false);  // 锁定状态=假
                    this.os.marshal(0);      // shuangjia size = 0
                }

                // 3. baseEffect (基础属性)
                Map<Integer, Integer> baseMap = this.equipAttr.getAttr();
                this.os.marshal(baseMap.size());
                for (Map.Entry<Integer, Integer> entry : baseMap.entrySet()) {
                    // 属性键值取整：去掉个位数
                    this.os.marshal(entry.getKey() - entry.getKey() % 10);
                    this.os.marshal(entry.getValue());
                }

                // 4. extrabaseEffect (额外基础属性 extraattr)
                Map<Integer, Integer> extraBaseMap = this.equipAttr.getExtraattr();
                this.os.marshal(extraBaseMap.size());
                for (Map.Entry<Integer, Integer> entry : extraBaseMap.entrySet()) {
                    // 属性键值取整：去掉个位数
                    this.os.marshal(entry.getKey() - entry.getKey() % 10);
                    this.os.marshal(entry.getValue());
                }

                // 5. plusEffect (熔炼属性 addattr)
                Map<Integer, Integer> addMap = this.equipAttr.getAddattr();
                this.os.marshal(addMap.size());
                for (Map.Entry<Integer, Integer> entry : addMap.entrySet()) {
                    // 属性键值取整：去掉个位数
                    this.os.marshal(entry.getKey() - entry.getKey() % 10);
                    this.os.marshal(entry.getValue());
                }

                // 6. extraplusEffect (额外附加属性 extraaddattr)
                Map<Integer, Integer> extraAddMap = this.equipAttr.getExtraaddattr();
                this.os.marshal(extraAddMap.size());
                for (Map.Entry<Integer, Integer> entry : extraAddMap.entrySet()) {
                    // 属性键值取整：去掉个位数
                    this.os.marshal(entry.getKey() - entry.getKey() % 10);
                    this.os.marshal(entry.getValue());
                }

                // 7. 离婚
                this.os.marshal(this.equipAttr.getSkill());

                // 8.技能效果
                this.os.marshal(this.equipAttr.getEffect());

                // 9. equipsit (套装)
                this.os.marshal(this.equipAttr.getEquipsit());

                // 10.新闻技能
                this.os.marshal(this.equipAttr.getNewskill());

                // 11.新闻技能效果
                this.os.marshal(this.equipAttr.getNeweffect());

                // 12. gemlist (宝石列表)
                List<Integer> diamonds = this.equipAttr.getDiamonds();
                this.os.marshal(diamonds.size());
                for (Integer gemId : diamonds) {
                    this.os.marshal(gemId);
                }

                // 13. endure (耐久)
                this.os.marshal(this.equipAttr.getEndure());

                // 14. endureuplimit (最大耐久)
                this.os.marshal(this.equipAttr.getMaxendure());

                // 15. repairTimes (修理失败次数)
                this.os.marshal(this.equipAttr.getRepairtimes());

                // 16. equipscore (装备评分)
                this.os.marshal(this.equipAttr.getEquipscore());

                // 17. maker (制造者 - wstring格式)
                try {
                    String producer = this.equipAttr.getProducer();
                    if (producer == null) {
                        producer = "";
                    }
                    this.os.marshal(new Octets(producer.getBytes("UTF-16LE")));
                } catch (UnsupportedEncodingException ex) {
                    Module.logger.error("EquipItem.getTipsAgain: 不支持的编码异常 for producer", ex);
                    try {
                        this.os.marshal(new Octets("".getBytes("UTF-16LE")));
                    } catch (UnsupportedEncodingException e) {
                        // 忽略
                    }
                }

                // 18. vFumo (附魔数据)
                Map<Integer, EnhancementData> enhancement = this.equipAttr.getEnhancement();
                this.os.marshal(enhancement.size());
                for (Map.Entry<Integer, EnhancementData> e : enhancement.entrySet()) {
                    Map<Integer, Integer> enhancementAttr = e.getValue().getEnhancementattr();
                    this.os.marshal(enhancementAttr.size());
                    for (Map.Entry<Integer, Integer> attr : enhancementAttr.entrySet()) {
                        this.os.marshal(attr.getKey());
                        this.os.marshal(attr.getValue());
                    }
                    this.os.marshal(e.getValue().getEnhancementtime());
                }

                // 19. crystalnum (水晶数量)
                // 功能未实现，硬编码为0
                this.os.marshal(0);

                // 20. crystalprogress (水晶进度)
                // 功能未实现，硬编码为0
                this.os.marshal(0);

                // 21. blesslv (祝福等级)
                // 功能未实现，硬编码为0
                this.os.marshal(0);

                // ========== 序列化完成诊断日志 ==========
                Module.logger.info("[序列化完成] itemId=" + this.itemData.getId()
                    + ", tipsSize=" + this.os.size()
                    + ", 评分=" + this.equipAttr.getEquipscore()
                    + ", 熔炼属性数=" + addMap.size()
                    + ", 序列化版本=V2_FIXED");

            } catch (Exception e) {
                Module.logger.error("EquipItem.getTipsAgain: Exception while building tips, itemId=" + this.itemData.getId(), e);
                this.os = new OctetsStream();
                return getEmptyTips();
            }
        }

        return this.os;
    }

    public int getTreasure() {
        return this.equipAttr.getTreasure();
    }

    private boolean isEffectItem() {
        return this instanceof WeaponItem;
    }

    private boolean isNeedSex(int rolesex) {
        int needSex = ((EquipItemShuXing)this.itemAttr).needSex;
        if (needSex == 0) {
            return true;
        } else {
            return rolesex == needSex;
        }
    }

    private boolean isNeedSchool(Integer school) {
        List<Integer> schoolLst = (List)Module.itemSchoolData.get(this.getItemId());
        if (schoolLst == null) {
            return true;
        } else {
            return (Integer)schoolLst.get(0) == 0 ? true : schoolLst.contains(school);
        }
    }

    private void loseEffect() {
        if (this.isEffectItem()) {
            Properties pProp = xtable.Properties.get(this.roleid);
            GRoleEquipChange notifymap = new GRoleEquipChange();
            notifymap.roleid = this.roleid;
            notifymap.pos = this.getEquipPos();
            notifymap.itemid = 0;
            notifymap.ride = -1;
            notifymap.effect = pProp.getEquipeffect();
            GsClient.pSendWhileCommit(notifymap);
            Team team = TeamManager.selectTeamByRoleId(this.roleid);
            if (team != null) {
                team.updateTeamMemberComponents2Others(this.roleid);
            }
        }

        this.refreshEquipBuff();
    }

    public boolean loseEndure(int lose) {
        if (this.equipAttr.isData()) {
            Module.logger.error("装备属性为只读");
            return false;
        } else if (this.equipAttr.getEndure() <= 0) {
            Module.logger.error("装备耐久为" + this.equipAttr.getEndure());
            return false;
        } else {
            Module.logger.debug("物品耐久为" + this.equipAttr.getExtendure());
            int alllose = lose + this.equipAttr.getExtendure();
            if (alllose >= 100) {
                this.setEndure(this.equipAttr.getEndure() - alllose / 100);
            }

            this.equipAttr.setExtendure(alllose % 100);
            if (this.equipAttr.getEndure() < 0) {
                this.equipAttr.setEndure(0);
            }

            Module.logger.debug("物品" + this.getPosition() + "的ext耐久为" + this.equipAttr.getExtendure());
            Module.logger.debug("装备耐久=" + this.equipAttr.getEndure());
            return true;
        }
    }

    public void onDeleted() {
        Equips.remove(this.itemData.getExtid());
    }

    public void onInserted() {
    }

    private void refreshEquipBuff() {
        SceneSkillRole role = SkillManager.getSceneSkillRole(this.roleid);
        HashMap<Integer, Float> effects = new HashMap();
        ArrayList<ConstantlyBuffConfig> cbuffs = new ArrayList();
        this.getEffectsAndBuffs(effects, cbuffs);
        Result r = role.unequip(this.getEquipType(), cbuffs);
        SRefreshRoleData snd = new SRefreshRoleData();
        snd.datas = (HashMap)r.getChangedAttrs();
        Procedure.psendWhileCommit(this.roleid, snd);
    }

    private void resumeEffect() {
        if (this.isEffectItem()) {
            GRoleEquipChange notifymap = new GRoleEquipChange();
            notifymap.roleid = this.roleid;
            notifymap.pos = this.getEquipPos();
            notifymap.itemid = this.itemData.getId();
            notifymap.ride = -1;
            notifymap.effect = -1;
            GsClient.pSendWhileCommit(notifymap);
            Team team = TeamManager.selectTeamByRoleId(this.roleid);
            if (team != null) {
                team.updateTeamMemberComponents2Others(this.roleid);
            }
        }

        this.refreshEquipBuff();
    }

    public void SetAddAttr(Map<Integer, Integer> addAttrs) {
        this.equipAttr.getAddattr().putAll(addAttrs);
    }

    public void SetBaseAttr(Map<Integer, Integer> baseAttrs) {
        this.equipAttr.getAttr().putAll(baseAttrs);
    }

    protected void setCurMaxEndure(int endure) {
        if (this.equipAttr.isData()) {
            throw new RuntimeException("EquipItem is read only");
        } else {
            if (endure >= 0 && endure != this.equipAttr.getRepairtimes()) {
                this.equipAttr.setCurmaxendure(endure);
                if (this.roleid != 0L) {
                    SRefreshMaxNaiJiu send = new SRefreshMaxNaiJiu();
                    send.packid = this.packid;
                    send.keyinpack = this.keyinpack;
                    send.maxendure = this.equipAttr.getCurmaxendure();
                    Procedure.psendWhileCommit(this.roleid, send);
                }
            }

        }
    }

    public void setEndure(int endure) {
        if (this.equipAttr.isData()) {
            throw new RuntimeException("EquipItem is read only");
        } else {
            if (endure != this.equipAttr.getEndure() && (this.equipAttr.getEndure() >= 1 || endure >= 1)) {
                int oldendure = this.equipAttr.getEndure();
                if (endure > this.equipAttr.getCurmaxendure()) {
                    this.equipAttr.setEndure(this.equipAttr.getCurmaxendure());
                    this.equipAttr.setExtendure(0);
                } else {
                    this.equipAttr.setEndure(endure);
                }

                if (this.getPackId() == 3) {
                    if (oldendure <= 0 && this.equipAttr.getEndure() > 0) {
                        this.resumeEffect();
                    } else if (oldendure > 0 && this.equipAttr.getEndure() <= 0) {
                        this.loseEffect();
                    }
                }

                SRefreshNaiJiu send = new SRefreshNaiJiu();
                send.packid = this.packid;
                EquipNaiJiu ee = new EquipNaiJiu();
                ee.endure = this.equipAttr.getEndure();
                ee.keyinpack = this.keyinpack;
                send.data.add(ee);
                Procedure.psendWhileCommit(this.roleid, send);
            }

        }
    }

    public void setEnhancementAttr(int type, Map<Integer, Integer> addAttrs, long time) {
        EnhancementData data = Pod.newEnhancementData();
        data.setEnhancementtime(time);
        data.getEnhancementattr().putAll(addAttrs);
        this.equipAttr.getEnhancement().put(type, data);
    }

    public void setExtraAttr(Map<Integer, Integer> baseAttrs) {
        this.equipAttr.getExtraattr().putAll(baseAttrs);
    }

    public void setExtraAddAttr(Map<Integer, Integer> baseAttrs) {
        this.equipAttr.getExtraaddattr().putAll(baseAttrs);
    }

    public void setEquipEndure() {
        EquipItemShuXing equipAttr = (EquipItemShuXing)this.itemAttr;
        this.getEquipAttr().setEndure(equipAttr.getMaxnaijiu());
        this.getEquipAttr().setCurmaxendure(equipAttr.getMaxnaijiu());
        this.getEquipAttr().setMaxendure(equipAttr.getMaxnaijiu());
    }

    private void setExtinfo(Bean extinfo) {
        if (extinfo instanceof Equip) {
            this.equipAttr = (Equip)extinfo;
            Long nextkey = Equips.insert(this.equipAttr);
            this.itemData.setExtid(nextkey);
        }

    }

    public void SetExtraBaseAttr(Map<Integer, Integer> paramMap) {
        Random random = new Random();
        Map<Integer, Integer> extraattr = this.equipAttr.getExtraattr();

        for(Map.Entry<Integer, Integer> entry : paramMap.entrySet()) {
            int maxattr = (Integer)entry.getValue() * 2;
            int key = (Integer)entry.getKey();
            int extraattrvalue = 0;
            if (extraattr.get(key) != null) {
                extraattrvalue = (Integer)extraattr.get(key);
            }

            int randomnum = random.nextInt(6);
            int addvalue = maxattr / 100 * randomnum;
            int curvalue = extraattrvalue + addvalue;
            int newaddvalue = extraattrvalue + addvalue;
            if (curvalue > maxattr) {
                newaddvalue = maxattr;
            }

            extraattr.put(key, newaddvalue);
        }

    }

    public void SetExtraAddAttr() {
        Random random = new Random();
        Map<Integer, Integer> addattr = this.equipAttr.getAddattr();
        Map<Integer, Integer> extraaddattr = this.equipAttr.getExtraaddattr();

        for(Integer integer : addattr.keySet()) {
            int randomnum = 2 * random.nextInt(3);
            int curvalue = 0;
            if (extraaddattr.get(integer) != null) {
                curvalue = (Integer)extraaddattr.get(integer);
            }

            int extraddattrvalue = curvalue + randomnum;
            if (extraddattrvalue > 200) {
                extraddattrvalue = 200;
            }

            extraaddattr.put(integer, extraddattrvalue);
        }

    }

    public void SetSpBaseAttr(Map<Integer, Integer> paramMap) {
        EquipItemShuXing attr = this.getItemAttr();
        int BaseEffectId = attr.getBaseAttrId();
        ZhuangBeiShuXing equipAttrCnf = (ZhuangBeiShuXing)ItemMakeUtil.effectConfigs.get(BaseEffectId);
        if (equipAttrCnf != null) {
            Map<Integer, Integer> baseAttrs = new HashMap();
            Map<Integer, ShuXing> erandomMap = equipAttrCnf.GetERandom();

            for(Map.Entry<Integer, ShuXing> shuxing : erandomMap.entrySet()) {
                ShuXing value = (ShuXing)shuxing.getValue();
                int effectid = fire.pb.effect.Module.getInstance().getIdByName(value.GetEffectName().trim());
                int i = this.getBaseEffectByConfig(value.GetBodongMap());
                baseAttrs.put(effectid, i);
            }

            Random random = new Random();
            Map<Integer, Integer> map = this.equipAttr.getAttr();

            for(Map.Entry<Integer, Integer> entry : baseAttrs.entrySet()) {
                int i = random.nextInt(20) + 21;
                Integer bodongattr = (Integer)entry.getValue();
                Integer equipattr = (Integer)map.get(entry.getKey());
                if (equipattr < bodongattr) {
                    if (bodongattr - equipattr <= 40) {
                        map.put((Integer)entry.getKey(), bodongattr);
                    } else {
                        map.put((Integer)entry.getKey(), equipattr + i);
                    }
                }
            }
        }

    }

    private int getBaseEffectByConfig(Map<Integer, BoDongDuan> bodongMaps) {
        List<Integer> quanzhongList = new ArrayList();

        for(Map.Entry<Integer, BoDongDuan> bdMap : bodongMaps.entrySet()) {
            quanzhongList.add(((BoDongDuan)bdMap.getValue()).bodongduanbase);
        }

        int resultIndex = Misc.getProbability(quanzhongList);
        if (resultIndex >= bodongMaps.size()) {
            return 0;
        } else {
            BoDongDuan bdduan = (BoDongDuan)bodongMaps.get(resultIndex);
            int value = Misc.getRandomBetween(bdduan.min, bdduan.max);
            return value > 0 ? value : 0;
        }
    }

    public void SetEquipSkillAndEffect() {
        try {
            EquipItemShuXing itemAttr = this.getItemAttr();
            if (itemAttr == null) {
                return;
            }

            int effectid;
            for(effectid = itemAttr.getRandomEffectId(); effectid == 0; effectid = itemAttr.getRandomEffectId()) {
            }

            if (effectid > 0) {
                SEquipAddattributerandomlib addMap = (SEquipAddattributerandomlib)ItemMakeUtil.EQUIPADDRANDOM_CFGS.get(effectid);
                if (addMap == null) {
                    return;
                }

                int texiaoid = this.getSkillAndEffectByConfig(addMap);
                if (texiaoid > 0) {
                    this.equipAttr.setEffect(texiaoid);
                }
            }

            int skillid;
            for(skillid = itemAttr.getRandomSkillId(); skillid == 0; skillid = itemAttr.getRandomSkillId()) {
            }

            if (skillid > 0) {
                SEquipAddattributerandomlib addMap = (SEquipAddattributerandomlib)ItemMakeUtil.EQUIPADDRANDOM_CFGS.get(skillid);
                if (addMap == null) {
                    return;
                }

                int jinengid = this.getSkillAndEffectByConfig(addMap);
                if (jinengid > 0) {
                    this.equipAttr.setSkill(jinengid);
                }
            }
        } catch (Exception var6) {
            var6.printStackTrace();
        }

    }

    public void SetBaseAndAddAttr() {
        Random random = new Random();
        Map<Integer, Integer> map = this.equipAttr.getAddattr();
        int size = map.size();
        if (size != 0) {
            int j = random.nextInt(size);
            int k = 0;
            ArrayList<Integer> sites = new ArrayList();
            sites.add(11);
            sites.add(21);
            sites.add(31);
            sites.add(41);
            sites.add(51);
            Map<Integer, Integer> newmap = new HashMap();
            if (map.size() == 1) {
                for(Integer integer : map.keySet()) {
                    int n = random.nextInt(sites.size());
                    int keyvar1 = (Integer)sites.get(n);
                    int keyvar2 = (Integer)map.get(integer);
                    newmap.put(keyvar1, keyvar2);
                }

                map.clear();
                map.putAll(newmap);
            } else if (map.size() == 2) {
                ArrayList var = new ArrayList();
                int key1 = random.nextInt(sites.size());
                int n = (Integer)sites.get(key1);
                sites.remove(key1);
                int keyvar1 = random.nextInt(sites.size());
                int keyvar2 = (Integer)sites.get(keyvar1);

                for(Integer integer : map.keySet()) {
                    int var1 = (Integer)map.get(integer);
                    var.add(var1);
                }

                Integer[] ints = new Integer[var.size()];
                var.toArray(ints);
                newmap.put(n, ints[0]);
                newmap.put(keyvar2, ints[1]);
                map.clear();
                map.putAll(newmap);
            }

            for(Integer integer : map.keySet()) {
                if (j == k) {
                    int n = random.nextInt(331) - 30;
                    map.put(integer, n);
                }
            }
        }

    }

    protected void setFailTimes(int times) {
        if (this.equipAttr.isData()) {
            throw new RuntimeException("EquipItem is read only");
        } else {
            if (times >= 0 && times != this.equipAttr.getRepairtimes()) {
                this.equipAttr.setRepairtimes(times);
                if (this.roleid != 0L) {
                    SXiuLiFailTimes send = new SXiuLiFailTimes();
                    send.packid = this.packid;
                    send.keyinpack = this.keyinpack;
                    send.failtimes = this.equipAttr.getRepairtimes();
                    Procedure.psendWhileCommit(this.roleid, send);
                }
            }

        }
    }

    public int updateEnhancementTimeOut() {
        long now = Calendar.getInstance().getTimeInMillis();
        List<Integer> removes = new ArrayList<>();

        for(Map.Entry<Integer, EnhancementData> e : this.equipAttr.getEnhancement().entrySet()) {
            long t = ((EnhancementData)e.getValue()).getEnhancementtime();
            if (t != 0L && now > t) {
                removes.add((Integer)e.getKey());
            }
        }

        for(Integer i : removes) {
            this.equipAttr.getEnhancement().remove(i);
        }

        return removes.size();
    }

    public void changeEquipID(ItemMgr im, int itemid) {
        this.itemAttr = im.getAttr(itemid);
        this.itemData.setId(itemid);
        this.itemData.setTypeid(this.itemAttr.getTypeid());
        this.setFlag(this.getIniFlag());
    }

    public void onTimeout() {
        super.onTimeout();
        this.loseEffect();
    }

    private int getSkillAndEffectByConfig(SEquipAddattributerandomlib addMap) {
        int resultIndex = Misc.getProbabilityByBase(addMap.addattributerquanzhong, addMap.allquanzhong);
        if (resultIndex < addMap.addattributer.size() && resultIndex != -1) {
            int value = (Integer)addMap.addattributer.get(resultIndex);
            if (value > 0) {
                SEquipAddattributelib equipAdd = (SEquipAddattributelib)ItemMakeUtil.EQUIPADDATTR_CFGS.get(value);
                if (equipAdd != null) {
                    return equipAdd.getSkillid();
                }
            }

            return 0;
        } else {
            return 0;
        }
    }

    public abstract int getEquipType();

    public static enum EquipError {
        LEVEL_NOT_SUIT,
        NO_ERROR,
        POS_NOT_SUIT,
        SEX_NOT_SUIT,
        SHAPE_NOT_SUIT,
        SCHOOL_NOT_SUIT,
        ZERO_ENDURE,
        JING_MAI_ERROR;
    }
}

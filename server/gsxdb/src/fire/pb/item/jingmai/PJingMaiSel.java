//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.jingmai;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.PAddExpProc;
import fire.pb.PropRole;
import fire.pb.RoleConfigManager;
import fire.pb.SRefreshUserExp;
import fire.pb.attr.SRefreshRoleData;
import fire.pb.effect.Module;
import fire.pb.item.ItemAddInfo;
import fire.pb.item.ItemBase;
import fire.pb.item.Pack;
import fire.pb.item.SItemAdded;
import fire.pb.main.ConfigManager;
import fire.pb.skill.Result;
import fire.pb.skill.SJingMaixiaoguo;
import fire.pb.skill.Sjingmaijihuoitem;
import fire.pb.skill.Sjingmaiqiankundan;
import fire.pb.skill.Sjingmaiqianyuandan;
import fire.pb.skill.SkillRole;
import fire.pb.skill.liveskill.LiveSkillManager;
import fire.pb.talk.MessageMgr;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import mkdb.Procedure;
import xbean.Jingmai;
import xbean.Pod;
import xbean.Properties;
import xbean.XingChenItem;

public class PJingMaiSel extends Procedure {
    private final long roleId;
    public int idx;
    public int index;
    public int itemkey;
    static Map<Integer, SJingMaixiaoguo> produceConfs = ConfigManager.getInstance().getConf(SJingMaixiaoguo.class);

    public PJingMaiSel(long paramLong, int idx, int index, int itemkey) {
        this.roleId = paramLong;
        this.idx = idx;
        this.index = index;
        this.itemkey = itemkey;
    }

    protected boolean process() throws Exception {
        int itemid = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(629).getValue());
        Properties prop = xtable.Properties.get(this.roleId);
        new SkillRole(this.roleId);
        if (this.idx == 1) {
            Jingmai zuoqi = (Jingmai)prop.getJingmai().get(this.idx);
            if (zuoqi == null) {
                zuoqi = Pod.newJingmai();
                zuoqi.setId(this.idx);
                zuoqi.setQianyuandan(0);
                zuoqi.setQiankundan(0);
                zuoqi.setFangan(1);
                zuoqi.setState(1);
                zuoqi.getJingmais().put(1, 0);
                zuoqi.getJingmais().put(2, 0);
                zuoqi.getJingmais().put(3, 0);
                zuoqi.getJingmais().put(4, 0);
                zuoqi.getJingmais().put(5, 0);
                zuoqi.getJingmais().put(6, 0);
                zuoqi.getJingmais().put(7, 0);
                zuoqi.getJingmais().put(8, 0);
                zuoqi.getJingmais().put(9, 0);
                zuoqi.getJingmais().put(10, 0);
                zuoqi.getJingmais().put(11, 0);
                zuoqi.getJingmais().put(12, 0);
                zuoqi.getJingmais().put(13, 0);
                zuoqi.getJingmais().put(14, 0);
                zuoqi.getJingmais().put(15, 0);
                zuoqi.getJingmais().put(16, 0);
                prop.getJingmai().put(this.idx, zuoqi);
                SJingMaiMain SJingMaiMain = new SJingMaiMain();
                SJingMaiMain.idx = zuoqi.getId();
                SJingMaiMain.qianyuandan = zuoqi.getQianyuandan();
                SJingMaiMain.qiankundan = zuoqi.getQiankundan();
                SJingMaiMain.fangan = 1;
                SJingMaiMain.state = 1;
                SJingMaiMain.jingmais.putAll(zuoqi.getJingmais());
                Set<Integer> set = zuoqi.getXingchen().keySet();
                if (!set.isEmpty()) {
                    for(int formId : set) {
                        XingChenItem WenShi = (XingChenItem)zuoqi.getXingchen().get(formId);
                        fire.pb.item.jingmai.XingChenItem XingChenItemTemp = new fire.pb.item.jingmai.XingChenItem();
                        XingChenItemTemp.id = (long)WenShi.getId();
                        XingChenItemTemp.pos = WenShi.getPos();
                        XingChenItemTemp.level = WenShi.getLevel();
                        XingChenItemTemp.pinzhi = WenShi.getPinzhi();
                        XingChenItemTemp.naijiu = WenShi.getNaijiu();
                        XingChenItemTemp.shuxing = (float)WenShi.getShuxing();
                        XingChenItemTemp.xishu = (float)WenShi.getXishu();
                        SJingMaiMain.xingchen.put(formId, XingChenItemTemp);
                    }
                }

                Procedure.psendWhileCommit(this.roleId, SJingMaiMain);
            } else {
                SJingMaiMain SJingMaiMain = new SJingMaiMain();
                SJingMaiMain.idx = zuoqi.getId();
                SJingMaiMain.qianyuandan = zuoqi.getQianyuandan();
                SJingMaiMain.qiankundan = zuoqi.getQiankundan();
                SJingMaiMain.fangan = zuoqi.getFangan();
                SJingMaiMain.state = zuoqi.getState();
                SJingMaiMain.jingmais.putAll(zuoqi.getJingmais());
                Set<Integer> set = zuoqi.getXingchen().keySet();
                if (!set.isEmpty()) {
                    for(int formId : set) {
                        XingChenItem WenShi = (XingChenItem)zuoqi.getXingchen().get(formId);
                        fire.pb.item.jingmai.XingChenItem XingChenItemTemp = new fire.pb.item.jingmai.XingChenItem();
                        XingChenItemTemp.id = (long)WenShi.getId();
                        XingChenItemTemp.pos = WenShi.getPos();
                        XingChenItemTemp.level = WenShi.getLevel();
                        XingChenItemTemp.pinzhi = WenShi.getPinzhi();
                        XingChenItemTemp.naijiu = WenShi.getNaijiu();
                        XingChenItemTemp.shuxing = (float)WenShi.getShuxing();
                        XingChenItemTemp.xishu = (float)WenShi.getXishu();
                        SJingMaiMain.xingchen.put(formId, XingChenItemTemp);
                    }
                }

                Procedure.psendWhileCommit(this.roleId, SJingMaiMain);
            }
        }

        if (this.idx == 2) {
            Jingmai zuoqi = (Jingmai)prop.getJingmai().get(this.index);
            if (zuoqi == null) {
                zuoqi = Pod.newJingmai();
                zuoqi.setId(this.index);
                zuoqi.setQianyuandan(0);
                zuoqi.setQiankundan(0);
                zuoqi.setFangan(this.index);
                zuoqi.setState(0);
                zuoqi.getJingmais().put(1, 0);
                zuoqi.getJingmais().put(2, 0);
                zuoqi.getJingmais().put(3, 0);
                zuoqi.getJingmais().put(4, 0);
                zuoqi.getJingmais().put(5, 0);
                zuoqi.getJingmais().put(6, 0);
                zuoqi.getJingmais().put(7, 0);
                zuoqi.getJingmais().put(8, 0);
                zuoqi.getJingmais().put(9, 0);
                zuoqi.getJingmais().put(10, 0);
                zuoqi.getJingmais().put(11, 0);
                zuoqi.getJingmais().put(12, 0);
                zuoqi.getJingmais().put(13, 0);
                zuoqi.getJingmais().put(14, 0);
                zuoqi.getJingmais().put(15, 0);
                zuoqi.getJingmais().put(16, 0);
                prop.getJingmai().put(this.index, zuoqi);
                SJingMaiMain SJingMaiMain = new SJingMaiMain();
                SJingMaiMain.idx = 1;
                SJingMaiMain.qianyuandan = zuoqi.getQianyuandan();
                SJingMaiMain.qiankundan = zuoqi.getQiankundan();
                SJingMaiMain.fangan = zuoqi.getFangan();
                SJingMaiMain.state = zuoqi.getState();
                SJingMaiMain.jingmais.putAll(zuoqi.getJingmais());
                Set<Integer> set = zuoqi.getXingchen().keySet();
                if (!set.isEmpty()) {
                    for(int formId : set) {
                        XingChenItem WenShi = (XingChenItem)zuoqi.getXingchen().get(formId);
                        fire.pb.item.jingmai.XingChenItem XingChenItemTemp = new fire.pb.item.jingmai.XingChenItem();
                        XingChenItemTemp.id = (long)WenShi.getId();
                        XingChenItemTemp.pos = WenShi.getPos();
                        XingChenItemTemp.level = WenShi.getLevel();
                        XingChenItemTemp.pinzhi = WenShi.getPinzhi();
                        XingChenItemTemp.naijiu = WenShi.getNaijiu();
                        XingChenItemTemp.shuxing = (float)WenShi.getShuxing();
                        XingChenItemTemp.xishu = (float)WenShi.getXishu();
                        SJingMaiMain.xingchen.put(formId, XingChenItemTemp);
                    }
                }

                Procedure.psendWhileCommit(this.roleId, SJingMaiMain);
            } else {
                SJingMaiMain SJingMaiMain = new SJingMaiMain();
                SJingMaiMain.idx = 1;
                SJingMaiMain.qianyuandan = zuoqi.getQianyuandan();
                SJingMaiMain.qiankundan = zuoqi.getQiankundan();
                SJingMaiMain.fangan = this.index;
                SJingMaiMain.state = zuoqi.getState();
                SJingMaiMain.jingmais.putAll(zuoqi.getJingmais());
                Set<Integer> set = zuoqi.getXingchen().keySet();
                if (!set.isEmpty()) {
                    for(int formId : set) {
                        XingChenItem WenShi = (XingChenItem)zuoqi.getXingchen().get(formId);
                        fire.pb.item.jingmai.XingChenItem XingChenItemTemp = new fire.pb.item.jingmai.XingChenItem();
                        XingChenItemTemp.id = (long)WenShi.getId();
                        XingChenItemTemp.pos = WenShi.getPos();
                        XingChenItemTemp.level = WenShi.getLevel();
                        XingChenItemTemp.pinzhi = WenShi.getPinzhi();
                        XingChenItemTemp.naijiu = WenShi.getNaijiu();
                        XingChenItemTemp.shuxing = (float)WenShi.getShuxing();
                        XingChenItemTemp.xishu = (float)WenShi.getXishu();
                        SJingMaiMain.xingchen.put(formId, XingChenItemTemp);
                    }
                }

                Procedure.psendWhileCommit(this.roleId, SJingMaiMain);
            }
        }

        if (this.idx == 3) {
            for(int formId1 : prop.getJingmai().keySet()) {
                Jingmai zuoqi = (Jingmai)prop.getJingmai().get(formId1);
                if (zuoqi.getState() == 1) {
                    Pack bag = new Pack(this.roleId, false);
                    Sjingmaijihuoitem pc = (Sjingmaijihuoitem)ConfigManager.getInstance().getConf(Sjingmaijihuoitem.class).get(this.index);
                    if (this.index >= 13) {
                        int nMoveNum11 = bag.removeItemById(pc.item2, pc.item2num, YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0, "Treasuremap used success");
                        if (nMoveNum11 > 1) {
                            MessageMgr.sendMsgNotify(this.roleId, 150058, (List)null);
                            return false;
                        }

                        int aa = this.index - 12;
                        if (zuoqi.getQiankundan() < aa) {
                            MessageMgr.sendMsgNotify(this.roleId, 199006, (List)null);
                            return false;
                        }
                    }

                    if (this.index < 12 && zuoqi.getQianyuandan() < this.index) {
                        MessageMgr.sendMsgNotify(this.roleId, 199007, (List)null);
                        return false;
                    }

                    int nMoveNum1 = bag.removeItemById(pc.item1, pc.item1num, YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0, "Treasuremap used success");
                    if (nMoveNum1 < 1) {
                        MessageMgr.sendMsgNotify(this.roleId, 150058, (List)null);
                        return false;
                    }

                    zuoqi.getJingmais().put(this.index, 1);
                    Map<Integer, Integer> sExtSkill = new HashMap();
                    SkillRole skillRole = new SkillRole(this.roleId);
                    int skill = this.index - 1;

                    for(SJingMaixiaoguo pc1 : produceConfs.values()) {
                        if (prop.getSchool() == pc1.zhiye && zuoqi.getFangan() == pc1.getJingmaiid()) {
                            sExtSkill.put((Integer)pc1.getJingmais().get(skill), 1);
                            Result r = skillRole.UpdateExtBuff(sExtSkill, true);
                            SRefreshRoleData snd = new SRefreshRoleData();
                            snd.datas.putAll(Module.getClientAttrs(r.getChangedAttrs()));
                            Procedure.psendWhileCommit(this.roleId, snd);
                        }
                    }

                    MessageMgr.sendMsgNotify(this.roleId, 199005, (List)null);
                    SJingMaiMain SJingMaiMain = new SJingMaiMain();
                    SJingMaiMain.idx = 1;
                    SJingMaiMain.qianyuandan = zuoqi.getQianyuandan();
                    SJingMaiMain.qiankundan = zuoqi.getQiankundan();
                    SJingMaiMain.fangan = zuoqi.getFangan();
                    SJingMaiMain.state = zuoqi.getState();
                    SJingMaiMain.jingmais.putAll(zuoqi.getJingmais());
                    Set<Integer> set = zuoqi.getXingchen().keySet();
                    if (!set.isEmpty()) {
                        for(int formId : set) {
                            XingChenItem WenShi = (XingChenItem)zuoqi.getXingchen().get(formId);
                            fire.pb.item.jingmai.XingChenItem XingChenItemTemp = new fire.pb.item.jingmai.XingChenItem();
                            XingChenItemTemp.id = (long)WenShi.getId();
                            XingChenItemTemp.pos = WenShi.getPos();
                            XingChenItemTemp.level = WenShi.getLevel();
                            XingChenItemTemp.pinzhi = WenShi.getPinzhi();
                            XingChenItemTemp.naijiu = WenShi.getNaijiu();
                            XingChenItemTemp.shuxing = (float)WenShi.getShuxing();
                            XingChenItemTemp.xishu = (float)WenShi.getXishu();
                            SJingMaiMain.xingchen.put(formId, XingChenItemTemp);
                        }
                    }

                    Procedure.psendWhileCommit(this.roleId, SJingMaiMain);
                }
            }
        }

        if (this.idx == 4) {
            Pack bag = new Pack(this.roleId, false);
            int needmoney = Integer.parseInt(RoleConfigManager.getRoleCommonConfig(630).getValue());
            if (bag.subGold((long)(-needmoney), "经脉切换", YYLoggerTuJingEnum.tujing_Value_xiuli, 0) != (long)(-needmoney)) {
                MessageMgr.sendMsgNotify(this.roleId, 160118, (List)null);
                return false;
            }

            Jingmai zuoqi = (Jingmai)prop.getJingmai().get(this.index);

            for(int formId1 : prop.getJingmai().keySet()) {
                Jingmai zuoqi1 = (Jingmai)prop.getJingmai().get(formId1);
                if (zuoqi1.getState() == 1) {
                    zuoqi1.setState(0);
                    zuoqi.setState(1);
                    SkillRole skillRole = new SkillRole(this.roleId);
                    Result r = skillRole.addJingmaiSkillBuff();
                    SRefreshRoleData snd = new SRefreshRoleData();
                    snd.datas.putAll(Module.getClientAttrs(r.getChangedAttrs()));
                    Procedure.psendWhileCommit(this.roleId, snd);
                    Result r1 = skillRole.addJingmaiSkillBuff1();
                    SRefreshRoleData snd1 = new SRefreshRoleData();
                    snd1.datas.putAll(Module.getClientAttrs(r1.getChangedAttrs()));
                    Procedure.psendWhileCommit(this.roleId, snd1);
                    SJingMaiMain SJingMaiMain = new SJingMaiMain();
                    SJingMaiMain.idx = 1;
                    SJingMaiMain.qianyuandan = zuoqi.getQianyuandan();
                    SJingMaiMain.qiankundan = zuoqi.getQiankundan();
                    SJingMaiMain.fangan = zuoqi.getFangan();
                    SJingMaiMain.state = zuoqi.getState();
                    SJingMaiMain.jingmais.putAll(zuoqi.getJingmais());
                    Set<Integer> set11 = zuoqi.getXingchen().keySet();
                    if (!set11.isEmpty()) {
                        for(int formId : set11) {
                            XingChenItem WenShi = (XingChenItem)zuoqi.getXingchen().get(formId);
                            fire.pb.item.jingmai.XingChenItem XingChenItemTemp = new fire.pb.item.jingmai.XingChenItem();
                            XingChenItemTemp.id = (long)WenShi.getId();
                            XingChenItemTemp.pos = WenShi.getPos();
                            XingChenItemTemp.level = WenShi.getLevel();
                            XingChenItemTemp.pinzhi = WenShi.getPinzhi();
                            XingChenItemTemp.naijiu = WenShi.getNaijiu();
                            XingChenItemTemp.shuxing = (float)WenShi.getShuxing();
                            XingChenItemTemp.xishu = (float)WenShi.getXishu();
                            SJingMaiMain.xingchen.put(formId, XingChenItemTemp);
                        }
                    }

                    Procedure.psendWhileCommit(this.roleId, SJingMaiMain);
                }
            }
        }

        if (this.idx == 5) {
            for(int formId1 : prop.getJingmai().keySet()) {
                Jingmai zuoqi = (Jingmai)prop.getJingmai().get(formId1);
                if (zuoqi.getState() == 1) {
                    Pack bag = new Pack(this.roleId, false);
                    bag.removeItemById(itemid, 1, YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0, "Treasuremap used success");
                    XingChenItem XingChen = (XingChenItem)zuoqi.getXingchen().get(this.index);
                    if (XingChen == null) {
                        XingChenItem XingChen1 = Pod.newXingChenItem();
                        XingChen1.setId(itemid);
                        XingChen1.setPos(this.index);
                        XingChen1.setLevel(1);
                        XingChen1.setNaijiu(500);
                        XingChen1.setPinzhi(1);
                        XingChen1.setShuxing(0);
                        XingChen1.setXishu(0);
                        zuoqi.getXingchen().put(this.index, XingChen1);
                    }

                    for(SJingMaixiaoguo pc1 : produceConfs.values()) {
                        if (prop.getSchool() == pc1.zhiye && zuoqi.getFangan() == pc1.getJingmaiid()) {
                            Map<Integer, Integer> sExtSkill = new HashMap();
                            SkillRole skillRole = new SkillRole(this.roleId);
                            int skill = this.index - 1;
                            sExtSkill.put((Integer)pc1.getXingchens().get(skill), 1);
                            Result r = skillRole.UpdateExtBuff(sExtSkill, true);
                            SRefreshRoleData snd = new SRefreshRoleData();
                            snd.datas.putAll(Module.getClientAttrs(r.getChangedAttrs()));
                            Procedure.psendWhileCommit(this.roleId, snd);
                            SJingMaiMain SJingMaiMain = new SJingMaiMain();
                            SJingMaiMain.idx = 1;
                            SJingMaiMain.qianyuandan = zuoqi.getQianyuandan();
                            SJingMaiMain.qiankundan = zuoqi.getQiankundan();
                            SJingMaiMain.fangan = zuoqi.getFangan();
                            SJingMaiMain.state = zuoqi.getState();
                            SJingMaiMain.jingmais.putAll(zuoqi.getJingmais());
                            Set<Integer> set = zuoqi.getXingchen().keySet();
                            if (!set.isEmpty()) {
                                for(int formId : set) {
                                    XingChenItem WenShi = (XingChenItem)zuoqi.getXingchen().get(formId);
                                    fire.pb.item.jingmai.XingChenItem XingChenItemTemp = new fire.pb.item.jingmai.XingChenItem();
                                    XingChenItemTemp.id = (long)WenShi.getId();
                                    XingChenItemTemp.pos = WenShi.getPos();
                                    XingChenItemTemp.level = WenShi.getLevel();
                                    XingChenItemTemp.pinzhi = WenShi.getPinzhi();
                                    XingChenItemTemp.naijiu = WenShi.getNaijiu();
                                    XingChenItemTemp.shuxing = (float)WenShi.getShuxing();
                                    XingChenItemTemp.xishu = (float)WenShi.getXishu();
                                    SJingMaiMain.xingchen.put(formId, XingChenItemTemp);
                                }
                            }

                            Procedure.psendWhileCommit(this.roleId, SJingMaiMain);
                        }
                    }
                }
            }
        }

        if (this.idx == 6) {
            for(int formId1 : prop.getJingmai().keySet()) {
                Jingmai zuoqi = (Jingmai)prop.getJingmai().get(formId1);
                if (zuoqi.getState() == 1) {
                    Pack bag = new Pack(this.roleId, false);
                    bag.addItem(itemid, 1, "Treasuremap used success", YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0, false);
                    SItemAdded localSItemAdded = new SItemAdded();
                    localSItemAdded.items.add(new ItemAddInfo(itemid, 1));
                    Procedure.psendWhileCommit(this.roleId, localSItemAdded);
                    zuoqi.getXingchen().remove(this.index);
                    SJingMaixiaoguo pc = (SJingMaixiaoguo)ConfigManager.getInstance().getConf(SJingMaixiaoguo.class).get(zuoqi.getFangan());
                    Map<Integer, Integer> sExtSkill = new HashMap();
                    SkillRole skillRole = new SkillRole(this.roleId);
                    int skill = this.index - 1;
                    sExtSkill.put((Integer)pc.getXingchens().get(skill), 1);
                    Result r = skillRole.UpdateExtBuff1(sExtSkill, true);
                    SRefreshRoleData snd = new SRefreshRoleData();
                    snd.datas.putAll(Module.getClientAttrs(r.getChangedAttrs()));
                    Procedure.psendWhileCommit(this.roleId, snd);
                    SJingMaiMain SJingMaiMain = new SJingMaiMain();
                    SJingMaiMain.idx = 1;
                    SJingMaiMain.qianyuandan = zuoqi.getQianyuandan();
                    SJingMaiMain.qiankundan = zuoqi.getQiankundan();
                    SJingMaiMain.fangan = zuoqi.getFangan();
                    SJingMaiMain.state = zuoqi.getState();
                    SJingMaiMain.jingmais.putAll(zuoqi.getJingmais());
                    Set<Integer> set = zuoqi.getXingchen().keySet();
                    if (!set.isEmpty()) {
                        for(int formId : set) {
                            XingChenItem WenShi = (XingChenItem)zuoqi.getXingchen().get(formId);
                            fire.pb.item.jingmai.XingChenItem XingChenItemTemp = new fire.pb.item.jingmai.XingChenItem();
                            XingChenItemTemp.id = (long)WenShi.getId();
                            XingChenItemTemp.pos = WenShi.getPos();
                            XingChenItemTemp.level = WenShi.getLevel();
                            XingChenItemTemp.pinzhi = WenShi.getPinzhi();
                            XingChenItemTemp.naijiu = WenShi.getNaijiu();
                            XingChenItemTemp.shuxing = (float)WenShi.getShuxing();
                            XingChenItemTemp.xishu = (float)WenShi.getXishu();
                            SJingMaiMain.xingchen.put(formId, XingChenItemTemp);
                        }
                    }

                    Procedure.psendWhileCommit(this.roleId, SJingMaiMain);
                }
            }
        }

        if (this.idx == 7) {
            for(int formId1 : prop.getJingmai().keySet()) {
                Jingmai zuoqi = (Jingmai)prop.getJingmai().get(formId1);
                if (zuoqi.getState() == 1) {
                    if (zuoqi.getXingchen().get(this.index) == null) {
                        MessageMgr.psendMsgNotify(this.roleId, 199008, (List)null);
                        return false;
                    }

                    Pack bag = new Pack(this.roleId, false);
                    bag.addItem(itemid, 1, "Treasuremap used success", YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0, false);
                    zuoqi.getXingchen().remove(this.index);
                    bag.removeItemById(itemid, 1, YYLoggerTuJingEnum.tujing_Value_changeschoolweaponcost, 0, "Treasuremap used success");
                    SItemAdded localSItemAdded = new SItemAdded();
                    localSItemAdded.items.add(new ItemAddInfo(itemid, 1));
                    Procedure.psendWhileCommit(this.roleId, localSItemAdded);
                    XingChenItem XingChen1 = Pod.newXingChenItem();
                    ItemBase oldWeaponIB = bag.getItem(this.itemkey);
                    XingChen1.setId(oldWeaponIB.getItemId());
                    XingChen1.setPos(this.index);
                    XingChen1.setLevel(1);
                    XingChen1.setNaijiu(500);
                    XingChen1.setPinzhi(1);
                    XingChen1.setShuxing(0);
                    XingChen1.setXishu(0);
                    zuoqi.getXingchen().put(this.index, XingChen1);
                    SJingMaiMain SJingMaiMain = new SJingMaiMain();
                    SJingMaiMain.idx = 1;
                    SJingMaiMain.qianyuandan = zuoqi.getQianyuandan();
                    SJingMaiMain.qiankundan = zuoqi.getQiankundan();
                    SJingMaiMain.fangan = zuoqi.getFangan();
                    SJingMaiMain.state = zuoqi.getState();
                    SJingMaiMain.jingmais.putAll(zuoqi.getJingmais());
                    Set<Integer> set = zuoqi.getXingchen().keySet();
                    if (!set.isEmpty()) {
                        for(int formId : set) {
                            XingChenItem WenShi = (XingChenItem)zuoqi.getXingchen().get(formId);
                            fire.pb.item.jingmai.XingChenItem XingChenItemTemp = new fire.pb.item.jingmai.XingChenItem();
                            XingChenItemTemp.id = (long)WenShi.getId();
                            XingChenItemTemp.pos = WenShi.getPos();
                            XingChenItemTemp.level = WenShi.getLevel();
                            XingChenItemTemp.pinzhi = WenShi.getPinzhi();
                            XingChenItemTemp.naijiu = WenShi.getNaijiu();
                            XingChenItemTemp.shuxing = (float)WenShi.getShuxing();
                            XingChenItemTemp.xishu = (float)WenShi.getXishu();
                            SJingMaiMain.xingchen.put(formId, XingChenItemTemp);
                        }
                    }

                    Procedure.psendWhileCommit(this.roleId, SJingMaiMain);
                }
            }
        }

        if (this.idx == 10) {
            for(int formId1 : prop.getJingmai().keySet()) {
                Jingmai zuoqi = (Jingmai)prop.getJingmai().get(formId1);
                if (zuoqi.getState() == 1) {
                    SJingMaiMain SJingMaiMain = new SJingMaiMain();
                    SJingMaiMain.idx = 10;
                    SJingMaiMain.qianyuandan = zuoqi.getQianyuandan();
                    SJingMaiMain.qiankundan = zuoqi.getQiankundan();
                    SJingMaiMain.fangan = zuoqi.getFangan();
                    SJingMaiMain.state = zuoqi.getState();
                    SJingMaiMain.jingmais.putAll(zuoqi.getJingmais());
                    Set<Integer> set = zuoqi.getXingchen().keySet();
                    if (!set.isEmpty()) {
                        for(int formId : set) {
                            XingChenItem WenShi = (XingChenItem)zuoqi.getXingchen().get(formId);
                            fire.pb.item.jingmai.XingChenItem XingChenItemTemp = new fire.pb.item.jingmai.XingChenItem();
                            XingChenItemTemp.id = (long)WenShi.getId();
                            XingChenItemTemp.pos = WenShi.getPos();
                            XingChenItemTemp.level = WenShi.getLevel();
                            XingChenItemTemp.pinzhi = WenShi.getPinzhi();
                            XingChenItemTemp.naijiu = WenShi.getNaijiu();
                            XingChenItemTemp.shuxing = (float)WenShi.getShuxing();
                            XingChenItemTemp.xishu = (float)WenShi.getXishu();
                            SJingMaiMain.xingchen.put(formId, XingChenItemTemp);
                        }
                    }

                    Procedure.psendWhileCommit(this.roleId, SJingMaiMain);
                }
            }
        }

        if (this.idx == 11) {
            PropRole prole = new PropRole(this.roleId, false);

            for(int formId1 : prop.getJingmai().keySet()) {
                Jingmai zuoqi = (Jingmai)prop.getJingmai().get(formId1);
                if (zuoqi.getState() == 1) {
                    int key = zuoqi.getQianyuandan();
                    if (zuoqi.getQianyuandan() == 0) {
                        key = zuoqi.getQianyuandan() + 1;
                    }

                    Sjingmaiqianyuandan pc = (Sjingmaiqianyuandan)ConfigManager.getInstance().getConf(Sjingmaiqianyuandan.class).get(key);
                    List<String> msg = new ArrayList();
                    msg.add(String.valueOf(pc.exp));
                    if ((long)pc.exp > prole.getCurExp()) {
                        MessageMgr.psendMsgNotify(this.roleId, 198166, msg);
                        return false;
                    }

                    (new PAddExpProc(this.roleId, (long)(-pc.exp), false, 5, "")).call();
                    Procedure.psendWhileCommit(this.roleId, new SRefreshUserExp(prole.getCurExp()));
                    if (prop.getEnergy() < pc.huoli) {
                        List<String> p = new ArrayList();
                        Integer v = pc.huoli;
                        p.add(v.toString());
                        MessageMgr.sendMsgNotify(this.roleId, 143432, p);
                        return false;
                    }

                    LiveSkillManager.getInstance().AddEnergy(this.roleId, prop, -pc.huoli, YYLoggerTuJingEnum.tujing_Value_worldchat_enery);
                    zuoqi.setQianyuandan(zuoqi.getQianyuandan() + 1);
                    SJingMaiMain SJingMaiMain = new SJingMaiMain();
                    SJingMaiMain.idx = 1;
                    SJingMaiMain.qianyuandan = zuoqi.getQianyuandan();
                    SJingMaiMain.qiankundan = zuoqi.getQiankundan();
                    SJingMaiMain.fangan = zuoqi.getFangan();
                    SJingMaiMain.state = zuoqi.getState();
                    SJingMaiMain.jingmais.putAll(zuoqi.getJingmais());
                    Set<Integer> set = zuoqi.getXingchen().keySet();
                    if (!set.isEmpty()) {
                        for(int formId : set) {
                            XingChenItem WenShi = (XingChenItem)zuoqi.getXingchen().get(formId);
                            fire.pb.item.jingmai.XingChenItem XingChenItemTemp = new fire.pb.item.jingmai.XingChenItem();
                            XingChenItemTemp.id = (long)WenShi.getId();
                            XingChenItemTemp.pos = WenShi.getPos();
                            XingChenItemTemp.level = WenShi.getLevel();
                            XingChenItemTemp.pinzhi = WenShi.getPinzhi();
                            XingChenItemTemp.naijiu = WenShi.getNaijiu();
                            XingChenItemTemp.shuxing = (float)WenShi.getShuxing();
                            XingChenItemTemp.xishu = (float)WenShi.getXishu();
                            SJingMaiMain.xingchen.put(formId, XingChenItemTemp);
                        }
                    }

                    Procedure.psendWhileCommit(this.roleId, SJingMaiMain);
                }
            }
        }

        if (this.idx == 12) {
            PropRole prole = new PropRole(this.roleId, false);

            for(int formId1 : prop.getJingmai().keySet()) {
                Jingmai zuoqi = (Jingmai)prop.getJingmai().get(formId1);
                if (zuoqi.getState() == 1) {
                    if (zuoqi.getQianyuandan() >= 12) {
                        int key = zuoqi.getQiankundan();
                        if (zuoqi.getQiankundan() == 0) {
                            key = zuoqi.getQiankundan() + 1;
                        }

                        Sjingmaiqiankundan pc = (Sjingmaiqiankundan)ConfigManager.getInstance().getConf(Sjingmaiqiankundan.class).get(key);
                        List<String> msg = new ArrayList();
                        msg.add(String.valueOf(pc.exp));
                        if ((long)pc.exp > prole.getCurExp()) {
                            MessageMgr.psendMsgNotify(this.roleId, 198166, msg);
                            return false;
                        }

                        (new PAddExpProc(this.roleId, (long)(-pc.exp), false, 5, "")).call();
                        Procedure.psendWhileCommit(this.roleId, new SRefreshUserExp(prole.getCurExp()));
                        if (prop.getEnergy() < pc.huoli) {
                            List<String> p = new ArrayList();
                            Integer v = pc.huoli;
                            p.add(v.toString());
                            MessageMgr.sendMsgNotify(this.roleId, 143432, p);
                            return false;
                        }

                        LiveSkillManager.getInstance().AddEnergy(this.roleId, prop, -pc.huoli, YYLoggerTuJingEnum.tujing_Value_worldchat_enery);
                        zuoqi.setQiankundan(zuoqi.getQiankundan() + 1);
                    }

                    SJingMaiMain SJingMaiMain = new SJingMaiMain();
                    SJingMaiMain.idx = 1;
                    SJingMaiMain.qianyuandan = zuoqi.getQianyuandan();
                    SJingMaiMain.qiankundan = zuoqi.getQiankundan();
                    SJingMaiMain.fangan = zuoqi.getFangan();
                    SJingMaiMain.state = zuoqi.getState();
                    SJingMaiMain.jingmais.putAll(zuoqi.getJingmais());
                    Set<Integer> set = zuoqi.getXingchen().keySet();
                    if (!set.isEmpty()) {
                        for(int formId : set) {
                            XingChenItem WenShi = (XingChenItem)zuoqi.getXingchen().get(formId);
                            fire.pb.item.jingmai.XingChenItem XingChenItemTemp = new fire.pb.item.jingmai.XingChenItem();
                            XingChenItemTemp.id = (long)WenShi.getId();
                            XingChenItemTemp.pos = WenShi.getPos();
                            XingChenItemTemp.level = WenShi.getLevel();
                            XingChenItemTemp.pinzhi = WenShi.getPinzhi();
                            XingChenItemTemp.naijiu = WenShi.getNaijiu();
                            XingChenItemTemp.shuxing = (float)WenShi.getShuxing();
                            XingChenItemTemp.xishu = (float)WenShi.getXishu();
                            SJingMaiMain.xingchen.put(formId, XingChenItemTemp);
                        }
                    }

                    Procedure.psendWhileCommit(this.roleId, SJingMaiMain);
                }
            }
        }

        return true;
    }
}

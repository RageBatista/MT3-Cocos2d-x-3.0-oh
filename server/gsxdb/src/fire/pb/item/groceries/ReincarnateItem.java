//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.groceries;

import fire.pb.PropRole;
import fire.pb.attr.SRefreshPointType;
import fire.pb.attr.SRefreshRoleData;
import fire.pb.effect.Role;
import fire.pb.effect.RoleImpl;
import fire.pb.item.Commontext;
import fire.pb.item.GroceryItem;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMgr;
import fire.pb.item.SReincarnateItem;
import fire.pb.item.UseItemHandler;
import fire.pb.item.Commontext.UseResult;
import fire.pb.main.ConfigManager;
import fire.pb.ranklist.proc.PRoleZongheRankProc;
import fire.pb.ranklist.proc.RankListManager;
import fire.pb.talk.MessageMgr;
import gnet.link.Onlines;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import mkio.Protocol;
import xbean.BasicFightProperties;
import xbean.Item;
import xbean.ItemUse;
import xbean.ItemUseCount;
import xbean.MarshalRoleLevelRecord;
import xbean.Pod;
import xbean.Properties;
import xbean.RoleAddPointProperties;
import xbean.RoleLevelListRecord;
import xbean.RoleLevelRankList;
import xtable.Rolelevellist;
import xtable.Roleuseitemcount;

public class ReincarnateItem extends GroceryItem {
    public ReincarnateItem(ItemMgr im, int itemid) {
        super(im, itemid);
    }

    public ReincarnateItem(ItemMgr im, Item item) {
        super(im, item);
    }

    protected UseItemHandler getUseItemHandler() {
        int itemid = this.getItemId();
        return new UseReincarnateItemHandler(itemid);
    }

    private class UseReincarnateItemHandler implements UseItemHandler {
        private int itemid;

        public UseReincarnateItemHandler(int itemid) {
            this.itemid = itemid;
        }

        public Commontext.UseResult onUse(long roleId, ItemBase bi, int usednum) {
            Properties prop = xtable.Properties.get(roleId);
            if (prop == null) {
                throw new IllegalArgumentException("无效的roleId:" + roleId);
            } else {
                SReincarnateItem cnf = (SReincarnateItem)ConfigManager.getInstance().getConf(SReincarnateItem.class).get(this.itemid);
                if (cnf.tolevel < prop.getLevel() && cnf.tolevel != 0) {
                    RoleAddPointProperties addfp = prop.getAddpointfp();
                    BasicFightProperties bfp = prop.getBfp();
                    int noldlevel = prop.getLevel();
                    int declevel = noldlevel - cnf.tolevel;
                    int curScheme = prop.getScheme();
                    int agi = (Integer)addfp.getAgi_save().get(curScheme) + declevel;
                    int cons = (Integer)addfp.getCons_save().get(curScheme) + declevel;
                    int endu = (Integer)addfp.getEndu_save().get(curScheme) + declevel;
                    int iq = (Integer)addfp.getIq_save().get(curScheme) + declevel;
                    int str = (Integer)addfp.getStr_save().get(curScheme) + declevel;
                    bfp.setAgi(bfp.getAgi() > agi ? (short)(bfp.getAgi() - agi) : 0);
                    bfp.setCons(bfp.getCons() > cons ? (short)(bfp.getCons() - cons) : 0);
                    bfp.setEndu(bfp.getEndu() > endu ? (short)(bfp.getEndu() - endu) : 0);
                    bfp.setIq(bfp.getIq() > iq ? (short)(bfp.getIq() - iq) : 0);
                    bfp.setStr(bfp.getStr() > str ? (short)(bfp.getStr() - str) : 0);

                    for(int i = 1; i < 4; ++i) {
                        int agitemp = (Integer)addfp.getAgi_save().get(i);
                        int constemp = (Integer)addfp.getCons_save().get(i);
                        int endutemp = (Integer)addfp.getEndu_save().get(i);
                        int iqtemp = (Integer)addfp.getIq_save().get(i);
                        int strtemp = (Integer)addfp.getStr_save().get(i);
                        addfp.getAgi_save().put(i, 0);
                        addfp.getCons_save().put(i, 0);
                        addfp.getEndu_save().put(i, 0);
                        addfp.getIq_save().put(i, 0);
                        addfp.getStr_save().put(i, 0);
                        int decpoints = agitemp + constemp + endutemp + iqtemp + strtemp - 5 * declevel;
                        prop.getPoint().put(i, (Integer)prop.getPoint().get(i) + decpoints);
                    }

                    bfp.setAgi(bfp.getAgi() + cnf.agi);
                    bfp.setCons(bfp.getCons() + cnf.cons);
                    bfp.setEndu(bfp.getEndu() + cnf.endu);
                    bfp.setIq(bfp.getIq() + cnf.iq);
                    bfp.setStr(bfp.getStr() + cnf.str);
                    prop.setExp(0L);
                    prop.setLevel(cnf.tolevel);
                    Map<Integer, Float> changedAttrs = new HashMap();
                    Role erole = new RoleImpl(roleId);
                    changedAttrs.putAll(erole.updateAllFinalAttrs());
                    changedAttrs.put(80, (float)prop.getHp());
                    changedAttrs.put(70, (float)prop.getUplimithp());
                    changedAttrs.put(100, (float)prop.getMp());
                    changedAttrs.put(1230, (float)prop.getLevel());
                    changedAttrs.put(470, (float)prop.getExp());
                    changedAttrs.put(1400, (float)(Integer)prop.getPoint().get(curScheme));
                    SRefreshRoleData roledata = new SRefreshRoleData();
                    roledata.datas.putAll(changedAttrs);
                    Procedure.psendWhileCommit(roleId, roledata);
                    SRefreshPointType refresh = new SRefreshPointType();
                    refresh.bfp.agi = (short)bfp.getAgi();
                    refresh.bfp.cons = (short)bfp.getCons();
                    refresh.bfp.endu = (short)bfp.getEndu();
                    refresh.bfp.iq = (short)bfp.getIq();
                    refresh.bfp.str = (short)bfp.getStr();
                    refresh.bfp.agi_save.putAll(prop.getAddpointfp().getAgi_save());
                    refresh.bfp.cons_save.putAll(prop.getAddpointfp().getCons_save());
                    refresh.bfp.endu_save.putAll(prop.getAddpointfp().getEndu_save());
                    refresh.bfp.iq_save.putAll(prop.getAddpointfp().getIq_save());
                    refresh.bfp.str_save.putAll(prop.getAddpointfp().getStr_save());
                    refresh.point.putAll(prop.getPoint());
                    refresh.pointscheme = prop.getScheme();
                    refresh.schemechanges = prop.getSchemechanges();
                    Procedure.psendWhileCommit(roleId, refresh);
                    int zhuansheng = prop.getZhuansheng() + 1;
                    prop.setZhuansheng(zhuansheng);
                    SRefreshRoleData send = new SRefreshRoleData();
                    Map<Integer, Float> res = new HashMap();
                    res.put(1240, (float)zhuansheng);
                    send.datas.putAll(res);
                    Procedure.psendWhileCommit(roleId, send);
                    int level = prop.getLevel();
                    if (prop.getZhuansheng() > 0) {
                        level += prop.getZhuansheng() * 1000;
                    }

                    if (level >= 30) {
                        RoleLevelListRecord record = Pod.newRoleLevelListRecord();
                        record.setTime(System.currentTimeMillis());
                        MarshalRoleLevelRecord marshRecord = record.getMarshaldata();
                        marshRecord.setLevel(level);
                        marshRecord.setRoleid(roleId);
                        PropRole pRole = new PropRole(roleId, true);
                        marshRecord.setRolename(pRole.getName());
                        marshRecord.setSchool(pRole.getSchool());
                        RoleLevelRankList list = Rolelevellist.get(1);
                        if (null == list) {
                            list = Pod.newRoleLevelRankList();
                            Rolelevellist.insert(1, list);
                        }

                        RankListManager.getInstance().tryInsertRecord(1, list.getRecords(), record);
                        Procedure.pexecuteWhileCommit(new PRoleZongheRankProc(ReincarnateItem.this.roleid));
                    }

                    int usecount = 0;
                    ItemUse itemUse = Roleuseitemcount.get(roleId);
                    if (itemUse != null) {
                        ItemUseCount itemUseCnt = (ItemUseCount)itemUse.getIteminfo().get(this.itemid);
                        usecount = itemUseCnt.getUsetimes();
                    }

                    if (usecount == 0) {
                        usecount = 1;
                    }

                    List<String> paras = new ArrayList();
                    paras.add(prop.getRolename());
                    paras.add(String.valueOf(usecount));
                    Protocol p = MessageMgr.getMsgNotify(191152, -1, paras);
                    Onlines.getInstance().broadcast(p, 999);
                    return UseResult.SUCC;
                } else {
                    return UseResult.FAIL;
                }
            }
        }
    }
}

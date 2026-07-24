//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item.groceries;

import fire.pb.attr.SRefreshPointType;
import fire.pb.attr.SRefreshRoleData;
import fire.pb.effect.Role;
import fire.pb.effect.RoleImpl;
import fire.pb.item.Commontext;
import fire.pb.item.GroceryItem;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemMgr;
import fire.pb.item.SPropertyItem;
import fire.pb.item.UseItemHandler;
import fire.pb.item.Commontext.UseResult;
import fire.pb.main.ConfigManager;
import fire.pb.talk.MessageMgr;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import mkdb.Procedure;
import xbean.BasicFightProperties;
import xbean.Item;
import xbean.Properties;

public class PropertyItem extends GroceryItem {
    public PropertyItem(ItemMgr im, int itemid) {
        super(im, itemid);
    }

    public PropertyItem(ItemMgr im, Item item) {
        super(im, item);
    }

    protected UseItemHandler getUseItemHandler() {
        int itemid = this.getItemId();
        return new UsePropertyItemHandler(itemid);
    }

    private class UsePropertyItemHandler implements UseItemHandler {
        private int itemid;

        public UsePropertyItemHandler(int itemid) {
            this.itemid = itemid;
        }

        public Commontext.UseResult onUse(long roleId, ItemBase bi, int usednum) {
            Properties prop = xtable.Properties.get(roleId);
            if (prop == null) {
                throw new IllegalArgumentException("错误的roleId:" + roleId);
            } else {
                SPropertyItem cnf = (SPropertyItem)ConfigManager.getInstance().getConf(SPropertyItem.class).get(this.itemid);
                BasicFightProperties bfp = prop.getBfp();
                int curScheme = prop.getScheme();
                int agi = 0;
                int cons = 0;
                int endu = 0;
                int iq = 0;
                int str = 0;
                int returnCnt = 0;
                if (cnf.getAgi() < 0) {
                    if (Math.abs(cnf.getAgi()) > bfp.getAgi()) {
                        agi = bfp.getAgi() * -1;
                    } else {
                        agi = cnf.getAgi();
                    }

                    ++returnCnt;
                } else {
                    agi = cnf.getAgi();
                }

                if (cnf.getCons() < 0) {
                    if (Math.abs(cnf.getCons()) > bfp.getCons()) {
                        cons = bfp.getCons() * -1;
                    } else {
                        cons = cnf.getCons();
                    }

                    ++returnCnt;
                } else {
                    cons = cnf.getCons();
                }

                if (cnf.getEndu() < 0) {
                    if (Math.abs(cnf.getEndu()) > bfp.getEndu()) {
                        endu = bfp.getEndu() * -1;
                    } else {
                        endu = cnf.getEndu();
                    }

                    ++returnCnt;
                } else {
                    endu = cnf.getEndu();
                }

                if (cnf.getIq() < 0) {
                    if (Math.abs(cnf.getIq()) > bfp.getIq()) {
                        iq = bfp.getIq() * -1;
                    } else {
                        iq = cnf.getIq();
                    }

                    ++returnCnt;
                } else {
                    iq = cnf.getIq();
                }

                if (cnf.getStr() < 0) {
                    if (Math.abs(cnf.getStr()) > bfp.getStr()) {
                        str = bfp.getStr() * -1;
                    } else {
                        str = cnf.getStr();
                    }

                    ++returnCnt;
                } else {
                    str = cnf.getStr();
                }

                int curpoint = (Integer)prop.getPoint().get(curScheme);
                int savepoint = bfp.getAgi() + bfp.getCons() + bfp.getEndu() + bfp.getIq() + bfp.getStr();
                int decpoints = agi + cons + endu + iq + str;
                if (savepoint + decpoints < 0) {
                    MessageMgr.sendMsgNotify(roleId, 150015, (List)null);
                    return UseResult.FAIL;
                } else {
                    prop.getPoint().put(curScheme, curpoint + Math.abs(decpoints));
                    bfp.setAgi((short)(bfp.getAgi() + agi));
                    bfp.setCons((short)(bfp.getCons() + cons));
                    bfp.setEndu((short)(bfp.getEndu() + endu));
                    bfp.setIq((short)(bfp.getIq() + iq));
                    bfp.setStr((short)(bfp.getStr() + str));
                    Map<Integer, Float> changedAttrs = new HashMap();
                    Role erole = new RoleImpl(roleId);
                    changedAttrs.putAll(erole.updateAllFinalAttrs());
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
                    return UseResult.SUCC;
                }
            }
        }
    }
}

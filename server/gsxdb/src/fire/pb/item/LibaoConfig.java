//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class LibaoConfig implements ConvMain.Checkable {
    public int id = 0;
    public int libaoid = 0;
    public int roletype = 0;
    public int school = 0;
    public int sextype = 0;
    public int opennotice = 0;
    public int awardtableid = 0;
    public long moneyaward1 = 0L;
    public int moneyaward2 = 0;
    public int vipexpaward = 0;
    public int currencytype = 0;
    public long currencyvalue = 0L;
    public ArrayList<Integer> itemids;
    public ArrayList<Integer> itemnums;
    public ArrayList<Integer> itembinds;

    public LibaoConfig() {
    }

    public LibaoConfig(LibaoConfig arg) {
        this.id = arg.id;
        this.libaoid = arg.libaoid;
        this.roletype = arg.roletype;
        this.school = arg.school;
        this.sextype = arg.sextype;
        this.opennotice = arg.opennotice;
        this.awardtableid = arg.awardtableid;
        this.moneyaward1 = arg.moneyaward1;
        this.moneyaward2 = arg.moneyaward2;
        this.vipexpaward = arg.vipexpaward;
        this.currencytype = arg.currencytype;
        this.currencyvalue = arg.currencyvalue;
        this.itemids = arg.itemids;
        this.itemnums = arg.itemnums;
        this.itembinds = arg.itembinds;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getLibaoid() {
        return this.libaoid;
    }

    public void setLibaoid(int v) {
        this.libaoid = v;
    }

    public int getRoletype() {
        return this.roletype;
    }

    public void setRoletype(int v) {
        this.roletype = v;
    }

    public int getSchool() {
        return this.school;
    }

    public void setSchool(int v) {
        this.school = v;
    }

    public int getSextype() {
        return this.sextype;
    }

    public void setSextype(int v) {
        this.sextype = v;
    }

    public int getOpennotice() {
        return this.opennotice;
    }

    public void setOpennotice(int v) {
        this.opennotice = v;
    }

    public int getAwardtableid() {
        return this.awardtableid;
    }

    public void setAwardtableid(int v) {
        this.awardtableid = v;
    }

    public long getMoneyaward1() {
        return this.moneyaward1;
    }

    public void setMoneyaward1(long v) {
        this.moneyaward1 = v;
    }

    public int getMoneyaward2() {
        return this.moneyaward2;
    }

    public void setMoneyaward2(int v) {
        this.moneyaward2 = v;
    }

    public int getVipexpaward() {
        return this.vipexpaward;
    }

    public void setVipexpaward(int v) {
        this.vipexpaward = v;
    }

    public int getCurrencytype() {
        return this.currencytype;
    }

    public void setCurrencytype(int v) {
        this.currencytype = v;
    }

    public long getCurrencyvalue() {
        return this.currencyvalue;
    }

    public void setCurrencyvalue(long v) {
        this.currencyvalue = v;
    }

    public ArrayList<Integer> getItemids() {
        return this.itemids;
    }

    public void setItemids(ArrayList<Integer> v) {
        this.itemids = v;
    }

    public ArrayList<Integer> getItemnums() {
        return this.itemnums;
    }

    public void setItemnums(ArrayList<Integer> v) {
        this.itemnums = v;
    }

    public ArrayList<Integer> getItembinds() {
        return this.itembinds;
    }

    public void setItembinds(ArrayList<Integer> v) {
        this.itembinds = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class MarketThreeTable implements ConvMain.Checkable, Comparable<MarketThreeTable> {
    public int id = 0;
    public int threeno = 0;
    public String itemname = null;
    public int itemtype = 0;
    public int logictype = 0;
    public int israrity = 0;
    public int firstno = 0;
    public int twono = 0;
    public int currency = 0;
    public ArrayList<Integer> ranges;
    public ArrayList<Integer> prices;
    public int 成交量 = 0;
    public int 挂单量 = 0;
    public int limitlooklv = 0;
    public int lvmin = 0;
    public int lvmax = 0;
    public double floatingmin = (double)0.0F;
    public double floatingmax = (double)0.0F;
    public double floatingprice = (double)0.0F;
    public int canstall = 0;

    public int compareTo(MarketThreeTable o) {
        return this.id - o.id;
    }

    public MarketThreeTable() {
    }

    public MarketThreeTable(MarketThreeTable arg) {
        this.id = arg.id;
        this.threeno = arg.threeno;
        this.itemname = arg.itemname;
        this.itemtype = arg.itemtype;
        this.logictype = arg.logictype;
        this.israrity = arg.israrity;
        this.firstno = arg.firstno;
        this.twono = arg.twono;
        this.currency = arg.currency;
        this.ranges = arg.ranges;
        this.prices = arg.prices;
        this.成交量 = arg.成交量;
        this.挂单量 = arg.挂单量;
        this.limitlooklv = arg.limitlooklv;
        this.lvmin = arg.lvmin;
        this.lvmax = arg.lvmax;
        this.floatingmin = arg.floatingmin;
        this.floatingmax = arg.floatingmax;
        this.floatingprice = arg.floatingprice;
        this.canstall = arg.canstall;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getThreeno() {
        return this.threeno;
    }

    public void setThreeno(int v) {
        this.threeno = v;
    }

    public String getItemname() {
        return this.itemname;
    }

    public void setItemname(String v) {
        this.itemname = v;
    }

    public int getItemtype() {
        return this.itemtype;
    }

    public void setItemtype(int v) {
        this.itemtype = v;
    }

    public int getLogictype() {
        return this.logictype;
    }

    public void setLogictype(int v) {
        this.logictype = v;
    }

    public int getIsrarity() {
        return this.israrity;
    }

    public void setIsrarity(int v) {
        this.israrity = v;
    }

    public int getFirstno() {
        return this.firstno;
    }

    public void setFirstno(int v) {
        this.firstno = v;
    }

    public int getTwono() {
        return this.twono;
    }

    public void setTwono(int v) {
        this.twono = v;
    }

    public int getCurrency() {
        return this.currency;
    }

    public void setCurrency(int v) {
        this.currency = v;
    }

    public ArrayList<Integer> getRanges() {
        return this.ranges;
    }

    public void setRanges(ArrayList<Integer> v) {
        this.ranges = v;
    }

    public ArrayList<Integer> getPrices() {
        return this.prices;
    }

    public void setPrices(ArrayList<Integer> v) {
        this.prices = v;
    }

    public int get成交量() {
        return this.成交量;
    }

    public void set成交量(int v) {
        this.成交量 = v;
    }

    public int get挂单量() {
        return this.挂单量;
    }

    public void set挂单量(int v) {
        this.挂单量 = v;
    }

    public int getLimitlooklv() {
        return this.limitlooklv;
    }

    public void setLimitlooklv(int v) {
        this.limitlooklv = v;
    }

    public int getLvmin() {
        return this.lvmin;
    }

    public void setLvmin(int v) {
        this.lvmin = v;
    }

    public int getLvmax() {
        return this.lvmax;
    }

    public void setLvmax(int v) {
        this.lvmax = v;
    }

    public double getFloatingmin() {
        return this.floatingmin;
    }

    public void setFloatingmin(double v) {
        this.floatingmin = v;
    }

    public double getFloatingmax() {
        return this.floatingmax;
    }

    public void setFloatingmax(double v) {
        this.floatingmax = v;
    }

    public double getFloatingprice() {
        return this.floatingprice;
    }

    public void setFloatingprice(double v) {
        this.floatingprice = v;
    }

    public int getCanstall() {
        return this.canstall;
    }

    public void setCanstall(int v) {
        this.canstall = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

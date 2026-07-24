//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SGoods implements ConvMain.Checkable, Comparable<SGoods> {
    public int id = 0;
    public String name = null;
    public int type = 0;
    public int itemId = 0;
    public ArrayList<Integer> currencys;
    public ArrayList<Integer> prices;
    public ArrayList<Integer> oldprices;
    public int limitType = 0;
    public int limitNum = 0;
    public int limitSaleNum = 0;
    public int limitLookLv = 0;
    public int lvMin = 0;
    public int lvMax = 0;
    public double floatingRisePrice = (double)0.0F;
    public double floatingDepreciatePrice = (double)0.0F;
    public double floatingmax = (double)0.0F;
    public double floatingmin = (double)0.0F;
    public int costItemId = 0;
    public int costItemNum = 0;

    public int compareTo(SGoods o) {
        return this.id - o.id;
    }

    public SGoods() {
    }

    public SGoods(SGoods arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.type = arg.type;
        this.itemId = arg.itemId;
        this.currencys = arg.currencys;
        this.prices = arg.prices;
        this.oldprices = arg.oldprices;
        this.limitType = arg.limitType;
        this.limitNum = arg.limitNum;
        this.limitSaleNum = arg.limitSaleNum;
        this.limitLookLv = arg.limitLookLv;
        this.lvMin = arg.lvMin;
        this.lvMax = arg.lvMax;
        this.floatingRisePrice = arg.floatingRisePrice;
        this.floatingDepreciatePrice = arg.floatingDepreciatePrice;
        this.floatingmax = arg.floatingmax;
        this.floatingmin = arg.floatingmin;
        this.costItemId = arg.costItemId;
        this.costItemNum = arg.costItemNum;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public int getType() {
        return this.type;
    }

    public void setType(int v) {
        this.type = v;
    }

    public int getItemId() {
        return this.itemId;
    }

    public void setItemId(int v) {
        this.itemId = v;
    }

    public ArrayList<Integer> getCurrencys() {
        return this.currencys;
    }

    public void setCurrencys(ArrayList<Integer> v) {
        this.currencys = v;
    }

    public ArrayList<Integer> getPrices() {
        return this.prices;
    }

    public void setPrices(ArrayList<Integer> v) {
        this.prices = v;
    }

    public ArrayList<Integer> getOldprices() {
        return this.oldprices;
    }

    public void setOldprices(ArrayList<Integer> v) {
        this.oldprices = v;
    }

    public int getLimitType() {
        return this.limitType;
    }

    public void setLimitType(int v) {
        this.limitType = v;
    }

    public int getLimitNum() {
        return this.limitNum;
    }

    public void setLimitNum(int v) {
        this.limitNum = v;
    }

    public int getLimitSaleNum() {
        return this.limitSaleNum;
    }

    public void setLimitSaleNum(int v) {
        this.limitSaleNum = v;
    }

    public int getLimitLookLv() {
        return this.limitLookLv;
    }

    public void setLimitLookLv(int v) {
        this.limitLookLv = v;
    }

    public int getLvMin() {
        return this.lvMin;
    }

    public void setLvMin(int v) {
        this.lvMin = v;
    }

    public int getLvMax() {
        return this.lvMax;
    }

    public void setLvMax(int v) {
        this.lvMax = v;
    }

    public double getFloatingRisePrice() {
        return this.floatingRisePrice;
    }

    public void setFloatingRisePrice(double v) {
        this.floatingRisePrice = v;
    }

    public double getFloatingDepreciatePrice() {
        return this.floatingDepreciatePrice;
    }

    public void setFloatingDepreciatePrice(double v) {
        this.floatingDepreciatePrice = v;
    }

    public double getFloatingmax() {
        return this.floatingmax;
    }

    public void setFloatingmax(double v) {
        this.floatingmax = v;
    }

    public double getFloatingmin() {
        return this.floatingmin;
    }

    public void setFloatingmin(double v) {
        this.floatingmin = v;
    }

    public int getCostItemId() {
        return this.costItemId;
    }

    public void setCostItemId(int v) {
        this.costItemId = v;
    }

    public int getCostItemNum() {
        return this.costItemNum;
    }

    public void setCostItemNum(int v) {
        this.costItemNum = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

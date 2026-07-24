//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SPetShop implements ConvMain.Checkable, Comparable<SPetShop> {
    public int id = 0;
    public int limitLookLv = 0;
    public ArrayList<Integer> goodsids;

    public int compareTo(SPetShop o) {
        return this.id - o.id;
    }

    public SPetShop() {
    }

    public SPetShop(SPetShop arg) {
        this.id = arg.id;
        this.limitLookLv = arg.limitLookLv;
        this.goodsids = arg.goodsids;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getLimitLookLv() {
        return this.limitLookLv;
    }

    public void setLimitLookLv(int v) {
        this.limitLookLv = v;
    }

    public ArrayList<Integer> getGoodsids() {
        return this.goodsids;
    }

    public void setGoodsids(ArrayList<Integer> v) {
        this.goodsids = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

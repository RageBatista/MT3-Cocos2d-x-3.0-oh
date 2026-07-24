//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SNpcSale implements ConvMain.Checkable, Comparable<SNpcSale> {
    public int id = 0;
    public int floating = 0;
    public int floatingtime = 0;
    public ArrayList<Integer> goodsids;

    public int compareTo(SNpcSale o) {
        return this.id - o.id;
    }

    public SNpcSale() {
    }

    public SNpcSale(SNpcSale arg) {
        this.id = arg.id;
        this.floating = arg.floating;
        this.floatingtime = arg.floatingtime;
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

    public int getFloating() {
        return this.floating;
    }

    public void setFloating(int v) {
        this.floating = v;
    }

    public int getFloatingtime() {
        return this.floatingtime;
    }

    public void setFloatingtime(int v) {
        this.floatingtime = v;
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

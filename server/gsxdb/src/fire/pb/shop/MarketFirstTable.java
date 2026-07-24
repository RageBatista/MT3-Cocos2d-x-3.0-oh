//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class MarketFirstTable implements ConvMain.Checkable, Comparable<MarketFirstTable> {
    public int id = 0;
    public String firstname = null;
    public int isfloating = 0;
    public ArrayList<Integer> secondno;

    public int compareTo(MarketFirstTable o) {
        return this.id - o.id;
    }

    public MarketFirstTable() {
    }

    public MarketFirstTable(MarketFirstTable arg) {
        this.id = arg.id;
        this.firstname = arg.firstname;
        this.isfloating = arg.isfloating;
        this.secondno = arg.secondno;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getFirstname() {
        return this.firstname;
    }

    public void setFirstname(String v) {
        this.firstname = v;
    }

    public int getIsfloating() {
        return this.isfloating;
    }

    public void setIsfloating(int v) {
        this.isfloating = v;
    }

    public ArrayList<Integer> getSecondno() {
        return this.secondno;
    }

    public void setSecondno(ArrayList<Integer> v) {
        this.secondno = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import java.util.Map;
import mytools.ConvMain;

public class SPetDepotPrice implements ConvMain.Checkable, Comparable<SPetDepotPrice> {
    public int id = 0;
    public int num = 0;
    public int nextneedmoney = 0;

    public int compareTo(SPetDepotPrice o) {
        return this.id - o.id;
    }

    public SPetDepotPrice() {
    }

    public SPetDepotPrice(SPetDepotPrice arg) {
        this.id = arg.id;
        this.num = arg.num;
        this.nextneedmoney = arg.nextneedmoney;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getNum() {
        return this.num;
    }

    public void setNum(int v) {
        this.num = v;
    }

    public int getNextneedmoney() {
        return this.nextneedmoney;
    }

    public void setNextneedmoney(int v) {
        this.nextneedmoney = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

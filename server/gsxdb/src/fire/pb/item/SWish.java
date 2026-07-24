//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SWish implements ConvMain.Checkable, Comparable<SWish> {
    public int id = 0;
    public int itemid = 0;
    public int probability = 0;

    public int compareTo(SWish o) {
        return this.id - o.id;
    }

    public SWish() {
    }

    public SWish(SWish arg) {
        this.id = arg.id;
        this.itemid = arg.itemid;
        this.probability = arg.probability;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getItemid() {
        return this.itemid;
    }

    public void setItemid(int v) {
        this.itemid = v;
    }

    public int getProbability() {
        return this.probability;
    }

    public void setProbability(int v) {
        this.probability = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import java.util.Map;
import mytools.ConvMain;

public class SActiveChestConfig4D implements ConvMain.Checkable, Comparable<SActiveChestConfig4D> {
    public int id = 0;
    public int activeness = 0;
    public int itemid = 0;

    public int compareTo(SActiveChestConfig4D o) {
        return this.id - o.id;
    }

    public SActiveChestConfig4D() {
    }

    public SActiveChestConfig4D(SActiveChestConfig4D arg) {
        this.id = arg.id;
        this.activeness = arg.activeness;
        this.itemid = arg.itemid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getActiveness() {
        return this.activeness;
    }

    public void setActiveness(int v) {
        this.activeness = v;
    }

    public int getItemid() {
        return this.itemid;
    }

    public void setItemid(int v) {
        this.itemid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

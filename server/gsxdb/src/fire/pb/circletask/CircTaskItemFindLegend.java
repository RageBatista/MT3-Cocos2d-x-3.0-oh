//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import java.util.Map;
import mytools.ConvMain;

public class CircTaskItemFindLegend implements ConvMain.Checkable, Comparable<CircTaskItemFindLegend> {
    public int id = 0;
    public int weight = 0;

    public int compareTo(CircTaskItemFindLegend o) {
        return this.id - o.id;
    }

    public CircTaskItemFindLegend() {
    }

    public CircTaskItemFindLegend(CircTaskItemFindLegend arg) {
        this.id = arg.id;
        this.weight = arg.weight;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getWeight() {
        return this.weight;
    }

    public void setWeight(int v) {
        this.weight = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import java.util.Map;
import mytools.ConvMain;

public class PetResetPointConfig implements ConvMain.Checkable, Comparable<PetResetPointConfig> {
    public int id = 0;
    public int cost = 0;

    public int compareTo(PetResetPointConfig o) {
        return this.id - o.id;
    }

    public PetResetPointConfig() {
    }

    public PetResetPointConfig(PetResetPointConfig arg) {
        this.id = arg.id;
        this.cost = arg.cost;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getCost() {
        return this.cost;
    }

    public void setCost(int v) {
        this.cost = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

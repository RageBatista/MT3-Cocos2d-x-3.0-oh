//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import java.util.Map;
import mytools.ConvMain;

public class PetLearnInternalCountConfig implements ConvMain.Checkable, Comparable<PetLearnInternalCountConfig> {
    public int id = 0;
    public double rate = (double)0.0F;

    public int compareTo(PetLearnInternalCountConfig o) {
        return this.id - o.id;
    }

    public PetLearnInternalCountConfig() {
    }

    public PetLearnInternalCountConfig(PetLearnInternalCountConfig arg) {
        this.id = arg.id;
        this.rate = arg.rate;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public double getRate() {
        return this.rate;
    }

    public void setRate(double v) {
        this.rate = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

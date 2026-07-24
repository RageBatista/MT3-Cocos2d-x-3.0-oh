//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SFumoInfo implements ConvMain.Checkable, Comparable<SFumoInfo> {
    public int id = 0;
    public int skilltype = 0;
    public double probability = (double)0.0F;

    public int compareTo(SFumoInfo o) {
        return this.id - o.id;
    }

    public SFumoInfo() {
    }

    public SFumoInfo(SFumoInfo arg) {
        this.id = arg.id;
        this.skilltype = arg.skilltype;
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

    public int getSkilltype() {
        return this.skilltype;
    }

    public void setSkilltype(int v) {
        this.skilltype = v;
    }

    public double getProbability() {
        return this.probability;
    }

    public void setProbability(double v) {
        this.probability = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

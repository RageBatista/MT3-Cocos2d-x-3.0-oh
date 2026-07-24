//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.effect;

import java.util.Map;
import mytools.ConvMain;

public class SPetAbilityScore implements ConvMain.Checkable, Comparable<SPetAbilityScore> {
    public int id = 0;
    public String name = null;
    public double score = (double)0.0F;

    public int compareTo(SPetAbilityScore o) {
        return this.id - o.id;
    }

    public SPetAbilityScore() {
    }

    public SPetAbilityScore(SPetAbilityScore arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.score = arg.score;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public double getScore() {
        return this.score;
    }

    public void setScore(double v) {
        this.score = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

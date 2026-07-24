//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import java.util.Map;
import mytools.ConvMain;

public class PetSynthesizeSkillRateConfig implements ConvMain.Checkable, Comparable<PetSynthesizeSkillRateConfig> {
    public int id = 0;
    public int value = 0;

    public int compareTo(PetSynthesizeSkillRateConfig o) {
        return this.id - o.id;
    }

    public PetSynthesizeSkillRateConfig() {
    }

    public PetSynthesizeSkillRateConfig(PetSynthesizeSkillRateConfig arg) {
        this.id = arg.id;
        this.value = arg.value;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getValue() {
        return this.value;
    }

    public void setValue(int v) {
        this.value = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

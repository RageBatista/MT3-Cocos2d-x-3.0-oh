//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.effect;

import java.util.Map;
import mytools.ConvMain;

public class SAbilityScore implements ConvMain.Checkable, Comparable<SAbilityScore> {
    public int id = 0;
    public String ablilityName = null;
    public double coefficient = (double)0.0F;
    public String parameter = null;
    public String formula = null;

    public int compareTo(SAbilityScore o) {
        return this.id - o.id;
    }

    public SAbilityScore() {
    }

    public SAbilityScore(SAbilityScore arg) {
        this.id = arg.id;
        this.ablilityName = arg.ablilityName;
        this.coefficient = arg.coefficient;
        this.parameter = arg.parameter;
        this.formula = arg.formula;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getAblilityName() {
        return this.ablilityName;
    }

    public void setAblilityName(String v) {
        this.ablilityName = v;
    }

    public double getCoefficient() {
        return this.coefficient;
    }

    public void setCoefficient(double v) {
        this.coefficient = v;
    }

    public String getParameter() {
        return this.parameter;
    }

    public void setParameter(String v) {
        this.parameter = v;
    }

    public String getFormula() {
        return this.formula;
    }

    public void setFormula(String v) {
        this.formula = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class QualityFormula implements ConvMain.Checkable, Comparable<QualityFormula> {
    public int id = 0;
    public int 效果1id = 0;
    public double 品质系数1 = (double)0.0F;
    public double 截距系数1 = (double)0.0F;
    public int 效果2id = 0;
    public double 品质系数2 = (double)0.0F;
    public double 截距系数2 = (double)0.0F;
    public int 中毒概率 = 0;

    public int compareTo(QualityFormula o) {
        return this.id - o.id;
    }

    public QualityFormula() {
    }

    public QualityFormula(QualityFormula arg) {
        this.id = arg.id;
        this.效果1id = arg.效果1id;
        this.品质系数1 = arg.品质系数1;
        this.截距系数1 = arg.截距系数1;
        this.效果2id = arg.效果2id;
        this.品质系数2 = arg.品质系数2;
        this.截距系数2 = arg.截距系数2;
        this.中毒概率 = arg.中毒概率;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int get效果1id() {
        return this.效果1id;
    }

    public void set效果1id(int v) {
        this.效果1id = v;
    }

    public double get品质系数1() {
        return this.品质系数1;
    }

    public void set品质系数1(double v) {
        this.品质系数1 = v;
    }

    public double get截距系数1() {
        return this.截距系数1;
    }

    public void set截距系数1(double v) {
        this.截距系数1 = v;
    }

    public int get效果2id() {
        return this.效果2id;
    }

    public void set效果2id(int v) {
        this.效果2id = v;
    }

    public double get品质系数2() {
        return this.品质系数2;
    }

    public void set品质系数2(double v) {
        this.品质系数2 = v;
    }

    public double get截距系数2() {
        return this.截距系数2;
    }

    public void set截距系数2(double v) {
        this.截距系数2 = v;
    }

    public int get中毒概率() {
        return this.中毒概率;
    }

    public void set中毒概率(int v) {
        this.中毒概率 = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import java.util.Map;
import mytools.ConvMain;

public class SCatchRate implements ConvMain.Checkable, Comparable<SCatchRate> {
    public int id = 0;
    public int upperlimit = 0;
    public int lowerlimit = 0;
    public double catchfactor = (double)0.0F;
    public double catchconst = (double)0.0F;

    public int compareTo(SCatchRate o) {
        return this.id - o.id;
    }

    public SCatchRate() {
    }

    public SCatchRate(SCatchRate arg) {
        this.id = arg.id;
        this.upperlimit = arg.upperlimit;
        this.lowerlimit = arg.lowerlimit;
        this.catchfactor = arg.catchfactor;
        this.catchconst = arg.catchconst;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getUpperlimit() {
        return this.upperlimit;
    }

    public void setUpperlimit(int v) {
        this.upperlimit = v;
    }

    public int getLowerlimit() {
        return this.lowerlimit;
    }

    public void setLowerlimit(int v) {
        this.lowerlimit = v;
    }

    public double getCatchfactor() {
        return this.catchfactor;
    }

    public void setCatchfactor(double v) {
        this.catchfactor = v;
    }

    public double getCatchconst() {
        return this.catchconst;
    }

    public void setCatchconst(double v) {
        this.catchconst = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

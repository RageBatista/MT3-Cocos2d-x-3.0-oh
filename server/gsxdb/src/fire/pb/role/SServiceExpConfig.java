//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import java.util.Map;
import mytools.ConvMain;

public class SServiceExpConfig implements ConvMain.Checkable, Comparable<SServiceExpConfig> {
    public int id = 0;
    public int midlevel = 0;
    public double bili = (double)0.0F;

    public int compareTo(SServiceExpConfig o) {
        return this.id - o.id;
    }

    public SServiceExpConfig() {
    }

    public SServiceExpConfig(SServiceExpConfig arg) {
        this.id = arg.id;
        this.midlevel = arg.midlevel;
        this.bili = arg.bili;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getMidlevel() {
        return this.midlevel;
    }

    public void setMidlevel(int v) {
        this.midlevel = v;
    }

    public double getBili() {
        return this.bili;
    }

    public void setBili(double v) {
        this.bili = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

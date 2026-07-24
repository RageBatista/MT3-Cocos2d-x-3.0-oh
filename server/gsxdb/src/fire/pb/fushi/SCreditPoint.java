//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi;

import java.util.Map;
import mytools.ConvMain;

public class SCreditPoint implements ConvMain.Checkable, Comparable<SCreditPoint> {
    public int id = 0;
    public double eventvalue = (double)0.0F;

    public int compareTo(SCreditPoint o) {
        return this.id - o.id;
    }

    public SCreditPoint() {
    }

    public SCreditPoint(SCreditPoint arg) {
        this.id = arg.id;
        this.eventvalue = arg.eventvalue;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public double getEventvalue() {
        return this.eventvalue;
    }

    public void setEventvalue(double v) {
        this.eventvalue = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

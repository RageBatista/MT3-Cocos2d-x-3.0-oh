//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.Map;
import mytools.ConvMain;

public class SActionTime implements ConvMain.Checkable, Comparable<SActionTime> {
    public int id = 0;
    public int actiontime = 0;

    public int compareTo(SActionTime o) {
        return this.id - o.id;
    }

    public SActionTime() {
    }

    public SActionTime(SActionTime arg) {
        this.id = arg.id;
        this.actiontime = arg.actiontime;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getActiontime() {
        return this.actiontime;
    }

    public void setActiontime(int v) {
        this.actiontime = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import java.util.Map;
import mytools.ConvMain;

public class SAllTaskLine implements ConvMain.Checkable, Comparable<SAllTaskLine> {
    public int id = 0;
    public int 职业 = 0;

    public int compareTo(SAllTaskLine o) {
        return this.id - o.id;
    }

    public SAllTaskLine() {
    }

    public SAllTaskLine(SAllTaskLine arg) {
        this.id = arg.id;
        this.职业 = arg.职业;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int get职业() {
        return this.职业;
    }

    public void set职业(int v) {
        this.职业 = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

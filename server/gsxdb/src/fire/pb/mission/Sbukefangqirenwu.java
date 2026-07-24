//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import java.util.Map;
import mytools.ConvMain;

public class Sbukefangqirenwu implements ConvMain.Checkable, Comparable<Sbukefangqirenwu> {
    public int id = 0;

    public int compareTo(Sbukefangqirenwu o) {
        return this.id - o.id;
    }

    public Sbukefangqirenwu() {
    }

    public Sbukefangqirenwu(Sbukefangqirenwu arg) {
        this.id = arg.id;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

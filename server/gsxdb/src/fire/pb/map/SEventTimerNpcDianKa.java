//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.map;

import java.util.Map;

public class SEventTimerNpcDianKa extends EventTimerNpc {
    public int shoulie = 0;

    public int compareTo(SEventTimerNpcDianKa o) {
        return this.id - o.id;
    }

    public SEventTimerNpcDianKa(EventTimerNpc arg) {
        super(arg);
    }

    public SEventTimerNpcDianKa() {
    }

    public SEventTimerNpcDianKa(SEventTimerNpcDianKa arg) {
        super(arg);
        this.shoulie = arg.shoulie;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    public int getShoulie() {
        return this.shoulie;
    }

    public void setShoulie(int v) {
        this.shoulie = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

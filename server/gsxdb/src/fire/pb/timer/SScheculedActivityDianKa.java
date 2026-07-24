//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.timer;

import java.util.Map;

public class SScheculedActivityDianKa extends ScheculedActivity {
    public int compareTo(SScheculedActivityDianKa o) {
        return this.id - o.id;
    }

    public SScheculedActivityDianKa(ScheculedActivity arg) {
        super(arg);
    }

    public SScheculedActivityDianKa() {
    }

    public SScheculedActivityDianKa(SScheculedActivityDianKa arg) {
        super(arg);
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

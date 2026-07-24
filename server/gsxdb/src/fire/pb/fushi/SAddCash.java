//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi;

import java.util.Map;

public class SAddCash extends ChargeConfig {
    public int compareTo(SAddCash o) {
        return this.id - o.id;
    }

    public SAddCash(ChargeConfig arg) {
        super(arg);
    }

    public SAddCash() {
    }

    public SAddCash(SAddCash arg) {
        super(arg);
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

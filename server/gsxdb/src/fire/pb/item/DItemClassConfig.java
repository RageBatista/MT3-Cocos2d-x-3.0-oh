//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;

public class DItemClassConfig extends ItemClassConfig {
    public int compareTo(DItemClassConfig o) {
        return this.id - o.id;
    }

    public DItemClassConfig(ItemClassConfig arg) {
        super(arg);
    }

    public DItemClassConfig() {
    }

    public DItemClassConfig(DItemClassConfig arg) {
        super(arg);
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

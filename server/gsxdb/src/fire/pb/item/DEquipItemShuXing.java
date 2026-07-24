//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;

public class DEquipItemShuXing extends EquipItemShuXing {
    public int compareTo(DEquipItemShuXing o) {
        return this.id - o.id;
    }

    public DEquipItemShuXing(EquipItemShuXing arg) {
        super(arg);
    }

    public DEquipItemShuXing() {
    }

    public DEquipItemShuXing(DEquipItemShuXing arg) {
        super(arg);
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

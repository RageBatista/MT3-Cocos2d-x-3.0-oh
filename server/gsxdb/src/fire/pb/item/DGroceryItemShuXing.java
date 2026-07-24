//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;

public class DGroceryItemShuXing extends GroceryItemShuXing {
    public int compareTo(DGroceryItemShuXing o) {
        return this.id - o.id;
    }

    public DGroceryItemShuXing(GroceryItemShuXing arg) {
        super(arg);
    }

    public DGroceryItemShuXing() {
    }

    public DGroceryItemShuXing(DGroceryItemShuXing arg) {
        super(arg);
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

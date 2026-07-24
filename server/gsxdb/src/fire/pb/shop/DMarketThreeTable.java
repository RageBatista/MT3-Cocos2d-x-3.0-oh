//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.shop;

import java.util.Map;

public class DMarketThreeTable extends MarketThreeTable {
    public int compareTo(DMarketThreeTable o) {
        return this.id - o.id;
    }

    public DMarketThreeTable(MarketThreeTable arg) {
        super(arg);
    }

    public DMarketThreeTable() {
    }

    public DMarketThreeTable(DMarketThreeTable arg) {
        super(arg);
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

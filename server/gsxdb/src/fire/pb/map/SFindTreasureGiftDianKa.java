//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.map;

import java.util.Map;

public class SFindTreasureGiftDianKa extends FindTreasureGift {
    public int compareTo(SFindTreasureGiftDianKa o) {
        return this.id - o.id;
    }

    public SFindTreasureGiftDianKa(FindTreasureGift arg) {
        super(arg);
    }

    public SFindTreasureGiftDianKa() {
    }

    public SFindTreasureGiftDianKa(SFindTreasureGiftDianKa arg) {
        super(arg);
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;

public class DSEquipLvGemInfo extends SEquipLvGemInfo {
    public int compareTo(DSEquipLvGemInfo o) {
        return this.id - o.id;
    }

    public DSEquipLvGemInfo(SEquipLvGemInfo arg) {
        super(arg);
    }

    public DSEquipLvGemInfo() {
    }

    public DSEquipLvGemInfo(DSEquipLvGemInfo arg) {
        super(arg);
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

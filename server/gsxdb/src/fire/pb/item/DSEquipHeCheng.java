//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;

public class DSEquipHeCheng extends SEquipHeCheng {
    public int compareTo(DSEquipHeCheng o) {
        return this.id - o.id;
    }

    public DSEquipHeCheng(SEquipHeCheng arg) {
        super(arg);
    }

    public DSEquipHeCheng() {
    }

    public DSEquipHeCheng(DSEquipHeCheng arg) {
        super(arg);
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

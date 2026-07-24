//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.Map;

public class SImperialExamVillageRepo extends ImperialExamVillageRepo {
    public int compareTo(SImperialExamVillageRepo o) {
        return this.id - o.id;
    }

    public SImperialExamVillageRepo(ImperialExamVillageRepo arg) {
        super(arg);
    }

    public SImperialExamVillageRepo() {
    }

    public SImperialExamVillageRepo(SImperialExamVillageRepo arg) {
        super(arg);
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

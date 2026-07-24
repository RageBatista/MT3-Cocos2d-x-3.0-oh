//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import java.util.Map;

public class SGuideCourseDianKa extends GuideCourse {
    public int compareTo(SGuideCourseDianKa o) {
        return this.id - o.id;
    }

    public SGuideCourseDianKa(GuideCourse arg) {
        super(arg);
    }

    public SGuideCourseDianKa() {
    }

    public SGuideCourseDianKa(SGuideCourseDianKa arg) {
        super(arg);
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

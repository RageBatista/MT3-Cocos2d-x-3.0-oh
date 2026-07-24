//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import java.util.Map;

public class SGuideCourse extends GuideCourse {
    public int compareTo(SGuideCourse o) {
        return this.id - o.id;
    }

    public SGuideCourse(GuideCourse arg) {
        super(arg);
    }

    public SGuideCourse() {
    }

    public SGuideCourse(SGuideCourse arg) {
        super(arg);
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

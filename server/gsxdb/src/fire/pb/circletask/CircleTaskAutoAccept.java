//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import java.util.Map;
import mytools.ConvMain;

public class CircleTaskAutoAccept implements ConvMain.Checkable, Comparable<CircleTaskAutoAccept> {
    public int id = 0;
    public int circletype = 0;

    public int compareTo(CircleTaskAutoAccept o) {
        return this.id - o.id;
    }

    public CircleTaskAutoAccept() {
    }

    public CircleTaskAutoAccept(CircleTaskAutoAccept arg) {
        this.id = arg.id;
        this.circletype = arg.circletype;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getCircletype() {
        return this.circletype;
    }

    public void setCircletype(int v) {
        this.circletype = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

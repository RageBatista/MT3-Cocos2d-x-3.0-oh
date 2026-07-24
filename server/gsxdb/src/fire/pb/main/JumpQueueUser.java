//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.main;

import java.util.Map;
import mytools.ConvMain;

public class JumpQueueUser implements ConvMain.Checkable, Comparable<JumpQueueUser> {
    public int id = 0;

    public int compareTo(JumpQueueUser o) {
        return this.id - o.id;
    }

    public JumpQueueUser() {
    }

    public JumpQueueUser(JumpQueueUser arg) {
        this.id = arg.id;
    }

    public void checkValid(Map<String, Map<Integer, ?>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

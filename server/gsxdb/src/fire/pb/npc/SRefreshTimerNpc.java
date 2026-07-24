//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.Map;

public class SRefreshTimerNpc extends RefreshTimerNpc {
    public int compareTo(SRefreshTimerNpc o) {
        return this.id - o.id;
    }

    public SRefreshTimerNpc(RefreshTimerNpc arg) {
        super(arg);
    }

    public SRefreshTimerNpc() {
    }

    public SRefreshTimerNpc(SRefreshTimerNpc arg) {
        super(arg);
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

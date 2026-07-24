//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.friends;

import java.util.Map;
import mytools.ConvMain;

public class FriendGiveItem implements ConvMain.Checkable, Comparable<FriendGiveItem> {
    public int id = 0;

    public int compareTo(FriendGiveItem o) {
        return this.id - o.id;
    }

    public FriendGiveItem() {
    }

    public FriendGiveItem(FriendGiveItem arg) {
        this.id = arg.id;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
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

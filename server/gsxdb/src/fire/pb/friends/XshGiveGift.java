//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.friends;

import java.util.Map;
import mytools.ConvMain;

public class XshGiveGift implements ConvMain.Checkable, Comparable<XshGiveGift> {
    public int id = 0;

    public int compareTo(XshGiveGift o) {
        return this.id - o.id;
    }

    public XshGiveGift() {
    }

    public XshGiveGift(XshGiveGift arg) {
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

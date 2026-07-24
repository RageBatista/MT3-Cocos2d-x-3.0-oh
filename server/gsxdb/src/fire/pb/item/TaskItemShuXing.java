//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;

public class TaskItemShuXing extends ItemShuXing {
    public int intoquestpack = 0;
    public int maxnaijiu = 0;

    public int compareTo(TaskItemShuXing o) {
        return this.id - o.id;
    }

    public TaskItemShuXing(ItemShuXing arg) {
        super(arg);
    }

    public TaskItemShuXing() {
    }

    public TaskItemShuXing(TaskItemShuXing arg) {
        super(arg);
        this.intoquestpack = arg.intoquestpack;
        this.maxnaijiu = arg.maxnaijiu;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    public int getIntoquestpack() {
        return this.intoquestpack;
    }

    public void setIntoquestpack(int v) {
        this.intoquestpack = v;
    }

    public int getMaxnaijiu() {
        return this.maxnaijiu;
    }

    public void setMaxnaijiu(int v) {
        this.maxnaijiu = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

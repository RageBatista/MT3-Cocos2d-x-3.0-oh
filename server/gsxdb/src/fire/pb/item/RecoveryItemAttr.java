//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;

public class RecoveryItemAttr extends ItemShuXing {
    public int addhp = 0;
    public int addhpmax = 0;
    public int addmp = 0;

    public RecoveryItemAttr(ItemShuXing arg) {
        super(arg);
    }

    public RecoveryItemAttr() {
    }

    public RecoveryItemAttr(RecoveryItemAttr arg) {
        super(arg);
        this.addhp = arg.addhp;
        this.addhpmax = arg.addhpmax;
        this.addmp = arg.addmp;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    public int getAddhp() {
        return this.addhp;
    }

    public void setAddhp(int v) {
        this.addhp = v;
    }

    public int getAddhpmax() {
        return this.addhpmax;
    }

    public void setAddhpmax(int v) {
        this.addhpmax = v;
    }

    public int getAddmp() {
        return this.addmp;
    }

    public void setAddmp(int v) {
        this.addmp = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

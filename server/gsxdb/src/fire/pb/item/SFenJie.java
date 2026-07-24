//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;

public class SFenJie extends ItemShuXing {
    public int canfenjie = 0;
    public int returnitemid = 0;
    public int returnitemnum = 0;

    public int compareTo(SFenJie o) {
        return this.id - o.id;
    }

    public SFenJie(ItemShuXing arg) {
        super(arg);
    }

    public SFenJie() {
    }

    public SFenJie(SFenJie arg) {
        super(arg);
        this.canfenjie = arg.canfenjie;
        this.returnitemid = arg.returnitemid;
        this.returnitemnum = arg.returnitemnum;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    public int getCanfenjie() {
        return this.canfenjie;
    }

    public void setCanfenjie(int v) {
        this.canfenjie = v;
    }

    public int getReturnitemid() {
        return this.returnitemid;
    }

    public void setReturnitemid(int v) {
        this.returnitemid = v;
    }

    public int getReturnitemnum() {
        return this.returnitemnum;
    }

    public void setReturnitemnum(int v) {
        this.returnitemnum = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

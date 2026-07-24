//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;

public class SHuiShou extends ItemShuXing {
    public int canhuishou = 0;
    public int huishouitemid = 0;
    public int huishouitemnum = 0;

    public int compareTo(SHuiShou o) {
        return this.id - o.id;
    }

    public SHuiShou(ItemShuXing arg) {
        super(arg);
    }

    public SHuiShou() {
    }

    public SHuiShou(SHuiShou arg) {
        super(arg);
        this.canhuishou = arg.canhuishou;
        this.huishouitemid = arg.huishouitemid;
        this.huishouitemnum = arg.huishouitemnum;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
        super.checkValid(objs);
    }

    public int getCanhuishou() {
        return this.canhuishou;
    }

    public void setCanhuishou(int v) {
        this.canhuishou = v;
    }

    public int getHuishouitemid() {
        return this.huishouitemid;
    }

    public void setHuishouitemid(int v) {
        this.huishouitemid = v;
    }

    public int getHuishouitemnum() {
        return this.huishouitemnum;
    }

    public void setHuishouitemnum(int v) {
        this.huishouitemnum = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

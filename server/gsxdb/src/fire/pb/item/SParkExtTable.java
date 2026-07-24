//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SParkExtTable implements ConvMain.Checkable, Comparable<SParkExtTable> {
    public int id = 0;
    public int haveCount = 0;
    public int needyinbi = 0;

    public int compareTo(SParkExtTable o) {
        return this.id - o.id;
    }

    public SParkExtTable() {
    }

    public SParkExtTable(SParkExtTable arg) {
        this.id = arg.id;
        this.haveCount = arg.haveCount;
        this.needyinbi = arg.needyinbi;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getHaveCount() {
        return this.haveCount;
    }

    public void setHaveCount(int v) {
        this.haveCount = v;
    }

    public int getNeedyinbi() {
        return this.needyinbi;
    }

    public void setNeedyinbi(int v) {
        this.needyinbi = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

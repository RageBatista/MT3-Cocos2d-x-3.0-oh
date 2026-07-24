//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SItemToDbPoint implements ConvMain.Checkable, Comparable<SItemToDbPoint> {
    public int id = 0;
    public int dbpoint = 0;

    public int compareTo(SItemToDbPoint o) {
        return this.id - o.id;
    }

    public SItemToDbPoint() {
    }

    public SItemToDbPoint(SItemToDbPoint arg) {
        this.id = arg.id;
        this.dbpoint = arg.dbpoint;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getDbpoint() {
        return this.dbpoint;
    }

    public void setDbpoint(int v) {
        this.dbpoint = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

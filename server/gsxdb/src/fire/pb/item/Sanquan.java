//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class Sanquan implements ConvMain.Checkable, Comparable<Sanquan> {
    public int id = 0;
    public String wpname = null;

    public int compareTo(Sanquan o) {
        return this.id - o.id;
    }

    public Sanquan() {
    }

    public Sanquan(Sanquan arg) {
        this.id = arg.id;
        this.wpname = arg.wpname;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getWpname() {
        return this.wpname;
    }

    public void setWpname(String v) {
        this.wpname = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

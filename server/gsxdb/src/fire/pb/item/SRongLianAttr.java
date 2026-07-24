//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SRongLianAttr implements ConvMain.Checkable, Comparable<SRongLianAttr> {
    public int id = 0;
    public int minvalue = 0;
    public int maxvalue = 0;

    public int compareTo(SRongLianAttr o) {
        return this.id - o.id;
    }

    public SRongLianAttr() {
    }

    public SRongLianAttr(SRongLianAttr arg) {
        this.id = arg.id;
        this.minvalue = arg.minvalue;
        this.maxvalue = arg.maxvalue;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getMinvalue() {
        return this.minvalue;
    }

    public void setMinvalue(int v) {
        this.minvalue = v;
    }

    public int getMaxvalue() {
        return this.maxvalue;
    }

    public void setMaxvalue(int v) {
        this.maxvalue = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

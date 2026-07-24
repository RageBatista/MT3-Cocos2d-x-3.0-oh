//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.common;

import java.util.Map;
import mytools.ConvMain;

public class SCommon implements ConvMain.Checkable, Comparable<SCommon> {
    public int id = 0;
    public String value = null;

    public int compareTo(SCommon o) {
        return this.id - o.id;
    }

    public SCommon() {
    }

    public SCommon(SCommon arg) {
        this.id = arg.id;
        this.value = arg.value;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getValue() {
        return this.value;
    }

    public void setValue(String v) {
        this.value = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

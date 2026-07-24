//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.SysConfig;

import java.util.Map;
import mytools.ConvMain;

public class SSysconfig implements ConvMain.Checkable, Comparable<SSysconfig> {
    public int id = 0;
    public int defval = 0;

    public int compareTo(SSysconfig o) {
        return this.id - o.id;
    }

    public SSysconfig() {
    }

    public SSysconfig(SSysconfig arg) {
        this.id = arg.id;
        this.defval = arg.defval;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getDefval() {
        return this.defval;
    }

    public void setDefval(int v) {
        this.defval = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

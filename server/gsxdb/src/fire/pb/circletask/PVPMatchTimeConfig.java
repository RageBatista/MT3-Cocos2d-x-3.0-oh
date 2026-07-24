//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import java.util.Map;
import mytools.ConvMain;

public class PVPMatchTimeConfig implements ConvMain.Checkable, Comparable<PVPMatchTimeConfig> {
    public int id = 0;
    public int lev = 0;

    public int compareTo(PVPMatchTimeConfig o) {
        return this.id - o.id;
    }

    public PVPMatchTimeConfig() {
    }

    public PVPMatchTimeConfig(PVPMatchTimeConfig arg) {
        this.id = arg.id;
        this.lev = arg.lev;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getLev() {
        return this.lev;
    }

    public void setLev(int v) {
        this.lev = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import java.util.Map;
import mytools.ConvMain;

public class SServiceLevelConfig implements ConvMain.Checkable, Comparable<SServiceLevelConfig> {
    public int id = 0;
    public int slevel = 0;
    public int lastday = 0;
    public int openday = 0;

    public int compareTo(SServiceLevelConfig o) {
        return this.id - o.id;
    }

    public SServiceLevelConfig() {
    }

    public SServiceLevelConfig(SServiceLevelConfig arg) {
        this.id = arg.id;
        this.slevel = arg.slevel;
        this.lastday = arg.lastday;
        this.openday = arg.openday;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getSlevel() {
        return this.slevel;
    }

    public void setSlevel(int v) {
        this.slevel = v;
    }

    public int getLastday() {
        return this.lastday;
    }

    public void setLastday(int v) {
        this.lastday = v;
    }

    public int getOpenday() {
        return this.openday;
    }

    public void setOpenday(int v) {
        this.openday = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

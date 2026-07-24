//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import java.util.Map;
import mytools.ConvMain;

public class SServerMaxLevelConfig implements ConvMain.Checkable, Comparable<SServerMaxLevelConfig> {
    public int id = 0;
    public int maxlevel = 0;

    public int compareTo(SServerMaxLevelConfig o) {
        return this.id - o.id;
    }

    public SServerMaxLevelConfig() {
    }

    public SServerMaxLevelConfig(SServerMaxLevelConfig arg) {
        this.id = arg.id;
        this.maxlevel = arg.maxlevel;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getMaxlevel() {
        return this.maxlevel;
    }

    public void setMaxlevel(int v) {
        this.maxlevel = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

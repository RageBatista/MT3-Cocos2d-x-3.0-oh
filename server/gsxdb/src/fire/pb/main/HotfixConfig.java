//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.main;

import java.util.Map;
import mytools.ConvMain;

public class HotfixConfig implements ConvMain.Checkable, Comparable<HotfixConfig> {
    public int id = 0;
    public int type = 0;
    public String name = null;

    public int compareTo(HotfixConfig o) {
        return this.id - o.id;
    }

    public HotfixConfig() {
    }

    public HotfixConfig(HotfixConfig arg) {
        this.id = arg.id;
        this.type = arg.type;
        this.name = arg.name;
    }

    public void checkValid(Map<String, Map<Integer, ?>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getType() {
        return this.type;
    }

    public void setType(int v) {
        this.type = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.Map;
import mytools.ConvMain;

public class SLeitaiLevel implements ConvMain.Checkable, Comparable<SLeitaiLevel> {
    public int id = 0;
    public int levelmin = 0;
    public int levelmax = 0;

    public int compareTo(SLeitaiLevel o) {
        return this.id - o.id;
    }

    public SLeitaiLevel() {
    }

    public SLeitaiLevel(SLeitaiLevel arg) {
        this.id = arg.id;
        this.levelmin = arg.levelmin;
        this.levelmax = arg.levelmax;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getLevelmin() {
        return this.levelmin;
    }

    public void setLevelmin(int v) {
        this.levelmin = v;
    }

    public int getLevelmax() {
        return this.levelmax;
    }

    public void setLevelmax(int v) {
        this.levelmax = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

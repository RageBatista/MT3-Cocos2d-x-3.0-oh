//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SRollCardConfig implements ConvMain.Checkable, Comparable<SRollCardConfig> {
    public int id = 0;
    public ArrayList<String> objs;

    public int compareTo(SRollCardConfig o) {
        return this.id - o.id;
    }

    public SRollCardConfig() {
    }

    public SRollCardConfig(SRollCardConfig arg) {
        this.id = arg.id;
        this.objs = arg.objs;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<String> getObjs() {
        return this.objs;
    }

    public void setObjs(ArrayList<String> v) {
        this.objs = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

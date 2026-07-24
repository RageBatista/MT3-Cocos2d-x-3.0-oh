//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.Map;
import mytools.ConvMain;

public class SNpcPreNameRandom implements ConvMain.Checkable, Comparable<SNpcPreNameRandom> {
    public int id = 0;
    public String preName = null;
    public int group = 0;

    public int compareTo(SNpcPreNameRandom o) {
        return this.id - o.id;
    }

    public SNpcPreNameRandom() {
    }

    public SNpcPreNameRandom(SNpcPreNameRandom arg) {
        this.id = arg.id;
        this.preName = arg.preName;
        this.group = arg.group;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getPreName() {
        return this.preName;
    }

    public void setPreName(String v) {
        this.preName = v;
    }

    public int getGroup() {
        return this.group;
    }

    public void setGroup(int v) {
        this.group = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.Map;
import mytools.ConvMain;

public class SAllConds implements ConvMain.Checkable, Comparable<SAllConds> {
    public int id = 0;
    public String condname = null;

    public int compareTo(SAllConds o) {
        return this.id - o.id;
    }

    public SAllConds() {
    }

    public SAllConds(SAllConds arg) {
        this.id = arg.id;
        this.condname = arg.condname;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getCondname() {
        return this.condname;
    }

    public void setCondname(String v) {
        this.condname = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

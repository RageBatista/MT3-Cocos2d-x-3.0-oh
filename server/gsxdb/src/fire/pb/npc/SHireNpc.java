//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.Map;
import mytools.ConvMain;

public class SHireNpc implements ConvMain.Checkable, Comparable<SHireNpc> {
    public int id = 0;
    public int BuffID = 0;

    public int compareTo(SHireNpc o) {
        return this.id - o.id;
    }

    public SHireNpc() {
    }

    public SHireNpc(SHireNpc arg) {
        this.id = arg.id;
        this.BuffID = arg.BuffID;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getBuffID() {
        return this.BuffID;
    }

    public void setBuffID(int v) {
        this.BuffID = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

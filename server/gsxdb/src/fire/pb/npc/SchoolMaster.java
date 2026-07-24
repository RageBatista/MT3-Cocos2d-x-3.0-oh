//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.Map;
import mytools.ConvMain;

public class SchoolMaster implements ConvMain.Checkable, Comparable<SchoolMaster> {
    public int id = 0;
    public int masterid = 0;

    public int compareTo(SchoolMaster o) {
        return this.id - o.id;
    }

    public SchoolMaster() {
    }

    public SchoolMaster(SchoolMaster arg) {
        this.id = arg.id;
        this.masterid = arg.masterid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getMasterid() {
        return this.masterid;
    }

    public void setMasterid(int v) {
        this.masterid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

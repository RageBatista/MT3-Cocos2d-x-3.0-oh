//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import java.util.Map;
import mytools.ConvMain;

public class CircTaskMailNpc implements ConvMain.Checkable, Comparable<CircTaskMailNpc> {
    public int id = 0;
    public int ctgroup = 0;
    public int school = 0;
    public String npc = null;
    public int serviceid = 0;

    public int compareTo(CircTaskMailNpc o) {
        return this.id - o.id;
    }

    public CircTaskMailNpc() {
    }

    public CircTaskMailNpc(CircTaskMailNpc arg) {
        this.id = arg.id;
        this.ctgroup = arg.ctgroup;
        this.school = arg.school;
        this.npc = arg.npc;
        this.serviceid = arg.serviceid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getCtgroup() {
        return this.ctgroup;
    }

    public void setCtgroup(int v) {
        this.ctgroup = v;
    }

    public int getSchool() {
        return this.school;
    }

    public void setSchool(int v) {
        this.school = v;
    }

    public String getNpc() {
        return this.npc;
    }

    public void setNpc(String v) {
        this.npc = v;
    }

    public int getServiceid() {
        return this.serviceid;
    }

    public void setServiceid(int v) {
        this.serviceid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

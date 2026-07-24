//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import java.util.Map;
import mytools.ConvMain;

public class DemonstrateDefaultMonster implements ConvMain.Checkable, Comparable<DemonstrateDefaultMonster> {
    public int id = 0;
    public int npcid = 0;
    public int mapid = 0;
    public String schoolname = null;

    public int compareTo(DemonstrateDefaultMonster o) {
        return this.id - o.id;
    }

    public DemonstrateDefaultMonster() {
    }

    public DemonstrateDefaultMonster(DemonstrateDefaultMonster arg) {
        this.id = arg.id;
        this.npcid = arg.npcid;
        this.mapid = arg.mapid;
        this.schoolname = arg.schoolname;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getNpcid() {
        return this.npcid;
    }

    public void setNpcid(int v) {
        this.npcid = v;
    }

    public int getMapid() {
        return this.mapid;
    }

    public void setMapid(int v) {
        this.mapid = v;
    }

    public String getSchoolname() {
        return this.schoolname;
    }

    public void setSchoolname(String v) {
        this.schoolname = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import java.util.Map;
import mytools.ConvMain;

public class CircTaskPatrol implements ConvMain.Checkable, Comparable<CircTaskPatrol> {
    public int id = 0;
    public int ctgroup = 0;
    public int schoolid = 0;
    public int levelmin = 0;
    public int levelmax = 0;
    public String mapid = null;
    public String battlecfgid = null;

    public int compareTo(CircTaskPatrol o) {
        return this.id - o.id;
    }

    public CircTaskPatrol() {
    }

    public CircTaskPatrol(CircTaskPatrol arg) {
        this.id = arg.id;
        this.ctgroup = arg.ctgroup;
        this.schoolid = arg.schoolid;
        this.levelmin = arg.levelmin;
        this.levelmax = arg.levelmax;
        this.mapid = arg.mapid;
        this.battlecfgid = arg.battlecfgid;
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

    public int getSchoolid() {
        return this.schoolid;
    }

    public void setSchoolid(int v) {
        this.schoolid = v;
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

    public String getMapid() {
        return this.mapid;
    }

    public void setMapid(String v) {
        this.mapid = v;
    }

    public String getBattlecfgid() {
        return this.battlecfgid;
    }

    public void setBattlecfgid(String v) {
        this.battlecfgid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

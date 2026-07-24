//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class RoleConfig implements ConvMain.Checkable, Comparable<RoleConfig> {
    public int id = 0;
    public int type = 0;
    public int mapx = 0;
    public int mapy = 0;
    public int regionx = 0;
    public int regiony = 0;
    public int mapid = 0;
    public int level = 0;
    public int race = 0;
    public ArrayList<Integer> presents;
    public ArrayList<Integer> nums;
    public ArrayList<Integer> addpoint;
    public ArrayList<Integer> addpoint2;
    public ArrayList<Integer> addpoint3;
    public int defaultscheme = 0;
    public int extAi = 0;

    public int compareTo(RoleConfig o) {
        return this.id - o.id;
    }

    public RoleConfig() {
    }

    public RoleConfig(RoleConfig arg) {
        this.id = arg.id;
        this.type = arg.type;
        this.mapx = arg.mapx;
        this.mapy = arg.mapy;
        this.regionx = arg.regionx;
        this.regiony = arg.regiony;
        this.mapid = arg.mapid;
        this.level = arg.level;
        this.race = arg.race;
        this.presents = arg.presents;
        this.nums = arg.nums;
        this.addpoint = arg.addpoint;
        this.addpoint2 = arg.addpoint2;
        this.addpoint3 = arg.addpoint3;
        this.defaultscheme = arg.defaultscheme;
        this.extAi = arg.extAi;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
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

    public int getMapx() {
        return this.mapx;
    }

    public void setMapx(int v) {
        this.mapx = v;
    }

    public int getMapy() {
        return this.mapy;
    }

    public void setMapy(int v) {
        this.mapy = v;
    }

    public int getRegionx() {
        return this.regionx;
    }

    public void setRegionx(int v) {
        this.regionx = v;
    }

    public int getRegiony() {
        return this.regiony;
    }

    public void setRegiony(int v) {
        this.regiony = v;
    }

    public int getMapid() {
        return this.mapid;
    }

    public void setMapid(int v) {
        this.mapid = v;
    }

    public int getLevel() {
        return this.level;
    }

    public void setLevel(int v) {
        this.level = v;
    }

    public int getRace() {
        return this.race;
    }

    public void setRace(int v) {
        this.race = v;
    }

    public ArrayList<Integer> getPresents() {
        return this.presents;
    }

    public void setPresents(ArrayList<Integer> v) {
        this.presents = v;
    }

    public ArrayList<Integer> getNums() {
        return this.nums;
    }

    public void setNums(ArrayList<Integer> v) {
        this.nums = v;
    }

    public ArrayList<Integer> getAddpoint() {
        return this.addpoint;
    }

    public void setAddpoint(ArrayList<Integer> v) {
        this.addpoint = v;
    }

    public ArrayList<Integer> getAddpoint2() {
        return this.addpoint2;
    }

    public void setAddpoint2(ArrayList<Integer> v) {
        this.addpoint2 = v;
    }

    public ArrayList<Integer> getAddpoint3() {
        return this.addpoint3;
    }

    public void setAddpoint3(ArrayList<Integer> v) {
        this.addpoint3 = v;
    }

    public int getDefaultscheme() {
        return this.defaultscheme;
    }

    public void setDefaultscheme(int v) {
        this.defaultscheme = v;
    }

    public int getExtAi() {
        return this.extAi;
    }

    public void setExtAi(int v) {
        this.extAi = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

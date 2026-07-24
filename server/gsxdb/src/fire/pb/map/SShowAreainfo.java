//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.map;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SShowAreainfo implements ConvMain.Checkable, Comparable<SShowAreainfo> {
    public int id = 0;
    public int environment = 0;
    public int typelevel = 0;
    public int maxnum = 0;
    public ArrayList<Integer> monsters;
    public int lootid = 0;

    public int compareTo(SShowAreainfo o) {
        return this.id - o.id;
    }

    public SShowAreainfo() {
    }

    public SShowAreainfo(SShowAreainfo arg) {
        this.id = arg.id;
        this.environment = arg.environment;
        this.typelevel = arg.typelevel;
        this.maxnum = arg.maxnum;
        this.monsters = arg.monsters;
        this.lootid = arg.lootid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getEnvironment() {
        return this.environment;
    }

    public void setEnvironment(int v) {
        this.environment = v;
    }

    public int getTypelevel() {
        return this.typelevel;
    }

    public void setTypelevel(int v) {
        this.typelevel = v;
    }

    public int getMaxnum() {
        return this.maxnum;
    }

    public void setMaxnum(int v) {
        this.maxnum = v;
    }

    public ArrayList<Integer> getMonsters() {
        return this.monsters;
    }

    public void setMonsters(ArrayList<Integer> v) {
        this.monsters = v;
    }

    public int getLootid() {
        return this.lootid;
    }

    public void setLootid(int v) {
        this.lootid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

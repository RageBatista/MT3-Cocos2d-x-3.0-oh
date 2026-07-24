//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SHeroWeekFreeInfo implements ConvMain.Checkable, Comparable<SHeroWeekFreeInfo> {
    public int id = 0;
    public int week = 0;
    public ArrayList<Integer> heros;
    public ArrayList<Integer> vipheros;

    public int compareTo(SHeroWeekFreeInfo o) {
        return this.id - o.id;
    }

    public SHeroWeekFreeInfo() {
    }

    public SHeroWeekFreeInfo(SHeroWeekFreeInfo arg) {
        this.id = arg.id;
        this.week = arg.week;
        this.heros = arg.heros;
        this.vipheros = arg.vipheros;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getWeek() {
        return this.week;
    }

    public void setWeek(int v) {
        this.week = v;
    }

    public ArrayList<Integer> getHeros() {
        return this.heros;
    }

    public void setHeros(ArrayList<Integer> v) {
        this.heros = v;
    }

    public ArrayList<Integer> getVipheros() {
        return this.vipheros;
    }

    public void setVipheros(ArrayList<Integer> v) {
        this.vipheros = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

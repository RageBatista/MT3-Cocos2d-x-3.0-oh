//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SEquipLvGemInfo implements ConvMain.Checkable, Comparable<SEquipLvGemInfo> {
    public int id = 0;
    public int gemsLevel = 0;
    public int hols = 0;
    public ArrayList<Integer> holsLevel;

    public int compareTo(SEquipLvGemInfo o) {
        return this.id - o.id;
    }

    public SEquipLvGemInfo() {
    }

    public SEquipLvGemInfo(SEquipLvGemInfo arg) {
        this.id = arg.id;
        this.gemsLevel = arg.gemsLevel;
        this.hols = arg.hols;
        this.holsLevel = arg.holsLevel;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getGemsLevel() {
        return this.gemsLevel;
    }

    public void setGemsLevel(int v) {
        this.gemsLevel = v;
    }

    public int getHols() {
        return this.hols;
    }

    public void setHols(int v) {
        this.hols = v;
    }

    public ArrayList<Integer> getHolsLevel() {
        return this.holsLevel;
    }

    public void setHolsLevel(ArrayList<Integer> v) {
        this.holsLevel = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SVipInfoConfig implements ConvMain.Checkable, Comparable<SVipInfoConfig> {
    public int id = 0;
    public int exp = 0;
    public ArrayList<Integer> itemids;
    public ArrayList<Integer> itemcounts;
    public ArrayList<Integer> viprights;
    public int bagsize = 0;
    public int depotsize = 0;

    public int compareTo(SVipInfoConfig o) {
        return this.id - o.id;
    }

    public SVipInfoConfig() {
    }

    public SVipInfoConfig(SVipInfoConfig arg) {
        this.id = arg.id;
        this.exp = arg.exp;
        this.itemids = arg.itemids;
        this.itemcounts = arg.itemcounts;
        this.viprights = arg.viprights;
        this.bagsize = arg.bagsize;
        this.depotsize = arg.depotsize;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getExp() {
        return this.exp;
    }

    public void setExp(int v) {
        this.exp = v;
    }

    public ArrayList<Integer> getItemids() {
        return this.itemids;
    }

    public void setItemids(ArrayList<Integer> v) {
        this.itemids = v;
    }

    public ArrayList<Integer> getItemcounts() {
        return this.itemcounts;
    }

    public void setItemcounts(ArrayList<Integer> v) {
        this.itemcounts = v;
    }

    public ArrayList<Integer> getViprights() {
        return this.viprights;
    }

    public void setViprights(ArrayList<Integer> v) {
        this.viprights = v;
    }

    public int getBagsize() {
        return this.bagsize;
    }

    public void setBagsize(int v) {
        this.bagsize = v;
    }

    public int getDepotsize() {
        return this.depotsize;
    }

    public void setDepotsize(int v) {
        this.depotsize = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

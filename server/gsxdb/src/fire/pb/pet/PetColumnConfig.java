//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import java.util.Map;
import mytools.ConvMain;

public class PetColumnConfig implements ConvMain.Checkable, Comparable<PetColumnConfig> {
    public int id = 0;
    public int initsize = 0;
    public String tablename = null;
    public int maxsize = 0;

    public int compareTo(PetColumnConfig o) {
        return this.id - o.id;
    }

    public PetColumnConfig() {
    }

    public PetColumnConfig(PetColumnConfig arg) {
        this.id = arg.id;
        this.initsize = arg.initsize;
        this.tablename = arg.tablename;
        this.maxsize = arg.maxsize;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getInitsize() {
        return this.initsize;
    }

    public void setInitsize(int v) {
        this.initsize = v;
    }

    public String getTablename() {
        return this.tablename;
    }

    public void setTablename(String v) {
        this.tablename = v;
    }

    public int getMaxsize() {
        return this.maxsize;
    }

    public void setMaxsize(int v) {
        this.maxsize = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

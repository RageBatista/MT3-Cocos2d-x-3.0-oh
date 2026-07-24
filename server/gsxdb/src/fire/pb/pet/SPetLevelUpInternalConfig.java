//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import java.util.Map;
import mytools.ConvMain;

public class SPetLevelUpInternalConfig implements ConvMain.Checkable, Comparable<SPetLevelUpInternalConfig> {
    public int id = 0;
    public int itemid = 0;
    public int count = 0;

    public int compareTo(SPetLevelUpInternalConfig o) {
        return this.id - o.id;
    }

    public SPetLevelUpInternalConfig() {
    }

    public SPetLevelUpInternalConfig(SPetLevelUpInternalConfig arg) {
        this.id = arg.id;
        this.itemid = arg.itemid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getItemid() {
        return this.itemid;
    }

    public void setItemid(int v) {
        this.itemid = v;
    }

    public int getItemcount() {
        return this.count;
    }

    public void setItemcount(int v) {
        this.itemid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;

        NeedId() {
        }
    }
}

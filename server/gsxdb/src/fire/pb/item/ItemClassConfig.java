//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class ItemClassConfig implements ConvMain.Checkable, Comparable<ItemClassConfig> {
    public int id = 0;
    public String classname = null;

    public int compareTo(ItemClassConfig o) {
        return this.id - o.id;
    }

    public ItemClassConfig() {
    }

    public ItemClassConfig(ItemClassConfig arg) {
        this.id = arg.id;
        this.classname = arg.classname;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getClassname() {
        return this.classname;
    }

    public void setClassname(String v) {
        this.classname = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

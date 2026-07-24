//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.title;

import java.util.Map;
import mytools.ConvMain;

public class SItemTitleConfig implements ConvMain.Checkable, Comparable<SItemTitleConfig> {
    public int id = 0;
    public int titleID = 0;

    public int compareTo(SItemTitleConfig o) {
        return this.id - o.id;
    }

    public SItemTitleConfig() {
    }

    public SItemTitleConfig(SItemTitleConfig arg) {
        this.id = arg.id;
        this.titleID = arg.titleID;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getTitleID() {
        return this.titleID;
    }

    public void setTitleID(int v) {
        this.titleID = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

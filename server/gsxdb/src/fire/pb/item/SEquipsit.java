//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SEquipsit implements ConvMain.Checkable, Comparable<SEquipsit> {
    public int id = 0;
    public String buffid = null;
    public int skillid = 0;

    public int compareTo(SEquipsit o) {
        return this.id - o.id;
    }

    public SEquipsit() {
    }

    public SEquipsit(SEquipsit arg) {
        this.id = arg.id;
        this.buffid = arg.buffid;
        this.skillid = arg.skillid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getUpperlimit() {
        return this.buffid;
    }

    public void setUpperlimit(String v) {
        this.buffid = v;
    }

    public int getLowerlimit() {
        return this.skillid;
    }

    public void setLowerlimit(int v) {
        this.skillid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

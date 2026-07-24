//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SItemUseTime implements ConvMain.Checkable, Comparable<SItemUseTime> {
    public int id = 0;
    public int times = 0;
    public int types = 0;

    public int compareTo(SItemUseTime o) {
        return this.id - o.id;
    }

    public SItemUseTime() {
    }

    public SItemUseTime(SItemUseTime arg) {
        this.id = arg.id;
        this.times = arg.times;
        this.types = arg.types;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getTimes() {
        return this.times;
    }

    public void setTimes(int v) {
        this.times = v;
    }

    public int getTypes() {
        return this.types;
    }

    public void setTypes(int v) {
        this.types = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

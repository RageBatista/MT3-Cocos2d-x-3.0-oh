//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import java.util.Map;
import mytools.ConvMain;

public class SLinepingji implements ConvMain.Checkable, Comparable<SLinepingji> {
    public int id = 0;
    public String level = null;
    public int minround = 0;
    public int maxround = 0;
    public int exppersent = 0;

    public int compareTo(SLinepingji o) {
        return this.id - o.id;
    }

    public SLinepingji() {
    }

    public SLinepingji(SLinepingji arg) {
        this.id = arg.id;
        this.level = arg.level;
        this.minround = arg.minround;
        this.maxround = arg.maxround;
        this.exppersent = arg.exppersent;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getLevel() {
        return this.level;
    }

    public void setLevel(String v) {
        this.level = v;
    }

    public int getMinround() {
        return this.minround;
    }

    public void setMinround(int v) {
        this.minround = v;
    }

    public int getMaxround() {
        return this.maxround;
    }

    public void setMaxround(int v) {
        this.maxround = v;
    }

    public int getExppersent() {
        return this.exppersent;
    }

    public void setExppersent(int v) {
        this.exppersent = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import java.util.Map;
import mytools.ConvMain;

public class SRuneSet implements ConvMain.Checkable, Comparable<SRuneSet> {
    public int id = 0;
    public String name = null;
    public String desc = null;

    public int compareTo(SRuneSet o) {
        return this.id - o.id;
    }

    public SRuneSet() {
    }

    public SRuneSet(SRuneSet arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.desc = arg.desc;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public String getDesc() {
        return this.desc;
    }

    public void setDesc(String v) {
        this.desc = v;
    }
}

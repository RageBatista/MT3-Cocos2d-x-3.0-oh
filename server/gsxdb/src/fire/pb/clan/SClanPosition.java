//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import java.util.Map;
import mytools.ConvMain;

public class SClanPosition implements ConvMain.Checkable, Comparable<SClanPosition> {
    public int id = 0;
    public String posname = null;
    public int posmaxnum = 0;

    public int compareTo(SClanPosition o) {
        return this.id - o.id;
    }

    public SClanPosition() {
    }

    public SClanPosition(SClanPosition arg) {
        this.id = arg.id;
        this.posname = arg.posname;
        this.posmaxnum = arg.posmaxnum;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getPosname() {
        return this.posname;
    }

    public void setPosname(String v) {
        this.posname = v;
    }

    public int getPosmaxnum() {
        return this.posmaxnum;
    }

    public void setPosmaxnum(int v) {
        this.posmaxnum = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

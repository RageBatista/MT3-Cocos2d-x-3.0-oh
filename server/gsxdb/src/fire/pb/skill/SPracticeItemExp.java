//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.Map;
import mytools.ConvMain;

public class SPracticeItemExp implements ConvMain.Checkable, Comparable<SPracticeItemExp> {
    public int id = 0;
    public int exp = 0;

    public int compareTo(SPracticeItemExp o) {
        return this.id - o.id;
    }

    public SPracticeItemExp() {
    }

    public SPracticeItemExp(SPracticeItemExp arg) {
        this.id = arg.id;
        this.exp = arg.exp;
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

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

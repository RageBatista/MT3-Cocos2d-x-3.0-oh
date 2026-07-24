//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

import java.util.Map;
import mytools.ConvMain;

public class SGuangHuanLevelup implements ConvMain.Checkable, Comparable<SGuangHuanLevelup> {
    public int id = 0;
    public int needexp = 0;

    public int compareTo(SGuangHuanLevelup o) {
        return this.id - o.id;
    }

    public SGuangHuanLevelup() {
    }

    public SGuangHuanLevelup(SGuangHuanLevelup arg) {
        this.id = arg.id;
        this.needexp = arg.needexp;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getNeedexp() {
        return this.needexp;
    }

    public void setNeedexp(int v) {
        this.needexp = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

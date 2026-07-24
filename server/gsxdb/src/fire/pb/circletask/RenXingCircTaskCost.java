//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import java.util.Map;
import mytools.ConvMain;

public class RenXingCircTaskCost implements ConvMain.Checkable, Comparable<RenXingCircTaskCost> {
    public int id = 0;
    public int stonecost = 0;
    public int xiayicost = 0;

    public int compareTo(RenXingCircTaskCost o) {
        return this.id - o.id;
    }

    public RenXingCircTaskCost() {
    }

    public RenXingCircTaskCost(RenXingCircTaskCost arg) {
        this.id = arg.id;
        this.stonecost = arg.stonecost;
        this.xiayicost = arg.xiayicost;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getStonecost() {
        return this.stonecost;
    }

    public void setStonecost(int v) {
        this.stonecost = v;
    }

    public int getXiayicost() {
        return this.xiayicost;
    }

    public void setXiayicost(int v) {
        this.xiayicost = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

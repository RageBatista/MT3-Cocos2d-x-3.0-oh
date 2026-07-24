//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SFreeDisRewardConfig implements ConvMain.Checkable, Comparable<SFreeDisRewardConfig> {
    public int id = 0;
    public String name = null;
    public ArrayList<Integer> itemids;
    public int num = 0;

    public int compareTo(SFreeDisRewardConfig o) {
        return this.id - o.id;
    }

    public SFreeDisRewardConfig() {
    }

    public SFreeDisRewardConfig(SFreeDisRewardConfig arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.itemids = arg.itemids;
        this.num = arg.num;
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

    public ArrayList<Integer> getItemids() {
        return this.itemids;
    }

    public void setItemids(ArrayList<Integer> v) {
        this.itemids = v;
    }

    public int getNum() {
        return this.num;
    }

    public void setNum(int v) {
        this.num = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.Map;
import mytools.ConvMain;

public class SRideItem implements ConvMain.Checkable, Comparable<SRideItem> {
    public int id = 0;
    public int rideid = 0;
    public int huobi = 0;
    public int money = 0;

    public int compareTo(SRideItem o) {
        return this.id - o.id;
    }

    public SRideItem() {
    }

    public SRideItem(SRideItem arg) {
        this.id = arg.id;
        this.rideid = arg.rideid;
        this.huobi = arg.huobi;
        this.money = arg.money;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getRideid() {
        return this.rideid;
    }

    public void setRideid(int v) {
        this.rideid = v;
    }

    public int getHuobi() {
        return this.huobi;
    }

    public void setHuobi(int v) {
        this.huobi = v;
    }

    public int getMoney() {
        return this.money;
    }

    public void setMoney(int v) {
        this.money = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

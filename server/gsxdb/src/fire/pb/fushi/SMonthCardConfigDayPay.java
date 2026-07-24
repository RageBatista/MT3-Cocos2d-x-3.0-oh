//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi;

import java.util.Map;
import mytools.ConvMain;

public class SMonthCardConfigDayPay implements ConvMain.Checkable, Comparable<SMonthCardConfigDayPay> {
    public int id = 0;
    public String name = null;
    public int rewardid = 0;
    public int itemid = 0;
    public int itemnum = 0;
    public int type = 0;

    public int compareTo(SMonthCardConfigDayPay o) {
        return this.id - o.id;
    }

    public SMonthCardConfigDayPay() {
    }

    public SMonthCardConfigDayPay(SMonthCardConfigDayPay arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.rewardid = arg.rewardid;
        this.itemid = arg.itemid;
        this.itemnum = arg.itemnum;
        this.type = arg.type;
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

    public int getRewardid() {
        return this.rewardid;
    }

    public void setRewardid(int v) {
        this.rewardid = v;
    }

    public int getItemid() {
        return this.itemid;
    }

    public void setItemid(int v) {
        this.itemid = v;
    }

    public int getItemnum() {
        return this.itemnum;
    }

    public void setItemnum(int v) {
        this.itemnum = v;
    }

    public int getType() {
        return this.type;
    }

    public void setType(int v) {
        this.type = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

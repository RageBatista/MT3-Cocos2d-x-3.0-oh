//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SItemToHuoban implements ConvMain.Checkable, Comparable<SItemToHuoban> {
    public int id = 0;
    public int huobanId = 0;
    public int daysType = 0;
    public int bagType = 0;

    public int compareTo(SItemToHuoban o) {
        return this.id - o.id;
    }

    public SItemToHuoban() {
    }

    public SItemToHuoban(SItemToHuoban arg) {
        this.id = arg.id;
        this.huobanId = arg.huobanId;
        this.daysType = arg.daysType;
        this.bagType = arg.bagType;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getHuobanId() {
        return this.huobanId;
    }

    public void setHuobanId(int v) {
        this.huobanId = v;
    }

    public int getDaysType() {
        return this.daysType;
    }

    public void setDaysType(int v) {
        this.daysType = v;
    }

    public int getBagType() {
        return this.bagType;
    }

    public void setBagType(int v) {
        this.bagType = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

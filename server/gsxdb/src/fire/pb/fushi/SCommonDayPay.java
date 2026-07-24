//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi;

import java.util.Map;
import mytools.ConvMain;

public class SCommonDayPay implements ConvMain.Checkable, Comparable<SCommonDayPay> {
    public int id = 0;
    public int serverdata = 0;

    public int compareTo(SCommonDayPay o) {
        return this.id - o.id;
    }

    public SCommonDayPay() {
    }

    public SCommonDayPay(SCommonDayPay arg) {
        this.id = arg.id;
        this.serverdata = arg.serverdata;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getServerdata() {
        return this.serverdata;
    }

    public void setServerdata(int v) {
        this.serverdata = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

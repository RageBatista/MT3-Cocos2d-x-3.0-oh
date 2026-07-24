//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SChargeReturnProfit implements ConvMain.Checkable, Comparable<SChargeReturnProfit> {
    public int id = 0;
    public int chargevalue = 0;
    public ArrayList<Integer> rewarditems;
    public ArrayList<Integer> rewarditemnums;

    public int compareTo(SChargeReturnProfit o) {
        return this.id - o.id;
    }

    public SChargeReturnProfit() {
    }

    public SChargeReturnProfit(SChargeReturnProfit arg) {
        this.id = arg.id;
        this.chargevalue = arg.chargevalue;
        this.rewarditems = arg.rewarditems;
        this.rewarditemnums = arg.rewarditemnums;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getChargevalue() {
        return this.chargevalue;
    }

    public void setChargevalue(int v) {
        this.chargevalue = v;
    }

    public ArrayList<Integer> getRewarditems() {
        return this.rewarditems;
    }

    public void setRewarditems(ArrayList<Integer> v) {
        this.rewarditems = v;
    }

    public ArrayList<Integer> getRewarditemnums() {
        return this.rewarditemnums;
    }

    public void setRewarditemnums(ArrayList<Integer> v) {
        this.rewarditemnums = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

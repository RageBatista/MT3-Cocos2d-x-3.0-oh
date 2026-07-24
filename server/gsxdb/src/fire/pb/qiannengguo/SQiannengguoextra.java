//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.qiannengguo;

import java.util.Map;
import mytools.ConvMain;

public class SQiannengguoextra implements ConvMain.Checkable, Comparable<SQiannengguoextra> {
    public int id = 0;
    public int needcount = 0;
    public String proppool = null;
    public int mincountvalue = 0;
    public int maxcountvalue = 0;
    public double doublerate = (double)0.0F;
    public int costmoney = 0;

    public int compareTo(SQiannengguoextra o) {
        return this.id - o.id;
    }

    public SQiannengguoextra() {
    }

    public SQiannengguoextra(SQiannengguoextra arg) {
        this.id = arg.id;
        this.needcount = arg.needcount;
        this.proppool = arg.proppool;
        this.mincountvalue = arg.mincountvalue;
        this.maxcountvalue = arg.maxcountvalue;
        this.doublerate = arg.doublerate;
        this.costmoney = arg.costmoney;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getNeedcount() {
        return this.needcount;
    }

    public void setNeedcount(int v) {
        this.needcount = v;
    }

    public String getProppool() {
        return this.proppool;
    }

    public void setProppool(String v) {
        this.proppool = v;
    }

    public int getMincountvalue() {
        return this.mincountvalue;
    }

    public void setMincountvalue(int v) {
        this.mincountvalue = v;
    }

    public int getMaxcountvalue() {
        return this.maxcountvalue;
    }

    public void setMaxcountvalue(int v) {
        this.maxcountvalue = v;
    }

    public double getDoublerate() {
        return this.doublerate;
    }

    public void setDoublerate(double v) {
        this.doublerate = v;
    }

    public int getCostmoney() {
        return this.costmoney;
    }

    public void setCostmoney(int v) {
        this.costmoney = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

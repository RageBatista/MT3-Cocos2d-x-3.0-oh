//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.fushi;

import java.util.Map;
import mytools.ConvMain;

public class SRedPackConfig implements ConvMain.Checkable, Comparable<SRedPackConfig> {
    public int id = 0;
    public int fushimin = 0;
    public int fishimax = 0;
    public int daysendmax = 0;
    public int dayreceivemax = 0;
    public int dayfushisendmax = 0;
    public int packmin = 0;
    public int packmax = 0;
    public int level = 0;

    public int compareTo(SRedPackConfig o) {
        return this.id - o.id;
    }

    public SRedPackConfig() {
    }

    public SRedPackConfig(SRedPackConfig arg) {
        this.id = arg.id;
        this.fushimin = arg.fushimin;
        this.fishimax = arg.fishimax;
        this.daysendmax = arg.daysendmax;
        this.dayreceivemax = arg.dayreceivemax;
        this.dayfushisendmax = arg.dayfushisendmax;
        this.packmin = arg.packmin;
        this.packmax = arg.packmax;
        this.level = arg.level;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getFushimin() {
        return this.fushimin;
    }

    public void setFushimin(int v) {
        this.fushimin = v;
    }

    public int getFishimax() {
        return this.fishimax;
    }

    public void setFishimax(int v) {
        this.fishimax = v;
    }

    public int getDaysendmax() {
        return this.daysendmax;
    }

    public void setDaysendmax(int v) {
        this.daysendmax = v;
    }

    public int getDayreceivemax() {
        return this.dayreceivemax;
    }

    public void setDayreceivemax(int v) {
        this.dayreceivemax = v;
    }

    public int getDayfushisendmax() {
        return this.dayfushisendmax;
    }

    public void setDayfushisendmax(int v) {
        this.dayfushisendmax = v;
    }

    public int getPackmin() {
        return this.packmin;
    }

    public void setPackmin(int v) {
        this.packmin = v;
    }

    public int getPackmax() {
        return this.packmax;
    }

    public void setPackmax(int v) {
        this.packmax = v;
    }

    public int getLevel() {
        return this.level;
    }

    public void setLevel(int v) {
        this.level = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

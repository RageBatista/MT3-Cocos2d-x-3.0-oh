//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import java.util.Map;
import mytools.ConvMain;

public class SClanDrugstore implements ConvMain.Checkable, Comparable<SClanDrugstore> {
    public int id = 0;
    public int levelupcost = 0;
    public int dragnummax = 0;
    public int doublemoney = 0;
    public int trimoney = 0;
    public int costeveryday = 0;

    public int compareTo(SClanDrugstore o) {
        return this.id - o.id;
    }

    public SClanDrugstore() {
    }

    public SClanDrugstore(SClanDrugstore arg) {
        this.id = arg.id;
        this.levelupcost = arg.levelupcost;
        this.dragnummax = arg.dragnummax;
        this.doublemoney = arg.doublemoney;
        this.trimoney = arg.trimoney;
        this.costeveryday = arg.costeveryday;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getLevelupcost() {
        return this.levelupcost;
    }

    public void setLevelupcost(int v) {
        this.levelupcost = v;
    }

    public int getDragnummax() {
        return this.dragnummax;
    }

    public void setDragnummax(int v) {
        this.dragnummax = v;
    }

    public int getDoublemoney() {
        return this.doublemoney;
    }

    public void setDoublemoney(int v) {
        this.doublemoney = v;
    }

    public int getTrimoney() {
        return this.trimoney;
    }

    public void setTrimoney(int v) {
        this.trimoney = v;
    }

    public int getCosteveryday() {
        return this.costeveryday;
    }

    public void setCosteveryday(int v) {
        this.costeveryday = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

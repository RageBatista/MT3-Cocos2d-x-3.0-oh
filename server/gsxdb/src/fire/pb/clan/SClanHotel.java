//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import java.util.Map;
import mytools.ConvMain;

public class SClanHotel implements ConvMain.Checkable, Comparable<SClanHotel> {
    public int id = 0;
    public int levelupcost = 0;
    public int peoplemax = 0;
    public int apprenticemax = 0;
    public int costeveryday = 0;

    public int compareTo(SClanHotel o) {
        return this.id - o.id;
    }

    public SClanHotel() {
    }

    public SClanHotel(SClanHotel arg) {
        this.id = arg.id;
        this.levelupcost = arg.levelupcost;
        this.peoplemax = arg.peoplemax;
        this.apprenticemax = arg.apprenticemax;
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

    public int getPeoplemax() {
        return this.peoplemax;
    }

    public void setPeoplemax(int v) {
        this.peoplemax = v;
    }

    public int getApprenticemax() {
        return this.apprenticemax;
    }

    public void setApprenticemax(int v) {
        this.apprenticemax = v;
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

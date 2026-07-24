//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.clan;

import java.util.Map;
import mytools.ConvMain;

public class SClanGoldBank implements ConvMain.Checkable, Comparable<SClanGoldBank> {
    public int id = 0;
    public int levelupcost = 0;
    public int bonus = 0;
    public int allbonus = 0;
    public int limitmoney = 0;
    public int costeveryday = 0;

    public int compareTo(SClanGoldBank o) {
        return this.id - o.id;
    }

    public SClanGoldBank() {
    }

    public SClanGoldBank(SClanGoldBank arg) {
        this.id = arg.id;
        this.levelupcost = arg.levelupcost;
        this.bonus = arg.bonus;
        this.allbonus = arg.allbonus;
        this.limitmoney = arg.limitmoney;
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

    public int getBonus() {
        return this.bonus;
    }

    public void setBonus(int v) {
        this.bonus = v;
    }

    public int getAllbonus() {
        return this.allbonus;
    }

    public void setAllbonus(int v) {
        this.allbonus = v;
    }

    public int getLimitmoney() {
        return this.limitmoney;
    }

    public void setLimitmoney(int v) {
        this.limitmoney = v;
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

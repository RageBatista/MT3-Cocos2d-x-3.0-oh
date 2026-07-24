//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.Map;
import mytools.ConvMain;

public class Sregreward implements ConvMain.Checkable, Comparable<Sregreward> {
    public int id = 0;
    public int itemid = 0;
    public int itemnum = 0;
    public int isbind = 0;
    public int mtype = 0;
    public int money = 0;
    public int ratio = 0;

    public int compareTo(Sregreward o) {
        return this.id - o.id;
    }

    public Sregreward() {
    }

    public Sregreward(Sregreward arg) {
        this.id = arg.id;
        this.itemid = arg.itemid;
        this.itemnum = arg.itemnum;
        this.isbind = arg.isbind;
        this.mtype = arg.mtype;
        this.money = arg.money;
        this.ratio = arg.ratio;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
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

    public int getIsbind() {
        return this.isbind;
    }

    public void setIsbind(int v) {
        this.isbind = v;
    }

    public int getMtype() {
        return this.mtype;
    }

    public void setMtype(int v) {
        this.mtype = v;
    }

    public int getMoney() {
        return this.money;
    }

    public void setMoney(int v) {
        this.money = v;
    }

    public int getRatio() {
        return this.ratio;
    }

    public void setRatio(int v) {
        this.ratio = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SPropertyItem implements ConvMain.Checkable, Comparable<SPropertyItem> {
    public int id = 0;
    public int cons = 0;
    public int iq = 0;
    public int str = 0;
    public int endu = 0;
    public int agi = 0;

    public int compareTo(SPropertyItem o) {
        return this.id - o.id;
    }

    public SPropertyItem() {
    }

    public SPropertyItem(SPropertyItem arg) {
        this.id = arg.id;
        this.cons = arg.cons;
        this.iq = arg.iq;
        this.str = arg.str;
        this.endu = arg.endu;
        this.agi = arg.agi;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getCons() {
        return this.cons;
    }

    public void setCons(int v) {
        this.cons = v;
    }

    public int getIq() {
        return this.iq;
    }

    public void setIq(int v) {
        this.iq = v;
    }

    public int getStr() {
        return this.str;
    }

    public void setStr(int v) {
        this.str = v;
    }

    public int getEndu() {
        return this.endu;
    }

    public void setEndu(int v) {
        this.endu = v;
    }

    public int getAgi() {
        return this.agi;
    }

    public void setAgi(int v) {
        this.agi = v;
    }
}

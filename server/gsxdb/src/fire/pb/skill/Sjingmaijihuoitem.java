//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.Map;
import mytools.ConvMain;

public class Sjingmaijihuoitem implements ConvMain.Checkable, Comparable<Sjingmaijihuoitem> {
    public int id = 0;
    public int item1 = 0;
    public int item1num = 0;
    public int item2 = 0;
    public int item2num = 0;

    public int compareTo(Sjingmaijihuoitem o) {
        return this.id - o.id;
    }

    public Sjingmaijihuoitem() {
    }

    public Sjingmaijihuoitem(Sjingmaijihuoitem arg) {
        this.id = arg.id;
        this.item1 = arg.item1;
        this.item1num = arg.item1num;
        this.item2 = arg.item2;
        this.item2num = arg.item2num;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getItem1() {
        return this.item1;
    }

    public void setItem1(int v) {
        this.item1 = v;
    }

    public int getItem1num() {
        return this.item1num;
    }

    public void setItem1num(int v) {
        this.item1num = v;
    }

    public int getItem2() {
        return this.item2;
    }

    public void setItem2(int v) {
        this.item2 = v;
    }

    public int getItem2num() {
        return this.item2num;
    }

    public void setItem2num(int v) {
        this.item2num = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

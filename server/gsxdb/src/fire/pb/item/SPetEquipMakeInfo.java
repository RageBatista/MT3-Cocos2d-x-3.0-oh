//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;

public class SPetEquipMakeInfo implements Comparable<SPetEquipMakeInfo> {
    public int id = 0;
    public int level = 0;
    public int item1 = 0;
    public int item1num = 0;
    public int item2 = 0;
    public int item2num = 0;
    public int jilv = 0;

    public int compareTo(SPetEquipMakeInfo o) {
        return this.id - o.id;
    }

    public SPetEquipMakeInfo() {
    }

    public SPetEquipMakeInfo(SPetEquipMakeInfo arg) {
        this.id = arg.id;
        this.level = arg.level;
        this.item1 = arg.item1;
        this.item1num = arg.item1num;
        this.item2 = arg.item2;
        this.item2num = arg.item2num;
        this.jilv = arg.jilv;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getlevel() {
        return this.level;
    }

    public void setlevel(int v) {
        this.level = v;
    }

    public int getitem1() {
        return this.item1;
    }

    public void setitem1(int v) {
        this.item1 = v;
    }

    public int getitem1num() {
        return this.item1num;
    }

    public void setitem1num(int v) {
        this.item1num = v;
    }

    public int getitem2() {
        return this.item2;
    }

    public void setitem2(int v) {
        this.item2 = v;
    }

    public int getitem2num() {
        return this.item2num;
    }

    public void setitem2numm(int v) {
        this.item2num = v;
    }

    public int getjilv() {
        return this.jilv;
    }

    public void setjilv(int v) {
        this.jilv = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;

        NeedId() {
        }
    }
}

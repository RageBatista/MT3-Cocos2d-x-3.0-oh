//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SSchoolWheel implements ConvMain.Checkable, Comparable<SSchoolWheel> {
    public int id = 0;
    public ArrayList<String> items;
    public int mustitem = 0;
    public int mustnum = 0;

    public int compareTo(SSchoolWheel o) {
        return this.id - o.id;
    }

    public SSchoolWheel() {
    }

    public SSchoolWheel(SSchoolWheel arg) {
        this.id = arg.id;
        this.items = arg.items;
        this.mustitem = arg.mustitem;
        this.mustnum = arg.mustnum;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<String> getItems() {
        return this.items;
    }

    public void setItems(ArrayList<String> v) {
        this.items = v;
    }

    public int getMustitem() {
        return this.mustitem;
    }

    public void setMustitem(int v) {
        this.mustitem = v;
    }

    public int getMustnum() {
        return this.mustnum;
    }

    public void setMustnum(int v) {
        this.mustnum = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

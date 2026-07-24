//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SEquipToEquipex implements ConvMain.Checkable, Comparable<SEquipToEquipex> {
    public int id = 0;
    public int needitemid = 0;
    public int needitemcount = 0;
    public ArrayList<Integer> toitemlist;

    public int compareTo(SEquipToEquipex o) {
        return this.id - o.id;
    }

    public SEquipToEquipex() {
    }

    public SEquipToEquipex(SEquipToEquipex arg) {
        this.id = arg.id;
        this.needitemid = arg.needitemid;
        this.needitemcount = arg.needitemcount;
        this.toitemlist = arg.toitemlist;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getNeeditemid() {
        return this.needitemid;
    }

    public void setNeeditemid(int v) {
        this.needitemid = v;
    }

    public int getNeeditemcount() {
        return this.needitemcount;
    }

    public void setNeeditemcount(int v) {
        this.needitemcount = v;
    }

    public ArrayList<Integer> getToitemlist() {
        return this.toitemlist;
    }

    public void setToitemlist(ArrayList<Integer> v) {
        this.toitemlist = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

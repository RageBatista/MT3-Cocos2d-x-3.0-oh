//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SSetFumoInfo implements ConvMain.Checkable, Comparable<SSetFumoInfo> {
    public int id = 0;
    public int skilltype = 0;
    public int itemid = 0;
    public int itemnum = 0;

    public int compareTo(SSetFumoInfo o) {
        return this.id - o.id;
    }

    public SSetFumoInfo() {
    }

    public SSetFumoInfo(SSetFumoInfo arg) {
        this.id = arg.id;
        this.skilltype = arg.skilltype;
        this.itemid = arg.itemid;
        this.itemnum = arg.itemnum;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getSkilltype() {
        return this.skilltype;
    }

    public void setSkilltype(int v) {
        this.skilltype = v;
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

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

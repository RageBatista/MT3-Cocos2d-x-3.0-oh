//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SEquipAddattributelib implements ConvMain.Checkable, Comparable<SEquipAddattributelib> {
    public int id = 0;
    public String namecolour = null;
    public String attributename = null;
    public String attributeidinterval = null;
    public int buffid = 0;
    public int skillid = 0;

    public int compareTo(SEquipAddattributelib o) {
        return this.id - o.id;
    }

    public SEquipAddattributelib() {
    }

    public SEquipAddattributelib(SEquipAddattributelib arg) {
        this.id = arg.id;
        this.namecolour = arg.namecolour;
        this.attributename = arg.attributename;
        this.attributeidinterval = arg.attributeidinterval;
        this.buffid = arg.buffid;
        this.skillid = arg.skillid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getNamecolour() {
        return this.namecolour;
    }

    public void setNamecolour(String v) {
        this.namecolour = v;
    }

    public String getAttributename() {
        return this.attributename;
    }

    public void setAttributename(String v) {
        this.attributename = v;
    }

    public String getAttributeidinterval() {
        return this.attributeidinterval;
    }

    public void setAttributeidinterval(String v) {
        this.attributeidinterval = v;
    }

    public int getBuffid() {
        return this.buffid;
    }

    public void setBuffid(int v) {
        this.buffid = v;
    }

    public int getSkillid() {
        return this.skillid;
    }

    public void setSkillid(int v) {
        this.skillid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

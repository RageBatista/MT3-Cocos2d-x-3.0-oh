//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SXingPanSuit implements ConvMain.Checkable, Comparable<SXingPanSuit> {
    public int id = 0;
    public String name = null;
    public int procount = 0;
    public int school = 0;
    public int skillid = 0;
    public int buffid = 0;

    public int compareTo(SXingPanSuit o) {
        return this.id - o.id;
    }

    public SXingPanSuit() {
    }

    public SXingPanSuit(SXingPanSuit arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.procount = arg.procount;
        this.school = arg.school;
        this.skillid = arg.skillid;
        this.buffid = arg.buffid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public int getProcount() {
        return this.procount;
    }

    public void setProcount(int v) {
        this.procount = v;
    }

    public int getSchool() {
        return this.school;
    }

    public void setSchool(int v) {
        this.school = v;
    }

    public int getSkillid() {
        return this.skillid;
    }

    public void setSkillid(int v) {
        this.skillid = v;
    }

    public int getBuffid() {
        return this.buffid;
    }

    public void setBuffid(int v) {
        this.buffid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

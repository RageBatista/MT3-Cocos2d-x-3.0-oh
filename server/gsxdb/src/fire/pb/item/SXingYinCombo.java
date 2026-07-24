//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SXingYinCombo implements ConvMain.Checkable, Comparable<SXingYinCombo> {
    public int id = 0;
    public String name = null;
    public int yuancount = 0;
    public int fangcount = 0;
    public int school = 0;
    public int skillid = 0;
    public int buffid = 0;
    public int buffskillid = 0;

    public int compareTo(SXingYinCombo o) {
        return this.id - o.id;
    }

    public SXingYinCombo() {
    }

    public SXingYinCombo(SXingYinCombo arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.yuancount = arg.yuancount;
        this.fangcount = arg.fangcount;
        this.school = arg.school;
        this.skillid = arg.skillid;
        this.buffid = arg.buffid;
        this.buffskillid = arg.buffskillid;
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

    public int getYuancount() {
        return this.yuancount;
    }

    public void setYuancount(int v) {
        this.yuancount = v;
    }

    public int getFangcount() {
        return this.fangcount;
    }

    public void setFangcount(int v) {
        this.fangcount = v;
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

    public int getBuffskillid() {
        return this.buffskillid;
    }

    public void setBuffskillid(int v) {
        this.buffskillid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

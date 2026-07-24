//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.Map;
import mytools.ConvMain;

public class SPetSkilllw implements ConvMain.Checkable, Comparable<SPetSkilllw> {
    public int id = 0;
    public int skillid = 0;
    public String skillname = null;
    public int addneeditem = 0;
    public int addneeditemnum = 0;
    public int addneeditem1 = 0;
    public int addneeditemnum1 = 0;
    public int addneedmoney = 0;
    public int removeneeditem = 0;
    public int removeneeditemnum = 0;
    public int removeneedmoney = 0;

    public int compareTo(SPetSkilllw o) {
        return this.id - o.id;
    }

    public SPetSkilllw() {
    }

    public SPetSkilllw(SPetSkilllw arg) {
        this.id = arg.id;
        this.skillid = arg.skillid;
        this.skillname = arg.skillname;
        this.addneeditem = arg.addneeditem;
        this.addneeditemnum = arg.addneeditemnum;
        this.addneeditem1 = arg.addneeditem1;
        this.addneeditemnum1 = arg.addneeditemnum1;
        this.addneedmoney = arg.addneedmoney;
        this.removeneeditem = arg.removeneeditem;
        this.removeneeditemnum = arg.removeneeditemnum;
        this.removeneedmoney = arg.removeneedmoney;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getSkillid() {
        return this.skillid;
    }

    public void setSkillid(int v) {
        this.skillid = v;
    }

    public String getSkillname() {
        return this.skillname;
    }

    public void setSkillname(String v) {
        this.skillname = v;
    }

    public int getAddneeditem() {
        return this.addneeditem;
    }

    public void setAddneeditem(int v) {
        this.addneeditem = v;
    }

    public int getAddneeditemnum() {
        return this.addneeditemnum;
    }

    public void setAddneeditemnum(int v) {
        this.addneeditemnum = v;
    }

    public int getAddneeditem1() {
        return this.addneeditem1;
    }

    public void setAddneeditem1(int v) {
        this.addneeditem1 = v;
    }

    public int getAddneeditemnum1() {
        return this.addneeditemnum1;
    }

    public void setAddneeditemnum1(int v) {
        this.addneeditemnum1 = v;
    }

    public int getAddneedmoney() {
        return this.addneedmoney;
    }

    public void setAddneedmoney(int v) {
        this.addneedmoney = v;
    }

    public int getRemoveneeditem() {
        return this.removeneeditem;
    }

    public void setRemoveneeditem(int v) {
        this.removeneeditem = v;
    }

    public int getRemoveneeditemnum() {
        return this.removeneeditemnum;
    }

    public void setRemoveneeditemnum(int v) {
        this.removeneeditemnum = v;
    }

    public int getRemoveneedmoney() {
        return this.removeneedmoney;
    }

    public void setRemoveneedmoney(int v) {
        this.removeneedmoney = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

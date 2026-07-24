//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import java.util.Map;
import mytools.ConvMain;

public class SGMStandard implements ConvMain.Checkable, Comparable<SGMStandard> {
    public int id = 0;
    public String schoolname = null;
    public String about = null;
    public int rolelv = 0;
    public String equipinfo = null;
    public String skillinfo = null;
    public String xiulianinfo = null;
    public String guildskillinfo = null;
    public String geminfo = null;
    public String petinfo = null;

    public int compareTo(SGMStandard o) {
        return this.id - o.id;
    }

    public SGMStandard() {
    }

    public SGMStandard(SGMStandard arg) {
        this.id = arg.id;
        this.schoolname = arg.schoolname;
        this.about = arg.about;
        this.rolelv = arg.rolelv;
        this.equipinfo = arg.equipinfo;
        this.skillinfo = arg.skillinfo;
        this.xiulianinfo = arg.xiulianinfo;
        this.guildskillinfo = arg.guildskillinfo;
        this.geminfo = arg.geminfo;
        this.petinfo = arg.petinfo;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getSchoolname() {
        return this.schoolname;
    }

    public void setSchoolname(String v) {
        this.schoolname = v;
    }

    public String getAbout() {
        return this.about;
    }

    public void setAbout(String v) {
        this.about = v;
    }

    public int getRolelv() {
        return this.rolelv;
    }

    public void setRolelv(int v) {
        this.rolelv = v;
    }

    public String getEquipinfo() {
        return this.equipinfo;
    }

    public void setEquipinfo(String v) {
        this.equipinfo = v;
    }

    public String getSkillinfo() {
        return this.skillinfo;
    }

    public void setSkillinfo(String v) {
        this.skillinfo = v;
    }

    public String getXiulianinfo() {
        return this.xiulianinfo;
    }

    public void setXiulianinfo(String v) {
        this.xiulianinfo = v;
    }

    public String getGuildskillinfo() {
        return this.guildskillinfo;
    }

    public void setGuildskillinfo(String v) {
        this.guildskillinfo = v;
    }

    public String getGeminfo() {
        return this.geminfo;
    }

    public void setGeminfo(String v) {
        this.geminfo = v;
    }

    public String getPetinfo() {
        return this.petinfo;
    }

    public void setPetinfo(String v) {
        this.petinfo = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.Map;
import mytools.ConvMain;

public class SSchoolSkillitem implements ConvMain.Checkable, Comparable<SSchoolSkillitem> {
    public int id = 0;
    public int effectid = 0;

    public int compareTo(SSchoolSkillitem o) {
        return this.id - o.id;
    }

    public SSchoolSkillitem() {
    }

    public SSchoolSkillitem(SSchoolSkillitem arg) {
        this.id = arg.id;
        this.effectid = arg.effectid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getEffectid() {
        return this.effectid;
    }

    public void setEffectid(int v) {
        this.effectid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

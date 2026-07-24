//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.Map;
import mytools.ConvMain;

public class SPetSkillitem implements ConvMain.Checkable, Comparable<SPetSkillitem> {
    public int id = 0;
    public int effectid = 0;
    public int score = 0;
    public int color = 0;

    public int compareTo(SPetSkillitem o) {
        return this.id - o.id;
    }

    public SPetSkillitem() {
    }

    public SPetSkillitem(SPetSkillitem arg) {
        this.id = arg.id;
        this.effectid = arg.effectid;
        this.score = arg.score;
        this.color = arg.color;
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

    public int getScore() {
        return this.score;
    }

    public void setScore(int v) {
        this.score = v;
    }

    public int getColor() {
        return this.color;
    }

    public void setColor(int v) {
        this.color = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

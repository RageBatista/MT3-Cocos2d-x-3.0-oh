//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.Map;
import mytools.ConvMain;

public class SAssistSkill implements ConvMain.Checkable, Comparable<SAssistSkill> {
    public int id = 0;
    public boolean isNeedExp = false;
    public String skillName = null;
    public int levelTotal = 0;
    public int 是否在技能学习人处显示 = 0;

    public int compareTo(SAssistSkill o) {
        return this.id - o.id;
    }

    public SAssistSkill() {
    }

    public SAssistSkill(SAssistSkill arg) {
        this.id = arg.id;
        this.isNeedExp = arg.isNeedExp;
        this.skillName = arg.skillName;
        this.levelTotal = arg.levelTotal;
        this.是否在技能学习人处显示 = arg.是否在技能学习人处显示;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public boolean getIsNeedExp() {
        return this.isNeedExp;
    }

    public void setIsNeedExp(boolean v) {
        this.isNeedExp = v;
    }

    public String getSkillName() {
        return this.skillName;
    }

    public void setSkillName(String v) {
        this.skillName = v;
    }

    public int getLevelTotal() {
        return this.levelTotal;
    }

    public void setLevelTotal(int v) {
        this.levelTotal = v;
    }

    public int get是否在技能学习人处显示() {
        return this.是否在技能学习人处显示;
    }

    public void set是否在技能学习人处显示(int v) {
        this.是否在技能学习人处显示 = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

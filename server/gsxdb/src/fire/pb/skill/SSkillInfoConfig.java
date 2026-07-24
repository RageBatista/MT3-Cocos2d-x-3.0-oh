//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SSkillInfoConfig implements ConvMain.Checkable, Comparable<SSkillInfoConfig> {
    public int id = 0;
    public ArrayList<Integer> SkillLevelRequireList;

    public int compareTo(SSkillInfoConfig o) {
        return this.id - o.id;
    }

    public SSkillInfoConfig() {
    }

    public SSkillInfoConfig(SSkillInfoConfig arg) {
        this.id = arg.id;
        this.SkillLevelRequireList = arg.SkillLevelRequireList;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<Integer> getSkillLevelRequireList() {
        return this.SkillLevelRequireList;
    }

    public void setSkillLevelRequireList(ArrayList<Integer> v) {
        this.SkillLevelRequireList = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

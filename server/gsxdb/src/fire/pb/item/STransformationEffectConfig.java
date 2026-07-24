//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class STransformationEffectConfig implements ConvMain.Checkable, Comparable<STransformationEffectConfig> {
    public int id = 0;
    public int shapeid = 0;
    public String color = null;
    public ArrayList<Integer> skills;
    public ArrayList<Integer> skillfactors;
    public ArrayList<Integer> skillconstants;

    public int compareTo(STransformationEffectConfig o) {
        return this.id - o.id;
    }

    public STransformationEffectConfig() {
    }

    public STransformationEffectConfig(STransformationEffectConfig arg) {
        this.id = arg.id;
        this.shapeid = arg.shapeid;
        this.color = arg.color;
        this.skills = arg.skills;
        this.skillfactors = arg.skillfactors;
        this.skillconstants = arg.skillconstants;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getShapeid() {
        return this.shapeid;
    }

    public void setShapeid(int v) {
        this.shapeid = v;
    }

    public String getColor() {
        return this.color;
    }

    public void setColor(String v) {
        this.color = v;
    }

    public ArrayList<Integer> getSkills() {
        return this.skills;
    }

    public void setSkills(ArrayList<Integer> v) {
        this.skills = v;
    }

    public ArrayList<Integer> getSkillfactors() {
        return this.skillfactors;
    }

    public void setSkillfactors(ArrayList<Integer> v) {
        this.skillfactors = v;
    }

    public ArrayList<Integer> getSkillconstants() {
        return this.skillconstants;
    }

    public void setSkillconstants(ArrayList<Integer> v) {
        this.skillconstants = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

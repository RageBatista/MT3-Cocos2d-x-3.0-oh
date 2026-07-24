//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SLifeSkillCost implements ConvMain.Checkable, Comparable<SLifeSkillCost> {
    public int id = 0;
    public ArrayList<Integer> needLevelList;
    public ArrayList<Integer> silverCostList;
    public ArrayList<Integer> guildContributeCostList;
    public ArrayList<Integer> strengthCostList;

    public int compareTo(SLifeSkillCost o) {
        return this.id - o.id;
    }

    public SLifeSkillCost() {
    }

    public SLifeSkillCost(SLifeSkillCost arg) {
        this.id = arg.id;
        this.needLevelList = arg.needLevelList;
        this.silverCostList = arg.silverCostList;
        this.guildContributeCostList = arg.guildContributeCostList;
        this.strengthCostList = arg.strengthCostList;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<Integer> getNeedLevelList() {
        return this.needLevelList;
    }

    public void setNeedLevelList(ArrayList<Integer> v) {
        this.needLevelList = v;
    }

    public ArrayList<Integer> getSilverCostList() {
        return this.silverCostList;
    }

    public void setSilverCostList(ArrayList<Integer> v) {
        this.silverCostList = v;
    }

    public ArrayList<Integer> getGuildContributeCostList() {
        return this.guildContributeCostList;
    }

    public void setGuildContributeCostList(ArrayList<Integer> v) {
        this.guildContributeCostList = v;
    }

    public ArrayList<Integer> getStrengthCostList() {
        return this.strengthCostList;
    }

    public void setStrengthCostList(ArrayList<Integer> v) {
        this.strengthCostList = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

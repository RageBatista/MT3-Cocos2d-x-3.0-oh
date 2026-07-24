//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SPointCardParticeSkillLevelup implements ConvMain.Checkable, Comparable<SPointCardParticeSkillLevelup> {
    public int id = 0;
    public ArrayList<Integer> vecskillexp;
    public int playerlevel = 0;
    public int factionlevel = 0;
    public int maxcon = 0;

    public int compareTo(SPointCardParticeSkillLevelup o) {
        return this.id - o.id;
    }

    public SPointCardParticeSkillLevelup() {
    }

    public SPointCardParticeSkillLevelup(SPointCardParticeSkillLevelup arg) {
        this.id = arg.id;
        this.vecskillexp = arg.vecskillexp;
        this.playerlevel = arg.playerlevel;
        this.factionlevel = arg.factionlevel;
        this.maxcon = arg.maxcon;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<Integer> getVecskillexp() {
        return this.vecskillexp;
    }

    public void setVecskillexp(ArrayList<Integer> v) {
        this.vecskillexp = v;
    }

    public int getPlayerlevel() {
        return this.playerlevel;
    }

    public void setPlayerlevel(int v) {
        this.playerlevel = v;
    }

    public int getFactionlevel() {
        return this.factionlevel;
    }

    public void setFactionlevel(int v) {
        this.factionlevel = v;
    }

    public int getMaxcon() {
        return this.maxcon;
    }

    public void setMaxcon(int v) {
        this.maxcon = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

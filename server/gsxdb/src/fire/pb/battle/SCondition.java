//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import java.util.Map;
import mytools.ConvMain;

public class SCondition implements ConvMain.Checkable, Comparable<SCondition> {
    public int id = 0;
    public String battleround = null;
    public String conditionscript = null;
    public int bounusnum = 0;
    public String fighterround = null;
    public String odds = null;
    public String targetfilters = null;
    public String skillids = null;

    public int compareTo(SCondition o) {
        return this.id - o.id;
    }

    public SCondition() {
    }

    public SCondition(SCondition arg) {
        this.id = arg.id;
        this.battleround = arg.battleround;
        this.conditionscript = arg.conditionscript;
        this.bounusnum = arg.bounusnum;
        this.fighterround = arg.fighterround;
        this.odds = arg.odds;
        this.targetfilters = arg.targetfilters;
        this.skillids = arg.skillids;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getBattleround() {
        return this.battleround;
    }

    public void setBattleround(String v) {
        this.battleround = v;
    }

    public String getConditionscript() {
        return this.conditionscript;
    }

    public void setConditionscript(String v) {
        this.conditionscript = v;
    }

    public int getBounusnum() {
        return this.bounusnum;
    }

    public void setBounusnum(int v) {
        this.bounusnum = v;
    }

    public String getFighterround() {
        return this.fighterround;
    }

    public void setFighterround(String v) {
        this.fighterround = v;
    }

    public String getOdds() {
        return this.odds;
    }

    public void setOdds(String v) {
        this.odds = v;
    }

    public String getTargetfilters() {
        return this.targetfilters;
    }

    public void setTargetfilters(String v) {
        this.targetfilters = v;
    }

    public String getSkillids() {
        return this.skillids;
    }

    public void setSkillids(String v) {
        this.skillids = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

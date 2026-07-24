//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import java.util.Map;
import mytools.ConvMain;

public class STargetFilter implements ConvMain.Checkable, Comparable<STargetFilter> {
    public int id = 0;
    public String relation = null;
    public String unitrelation = null;
    public int unitcamp = 0;
    public String unittype = null;
    public int unitmonstertype = 0;
    public int specialtype = 0;
    public String includedead = null;
    public String includehide = null;
    public String roundresult = null;
    public String hppercentmin = null;
    public String hppercentmax = null;
    public String mppercentmin = null;
    public String mppercentmax = null;
    public String attributesort = null;
    public String buffs = null;
    public String gender = null;
    public String school = null;
    public int levelmin = 0;
    public int levelmax = 0;
    public String monsterids = null;
    public String figherids = null;

    public int compareTo(STargetFilter o) {
        return this.id - o.id;
    }

    public STargetFilter() {
    }

    public STargetFilter(STargetFilter arg) {
        this.id = arg.id;
        this.relation = arg.relation;
        this.unitrelation = arg.unitrelation;
        this.unitcamp = arg.unitcamp;
        this.unittype = arg.unittype;
        this.unitmonstertype = arg.unitmonstertype;
        this.specialtype = arg.specialtype;
        this.includedead = arg.includedead;
        this.includehide = arg.includehide;
        this.roundresult = arg.roundresult;
        this.hppercentmin = arg.hppercentmin;
        this.hppercentmax = arg.hppercentmax;
        this.mppercentmin = arg.mppercentmin;
        this.mppercentmax = arg.mppercentmax;
        this.attributesort = arg.attributesort;
        this.buffs = arg.buffs;
        this.gender = arg.gender;
        this.school = arg.school;
        this.levelmin = arg.levelmin;
        this.levelmax = arg.levelmax;
        this.monsterids = arg.monsterids;
        this.figherids = arg.figherids;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getRelation() {
        return this.relation;
    }

    public void setRelation(String v) {
        this.relation = v;
    }

    public String getUnitrelation() {
        return this.unitrelation;
    }

    public void setUnitrelation(String v) {
        this.unitrelation = v;
    }

    public int getUnitcamp() {
        return this.unitcamp;
    }

    public void setUnitcamp(int v) {
        this.unitcamp = v;
    }

    public String getUnittype() {
        return this.unittype;
    }

    public void setUnittype(String v) {
        this.unittype = v;
    }

    public int getUnitmonstertype() {
        return this.unitmonstertype;
    }

    public void setUnitmonstertype(int v) {
        this.unitmonstertype = v;
    }

    public int getSpecialtype() {
        return this.specialtype;
    }

    public void setSpecialtype(int v) {
        this.specialtype = v;
    }

    public String getIncludedead() {
        return this.includedead;
    }

    public void setIncludedead(String v) {
        this.includedead = v;
    }

    public String getIncludehide() {
        return this.includehide;
    }

    public void setIncludehide(String v) {
        this.includehide = v;
    }

    public String getRoundresult() {
        return this.roundresult;
    }

    public void setRoundresult(String v) {
        this.roundresult = v;
    }

    public String getHppercentmin() {
        return this.hppercentmin;
    }

    public void setHppercentmin(String v) {
        this.hppercentmin = v;
    }

    public String getHppercentmax() {
        return this.hppercentmax;
    }

    public void setHppercentmax(String v) {
        this.hppercentmax = v;
    }

    public String getMppercentmin() {
        return this.mppercentmin;
    }

    public void setMppercentmin(String v) {
        this.mppercentmin = v;
    }

    public String getMppercentmax() {
        return this.mppercentmax;
    }

    public void setMppercentmax(String v) {
        this.mppercentmax = v;
    }

    public String getAttributesort() {
        return this.attributesort;
    }

    public void setAttributesort(String v) {
        this.attributesort = v;
    }

    public String getBuffs() {
        return this.buffs;
    }

    public void setBuffs(String v) {
        this.buffs = v;
    }

    public String getGender() {
        return this.gender;
    }

    public void setGender(String v) {
        this.gender = v;
    }

    public String getSchool() {
        return this.school;
    }

    public void setSchool(String v) {
        this.school = v;
    }

    public int getLevelmin() {
        return this.levelmin;
    }

    public void setLevelmin(int v) {
        this.levelmin = v;
    }

    public int getLevelmax() {
        return this.levelmax;
    }

    public void setLevelmax(int v) {
        this.levelmax = v;
    }

    public String getMonsterids() {
        return this.monsterids;
    }

    public void setMonsterids(String v) {
        this.monsterids = v;
    }

    public String getFigherids() {
        return this.figherids;
    }

    public void setFigherids(String v) {
        this.figherids = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

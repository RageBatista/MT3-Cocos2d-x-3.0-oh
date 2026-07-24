//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SLifeSkill implements ConvMain.Checkable, Comparable<SLifeSkill> {
    public int id = 0;
    public String name = null;
    public int icon = 0;
    public int skillType = 0;
    public int needGuild = 0;
    public int skillLevelMax = 0;
    public int studyLevelRule = 0;
    public int studyCostRule = 0;
    public int strengthCostRule = 0;
    public int skillId = 0;
    public int isShow = 0;
    public String guidetips = null;
    public String description = null;
    public String brief = null;
    public String effect = null;
    public String effectnow = null;
    public int ParaNum = 0;
    public ArrayList<Integer> ParamIndexList;
    public int needSkilled = 0;
    public String guildDscription = null;
    public int enhanceitemid = 0;

    public int compareTo(SLifeSkill o) {
        return this.id - o.id;
    }

    public SLifeSkill() {
    }

    public SLifeSkill(SLifeSkill arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.icon = arg.icon;
        this.skillType = arg.skillType;
        this.needGuild = arg.needGuild;
        this.skillLevelMax = arg.skillLevelMax;
        this.studyLevelRule = arg.studyLevelRule;
        this.studyCostRule = arg.studyCostRule;
        this.strengthCostRule = arg.strengthCostRule;
        this.skillId = arg.skillId;
        this.isShow = arg.isShow;
        this.guidetips = arg.guidetips;
        this.description = arg.description;
        this.brief = arg.brief;
        this.effect = arg.effect;
        this.effectnow = arg.effectnow;
        this.ParaNum = arg.ParaNum;
        this.ParamIndexList = arg.ParamIndexList;
        this.needSkilled = arg.needSkilled;
        this.guildDscription = arg.guildDscription;
        this.enhanceitemid = arg.enhanceitemid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public int getIcon() {
        return this.icon;
    }

    public void setIcon(int v) {
        this.icon = v;
    }

    public int getSkillType() {
        return this.skillType;
    }

    public void setSkillType(int v) {
        this.skillType = v;
    }

    public int getNeedGuild() {
        return this.needGuild;
    }

    public void setNeedGuild(int v) {
        this.needGuild = v;
    }

    public int getSkillLevelMax() {
        return this.skillLevelMax;
    }

    public void setSkillLevelMax(int v) {
        this.skillLevelMax = v;
    }

    public int getStudyLevelRule() {
        return this.studyLevelRule;
    }

    public void setStudyLevelRule(int v) {
        this.studyLevelRule = v;
    }

    public int getStudyCostRule() {
        return this.studyCostRule;
    }

    public void setStudyCostRule(int v) {
        this.studyCostRule = v;
    }

    public int getStrengthCostRule() {
        return this.strengthCostRule;
    }

    public void setStrengthCostRule(int v) {
        this.strengthCostRule = v;
    }

    public int getSkillId() {
        return this.skillId;
    }

    public void setSkillId(int v) {
        this.skillId = v;
    }

    public int getIsShow() {
        return this.isShow;
    }

    public void setIsShow(int v) {
        this.isShow = v;
    }

    public String getGuidetips() {
        return this.guidetips;
    }

    public void setGuidetips(String v) {
        this.guidetips = v;
    }

    public String getDescription() {
        return this.description;
    }

    public void setDescription(String v) {
        this.description = v;
    }

    public String getBrief() {
        return this.brief;
    }

    public void setBrief(String v) {
        this.brief = v;
    }

    public String getEffect() {
        return this.effect;
    }

    public void setEffect(String v) {
        this.effect = v;
    }

    public String getEffectnow() {
        return this.effectnow;
    }

    public void setEffectnow(String v) {
        this.effectnow = v;
    }

    public int getParaNum() {
        return this.ParaNum;
    }

    public void setParaNum(int v) {
        this.ParaNum = v;
    }

    public ArrayList<Integer> getParamIndexList() {
        return this.ParamIndexList;
    }

    public void setParamIndexList(ArrayList<Integer> v) {
        this.ParamIndexList = v;
    }

    public int getNeedSkilled() {
        return this.needSkilled;
    }

    public void setNeedSkilled(int v) {
        this.needSkilled = v;
    }

    public String getGuildDscription() {
        return this.guildDscription;
    }

    public void setGuildDscription(String v) {
        this.guildDscription = v;
    }

    public int getEnhanceitemid() {
        return this.enhanceitemid;
    }

    public void setEnhanceitemid(int v) {
        this.enhanceitemid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

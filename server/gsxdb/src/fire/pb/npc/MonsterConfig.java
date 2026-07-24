//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.Map;
import mytools.ConvMain;

public class MonsterConfig implements ConvMain.Checkable {
    public int id = 0;
    public String name = null;
    public int fightnpctype = 0;
    public int monstertype = 0;
    public int specialtype = 0;
    public int school = 0;
    public int pet = 0;
    public int colorid = 0;
    public double bodytype = (double)0.0F;
    public int orbinding = 0;
    public String title = null;
    public int shape = 0;
    public String randomShapes = null;
    public int levelType = 0;
    public int level = 0;
    public int minlevellimit = 0;
    public int maxlevellimit = 0;
    public int canCatch = 0;
    public int catchRate = 0;
    public int runRate = 0;
    public String aiIds = null;
    public String immunebuffid = null;

    public MonsterConfig() {
    }

    public MonsterConfig(MonsterConfig arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.fightnpctype = arg.fightnpctype;
        this.monstertype = arg.monstertype;
        this.specialtype = arg.specialtype;
        this.school = arg.school;
        this.pet = arg.pet;
        this.colorid = arg.colorid;
        this.bodytype = arg.bodytype;
        this.orbinding = arg.orbinding;
        this.title = arg.title;
        this.shape = arg.shape;
        this.randomShapes = arg.randomShapes;
        this.levelType = arg.levelType;
        this.level = arg.level;
        this.minlevellimit = arg.minlevellimit;
        this.maxlevellimit = arg.maxlevellimit;
        this.canCatch = arg.canCatch;
        this.catchRate = arg.catchRate;
        this.runRate = arg.runRate;
        this.aiIds = arg.aiIds;
        this.immunebuffid = arg.immunebuffid;
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

    public int getFightnpctype() {
        return this.fightnpctype;
    }

    public void setFightnpctype(int v) {
        this.fightnpctype = v;
    }

    public int getMonstertype() {
        return this.monstertype;
    }

    public void setMonstertype(int v) {
        this.monstertype = v;
    }

    public int getSpecialtype() {
        return this.specialtype;
    }

    public void setSpecialtype(int v) {
        this.specialtype = v;
    }

    public int getSchool() {
        return this.school;
    }

    public void setSchool(int v) {
        this.school = v;
    }

    public int getPet() {
        return this.pet;
    }

    public void setPet(int v) {
        this.pet = v;
    }

    public int getColorid() {
        return this.colorid;
    }

    public void setColorid(int v) {
        this.colorid = v;
    }

    public double getBodytype() {
        return this.bodytype;
    }

    public void setBodytype(double v) {
        this.bodytype = v;
    }

    public int getOrbinding() {
        return this.orbinding;
    }

    public void setOrbinding(int v) {
        this.orbinding = v;
    }

    public String getTitle() {
        return this.title;
    }

    public void setTitle(String v) {
        this.title = v;
    }

    public int getShape() {
        return this.shape;
    }

    public void setShape(int v) {
        this.shape = v;
    }

    public String getRandomShapes() {
        return this.randomShapes;
    }

    public void setRandomShapes(String v) {
        this.randomShapes = v;
    }

    public int getLevelType() {
        return this.levelType;
    }

    public void setLevelType(int v) {
        this.levelType = v;
    }

    public int getLevel() {
        return this.level;
    }

    public void setLevel(int v) {
        this.level = v;
    }

    public int getMinlevellimit() {
        return this.minlevellimit;
    }

    public void setMinlevellimit(int v) {
        this.minlevellimit = v;
    }

    public int getMaxlevellimit() {
        return this.maxlevellimit;
    }

    public void setMaxlevellimit(int v) {
        this.maxlevellimit = v;
    }

    public int getCanCatch() {
        return this.canCatch;
    }

    public void setCanCatch(int v) {
        this.canCatch = v;
    }

    public int getCatchRate() {
        return this.catchRate;
    }

    public void setCatchRate(int v) {
        this.catchRate = v;
    }

    public int getRunRate() {
        return this.runRate;
    }

    public void setRunRate(int v) {
        this.runRate = v;
    }

    public String getAiIds() {
        return this.aiIds;
    }

    public void setAiIds(String v) {
        this.aiIds = v;
    }

    public String getImmunebuffid() {
        return this.immunebuffid;
    }

    public void setImmunebuffid(String v) {
        this.immunebuffid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

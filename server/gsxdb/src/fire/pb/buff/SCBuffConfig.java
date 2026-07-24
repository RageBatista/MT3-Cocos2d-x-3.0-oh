//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.buff;

import java.util.Map;
import mytools.ConvMain;

public class SCBuffConfig implements ConvMain.Checkable, Comparable<SCBuffConfig> {
    public int id = 0;
    public String name = null;
    public String classname = null;
    public String limitOperations = null;
    public long initTime = 0L;
    public int initCount = 0;
    public long initAmount = 0L;
    public int clearType = 0;
    public boolean storeToDisk = false;
    public long time = 0L;
    public int buffclass = 0;
    public String Anticlass = null;
    public int sendtoclient = 0;
    public int showScale = 0;
    public boolean inBattleScript = false;
    public String effects = null;
    public int overrideSelfType = 0;
    public String overrideAttr = null;
    public int instantbuff = 0;
    public String instantbuffeffect = null;
    public String scenestateId = null;

    public int compareTo(SCBuffConfig o) {
        return this.id - o.id;
    }

    public SCBuffConfig() {
    }

    public SCBuffConfig(SCBuffConfig arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.classname = arg.classname;
        this.limitOperations = arg.limitOperations;
        this.initTime = arg.initTime;
        this.initCount = arg.initCount;
        this.initAmount = arg.initAmount;
        this.clearType = arg.clearType;
        this.storeToDisk = arg.storeToDisk;
        this.time = arg.time;
        this.buffclass = arg.buffclass;
        this.Anticlass = arg.Anticlass;
        this.sendtoclient = arg.sendtoclient;
        this.showScale = arg.showScale;
        this.inBattleScript = arg.inBattleScript;
        this.effects = arg.effects;
        this.overrideSelfType = arg.overrideSelfType;
        this.overrideAttr = arg.overrideAttr;
        this.instantbuff = arg.instantbuff;
        this.instantbuffeffect = arg.instantbuffeffect;
        this.scenestateId = arg.scenestateId;
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

    public String getClassname() {
        return this.classname;
    }

    public void setClassname(String v) {
        this.classname = v;
    }

    public String getLimitOperations() {
        return this.limitOperations;
    }

    public void setLimitOperations(String v) {
        this.limitOperations = v;
    }

    public long getInitTime() {
        return this.initTime;
    }

    public void setInitTime(long v) {
        this.initTime = v;
    }

    public int getInitCount() {
        return this.initCount;
    }

    public void setInitCount(int v) {
        this.initCount = v;
    }

    public long getInitAmount() {
        return this.initAmount;
    }

    public void setInitAmount(long v) {
        this.initAmount = v;
    }

    public int getClearType() {
        return this.clearType;
    }

    public void setClearType(int v) {
        this.clearType = v;
    }

    public boolean getStoreToDisk() {
        return this.storeToDisk;
    }

    public void setStoreToDisk(boolean v) {
        this.storeToDisk = v;
    }

    public long getTime() {
        return this.time;
    }

    public void setTime(long v) {
        this.time = v;
    }

    public int getBuffclass() {
        return this.buffclass;
    }

    public void setBuffclass(int v) {
        this.buffclass = v;
    }

    public String getAnticlass() {
        return this.Anticlass;
    }

    public void setAnticlass(String v) {
        this.Anticlass = v;
    }

    public int getSendtoclient() {
        return this.sendtoclient;
    }

    public void setSendtoclient(int v) {
        this.sendtoclient = v;
    }

    public int getShowScale() {
        return this.showScale;
    }

    public void setShowScale(int v) {
        this.showScale = v;
    }

    public boolean getInBattleScript() {
        return this.inBattleScript;
    }

    public void setInBattleScript(boolean v) {
        this.inBattleScript = v;
    }

    public String getEffects() {
        return this.effects;
    }

    public void setEffects(String v) {
        this.effects = v;
    }

    public int getOverrideSelfType() {
        return this.overrideSelfType;
    }

    public void setOverrideSelfType(int v) {
        this.overrideSelfType = v;
    }

    public String getOverrideAttr() {
        return this.overrideAttr;
    }

    public void setOverrideAttr(String v) {
        this.overrideAttr = v;
    }

    public int getInstantbuff() {
        return this.instantbuff;
    }

    public void setInstantbuff(int v) {
        this.instantbuff = v;
    }

    public String getInstantbuffeffect() {
        return this.instantbuffeffect;
    }

    public void setInstantbuffeffect(String v) {
        this.instantbuffeffect = v;
    }

    public String getScenestateId() {
        return this.scenestateId;
    }

    public void setScenestateId(String v) {
        this.scenestateId = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

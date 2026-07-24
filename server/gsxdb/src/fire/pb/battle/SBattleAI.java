//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import java.util.Map;
import mytools.ConvMain;

public class SBattleAI implements ConvMain.Checkable, Comparable<SBattleAI> {
    public int id = 0;
    public int trigger = 0;
    public String conditions = null;
    public String actionId = null;
    public String count = null;
    public String enableAI = null;
    public String extraAI = null;

    public int compareTo(SBattleAI o) {
        return this.id - o.id;
    }

    public SBattleAI() {
    }

    public SBattleAI(SBattleAI arg) {
        this.id = arg.id;
        this.trigger = arg.trigger;
        this.conditions = arg.conditions;
        this.actionId = arg.actionId;
        this.count = arg.count;
        this.enableAI = arg.enableAI;
        this.extraAI = arg.extraAI;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getTrigger() {
        return this.trigger;
    }

    public void setTrigger(int v) {
        this.trigger = v;
    }

    public String getConditions() {
        return this.conditions;
    }

    public void setConditions(String v) {
        this.conditions = v;
    }

    public String getActionId() {
        return this.actionId;
    }

    public void setActionId(String v) {
        this.actionId = v;
    }

    public String getCount() {
        return this.count;
    }

    public void setCount(String v) {
        this.count = v;
    }

    public String getEnableAI() {
        return this.enableAI;
    }

    public void setEnableAI(String v) {
        this.enableAI = v;
    }

    public String getExtraAI() {
        return this.extraAI;
    }

    public void setExtraAI(String v) {
        this.extraAI = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

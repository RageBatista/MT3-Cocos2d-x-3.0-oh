//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import java.util.Map;
import mytools.ConvMain;

public class SRoleFighteAI implements ConvMain.Checkable, Comparable<SRoleFighteAI> {
    public int id = 0;
    public int schoolid = 0;
    public int aiid = 0;
    public int effectpoint = 0;
    public int defaulthave = 0;

    public int compareTo(SRoleFighteAI o) {
        return this.id - o.id;
    }

    public SRoleFighteAI() {
    }

    public SRoleFighteAI(SRoleFighteAI arg) {
        this.id = arg.id;
        this.schoolid = arg.schoolid;
        this.aiid = arg.aiid;
        this.effectpoint = arg.effectpoint;
        this.defaulthave = arg.defaulthave;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getSchoolid() {
        return this.schoolid;
    }

    public void setSchoolid(int v) {
        this.schoolid = v;
    }

    public int getAiid() {
        return this.aiid;
    }

    public void setAiid(int v) {
        this.aiid = v;
    }

    public int getEffectpoint() {
        return this.effectpoint;
    }

    public void setEffectpoint(int v) {
        this.effectpoint = v;
    }

    public int getDefaulthave() {
        return this.defaulthave;
    }

    public void setDefaulthave(int v) {
        this.defaulthave = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

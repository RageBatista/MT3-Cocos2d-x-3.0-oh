//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.Map;
import mytools.ConvMain;

public class SMonsterSkill implements ConvMain.Checkable {
    public int skillid = 0;
    public int showrate = 0;
    public int castrate = 0;
    public double levelfactor = (double)0.0F;
    public double levelconstant = (double)0.0F;

    public SMonsterSkill() {
    }

    public SMonsterSkill(SMonsterSkill arg) {
        this.skillid = arg.skillid;
        this.showrate = arg.showrate;
        this.castrate = arg.castrate;
        this.levelfactor = arg.levelfactor;
        this.levelconstant = arg.levelconstant;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getSkillid() {
        return this.skillid;
    }

    public void setSkillid(int v) {
        this.skillid = v;
    }

    public int getShowrate() {
        return this.showrate;
    }

    public void setShowrate(int v) {
        this.showrate = v;
    }

    public int getCastrate() {
        return this.castrate;
    }

    public void setCastrate(int v) {
        this.castrate = v;
    }

    public double getLevelfactor() {
        return this.levelfactor;
    }

    public void setLevelfactor(double v) {
        this.levelfactor = v;
    }

    public double getLevelconstant() {
        return this.levelconstant;
    }

    public void setLevelconstant(double v) {
        this.levelconstant = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

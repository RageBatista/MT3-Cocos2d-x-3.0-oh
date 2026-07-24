//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SInbornEffectSkill implements ConvMain.Checkable, Comparable<SInbornEffectSkill> {
    public int id = 0;
    public int initEffect = 0;
    public ArrayList<InbornEffect> inborns;

    public int compareTo(SInbornEffectSkill o) {
        return this.id - o.id;
    }

    public SInbornEffectSkill() {
    }

    public SInbornEffectSkill(SInbornEffectSkill arg) {
        this.id = arg.id;
        this.initEffect = arg.initEffect;
        this.inborns = arg.inborns;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getInitEffect() {
        return this.initEffect;
    }

    public void setInitEffect(int v) {
        this.initEffect = v;
    }

    public ArrayList<InbornEffect> getInborns() {
        return this.inborns;
    }

    public void setInborns(ArrayList<InbornEffect> v) {
        this.inborns = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

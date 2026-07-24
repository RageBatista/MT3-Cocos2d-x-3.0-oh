//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.battle;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SEffectPostions implements ConvMain.Checkable, Comparable<SEffectPostions> {
    public int id = 0;
    public ArrayList<Integer> diffuseposs;
    public ArrayList<Integer> effectposs;

    public int compareTo(SEffectPostions o) {
        return this.id - o.id;
    }

    public SEffectPostions() {
    }

    public SEffectPostions(SEffectPostions arg) {
        this.id = arg.id;
        this.diffuseposs = arg.diffuseposs;
        this.effectposs = arg.effectposs;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<Integer> getDiffuseposs() {
        return this.diffuseposs;
    }

    public void setDiffuseposs(ArrayList<Integer> v) {
        this.diffuseposs = v;
    }

    public ArrayList<Integer> getEffectposs() {
        return this.effectposs;
    }

    public void setEffectposs(ArrayList<Integer> v) {
        this.effectposs = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SItemBuff implements ConvMain.Checkable, Comparable<SItemBuff> {
    public int id = 0;
    public ArrayList<Integer> monsterids;
    public int inskill_id = 0;
    public int outskill_id = 0;

    public int compareTo(SItemBuff o) {
        return this.id - o.id;
    }

    public SItemBuff() {
    }

    public SItemBuff(SItemBuff arg) {
        this.id = arg.id;
        this.monsterids = arg.monsterids;
        this.inskill_id = arg.inskill_id;
        this.outskill_id = arg.outskill_id;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<Integer> getMonsterids() {
        return this.monsterids;
    }

    public void setMonsterids(ArrayList<Integer> v) {
        this.monsterids = v;
    }

    public int getInskill_id() {
        return this.inskill_id;
    }

    public void setInskill_id(int v) {
        this.inskill_id = v;
    }

    public int getOutskill_id() {
        return this.outskill_id;
    }

    public void setOutskill_id(int v) {
        this.outskill_id = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

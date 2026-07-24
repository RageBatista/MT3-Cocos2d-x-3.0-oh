//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SServiceConds implements ConvMain.Checkable, Comparable<SServiceConds> {
    public int id = 0;
    public ArrayList<SNpcCond> conditionids;
    public ArrayList<Integer> childservice;

    public int compareTo(SServiceConds o) {
        return this.id - o.id;
    }

    public SServiceConds() {
    }

    public SServiceConds(SServiceConds arg) {
        this.id = arg.id;
        this.conditionids = arg.conditionids;
        this.childservice = arg.childservice;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<SNpcCond> getConditionids() {
        return this.conditionids;
    }

    public void setConditionids(ArrayList<SNpcCond> v) {
        this.conditionids = v;
    }

    public ArrayList<Integer> getChildservice() {
        return this.childservice;
    }

    public void setChildservice(ArrayList<Integer> v) {
        this.childservice = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

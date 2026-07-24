//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.mission;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SSpecialScenarioQuestConfig implements ConvMain.Checkable, Comparable<SSpecialScenarioQuestConfig> {
    public int id = 0;
    public ArrayList<Integer> params;
    public int 类型ID = 0;
    public ArrayList<Integer> activeparams;
    public int 类型ID2 = 0;
    public int emsg = 0;

    public int compareTo(SSpecialScenarioQuestConfig o) {
        return this.id - o.id;
    }

    public SSpecialScenarioQuestConfig() {
    }

    public SSpecialScenarioQuestConfig(SSpecialScenarioQuestConfig arg) {
        this.id = arg.id;
        this.params = arg.params;
        this.类型ID = arg.类型ID;
        this.activeparams = arg.activeparams;
        this.类型ID2 = arg.类型ID2;
        this.emsg = arg.emsg;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public ArrayList<Integer> getParams() {
        return this.params;
    }

    public void setParams(ArrayList<Integer> v) {
        this.params = v;
    }

    public int get类型ID() {
        return this.类型ID;
    }

    public void set类型ID(int v) {
        this.类型ID = v;
    }

    public ArrayList<Integer> getActiveparams() {
        return this.activeparams;
    }

    public void setActiveparams(ArrayList<Integer> v) {
        this.activeparams = v;
    }

    public int get类型ID2() {
        return this.类型ID2;
    }

    public void set类型ID2(int v) {
        this.类型ID2 = v;
    }

    public int getEmsg() {
        return this.emsg;
    }

    public void setEmsg(int v) {
        this.emsg = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

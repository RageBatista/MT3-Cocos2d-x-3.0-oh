//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import java.util.ArrayList;
import java.util.Map;
import mytools.ConvMain;

public class SPVP5MapConfig implements ConvMain.Checkable, Comparable<SPVP5MapConfig> {
    public int id = 0;
    public int level1 = 0;
    public int level2 = 0;
    public ArrayList<Integer> generalMap;
    public ArrayList<Integer> excellentMap;

    public int compareTo(SPVP5MapConfig o) {
        return this.id - o.id;
    }

    public SPVP5MapConfig() {
    }

    public SPVP5MapConfig(SPVP5MapConfig arg) {
        this.id = arg.id;
        this.level1 = arg.level1;
        this.level2 = arg.level2;
        this.generalMap = arg.generalMap;
        this.excellentMap = arg.excellentMap;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getLevel1() {
        return this.level1;
    }

    public void setLevel1(int v) {
        this.level1 = v;
    }

    public int getLevel2() {
        return this.level2;
    }

    public void setLevel2(int v) {
        this.level2 = v;
    }

    public ArrayList<Integer> getGeneralMap() {
        return this.generalMap;
    }

    public void setGeneralMap(ArrayList<Integer> v) {
        this.generalMap = v;
    }

    public ArrayList<Integer> getExcellentMap() {
        return this.excellentMap;
    }

    public void setExcellentMap(ArrayList<Integer> v) {
        this.excellentMap = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.circletask;

import java.util.Map;
import mytools.ConvMain;

public class SPVP1MapConfig implements ConvMain.Checkable, Comparable<SPVP1MapConfig> {
    public int id = 0;
    public int lev1 = 0;
    public int lev2 = 0;
    public int map = 0;

    public int compareTo(SPVP1MapConfig o) {
        return this.id - o.id;
    }

    public SPVP1MapConfig() {
    }

    public SPVP1MapConfig(SPVP1MapConfig arg) {
        this.id = arg.id;
        this.lev1 = arg.lev1;
        this.lev2 = arg.lev2;
        this.map = arg.map;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getLev1() {
        return this.lev1;
    }

    public void setLev1(int v) {
        this.lev1 = v;
    }

    public int getLev2() {
        return this.lev2;
    }

    public void setLev2(int v) {
        this.lev2 = v;
    }

    public int getMap() {
        return this.map;
    }

    public void setMap(int v) {
        this.map = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

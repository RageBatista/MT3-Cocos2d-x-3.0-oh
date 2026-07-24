//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class STransformationConfig implements ConvMain.Checkable, Comparable<STransformationConfig> {
    public int id = 0;
    public String name = null;
    public int time = 0;
    public int effectid = 0;

    public int compareTo(STransformationConfig o) {
        return this.id - o.id;
    }

    public STransformationConfig() {
    }

    public STransformationConfig(STransformationConfig arg) {
        this.id = arg.id;
        this.name = arg.name;
        this.time = arg.time;
        this.effectid = arg.effectid;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public int getTime() {
        return this.time;
    }

    public void setTime(int v) {
        this.time = v;
    }

    public int getEffectid() {
        return this.effectid;
    }

    public void setEffectid(int v) {
        this.effectid = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.item;

import java.util.Map;
import mytools.ConvMain;

public class SPetSkillSuccessConfig implements ConvMain.Checkable, Comparable<SPetSkillSuccessConfig> {
    public int id = 0;
    public int odds = 0;
    public int basenumber = 0;

    public int compareTo(SPetSkillSuccessConfig o) {
        return this.id - o.id;
    }

    public SPetSkillSuccessConfig() {
    }

    public SPetSkillSuccessConfig(SPetSkillSuccessConfig arg) {
        this.id = arg.id;
        this.odds = arg.odds;
        this.basenumber = arg.basenumber;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getOdds() {
        return this.odds;
    }

    public void setOdds(int v) {
        this.odds = v;
    }

    public int getBasenumber() {
        return this.basenumber;
    }

    public void setBasenumber(int v) {
        this.basenumber = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

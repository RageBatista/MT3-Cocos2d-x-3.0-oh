//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.pet;

import java.util.Map;
import mytools.ConvMain;

public class SkillRate implements ConvMain.Checkable {
    public int skillid = 0;
    public int rate = 0;

    public SkillRate() {
    }

    public SkillRate(SkillRate arg) {
        this.skillid = arg.skillid;
        this.rate = arg.rate;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getSkillid() {
        return this.skillid;
    }

    public void setSkillid(int v) {
        this.skillid = v;
    }

    public int getRate() {
        return this.rate;
    }

    public void setRate(int v) {
        this.rate = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

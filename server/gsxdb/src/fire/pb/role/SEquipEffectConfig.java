//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.role;

import java.util.Map;
import mytools.ConvMain;

public class SEquipEffectConfig implements ConvMain.Checkable, Comparable<SEquipEffectConfig> {
    public int id = 0;
    public int equipNum = 0;
    public int quality = 0;

    public int compareTo(SEquipEffectConfig o) {
        return this.id - o.id;
    }

    public SEquipEffectConfig() {
    }

    public SEquipEffectConfig(SEquipEffectConfig arg) {
        this.id = arg.id;
        this.equipNum = arg.equipNum;
        this.quality = arg.quality;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getEquipNum() {
        return this.equipNum;
    }

    public void setEquipNum(int v) {
        this.equipNum = v;
    }

    public int getQuality() {
        return this.quality;
    }

    public void setQuality(int v) {
        this.quality = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

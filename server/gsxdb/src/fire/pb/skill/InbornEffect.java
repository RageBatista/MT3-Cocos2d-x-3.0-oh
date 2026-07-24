//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.Map;
import mytools.ConvMain;

public class InbornEffect implements ConvMain.Checkable {
    public int inbornId = 0;
    public double effect = (double)0.0F;

    public InbornEffect() {
    }

    public InbornEffect(InbornEffect arg) {
        this.inbornId = arg.inbornId;
        this.effect = arg.effect;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getInbornId() {
        return this.inbornId;
    }

    public void setInbornId(int v) {
        this.inbornId = v;
    }

    public double getEffect() {
        return this.effect;
    }

    public void setEffect(double v) {
        this.effect = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

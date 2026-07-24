//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.game;

import java.util.Map;
import mytools.ConvMain;

public class BindTelAwardData implements ConvMain.Checkable {
    public String item1id = null;
    public int item1num = 0;

    public BindTelAwardData() {
    }

    public BindTelAwardData(BindTelAwardData arg) {
        this.item1id = arg.item1id;
        this.item1num = arg.item1num;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public String getItem1id() {
        return this.item1id;
    }

    public void setItem1id(String v) {
        this.item1id = v;
    }

    public int getItem1num() {
        return this.item1num;
    }

    public void setItem1num(int v) {
        this.item1num = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

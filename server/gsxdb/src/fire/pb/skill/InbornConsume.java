//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.skill;

import java.util.Map;
import mytools.ConvMain;

public class InbornConsume implements ConvMain.Checkable {
    public int exp = 0;
    public int money = 0;

    public InbornConsume() {
    }

    public InbornConsume(InbornConsume arg) {
        this.exp = arg.exp;
        this.money = arg.money;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getExp() {
        return this.exp;
    }

    public void setExp(int v) {
        this.exp = v;
    }

    public int getMoney() {
        return this.money;
    }

    public void setMoney(int v) {
        this.money = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

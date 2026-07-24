//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

import java.util.Map;
import mytools.ConvMain;

public class SNpcCond implements ConvMain.Checkable {
    public int condid = 0;
    public int args1 = 0;
    public int args2 = 0;

    public SNpcCond() {
    }

    public SNpcCond(SNpcCond arg) {
        this.condid = arg.condid;
        this.args1 = arg.args1;
        this.args2 = arg.args2;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getCondid() {
        return this.condid;
    }

    public void setCondid(int v) {
        this.condid = v;
    }

    public int getArgs1() {
        return this.args1;
    }

    public void setArgs1(int v) {
        this.args1 = v;
    }

    public int getArgs2() {
        return this.args2;
    }

    public void setArgs2(int v) {
        this.args2 = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

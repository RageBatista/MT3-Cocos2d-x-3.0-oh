//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.qiannengguo;

import java.util.Map;
import mytools.ConvMain;

public class SQiannengguoLevelUp implements ConvMain.Checkable, Comparable<SQiannengguoLevelUp> {
    public int id = 0;
    public int levelupvalue = 0;
    public int returnvalue = 0;
    public int openlevel = 0;
    public int resetmoney = 0;

    public int compareTo(SQiannengguoLevelUp o) {
        return this.id - o.id;
    }

    public SQiannengguoLevelUp() {
    }

    public SQiannengguoLevelUp(SQiannengguoLevelUp arg) {
        this.id = arg.id;
        this.levelupvalue = arg.levelupvalue;
        this.returnvalue = arg.returnvalue;
        this.openlevel = arg.openlevel;
        this.resetmoney = arg.resetmoney;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getLevelupvalue() {
        return this.levelupvalue;
    }

    public void setLevelupvalue(int v) {
        this.levelupvalue = v;
    }

    public int getReturnvalue() {
        return this.returnvalue;
    }

    public void setReturnvalue(int v) {
        this.returnvalue = v;
    }

    public int getOpenlevel() {
        return this.openlevel;
    }

    public void setOpenlevel(int v) {
        this.openlevel = v;
    }

    public int getResetmoney() {
        return this.resetmoney;
    }

    public void setResetmoney(int resetmoney) {
        this.resetmoney = resetmoney;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}

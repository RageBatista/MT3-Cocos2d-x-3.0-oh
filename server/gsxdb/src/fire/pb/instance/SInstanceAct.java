//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.instance;

import java.util.Map;
import mytools.ConvMain;

public class SInstanceAct implements ConvMain.Checkable, Comparable<SInstanceAct> {
    public int id = 0;
    public int type = 0;
    public String parameters = null;
    public int belongfuben = 0;

    public int compareTo(SInstanceAct o) {
        return this.id - o.id;
    }

    public SInstanceAct() {
    }

    public SInstanceAct(SInstanceAct arg) {
        this.id = arg.id;
        this.type = arg.type;
        this.parameters = arg.parameters;
        this.belongfuben = arg.belongfuben;
    }

    public void checkValid(Map<String, Map<Integer, ? extends Object>> objs) {
    }

    public int getId() {
        return this.id;
    }

    public void setId(int v) {
        this.id = v;
    }

    public int getType() {
        return this.type;
    }

    public void setType(int v) {
        this.type = v;
    }

    public String getParameters() {
        return this.parameters;
    }

    public void setParameters(String v) {
        this.parameters = v;
    }

    public int getBelongfuben() {
        return this.belongfuben;
    }

    public void setBelongfuben(int v) {
        this.belongfuben = v;
    }

    static class NeedId extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
